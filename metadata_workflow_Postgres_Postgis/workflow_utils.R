username <- NULL
token <- NULL

#-----------------------------------------------------------------------------------------------------------------
#initWorkflow
#Reads the workflow configuration file
#@param file
#returns an object of class "list"
#-----------------------------------------------------------------------------------------------------------------
initWorkflow <- function(file){
  
  config <- jsonlite::read_json(file)
  config$src <- file
  
  #worfklow config$loggers
  config$logger <- function(type, text){cat(sprintf("[%s][%s] %s \n", config$id, type, text))}
  config$logger.info <- function(text){config$logger("INFO", text)}
  config$logger.warn <- function(text){config$logger("WARNING", text)}
  config$logger.error <- function(text){config$logger("ERROR", text)}
  
  config$logger.info("Init Workflow configuration")
  config$logger.info("========================================================================")
  
  #working dir
  config$wd <- getwd()
  
  #load packages
  #-------------
  #from CRAN
  config$logger.info("Loading R CRAN packages...")
  cran_pkgs = c("devtools", config$dependencies$packages$cran)
  invisible(sapply(cran_pkgs, function(pkg){
    if(config$dependencies$packages$cran_force_install){
      config$logger.info(sprintf("Reinstalling R CRAN package '%s'", pkg))
      eval(parse(text = sprintf("try(detach(\"package:%s\", unload=TRUE, force = TRUE))", pkg)))
      install.packages(pkg)
    }
    config$logger.info(sprintf("Loading R CRAN package '%s'", pkg))
    eval(parse(text = sprintf("require(%s)", pkg)))
  }))
  #from Github
  config$logger.info("Loading R GitHub packages...")
  github_pkgs = config$dependencies$packages$github
  invisible(sapply(github_pkgs, function(pkg){
    pkgname <- unlist(strsplit(pkg, "/"))[2]
    if(config$dependencies$packages$github_force_install){
      config$logger.info(sprintf("Reinstalling R GitHub package '%s'", pkgname))
      eval(parse(text = sprintf("try(detach(\"package:%s\", unload=TRUE, force = TRUE))", pkgname)))
      devtools::install_github(pkg, force = TRUE)
    }
    config$logger.info(sprintf("Loading R GitHub package '%s'", pkgname))
    eval(parse(text = sprintf("require(%s)", pkgname)))
  }))
  #load source scripts
  #--------------------
  config$logger.info("Loading R scripts...")
  source_scripts <- config$dependencies$scripts
  invisible(sapply(source_scripts,function(script){
    config$logger.info(sprintf("Loading R script '%s'...", script))
    source(script)
  }))
  
  #TODO gcube userprofile
  #--------------------
  config$logger.info("Fetching gcube user profile...")
  userProfileReq <- sprintf("https://socialnetworking1.d4science.org/social-networking-library-ws/rest/2/people/profile?gcube-token=%s",config$gcube$token)
  req <- GET(userProfileReq)
  if(status_code(req)==200){
    reqContent <- content(req)
    config$gcube$username <- reqContent$result$username
    config$gcube$workspace <- paste("/Home", config$gcube$username,"Workspace/", sep = "/")
    #to deal with bad R practice of workspace R library
    username <<- config$gcube$username
    token <<- config$gcube$token
    
    #gcube repositories
    repo <- lapply(config$gcube$repositories, function(x){paste0(config$gcube$workspace, x)})
    names(repo) <- names(config$gcube$repositories)
    config$gcube$repositories <- repo
  }else{
    config$logger.error("Error while fetching gcube user profile. Check the token!")
  }
  
  #load Scripts (if config$gcube$scripts_download = TRUE, download them before)
  #-------------------------------
  config$logger.info("Loading R scripts...")
  mainDir <- config$wd
  subDir <- "scripts"
  if (!file.exists(subDir)){
    dir.create(file.path(mainDir, subDir))
  }
  setwd(file.path(mainDir, subDir))
  for(script in config$gcube$scripts){
    if(config$gcube$scripts_download){
      config$logger.info(sprintf("Downloading script '%s' from workspace", script))
      downloadFileWS(paste(config$gcube$repositories$scripts, script, sep = "/"))
    }
    
    config$logger.info(sprintf("Loading script '%s' in R", script))
    source(script)
  }
  setwd(config$wd)
  
  #load google sheets from Urls
  #-------------------------------
  config$logger.info("Loading Google sheets...")
  config$gsheets = lapply(names(config$gsheetUrls), function(gsheetName){
    gsheetUrl <- config$gsheetUrls[[gsheetName]]
    config$logger.info(sprintf("Loading Google sheet '%s' (%s)...", gsheetUrl, gsheetName))
    out <- as.data.frame(gsheet::gsheet2tbl(gsheetUrl))
    return(out)
  })
  names(config$gsheets) <- names(config$gsheetUrls)
  
  #connect to database
  #--------------------
  db <- config$db
  config$logger.info(sprintf("Connect to database '%s'...", db$name))
  config$db[["con"]] <- con <- dbConnect(db$drv, dbname=db$name, user=db$user, password=db$pwd, host=db$host)
  
  #Geoserver API manager
  #--------------------
  config$logger.info("Connect to GeoServer API...")
  gs <- config$sdi$geoserver
  config$sdi$geoserver[["api"]] <- GSManager$new(url = gs$url, user = gs$user, pwd = gs$pwd,
                                                         config$sdi$loggerLevel)
  
  #Geonetwork API manager
  #--------------------
  config$logger.info("Connect to GeoNetwork API...")
  gn <- config$sdi$geonetwork
  config$sdi$geonetwork[["api"]] <- GNManager$new(url = gn$url, user = gn$user, pwd = gn$pwd, version = gn$version,
                                                          config$sdi$loggerLevel)
  return(config)
}

#-----------------------------------------------------------------------------------------------------------------
#closeWorkflow
#@param config
#-----------------------------------------------------------------------------------------------------------------
closeWorkflow <- function(config){
  #close DB
  config$logger.info("Closing database connection")
  dbDisconnect(config$db$con)
  #Geoserver API manager
  config$logger.info("Reset Geoserver API manager")
  config$sdi$geoserver$api <- NULL
  #Geonetwork API manager
  config$logger.info("Reset Geonetwork API manager")
  config$sdi$geonetwork$api <- NULL
  setwd(config$wd)
}

#-----------------------------------------------------------------------------------------------------------------
#initWorkflowJob
#@param config
#-----------------------------------------------------------------------------------------------------------------
initWorkflowJob <- function(config){
  config$logger.info("Init Workflow job directory")
  config$logger.info("========================================================================")
  config_file <- config$src
  mainDir <- config$wd
  subDir <- "jobs"
  if (!file.exists(subDir)){
    dir.create(file.path(mainDir, subDir))
  }
  setwd(file.path(mainDir, subDir))
  jobDir <- format(Sys.time(),paste0("%Y%m%d-%H%M%S-", config$gcube$username))
  config$logger.info(sprintf("Initialize workflow job '%s'", jobDir))
  
  #create directories
  if (file.exists(subDir)){
    setwd(file.path(mainDir, subDir, jobDir))
  } else {
    dir.create(file.path(mainDir, subDir, jobDir))
    setwd(file.path(mainDir, subDir, jobDir))
  }
  
  #copy configuration file
  file.copy(from = file.path(mainDir, config_file), to = getwd())
  #rename copied file
  file.rename(from = config_file, to = "job.json")
  
  #create sub directories as listed in the configuration file
  directories <- c("data", "metadata", "logs")
  for(directory in directories){
    if (!file.exists(directory)){
      dir.create(file.path(getwd(), directory))
    }
  }
  dir.create(file.path(getwd(), "data", "csv"))
  dir.create(file.path(getwd(), "data", "netcdf"))
  
}

#-----------------------------------------------------------------------------------------------------------------
#executeWorkflowJob
#@param config
#-----------------------------------------------------------------------------------------------------------------
executeWorkflowJob <- function(config){
  
  capture.output({
    config$logger.info(sprintf("Executing workflow job with main R function '%s'...", config$actions$main))
    eval(parse(text = sprintf("%s(config)", config$actions$main)))
  },file = file.path(getwd(), "logs", "job.log"))
}
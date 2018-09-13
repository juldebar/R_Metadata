# https://cran.r-project.org/web/packages/dataverse/vignettes/A-introduction.html
# https://cran.r-project.org/web/packages/dataverse/vignettes/D-archiving.html#sword-based_data_archiving

write_dataverse_metadata_from_Dublin_Core <- function(config = NULL,
                                                metadata = NULL,
                                                contacts_metadata = NULL,
                                                spatial_metadata = NULL,
                                                temporal_metadata = NULL,
                                                keywords_metadata = NULL, # DATAFRAME WITH ALL (STATIC & DYNAMIC)  KEYWORDS
                                                urls_metadata= NULL # LIST OF DYNAMIC / COMMON URLs
)
{
  library("dataverse")
  
  #config shortcuts
  con <- config$sdi$dataverse
  dataverse_server=con$url
  dataverse_key=con$pwd
  dataverse_name=con$dataverse_name
  dataverse_user_name=con$user
  Sys.setenv("DATAVERSE_SERVER" = dataverse_server)
  Sys.setenv("DATAVERSE_KEY" = dataverse_key)
  
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  logger.info("----------------------------------------------------")  
  logger.info("DATAVERSE : MAIN METADATA ELEMENTS")  
  logger.info("----------------------------------------------------")  
  
    #################################### LOAD METADATA FROM SPREADSHEET / DATA FRAME #############################################
    # metadata$Permanent_Identifier <- metadata$Identifier
    #################################### MAP DATAVERSE AND DCMI METADATA ELEMENTS #############################################
    # CHECK METADATA FOR PROPER MAPPING : https://www.rdocumentation.org/packages/dataverse/versions/0.2.0/topics/initiate_sword_dataset
  Dataverse_metadata <- NULL
  Dataverse_metadata <- list(identifier=metadata$Identifier,
                               title = metadata$Title,
                               # creator = dataverse_user_name,
                               description = metadata$Description,
                               date=metadata$Date,
                               type = metadata$Type,
                               # language = metadata$Language,
                               # relation = metadata$Relation,
                               extent = paste(metadata$Relation,metadata$Temporal_Coverage,sep=" & "),
                               spatial = metadata$Spatial_Coverage,
                               temporal = metadata$Temporal_Coverage,
                               provenance = metadata$Lineage, 
                               rights = metadata$Rights
    )
    
    # keywords <-return_keywords_and_thesaurus_as_data_frame(metadata$Subject)
    for (k in keywords_metadata$keyword) {
      if(substring(k, 1, 1)== " "){k=substring(k, 2, nchar(k))}
      Dataverse_metadata <- c(Dataverse_metadata,subject = k)
    }
    # urls <-return_urls_as_data_frame(metadata$Relation)
    for (u in urls_metadata$http_URLs_links) {
      Dataverse_metadata <- c(Dataverse_metadata,relation = u)
    }
    # contacts <-return_contacts_as_data_frame(metadata$Creator)
    for (c in contacts_metadata$contacts_roles$contact) {
      Dataverse_metadata <- c(Dataverse_metadata,creator = c)
    }
    
    #################################### ADD THIS DATASET IN THE DATAVERSE #############################################
    add_dataset_with_sword <- dataverse::initiate_sword_dataset(dataverse_name, body = Dataverse_metadata)
  
  #@julien => should return the DOI of the created / updated metadata & dataset (check update_dataset(ds, body = meta2) ?)
}


#################################### DELETE ALL DATASETS FROM A GIVEN DATAVERSE #############################################
# EXAMPLE IN THE 3 LINES BELOW => REMOVE ALL DATASETS FROM A DATAVERSE
# my_dataverse <- get_dataverse(dataverse_name)
# remove_all_datasets_from_a_dataverse(my_dataverse)
# remove_all_datasets_from_a_dataverse("julien_dataverse")

remove_all_datasets_from_a_dataverse <- function(config,dataverse){
  
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  logger.info("----------------------------------------------------")  
  logger.info("REMOVE ALL DATA IN THIS DATAVERSE")  
  logger.info("----------------------------------------------------")  
  
  dataverse_data <- dataverse_contents(dataverse)
  number_row<-length(dataverse_data)
  if(number_row>0){
    for (i in 1:number_row) {
      cat("\n")  
      cat(i)
      cat("\n")  
      this_dataset <- get_dataset(dataverse_data[[i]])
      cat(this_dataset$id)
      delete_dataset(dataverse_data[[i]])
    }
  } else{
    logger.info("The dataverse is already empty !")
    }
}

#################################### COMMON FUNCTIONS FOR SPREADSHEETS (CSV, GOOGLE DOC...) #############################################
# contacts<-Dublin_Core_metadata$Creator[1]
# test_contacts<-return_contacts_as_data_frame(contacts)
# test_contacts
# test_relations$http_URLs_links
# all_relations <- the_relations

return_contacts_as_data_frame <- function(all_contacts){
  contacts_metadata <-NULL
  contact_email=NULL
  contact_role=NULL
  contacts_roles=NULL
  list_contacts <- strsplit(all_contacts, split = ";")
  for(contact in list_contacts[[1]]){
    split_contact <- strsplit(contact, split = "=")
    split_contact
    contact_email <- c(contact_email, split_contact[[1]][2])
    split_contact[[1]][2]
    contact_role <- c(contact_role,split_contact[[1]][1]) # to be done Ã  changer  
    split_contact[[1]][1]  
  }
  # contacts_roles_data_frame <- data.frame(contact=contact_email, RoleCode=contact_role, dataset=metadata$Identifier,stringsAsFactors=FALSE) #dataset=metadata$Identifier => A VIRER 
  contacts_roles_data_frame <- data.frame(contact=contact_email, RoleCode=contact_role,stringsAsFactors=FALSE)
  return(contacts_roles_data_frame)
}

#################################### PROCESS RELATIONS #############################################

# the_relations<-Dublin_Core_metadata$Relation[1]
# test_relations<-return_urls_as_data_frame(the_relations)
# test_relations
# test_relations$http_URLs_links
# all_relations <- the_relations

return_urls_as_data_frame <- function(all_relations){
  urls_metadata <- NULL
  http_urls <- NULL
  http_URLs_links=NULL
  http_URLs_names=NULL
  http_URLs_descriptions=NULL
  http_URLs_protocols=NULL
  http_URLs_functions=NULL
  http_urls <-data.frame(http_URLs_links = character(), http_URLs_names = character(),http_URLs_descriptions = character(),http_URLs_protocols = character(), http_URLs_functions = character(),stringsAsFactors=FALSE)
  
  #Add as many links as stored in the google doc "Relation" column
  list_Relation <- strsplit(as.character(all_relations), split = "\n")
  for(relation in list_Relation[[1]]){
    split_Relation <- strsplit(relation, split = "@")
    http_URLs_links <- split_Relation[[1]][2]
    http_URLs_names <- split_Relation[[1]][1]
    if(http_URLs_names=="thumbnail"){
      http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, "thumbnail","Aperçu", "WWW:LINK-1.0-http--link","image/png")
    } else{
      if(grepl("\\[",http_URLs_names)==TRUE){
        split_http_URLs_names <- strsplit(http_URLs_names, split = "\\[")
        http_URLs_names <- split_http_URLs_names[[1]][1]
        http_URLs_descriptions <- gsub("\\]","",split_http_URLs_names[[1]][2] )
      }else{
        http_URLs_descriptions <- "Click the link"  
      }
      http_URLs_protocols  <- "WWW:LINK-1.0-http--link"
      http_URLs_functions <- "donwload"
      http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, http_URLs_names,http_URLs_descriptions,http_URLs_protocols, http_URLs_functions)
    }
  }
  # urls_metadata$http_urls <- http_urls
  return(http_urls)
}

#################################### PROCESS RELATIONS #############################################
#################################### EXAMPLE 1: PUBLISH ALL DATASETS IN A GIVEN DATAVERSE #############################################
# Dublin_Core_spreadsheet <- "https://docs.google.com/spreadsheets/d/1GAkcifGlZ-TNDP4vArH7SuwhWaDVkIIMdmgLjsGL8MQ/edit?usp=sharing"
# Dublin_Core_metadata <- as.data.frame(gsheet::gsheet2tbl(Dublin_Core_spreadsheet))
# # contacts <- as.data.frame(gsheet::gsheet2tbl(google_sheet_contacts))
# Titles<-Dublin_Core_metadata$Title[22]
# Titles
# multilingual_data_frame <- return_multilingual_data_frame(Titles)
# multilingual_data_frame

return_multilingual_data_frame <- function(Titles){
  language <- NULL
  text <- NULL
  list_titles <- strsplit(as.character(Titles), split = "\n")
  data_frame_multilingual <-data.frame(language = character(), text = character(),stringsAsFactors=FALSE)
  
  for(title in list_titles[[1]]){
    split_Relation <- strsplit(title, split = "@")
    language <- split_Relation[[1]][1]
    text <- split_Relation[[1]][2]
    data_frame_multilingual[nrow(data_frame_multilingual)+1,] <- c(language, text)
  }
  # urls_metadata$http_urls <- http_urls
  return(data_frame_multilingual)
}

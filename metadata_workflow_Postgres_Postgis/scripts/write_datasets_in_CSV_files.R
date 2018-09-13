# Clean unused input parameters
# @param config
# @param the_current_dataset
# @param ZipFileName
# @param virtual_repository_with_csv_files
# @param static_metadata_id
# @param SQL_query_CSV
write_datasets_in_CSV_files <- function(config,metadata,SQL){
  logger.info <- config$logger.info
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set shortcuts for variables (from json configuration file)")  
  logger.info("---------------------------------------------------------------------------------")  
  con <- config$sdi$db$con
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set working directory")  
  logger.info("---------------------------------------------------------------------------------")  
  from_wd <-getwd()
  CSV_wd <- paste(config$wd,"/jobs/", jobDir, "/data/csv/",sep="")
  setwd(CSV_wd)
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Execute SQL query to extract the dataset from the database, write and compress the CSV file (along with metadata as CSV) in a ZIP archive")  
  logger.info("---------------------------------------------------------------------------------")
  # SQL_query_CSV <- SQL$query_CSV
  SQL_query_CSV <- gsub(";"," LIMIT 50;",SQL$query_CSV)
  df<-dbGetQuery(con,SQL_query_CSV)
  CSV_file_name <-paste(metadata$Identifier,".csv",sep="")
  write.csv(df,CSV_file_name,row.names=F)
  CSV_metadata_file_name <-paste(metadata$Identifier,"_metadata.csv",sep="")
  write.csv(metadata,CSV_metadata_file_name,row.names=F)
  ZipFileName<-paste(metadata$Identifier,".zip",sep="")
  files_to_zip=c(CSV_file_name,CSV_metadata_file_name)
  zip(ZipFileName, files=files_to_zip, flags= "-r9X", extras = "",zip = Sys.getenv("R_ZIPCMD", "zip"))
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Upload the CSV (in ZIP archive) in the workspace")  
  logger.info("---------------------------------------------------------------------------------")   
  uploadWS(config$gcube$repositories$csv,ZipFileName,overwrite=T)
  csvFileURL <- getPublicFileLinkWS(paste(config$gcube$repositories$csv,ZipFileName,sep="/"))
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Restore previous directory")  
  logger.info("---------------------------------------------------------------------------------")   

  setwd(from_wd)
  return(csvFileURL)
}
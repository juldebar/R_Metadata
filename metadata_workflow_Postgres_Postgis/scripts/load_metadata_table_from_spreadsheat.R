#metadata_dataframe prepares a dataframe from a google spreadsheet to load the metadata table of the postgres database
#@param Dublin_Core_metadata
#@returns an object of class dataframe
metadata_dataframe <- function(Dublin_Core_metadata){
  all_metadata <- NULL
  number_row<-nrow(Dublin_Core_metadata)
  
  for (i in 1:number_row) {
    metadata <- NULL
    metadata$id_dataset  <- i
    if(is.null(Dublin_Core_metadata$persistent_identifier[i])){metadata$persistent_identifier <- Dublin_Core_metadata$Identifier[i]} else {metadata$persistent_identifier <- Dublin_Core_metadata$persistent_identifier[i]}
    metadata$related_sql_query <- Dublin_Core_metadata$related_sql_query[i]
    metadata$related_view_name <- Dublin_Core_metadata$related_view_name[i]
    # @jbarde => if no view create one with name paste("view_", Dublin_Core_metadata$Identifier[i], sep="") ?
    metadata$identifier <- Dublin_Core_metadata$Identifier[i]
    metadata$title  <- Dublin_Core_metadata$Title[i]
    metadata$contacts_and_roles  <- Dublin_Core_metadata$Creator[i]
    metadata$subject  <- Dublin_Core_metadata$Subject[i]
    metadata$description <- Dublin_Core_metadata$Description[i]
    metadata$date  <- Dublin_Core_metadata$Date[i]
    metadata$type  <- Dublin_Core_metadata$Type[i]
    metadata$format  <- Dublin_Core_metadata$Format[i]
    metadata$language  <- Dublin_Core_metadata$Language[i]
    metadata$relation  <- Dublin_Core_metadata$Relation[i]
    metadata$spatial_coverage  <-  Dublin_Core_metadata$Spatial_Coverage[i]
    metadata$temporal_coverage  <-  Dublin_Core_metadata$Temporal_Coverage[i]
    metadata$rights  <- Dublin_Core_metadata$Rights[i]
    metadata$source  <- Dublin_Core_metadata$Source[i]
    metadata$provenance  <- Dublin_Core_metadata$Provenance[i]
    
    all_metadata <- bind_rows(all_metadata, metadata)
  }
    return(all_metadata)
}


create_one_view_per_dataset <- function(config, metadata){
  logger.info <- config$logger.info
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set configuration variables")  
  logger.info("---------------------------------------------------------------------------------")  
  con <- config$sdi$db$con
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  
  number_row<-nrow(metadata)
  for (i in 1:number_row ) {
    view_name <- metadata$related_view_name[i]
    sql_view <- metadata$related_sql_query[i]
    # sql_view <- paste('SELECT ogc_fid, wkb_geometry AS geom, filename, gpslatitud AS lat,gpslongitu AS lon, gpsdatetim AS date,lightvalue,imagesize,model,path,parent_dir FROM "public"."photos_metadata" WHERE parent_dir = \'',view_name,'\';')
    SQLquery <- paste('DROP VIEW IF EXISTS ',view_name,' CASCADE ; CREATE VIEW ',view_name,' AS ', sql_view, sep="");
    resuling_view <- dbGetQuery(con, SQLquery)
  }
  
}


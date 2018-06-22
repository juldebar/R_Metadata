getSQLQueries <- function(config, metadata){
  #config shortcut
  con <- config$db$con
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  ######################################################################################################
  logger.info("Initialize SQL queries variables")
  ######################################################################################################
  SQL <- list()
  SQL$dynamic_metadata_spatial_Extent=NULL
  SQL$dynamic_metadata_count_features=NULL
  SQL$SRID=NULL
  SQL$dynamic_metadata_temporal_Extent=NULL
  SQL$dynamic_list_keywords =NULL
  SQL$query_CSV =NULL
  SQL$query_wfs_wms=NULL
  ######################################################################################################
  logger.info("Setting SQL queries")
  ######################################################################################################
  # metadata$view_name <-metadata$Identifier
  SQL$query_dynamic_metadata_spatial_Extent <- paste("SELECT ST_AsText(ST_Envelope(ST_ConvexHull(ST_Collect(schoolsighting_location)))) As geom FROM",metadata$view_name,";",sep=" ")
  SQL$query_dynamic_metadata_count_features <-  paste("SELECT count(*) FROM",metadata$view_name,";",sep=" ")
  SQL$query_dynamic_metadata_get_SRID <-  paste("SELECT DISTINCT(ST_SRID(schoolsighting_location)) AS SRID FROM",metadata$view_name,";",sep=" ")
  # SQL$query_dynamic_metadata_temporal_Extent <- paste("SELECT MIN(date) AS start_date, MAX(date) AS end_date FROM",metadata$view_name,";",sep=" ")
  SQL$query_dynamic_metadata_temporal_Extent <- paste("SELECT 'start='::text || MIN(school_sighting_date)::text || ';end='::text ||MAX(school_sighting_date)::text AS temporal_extent FROM",metadata$view_name,";",sep=" ")
  # SQL$query_dynamic_list_keywords <- paste("SELECT DISTINCT (tag) FROM",metadata$view_name,";",sep=" ")
  SQL$query_CSV <- paste("SELECT * FROM",metadata$view_name," LIMIT 10;",sep=" ")
  SQL$query_wfs_wms <- SQL$query_CSV
  ######################################################################################################
  logger.info("Execute all SQL queries")
  ######################################################################################################
  SQL$dynamic_metadata_spatial_Extent <- dbGetQuery(con, SQL$query_dynamic_metadata_spatial_Extent)
  SQL$dynamic_metadata_count_features <- dbGetQuery(con, SQL$query_dynamic_metadata_count_features)
  SQL$SRID <- dbGetQuery(con, SQL$query_dynamic_metadata_get_SRID )
  SQL$dynamic_metadata_temporal_Extent <- dbGetQuery(con, SQL$query_dynamic_metadata_temporal_Extent)
  # SQL$dynamic_list_keywords <- dbGetQuery(con, SQL$query_dynamic_list_keywords)
  ######################################################################################################
  logger.info("Return results of SQL queries")
  ######################################################################################################  
  return(SQL)
}
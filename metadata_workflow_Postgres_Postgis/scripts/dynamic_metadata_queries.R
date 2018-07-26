getSQLQueries <- function(config, metadata){
  
  #config shortcut
  con <- config$db$con
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  logger.info("######################################################################################################")
  logger.info("Initialize SQL queries variables")
  logger.info("######################################################################################################")
  SQL <- list()
  SQL$dynamic_metadata_spatial_Extent=NULL
  SQL$dynamic_metadata_count_features=NULL
  SQL$SRID=NULL
  SQL$dynamic_metadata_temporal_Extent=NULL
  SQL$dynamic_list_keywords =NULL
  SQL$query_CSV =NULL
  SQL$query_wfs_wms=NULL
  logger.info("######################################################################################################")
  logger.info("Setting SQL queries")
  logger.info("######################################################################################################")
  # metadata$view_name <-metadata$Identifier
  SQL$query_dynamic_metadata_spatial_Extent <- paste("SELECT ST_AsText(ST_Envelope(ST_ConvexHull(ST_Collect(geom)))) As geom FROM",metadata$view_name,";",sep=" ")
  SQL$query_dynamic_metadata_count_features <-  paste("SELECT count(*) FROM",metadata$view_name,";",sep=" ")
  SQL$query_dynamic_metadata_get_SRID <-  paste("SELECT DISTINCT(ST_SRID(geom)) AS SRID FROM",metadata$view_name,";",sep=" ")
  # SQL$query_dynamic_metadata_temporal_Extent <- paste("SELECT MIN(date) AS start_date, MAX(date) AS end_date FROM",metadata$view_name,";",sep=" ")
  SQL$query_dynamic_metadata_temporal_Extent <- paste("SELECT 'start='::text || MIN(date)::text || ';end='::text ||MAX(date)::text AS temporal_extent FROM",metadata$view_name,";",sep=" ")
  # SQL$query_dynamic_list_keywords <- paste("SELECT DISTINCT (tag) FROM",metadata$view_name,";",sep=" ")
  SQL$query_CSV <- paste("SELECT * FROM ",metadata$view_name," ;",sep=" ")
  SQL$query_wfs_wms <- SQL$query_CSV
  logger.info("######################################################################################################")
  logger.info("Execute all SQL queries")
  logger.info("######################################################################################################")
  SQL$dynamic_metadata_spatial_Extent <- dbGetQuery(con, SQL$query_dynamic_metadata_spatial_Extent)
  SQL$dynamic_metadata_count_features <- dbGetQuery(con, SQL$query_dynamic_metadata_count_features)
  SQL$SRID <- dbGetQuery(con, SQL$query_dynamic_metadata_get_SRID )
  SQL$dynamic_metadata_temporal_Extent <- dbGetQuery(con, SQL$query_dynamic_metadata_temporal_Extent)
  # SQL$dynamic_list_keywords <- dbGetQuery(con, SQL$query_dynamic_list_keywords)
  logger.info("######################################################################################################")
  logger.info("Return results of SQL queries")
  logger.info("######################################################################################################")

  return(SQL)
}

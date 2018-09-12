getSQLQueries <- function(config, metadata){
  
  #config shortcut
  con <- config$sdi$db$con
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
  SQL$query_dynamic_metadata_spatial_Extent <- paste("SELECT ST_AsText(ST_Envelope(ST_ConvexHull(ST_Collect(geom)))) As geom FROM",metadata$related_view_name,";",sep=" ")
  SQL$query_dynamic_metadata_count_features <-  paste("SELECT count(*) FROM",metadata$related_view_name,";",sep=" ")
  SQL$query_dynamic_metadata_get_geometry_name <-  paste("SELECT f_geometry_column FROM geometry_columns WHERE f_table_name='",metadata$related_view_name,"';",sep="")
  SQL$query_dynamic_metadata_get_geometry_type <-  paste("SELECT type FROM geometry_columns WHERE f_table_name='",metadata$related_view_name,"';",sep="")
  SQL$query_dynamic_metadata_get_geometry_SRID <-  paste("SELECT SRID FROM geometry_columns WHERE f_table_name='",metadata$related_view_name,"';",sep="")
  SQL$query_dynamic_metadata_temporal_Extent <- paste("SELECT 'start='::text || MIN(date)::text || ';end='::text ||MAX(date)::text AS temporal_extent FROM",metadata$related_view_name,";",sep=" ")
  # SQL$query_dynamic_list_keywords <- paste("SELECT DISTINCT (tag) FROM",metadata$related_view_name,";",sep=" ")
  SQL$query_CSV <- paste("SELECT *, ST_AsText(geom) AS WKT  FROM  ",metadata$related_view_name," ;",sep=" ")# julien To BE Done => transform WKB in WKT ?
  SQL$query_wfs_wms <- SQL$query_CSV # julien To BE Done => change query if CSV = transform WKB in WKT
  logger.info("######################################################################################################")
  logger.info("Execute all SQL queries")
  logger.info("######################################################################################################")
  SQL$dynamic_metadata_spatial_Extent <- dbGetQuery(con, SQL$query_dynamic_metadata_spatial_Extent)
  SQL$dynamic_metadata_count_features <- dbGetQuery(con, SQL$query_dynamic_metadata_count_features)
  SQL$geometry_name <- dbGetQuery(con, SQL$query_dynamic_metadata_get_geometry_name )
  SQL$geometry_type <- dbGetQuery(con, SQL$query_dynamic_metadata_get_geometry_type )
  SQL$SRID <- dbGetQuery(con, SQL$query_dynamic_metadata_get_geometry_SRID )
  
  SQL$dynamic_metadata_temporal_Extent <- dbGetQuery(con, SQL$query_dynamic_metadata_temporal_Extent)
  # SQL$dynamic_list_keywords <- dbGetQuery(con, SQL$query_dynamic_list_keywords)
  logger.info("######################################################################################################")
  logger.info("Return results of SQL queries")
  logger.info("######################################################################################################")

  return(SQL)
}

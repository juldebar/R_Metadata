# https://github.com/eblondel/geosapi/wiki#publishFeatureLayer-publish
write_data_access_OGC_WMS_WFS <- function(config,
                                          metadata,
                                          SQL,   
                                          spatial_metadata,
                                          keywords_metadata
                                          ){
  # config=CFG
  logger.info <- config$logger.info
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set configuration variables")  
  logger.info("---------------------------------------------------------------------------------")  
  con <- config$db$con
  logger <- config$logger
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  gsman <- config$sdi$geoserver$api
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set Geoserver workspace and store")  
  logger.info("---------------------------------------------------------------------------------") 
  # unpublish before republishing (if the layer was already existing.)
  wsnames <- gsman$getWorkspaceNames()
  workspace<-"RTTP_workspace"
  datastore<-"RTTP_datastore"
  # deleted <- gsman$deleteWorkspace(workspace, recurse = TRUE)
  # workspace <- gsman$createWorkspace("RTTP_workspace", "http://juldebar")
#   unpublished <- gsman$unpublishLayer(workspace, datastore, metadata$Permanent_Identifier)
#   unpublished <- gsman$unpublishLayer(workspace, datastore, "rttp_released_tagged_tuna")
#   unpublished <- gsman$deleteFeatureType(workspace, datastore, "rttp_released_tagged_tuna")
  # ns<-NULL
#   if (!is.null(ns <- gsman$getNamespace("RTTP_workspace"))){
#     created <- gsman$createWorkspace(workspace, "http://julien")
    # created <- gsman$createDataStore(workspace, datastore)
#   }
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set general metadata elements")  
  logger.info("---------------------------------------------------------------------------------") 
  # information common to all the datasets
  featureType <- GSFeatureType$new()
  featureType$setName(metadata$Permanent_Identifier)
  featureType$setNativeName(metadata$Permanent_Identifier)
  featureType$setAbstract(metadata$Description)
  featureType$setTitle(metadata$Title)
  featureType$setEnabled(TRUE)
  featureType$setSrs(paste0("EPSG:",spatial_metadata$SRID))
  featureType$setNativeCRS(paste0("EPSG:",spatial_metadata$SRID))
  featureType$setProjectionPolicy("REPROJECT_TO_DECLARED")
  featureType$setLatLonBoundingBox(spatial_metadata$dynamic_metadata_spatial_Extent$xmin,spatial_metadata$dynamic_metadata_spatial_Extent$ymin,spatial_metadata$dynamic_metadata_spatial_Extent$xmax,spatial_metadata$dynamic_metadata_spatial_Extent$ymax, crs = paste0("EPSG:",spatial_metadata$SRID))
  featureType$setNativeBoundingBox(spatial_metadata$dynamic_metadata_spatial_Extent$xmin,spatial_metadata$dynamic_metadata_spatial_Extent$ymin,spatial_metadata$dynamic_metadata_spatial_Extent$xmax,spatial_metadata$dynamic_metadata_spatial_Extent$ymax, crs = paste0("EPSG:",spatial_metadata$SRID))
  #add general static keywords for this metadata
  for (i in 1:nrow(keywords_metadata$all_keywords)){
    featureType$addKeyword(keywords_metadata$all_keywords$keyword[i])
  }
  
  #different_thesaurus <- unique(keywords_metadata$thesaurus)
  #number_thesaurus<-length(unique(different_thesaurus))
  #for(t in 1:number_thesaurus){
  #  if(!is.null(keywords_metadata)){
  #    number_row<-nrow(keywords_metadata$all_keywords[t])
  #    for (i in 1:number_row) {
  #      if(keywords_metadata$thesaurus[i]==different_thesaurus[t]){
  #        featureType$addKeyword(keywords_metadata$keyword[i])
  #      }
  #    }
  #  }
  #}
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set LINKS POINTING OGC 19115 METADATA (IF EXISTS)")  
  logger.info("---------------------------------------------------------------------------------")
  if(config$actions$metadata_iso_19115){ # Only if 19115 is published
    XML_metadata_from_CSW <- GSMetadataLink$new(
      type = "text/xml",
      metadataType = "ISO19115:2003",
      content = paste0(config$sdi$geonetwork$url, "/srv/eng/csw?service=CSW&request=GetRecordById&Version=2.0.2&elementSetName=full&outputSchema=http%3A//www.isotc211.org/2005/gmd&id=",metadata$Permanent_Identifier)
    )
    featureType$addMetadataLink(XML_metadata_from_CSW)
    
    metadata_in_geonetwork <- GSMetadataLink$new(
      type = "text/html",
      metadataType = "ISO19115:2003",
      content = paste0(config$sdi$geonetwork$url, "/srv/eng/catalog.search#/metadata/",metadata$Permanent_Identifier)
    )
    featureType$addMetadataLink(metadata_in_geonetwork)
  }
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set virtual table (NOT OGC STANDARD)")  
  logger.info("---------------------------------------------------------------------------------")
  vt <- GSVirtualTable$new()
  vt$setName(metadata$Permanent_Identifier)
  vt$setSql(gsub(";","",SQL$query_wfs_wms))
  # vt$setSql("SELECT * FROM released_tagged_tuna")
  vtg <- GSVirtualTableGeometry$new(name = "geom", type = SQL$geometry_type, srid = spatial_metadata$SRID)
  vt$setGeometry(vtg)
  featureType$setVirtualTable(vt)
  logger.info("---------------------------------------------------------------------------------")  
  logger.info("Set and publish the complete layer (featuretype + layer)")  
  logger.info("---------------------------------------------------------------------------------")  
  layer <- GSLayer$new()
  layer$setName(metadata$Permanent_Identifier)
  layer$setDefaultStyle("point")
  published <- gsman$publishLayer(workspace, datastore, featureType, layer)
  return(published)
}
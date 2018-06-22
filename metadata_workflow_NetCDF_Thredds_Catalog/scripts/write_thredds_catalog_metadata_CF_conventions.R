# RECURSIVE FUNCTION TO BROWSE A THREDDS CATALOG AND RELATED SUB-CATALOGS
browse_sub_catalog <- function(config,Thredds){
  
  #config shortcuts
  # logger <- config$logger
  # logger.info <- config$logger.info
  # logger.warn <- config$logger.warn
  # logger.error <- config$logger.error
  # Thredds_URL<-"http://mdst-macroes.ird.fr:8080/thredds/catalog/BlueBridge/MOI/SST_1km_daily/SST_1km_daily/catalog.xml"
  # Thredds <-NULL
  # config  <- CFG
  # Thredds$url <-config$sdi$thredds$url
  Thredds_URL<-Thredds$url
  # config <- CFG
  Thredds_catalog <- get_catalog(Thredds_URL)
  sub_catalogs <- Thredds_catalog$get_catalogs()
  All_datasets_for_metadata <- Thredds_catalog$get_datasets()
  
  if (!is.null(All_datasets_for_metadata)==TRUE){
    write_thredds_catalog_metadata(config,Thredds)
    print("\n write metadata \n")
  }
  if (!is.null(sub_catalogs)==TRUE){
    number_catalogs<-length(sub_catalogs)
    for (i in 1:number_catalogs ) {
      sub_catalog <- sub_catalogs[[i]]
      # catalog_url<-sub_catalog$url
      browse_sub_catalog(config,sub_catalog)
    }
  } else {
    print("\n no more sub catalogs\n")
    print(sub_catalogs)
  }

}


write_thredds_catalog_metadata <- function(config, source){

  #config shortcuts
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  
  
  logger.info("===================================================================================================================")
  logger.info("=================New Thredds catalag to be browsed ============================")
  logger.info(paste(source$url,sep=""))
  logger.info("===================================================================================================================")
  
  Thredds_URL<-source$url
  # Thredds_URL<-"http://mdst-macroes.ird.fr:8080/thredds/BlueBridge/MOI/Chl-a/Chl_4km/catalog.xml"
  
  Thredds_catalog <- get_catalog(Thredds_URL)
  sub_catalogs <- Thredds_catalog$get_catalogs()
  All_datasets_for_metadata <- Thredds_catalog$get_datasets()
  
  # cat(All_datasets_for_metadata)
  head(All_datasets_for_metadata)
  number_datasets<-length(All_datasets_for_metadata)
  #' @ julien => FAIRE UN SELECT SUR LE TYPE MIME ".nc" ou ".ncml"
  # names(All_datasets_for_metadata)[2]
  # lapply(All_datasets_for_metadata, class)
  
  logger.info("START THE WORKFLOW WITH THE MAIN LOOP : ITERATE ON EACH LINE OF THE METADATA TABLE => CREATE ONE METADATA PER SHEET")

  for (i in 1:number_datasets ) {
    # for (i in 1:1 ) {
      
    logger.info("===================================================================================================================")
    logger.info("===================================================================================================================")
    
    # dataset <- All_datasets_for_metadata[[1]]
    dataset <- All_datasets_for_metadata[[i]]
    
    if(grepl(".ncml",dataset$url)){
      
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Run OPeNDAP query to open the current NetCDF file and extract metadata from the header")
    logger.info("-------------------------------------------------------------------------------------------------------------------")

    opendap_url <- gsub("catalog", "dodsC", dataset$url)
    # opendap_url <-"http://mdst-macroes.ird.fr:8080/thredds/dodsC/BlueBridge/MOI/Chl-a/Chl_4km/All-datasets_L3m_DAY_CHL_chlor_a_4km.ncml"
    # opendap_url <-"http://mdst-macroes.ird.fr:8080/thredds/dodsC/BlueBridge/MOI/SST/SST_1km_daily/Tanzania.ncml"
    # opendap_url <-"http://mdst-macroes.ird.fr:8080/thredds/dodsC/BlueBridge/IOTC/data_ss324_GAJ_1.nc"
    # opendap_url <-"http://mdst-macroes.ird.fr:8080/thredds/dodsC/BlueBridge/MOI/SST_1km_daily/SST_1km_daily/Tanzania.ncml"
    ncin <- nc_open(opendap_url)
    # PRINT THE HEADER TO SEE THE METADATA
    # print(ncin)
    # variable_names <- names(ncin$var)
    # variable_names[1]
    # dimension_names <- names(ncin$dim)
    # dimension_names[1]
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Dublin Core Metadata elements: mapping with CF conventions metadata")
    logger.info("-------------------------------------------------------------------------------------------------------------------")

    metadata <- NULL
    metadata$Identifier  <- names(All_datasets_for_metadata)[i]# if(is.na(metadata$Identifier)){metadata$Identifier="TITLE AND DATASET NAME TO BE FILLED !!"}
    metadata$dataset_permanent_identifier <- gsub("\\..*","",metadata$Identifier)
    metadata$Title  <- ncatt_get(ncin,0,"title")$value
    metadata$Description <- ncatt_get(ncin,0,"summary")$value
    # metadata$Description <- paste(dataset$name,dataset$title,dataset$ID, sep=" ET ")
    
    metadata$Date  <- ncatt_get(ncin,0,"date_created")$value
    metadata$Type  <- "NetCDF"
    # metadata$table_type <- static_metadata_view_type # @jbarde to be removed ??
    metadata$Format  <- "NetCDF or NCML data format and OPeNDAP access protocol (in addition to WMS/WCS)"
    metadata$Language  <-  "eng" # only worth for metadata  ?
    metadata$Lineage  <- ncatt_get(ncin,0,"history")$value
    metadata$Rights  <- "intellectualPropertyRights" # check if in NetCDF
    
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    metadata$dataset_access_query <- NULL # @jbarde => Needed to load and browse the data itself (can be SQL query / http or OPeNDAP ACCESS)
    metadata$Parent_Metadata_Identifier  <- NULL
    metadata$Purpose <- ncatt_get(ncin,0,"comment")$value
    metadata$addHierarchyLevel <- "dataset" # @jbarde should be use to distinguish database / datasets....
    metadata$Dataset_Type  <- "NetCDF" # @jbarde => we should define a proper typology of datasets same as "file type" ?
    metadata$Update_frequency <- "annually" # TO BE DONE PROPERLY
    static_metadata_dataset_origin_institution <- ncatt_get(ncin,0,"institution")$value # @jbarde => Not needed for the mapping if already in contacts
    # static_metadata_dataset_release_date <- ncatt_get(ncin,0,"date_modified")$value
    # metadata$Projet  <- Dublin_Core_metadata$Projet[i] # @jbarde => to replace "static_metadata_dataset_origin_institution" ?
    # static_metadata_table_sql_query <- NULL # SHOULD BE GIVEN BY NETCDF METADATA
    # metadata$Credits <- NULL # Credits=NULL # @jbarde should be added ?
    
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements to describe the SPATIAL COVERAGE AND RELATED GEOGRAPHIC OBJECTS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    spatial_metadata <-NULL
    geospatial_lon_min <- ncatt_get(ncin,0,"geospatial_lon_min")
    geospatial_lat_min <- ncatt_get(ncin,0,"geospatial_lat_min")
    geospatial_lon_max <- ncatt_get(ncin,0,"geospatial_lon_max")
    geospatial_lat_max <- ncatt_get(ncin,0,"geospatial_lat_max")
    geospatial_lon_units <- ncatt_get(ncin,0,"geospatial_lon_units")
    geospatial_lat_units <- ncatt_get(ncin,0,"geospatial_lat_units")
    WKT_area_polygon <- ncatt_get(ncin,0,"WKT_area_polygon")
    xmin <- c(geospatial_lon_min$value)
    xmax <- c(geospatial_lon_max$value)
    ymin <- c(geospatial_lat_min$value)
    ymax <- c(geospatial_lat_max$value)
    dynamic_metadata_spatial_Extent <- data.frame(xmin, ymin, xmax, ymax, stringsAsFactors=FALSE)
    spatial_metadata$dynamic_metadata_spatial_Extent <- dynamic_metadata_spatial_Extent
    spatial_metadata$SRID<-"4326"
    spatial_metadata$geographic_identifier="Mauritius"
    spatial_metadata$Spatial_resolution<-NULL
    spatial_metadata$SpatialRepresentationType <- "grid"
    # GeometricObjectType ???  # @jbarde => only if vector ?
    Thumbnail_WMS=paste("http://mdst-macroes.ird.fr:8080/thredds/wms/BlueBridge/MOI/SST_1km_daily/SST_1km_daily/",dataset$name,"?service=WMS&version=1.3.0&request=GetMap&LAYERS=sst&ELEVATION=0&TRANSPARENT=true&STYLES=boxfill%2Fsst_36&CRS=EPSG%3A4326&COLORSCALERANGE=25.61%2C32.53&NUMCOLORBANDS=253&LOGSCALE=false&SERVICE=WMS&EXCEPTIONS=application%2Fvnd.ogc.se_inimage&FORMAT=image%2Fpng&SRS=EPSG%3A4326&BBOX=",ymin,",",xmin,",",ymax,",",xmax,"&width=768&height=768&srs=EPSG:4326&format=image/png",sep="")
    # Thumbnail_WMS=paste("http://mdst-macroes.ird.fr:8080/thredds/wms/BlueBridge/MOI/SST_1km_daily/SST_1km_daily/SSomalia.ncml?service=WMS&version=1.3.0&request=GetMap&LAYERS=sst&ELEVATION=0&TRANSPARENT=true&STYLES=boxfill%2Fsst_36&CRS=EPSG%3A4326&COLORSCALERANGE=25.61%2C32.53&NUMCOLORBANDS=253&LOGSCALE=false&SERVICE=WMS&EXCEPTIONS=application%2Fvnd.ogc.se_inimage&FORMAT=image%2Fpng&SRS=EPSG%3A4326&BBOX=-14.2,36.8,-4.7978006157276,50.204176133524&width=768&height=768&srs=EPSG:4326&format=image/png
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements to describe the TEMPORAL COVERAGE")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    temporal_metadata <-NULL
    # time <- ncvar_get(ncin,"year") => commenter pour MOI
    time_coverage_start <- ncatt_get(ncin,0,"time_coverage_start")
    time_coverage_end <- ncatt_get(ncin,0,"time_coverage_end")
    time_coverage_units <- ncatt_get(ncin,0,"time_coverage_units")
    time_coverage_resolution <- ncatt_get(ncin,0,"time_coverage_resolution")
    start_date <- as.POSIXct(time_coverage_start$value,format='%Y')
    end_date <- as.POSIXct(time_coverage_start$value,format='%Y')
    dynamic_metadata_temporal_Extent <- data.frame(start_date, end_date, stringsAsFactors=FALSE)
    temporal_metadata$dynamic_metadata_temporal_Extent <- dynamic_metadata_temporal_Extent
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the CONTACTS AND ROLES")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    contacts_metadata <-NULL
    contact_email=NULL
    contact_role=NULL
    contacts_roles=NULL
    all_contacts <- ncatt_get(ncin,0,"all_contacts")$value
    # all_contacts <- metadata$contacts_and_roles # TO BE REUSED ONCE DONE 
    list_contacts <- strsplit(all_contacts, split = ";") 
    for(contact in list_contacts[[1]]){
      split_contact <- strsplit(contact, split = "=")
      split_contact
      contact_email <- c(contact_email, split_contact[[1]][2])
      split_contact[[1]][2]
      contact_role <- c(contact_role,split_contact[[1]][1]) # to be done Ã  changer  
      split_contact[[1]][1]  
    }
    contacts_roles <- data.frame(contact=contact_email, RoleCode=contact_role, dataset=metadata$Identifier,stringsAsFactors=FALSE)
    contacts_metadata$contacts_roles <- contacts_roles
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the CONTROLLED VOCABULARIES: KEYWORDS AND THESAURUS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    keywords_metadata <-NULL
    all_keywords <-NULL
    static_keywords<-NULL
    wms_variable <-ncatt_get(ncin,0,"wms_variable")$value
    
    metadata$Subject  <- c(ncatt_get(ncin,0,"keywords")$value)
    list_of_keywords <- metadata$Subject
    list_of_keywords <- gsub("GENERAL=", "", list_of_keywords)
    thesaurus <- c("AGROVOC")
    list_keywords <- strsplit(as.character(list_of_keywords), split = ", ")
    list_keywords <- unlist(list_keywords)
    all_keywords <-data.frame(keyword=list_keywords, thesaurus=thesaurus, stringsAsFactors=FALSE)
    keywords_metadata$all_keywords <- all_keywords
    TopicCategory <- c("biota", "oceans", "environment", "geoscientificInformation")
    keywords_metadata$TopicCategory <- TopicCategory
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the DCMI RELATION (OGC ONLINE RESOURCES)")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    # metadata$Relation  <- A METTRE OU VERIFIER SI PRESENT DANS LE NETCDF
    # Relation <- metadata$Relation # to be done => should be a URL and used to list identifiers of other related reources.
    urls_metadata <- NULL
    http_urls <- NULL
    http_URLs_links=NULL
    http_URLs_names=NULL
    http_URLs_descriptions=NULL
    http_URLs_protocols=NULL
    http_URLs_functions=NULL
    http_urls <-data.frame(http_URLs_links = character(), http_URLs_names = character(),http_URLs_descriptions = character(),http_URLs_protocols = character(), http_URLs_functions = character(),stringsAsFactors=FALSE)

    #Linkages
    #----------
    md_xml_csw <- paste0(config$sdi$geonetwork$url,"/srv/eng/csw?service=CSW&request=GetRecordById&Version=2.0.2&elementSetName=full&outputSchema=http%3A//www.isotc211.org/2005/gmd&id=",metadata$dataset_permanent_identifier)
    md_html_GN <- sprintf("%s/srv/en/main.home?uuid=%s",config$sdi$geonetwork$url, metadata$dataset_permanent_identifier)
    color_range <- switch(wms_variable,
           "chlor_a" = "&ELEVATION=0&STYLES=boxfill%2Fsst_36&COLORSCALERANGE=0.03826%2C1.892&NUMCOLORBANDS=253&LOGSCALE=true",
           "sst" = "&ELEVATION=0&STYLES=boxfill%2Fsst_36&COLORSCALERANGE=25.61%2C32.53&NUMCOLORBANDS=253&LOGSCALE=true",
           "u"="&ELEVATION=15&STYLES=boxfill%2Foccam&COLORSCALERANGE=-1.802%2C1.03&NUMCOLORBANDS=20&LOGSCALE=false",
           "w"="&ELEVATION=10&STYLES=boxfill%2Fsst_36&CRS=EPSG%3A4326&COLORSCALERANGE=1%2C20&NUMCOLORBANDS=253&LOGSCALE=false",
           "sla"="&ELEVATION=0&STYLES=boxfill%2Fsst_36&CRS=EPSG%3A4326&COLORSCALERANGE=-0.5558%2C0.5545&NUMCOLORBANDS=253&LOGSCALE=false",
           "par"="ELEVATION=0&STYLES=boxfill%2Fsst_36&CRS=EPSG%3A4326&COLORSCALERANGE=0.028%2C61.76&NUMCOLORBANDS=253&LOGSCALE=false",
           "Kd_490"="ELEVATION=0&STYLES=boxfill%2Fsst_36&CRS=EPSG%3A4326&COLORSCALERANGE=0.0182%2C2.259&NUMCOLORBANDS=253&LOGSCALE=true"
                      )
    wms_url <-paste(gsub("/catalog/","/wms/",gsub("catalog.xml",dataset$name,Thredds_catalog$url)),"?",sep="")
    wms_layer=wms_variable
    Thumbnail_WMS=paste(wms_url,"service=WMS&version=1.3.0&request=GetMap&LAYERS=",wms_variable,"&TRANSPARENT=true&CRS=EPSG%3A4326&",color_range,"&SERVICE=WMS&EXCEPTIONS=application%2Fvnd.ogc.se_inimage&FORMAT=image%2Fpng&SRS=EPSG%3A4326&BBOX=",ymin,",",xmin,",",ymax,",",xmax,"&width=768&height=768&srs=EPSG:4326&format=image/png",sep="")
    
    
    # julien => A SUPPRIMER
    static_metadata_dataset_origin_institution<-tolower(static_metadata_dataset_origin_institution)

    #Online Resources
    #----------------
    http_urls[nrow(http_urls)+1,] <- c("http://moi.govmu.org/mesa/", "MESA project on MOI Website","Get more information on MESA project from MOI Website", "WWW:LINK-1.0-http--link","information")
    http_urls[nrow(http_urls)+1,] <- c(Thumbnail_WMS, "thumbnail","thumbnail", "WWW:LINK-1.0-http--link","search")
    http_urls[nrow(http_urls)+1,] <- c(paste(gsub(".xml",".html",Thredds_catalog$url),"?dataset=",dataset$ID,sep=""),"Thredds metadata sheet", "Thredds metadata sheet", "WWW:LINK-1.0-http--link","search")
    http_urls[nrow(http_urls)+1,] <- c(wms_url,wms_layer,"Visualize maps from WMS (Web Map Service) - see service/operation metadata for guidance to use query parameters","OGC:WMS-1.1.0-http-get-map","download")
    http_urls[nrow(http_urls)+1,] <- c(md_html_GN, "OGC metadata: HTML view in Geonetwork","Visualize metadata HTML view in Geonetwork", "WWW:LINK-1.0-http--link","search")
    http_urls[nrow(http_urls)+1,] <- c(md_xml_csw, "OGC metadata: XML from CSW", "Visualize metadata XML from CSW (Catalogue Service for the Web)", "WWW:LINK-1.0-http--link","download")
    # http://mdst-macroes.ird.fr:8080/thredds/catalog/BlueBridge/MOI/SST_1km_daily/SST_1km_daily/catalog.html?dataset=BlueBridgeCatalog/MOI/SST_1km_daily/SST_1km_daily/Tanzania.ncml
    # dataset$url
    
    if(is.na(metadata$Identifier)){metadata$Identifier="TITLE AND DATASET NAME TO BE FILLED !!"}
    # thumbnail <-"http://mdst-macroes.ird.fr/tmp/logo_IRD.svg"
    thumbnail <-"https://drive.google.com/uc?id=1Uc7tYMXWo3nFMs9xNuY651orAVGaGlJO"
    http_urls[nrow(http_urls)+1,] <- c(thumbnail, "thumbnail","Codelist Icon", "WWW:LINK-1.0-http--link","image/png")
  
    urls_metadata$http_urls <- http_urls
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Workflow step 4: ISO Metadata (19115 & 19119 TOGETHER, 19110 SEPARATELY) generation & publication")
    logger.info("-------------------------------------------------------------------------------------------------------------------")

    #ISO 19115
    if(config$actions$metadata_iso_19115){
      ogc_metatada_sheet <- write_metadata_OGC_19115_from_Dublin_Core(config=config,
                                                                      metadata=metadata,
                                                                      spatial_metadata=spatial_metadata,
                                                                      temporal_metadata=temporal_metadata,
                                                                      contacts_metadata=contacts_metadata,
                                                                      keywords_metadata=keywords_metadata,
                                                                      urls_metadata=urls_metadata
                                                                      )

    logger.info(sprintf("...ISO/OGC 19115 metadata for dataset with permanent id '%s' has been created!", metadata$Permanent_Identifier))
    logger.info("Saving ISO/OGC XML metadata (ISO 19115) file to R job working directory")
    metatada_sheet_xml <- ogc_metatada_sheet$encode()
    xml_file_name <- paste(metadata$Identifier,".xml",sep="")
    
    setwd(file.path(getwd(), "metadata"))
    saveXML(metatada_sheet_xml, file = xml_file_name)
    logger.info(sprintf("ISO/OGC 19139 XML metadata (ISO 19115) file '%s' has been created!", xml_file_name))
    setwd("..")
    
    #Publication to Geonetwork
    logger.info("Publishing ISO/OGC XML metadata file to Geonetwork")
    metadata_URL <- push_metadata_in_geonetwork(config, metadata$Identifier, ogc_metatada_sheet)
    logger.info(sprintf("URL ?", metadata_URL))
    logger.info(sprintf("ISO/OGC 19139 XML metadata (ISO 19115) file '%s' has been published!", xml_file_name))
    
  } else {
    logger.warn("METADATA ISO/OGC 19115 generation/publication DISABLED")
  }
    
    
    #ISO 19110 => not if "grid"

    }else{
      cat ("nada in \n")
      print(dataset)
      print(dataset$url)
      }
  }
  
}

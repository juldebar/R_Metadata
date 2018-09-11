write_Dublin_Core_metadata <- function(config, source){
  
  #config shortcuts
  con <- config$sdi$db$con
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Load contacts and metadata from google spreadsheet")
  logger.info("-------------------------------------------------------------------------------------------------------------------")  
  google_sheet_contacts <- config$gsheetUrls$contacts
  contacts <- as.data.frame(gsheet::gsheet2tbl(google_sheet_contacts))
  Postgres_metadata_table <- config$gsheetUrls$dublin_core_gsheet
  Datasets <- as.data.frame(gsheet::gsheet2tbl(Postgres_metadata_table))
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Workflow Postgres:  SQL QUERY: CREATE 'metadata' TABLE and fill it by loading the content from a google spreadsheet")
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  if (config$actions$create_metadata_table){
    query_create_table <- readLines(paste(config$wd,"/scripts/SQL/create_table_metadata.sql",sep=""))
    create_Table <- dbGetQuery(con,query_create_table)
    metadata <- metadata_dataframe(Dublin_Core_metadata=Datasets)
    dbWriteTable(con, "metadata", metadata, row.names=FALSE, append=TRUE)
  } else {
    logger.info("Table 'metadata' not created")
  }
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Create one SQL VIEW per dataset")
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  if (config$actions$create_sql_view_for_each_dataset){
    create_one_view_per_dataset(config, metadata)
    logger.info("A SQL view has been created for each dataset")
  } else {
    logger.info("No SQL view has been created")
  }
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Workflow Postgres: READ CONTENT OF 'metadata' table")
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  
  SQL_query_metadata <- "SELECT * FROM metadata ;"
  Dublin_Core_metadata <- dbGetQuery(con, SQL_query_metadata)
  number_row<-nrow(Dublin_Core_metadata)
  
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Workflow Postgres: START THE MAIN LOOP : ITERATE ON EACH LINE OF THE METADATA TABLE => CREATE ONE METADATA PER SHEET")
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  
  for (i in 1:number_row) {
    metadata <- NULL
    metadata <- Dublin_Core_metadata[i,]
    
    logger.info("===================================================================================================================")
    logger.info(sprintf("New dataset found in the metadata table of the database"))
    logger.info("===================================================================================================================")
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Dublin Core Metadata elements")
    logger.info("Loading static metadata elements from metadata table")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    # if(is.na(metadata$Identifier)){metadata$Identifier="TITLE AND DATASET NAME TO BE FILLED !!"} => @julien => est-ce qu'on ajoute des contrôles et des erreurs si non remplis ?
    metadata$Identifier  <- Dublin_Core_metadata$identifier[i]
    metadata$Title  <- Dublin_Core_metadata$title[i]
    metadata$Description <- Dublin_Core_metadata$description[i]
    metadata$Date  <- Dublin_Core_metadata$date[i]
    metadata$Type  <- Dublin_Core_metadata$type[i]
    metadata$Format  <- Dublin_Core_metadata$format[i]
    metadata$Language  <- Dublin_Core_metadata$language[i]
    metadata$Rights  <- Dublin_Core_metadata$rights[i]
    metadata$Source  <- Dublin_Core_metadata$source[i] 
    metadata$Lineage  <- Dublin_Core_metadata$provenance[i]
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    metadata$Permanent_Identifier  <- Dublin_Core_metadata$persistent_identifier[i]
    metadata$Parent_Metadata_Identifier  <- config$sdi$db$name # @jbarde => indicates the database the dataset comes from
    # metadata$Update_frequency <- "annually" # TO BE DONE PROPERLY => same for the whole database ?
    metadata$addHierarchyLevel <- "dataset" 
    metadata$Dataset_Type  <- "dataset stored in a database" # @jbarde => we should define a proper typology of datasets same as "file type" ?
    metadata$Purpose <- "describe Purpose"
    metadata$dataset_access_query <- Dublin_Core_metadata$related_sql_query[i] # @jbarde => Needed to load and browse the data itself (can be SQL query / http or OPeNDAP ACCESS)
    metadata$view_name <- Dublin_Core_metadata$related_view_name[i]
    metadata$Credits <- "TO BE ADDED AS A NEW COLUMN OF THE METADATA TABLE IN THE DATABASE ?" # Credits=NULL # @jbarde should be added ?
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Loading dynamic metadata elements from metadata table")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    contact_email=NULL
    contact_role=NULL
    contacts_roles=NULL
    all_keywords=NULL
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Get SQL Sardara queries for current dataset...")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    SQL <- getSQLQueries(config, metadata)
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements to describe the SPATIAL COVERAGE AND RELATED GEOGRAPHIC OBJECTS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    spatial_metadata <-NULL
    
    spatial_metadata$SRID<-SQL$SRID
    if(spatial_metadata$SRID[,1]==0){spatial_metadata$SRID<-4326}
    
    spatial_extent=readWKT(SQL$dynamic_metadata_spatial_Extent)
    xmin <- spatial_extent@bbox[1,1]
    xmax <- spatial_extent@bbox[1,2]
    ymin <- spatial_extent@bbox[2,1]
    ymax <- spatial_extent@bbox[2,2]
    spatial_metadata$dynamic_metadata_spatial_Extent <- data.frame(xmin, ymin, xmax, ymax, stringsAsFactors=FALSE)
    
    spatial_metadata$dynamic_metadata_count_features <-SQL$dynamic_metadata_count_features
    
    spatial_metadata$geographic_identifier="Mauritius" # => @julien à changer
    
    spatial_metadata$Spatial_resolution<-NULL
    spatial_metadata$SpatialRepresentationType <- "vector"
    spatial_metadata$GeometricObjectType="surface"
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements to describe the SPATIAL COVERAGE AND RELATED GEOGRAPHIC OBJECTS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    temporal_metadata <-NULL
    Temporal_Coverage  <- as.character(SQL$dynamic_metadata_temporal_Extent)
    Temporal_Coverage
    # Temporal_Coverage <- "start=2018:01:02 15:58:48Z;end=2018:01:02 16:58:48Z"
    Temporal_Coverage <- strsplit(Temporal_Coverage, split = ";")
    start_date <- as.POSIXct(gsub("start=", "", Temporal_Coverage[[1]][1]),format='%Y-%m-%d %H:%M:%S',tz="Z")
    end_date <- as.POSIXct(gsub("end=", "", Temporal_Coverage[[1]][2]),format='%Y-%m-%d %H:%M:%S',tz="Z")
    dynamic_metadata_temporal_Extent <- data.frame(start_date, end_date, stringsAsFactors=FALSE)
    temporal_metadata$dynamic_metadata_temporal_Extent <- dynamic_metadata_temporal_Extent
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the CONTACTS AND ROLES")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    all_contacts <- Dublin_Core_metadata$contacts_and_roles[i]
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
    contacts_roles <- data.frame(contact=contact_email, RoleCode=contact_role, dataset=metadata$Identifier,stringsAsFactors=FALSE)
    contacts_metadata$contacts_roles <- contacts_roles
    
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the CONTROLLED VOCABULARIES: KEYWORDS AND THESAURUS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    metadata$Subject <- Dublin_Core_metadata$subject[i]
    # static_keywords<-NULL
    keywords_metadata<-return_keywords_and_thesaurus_as_data_frame(metadata$Subject)
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the DCMI RELATION (OGC ONLINE RESOURCES)")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    #Online Resources
    #----------------
    
    metadata$Relation  <- Dublin_Core_metadata$relation[i]
    Relation <- metadata$Relation # to be done => should be a URL and used to list identifiers of other related reources.
    urls_metadata <- NULL
    http_urls <- NULL
    http_URLs_links=NULL
    http_URLs_names=NULL
    http_URLs_descriptions=NULL
    http_URLs_protocols=NULL
    http_URLs_functions=NULL
    http_urls <-data.frame(http_URLs_links = character(), http_URLs_names = character(),http_URLs_descriptions = character(),http_URLs_protocols = character(), http_URLs_functions = character(),stringsAsFactors=FALSE)
    
    
    logger.info("Add the thumbnail generated by geoserver (requires WMS to be set up)")
    # http://geoserver-sdi-lab.d4science.org/geoserver/RTTP_workspace/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&FORMAT=image%2Fpng&TRANSPARENT=true&QUERY_LAYERS=RTTP_workspace%3Arttp_released_tagged_tuna&STYLES&LAYERS=RTTP_workspace%3Arttp_released_tagged_tuna&INFO_FORMAT=text%2Fhtml&FEATURE_COUNT=50&X=50&Y=50&SRS=EPSG%3A4326&WIDTH=101&HEIGHT=101&BBOX=42.95654296875%2C-17.02880859375%2C47.39501953125%2C-12.59033203125
    wms_url <-paste(config$sdi$geoserver$url, config$sdi$geoserver$workspace, "wms?", sep="/")
    wms_layer<-paste0(config$sdi$geoserver$workspace,":",metadata$Identifier)
    thumbnail <-paste(wms_url,"service=WMS&version=1.1.1&request=GetMap&layers=",config$sdi$geoserver$workspace,":world,",wms_layer,"&bbox=",spatial_metadata$dynamic_metadata_spatial_Extent$xmin,",",spatial_metadata$dynamic_metadata_spatial_Extent$ymin,",",spatial_metadata$dynamic_metadata_spatial_Extent$xmax,",",spatial_metadata$dynamic_metadata_spatial_Extent$ymax,"&TRANSPARENT=true&width=768&height=768&srs=EPSG:4326&format=image/png",sep="")
    http_urls[nrow(http_urls)+1,] <- c(thumbnail, "thumbnail","Thumbnail from WMS / Geoserver", "WWW:LINK-1.0-http--link","image/png")
    http_urls[nrow(http_urls)+1,] <- c(wms_url,wms_layer,"Visualize maps from WMS (Web Map Service) - see service/operation metadata for guidance to use query parameters","OGC:WMS-1.3.0-http-get-map","download")
    
    logger.info("Add the links to get the metadata as HTML and XML sheet")
    md_xml_csw <- paste0(config$sdi$geonetwork$url,"/srv/eng/csw?service=CSW&request=GetRecordById&Version=2.0.2&elementSetName=full&outputSchema=http%3A//www.isotc211.org/2005/gmd&id=",metadata$Permanent_Identifier)
    md_html_GN <- sprintf("%s/srv/en/main.home?uuid=%s",config$sdi$geonetwork$url, metadata$Permanent_Identifier)
    http_urls[nrow(http_urls)+1,] <- c(md_html_GN, "OGC metadata: HTML view in Geonetwork","Visualize metadata HTML view in Geonetwork", "WWW:LINK-1.0-http--link","search")
    http_urls[nrow(http_urls)+1,] <- c(md_xml_csw, "OGC metadata: XML view from CSW server","OGC metadata: XML view from CSW server", "WWW:LINK-1.0-http--link","search")
    
    logger.info("Add the URLs listed in 'Relation' column of the 'metadata' table")
    list_Relation <- strsplit(as.character(Relation), split = "\n")
    for(relation in list_Relation[[1]]){
      split_Relation <- strsplit(relation, split = "@")
      http_URLs_links <- split_Relation[[1]][2]
      http_URLs_names <- split_Relation[[1]][1]
      if(http_URLs_names=="thumbnail"){
        http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, "thumbnail","Aperçu", "WWW:LINK-1.0-http--link","image/png")
      }else{
        http_URLs_descriptions <- split_Relation[[1]][1]
        http_URLs_protocols  <- "WWW:LINK-1.0-http--link"
        http_URLs_functions <- "donwload"
        http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, http_URLs_names,http_URLs_descriptions,http_URLs_protocols, http_URLs_functions)
      }
    }
    
    logger.info("Look if the CSV file is available in the Worspace and get the URL")
    CsvFileName<-paste(metadata$Identifier,".zip",sep="")
    virtual_repository_with_csv_files <- config$gcube$repositories$csv
    remoteCsvFile<-paste(virtual_repository_with_csv_files, CsvFileName, sep="/")
    csvFileURL<-getPublicFileLinkWS(remoteCsvFile)
    
    logger.info("Add the URL of the CSV file if available with http")
    if(startsWith(csvFileURL,"http://") | startsWith(csvFileURL,"https://")){
      http_urls[nrow(http_urls)+1,] <- c(csvFileURL, "Dataset as CSV","Download the dataset and metadata in CSV format","WWW:LINK-1.0-http--link","download")
    }
    
    urls_metadata$http_urls <- http_urls
    
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Workflow step 4: ISO Metadata (19115 & 19119 TOGETHER, 19110 SEPARATELY) generation & publication")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    if(config$actions$metadata_iso_19115){
      
      logger.info("Generating/Publishing ISO 19115 metadata...")
      ogc_metatada_sheet <- write_metadata_OGC_19115_from_Dublin_Core(config=config,
                                                                      metadata=metadata,
                                                                      contacts_metadata=contacts_metadata,
                                                                      spatial_metadata=spatial_metadata,
                                                                      temporal_metadata=temporal_metadata,
                                                                      keywords_metadata=keywords_metadata,
                                                                      urls_metadata=urls_metadata
      )
      
      logger.info(sprintf("...ISO/OGC 19115 metadata for dataset with permanent id '%s' has been created!", metadata$Permanent_Identifier))
      logger.info("Saving ISO/OGC XML metadata (ISO 19115) file to R job working directory")
      metatada_sheet_xml <- ogc_metatada_sheet$encode()
      xml_file_name <- paste(metadata$Identifier,".xml",sep="")
      metadata_wd <- paste(config$wd,"/jobs/", jobDir, "/metadata/",xml_file_name, sep="")
      # setwd(metadata_wd)
      setwd(file.path(getwd(), "metadata"))
      saveXML(metatada_sheet_xml, file = xml_file_name)
      logger.info(sprintf("ISO/OGC 19139 XML metadata (ISO 19115) file '%s' has been created!", xml_file_name))
      setwd("..")

      
      if(config$actions$geonetwork_publication){
        logger.info("Publishing ISO/OGC XML metadata file in Geonetwork")
        metadata_URL <- push_metadata_in_geonetwork(config, metadata$Identifier, ogc_metatada_sheet)
        logger.info(sprintf("URL ?", metadata_URL))
        logger.info(sprintf("ISO/OGC 19139 XML metadata (ISO 19115) file '%s' has been published!", xml_file_name))
      } else if (config$actions$`CSW-T_publication`){
        logger.info("Publishing ISO/OGC XML metadata file in CSW-T server")
        metadata_URL <- push_metadata_in_csw_server(config, ogc_metatada_sheet)
        logger.info(sprintf("Publication via CSW-T => ", metadata_URL))
      }
      
      
    } else {
      logger.warn("METADATA ISO/OGC 19115 generation/publication DISABLED")
    }
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Workflow step 4 BIS : EML Metadata")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    if(config$actions$write_metadata_EML){
      EML_metatada_sheet <- write_EML_metadata_from_Dublin_Core(config=config,
                                                                metadata=metadata,
                                                                contacts_metadata=contacts_metadata,
                                                                spatial_metadata=spatial_metadata,
                                                                temporal_metadata=temporal_metadata,
                                                                keywords_metadata=keywords_metadata,
                                                                urls_metadata=urls_metadata
      )
      logger.info(sprintf("EML metadata for dataset with permanent id '%s' has been created!", metadata$Permanent_Identifier))
      filename <-paste("metadata_eml_", metadata$Permanent_Identifier,"_eml.xml", sep="")
      
      
      setwd(file.path(getwd(), "metadata"))
      write_eml(EML_metatada_sheet, filename)
      eml_validate(filename)
      setwd("..")
      logger.info(sprintf("EML metadata '%s' has been created!", xml_file_name))
      
      
    }
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Workflow step 4 BIS : OGC WMS / WFS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    if (config$actions$data_wms_wfs){
      logger.info("DATA publication to OGC WMS/WFS services (Geoserver)...")
      published<-write_data_access_OGC_WMS_WFS(config=config,
                                               metadata=metadata,
                                               SQL=SQL,
                                               spatial_metadata=spatial_metadata,
                                               keywords_metadata=keywords_metadata)
      if(published){
        logger.info("DATA WMS/WFS successfull publication!")
      }else{ 
        logger.error("Error during DATA WMS/WFS publication")
      }
      
    }else{
      logger.warn("DATA publication to OGC WMS/WFS service (GeoServer) DISABLED")
    }
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Workflow step 4 BIS : WRITE CSV FILES")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    if (config$actions$data_csv){
      logger.info("Writing CSV dataset in the WS...")
      csvFileURL<-write_datasets_in_CSV_files(config=config,metadata=metadata,SQL=SQL)
      logger.info(sprintf("CSV for file '%s' has been created and uploaded!", csvFileURL))
      ## Add the URL in the online ressouces
      # if (!(csvFileURL %in% urls_metadata$http_urls$http_URLs_links)){
      #   http_urls[nrow(http_urls)+1,] <- c(csvFileURL, "Dataset as CSV","Download the dataset and metadata in CSV format","WWW:LINK-1.0-http--link","download")
      #   # make this ressource (the last) the first so that it appears as first on the catalogue
      #   http_urls<-rbind(http_urls[nrow(http_urls),],http_urls[1:nrow(http_urls)-1,])
      #   urls_metadata$http_urls <- http_urls
      # }
    } else {
      logger.warn("CSV Dataset generation/publication DISABLED")
    }
  }
  logger.warn("ALL METADATA ISO/OGC 19115 have been created for the Postgres database and related metadata table")
}

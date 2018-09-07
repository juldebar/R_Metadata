write_Dublin_Core_metadata <- function(config, source){
  
  #config shortcuts
  con <- config$db$con
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  google_sheet_contacts <- config$gsheetUrls$contacts
  google_sheet_Dublin_Core <- config$gsheetUrls$dublin_core_gsheet
  
  contacts <- as.data.frame(gsheet::gsheet2tbl(google_sheet_contacts))
  Dublin_Core_metadata <- as.data.frame(gsheet::gsheet2tbl(google_sheet_Dublin_Core))
  
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Workflow Google doc: browse the doc & iterate for each line")
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  
  
  number_row<-nrow(Dublin_Core_metadata)
  for (i in 1:number_row) {
    metadata <- NULL
    metadata <- Dublin_Core_metadata[i,]
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Dublin Core Metadata elements")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    metadata$Identifier  <- Dublin_Core_metadata$Identifier[i]# if(is.na(metadata$Identifier)){metadata$Identifier="TITLE AND DATASET NAME TO BE FILLED !!"}
    metadata$Title  <- Dublin_Core_metadata$Title[i]
    metadata$Description <- Dublin_Core_metadata$Description[i]
    metadata$Date  <- Dublin_Core_metadata$Date[i]
    metadata$Type  <- Dublin_Core_metadata$Type[i]
    metadata$Format  <- Dublin_Core_metadata$Format[i]
    metadata$Language  <- Dublin_Core_metadata$Language[i]
    metadata$Lineage  <- Dublin_Core_metadata$Provenance[i]
    metadata$Rights  <- Dublin_Core_metadata$Rights[i]
    #complex metadata elements
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    metadata$Permanent_Identifier  <- Dublin_Core_metadata$Identifier[i]
    metadata$addHierarchyLevel <- "dataset" # @jbarde should be use to distinguish database / datasets....
    metadata$Dataset_Type  <- "google_doc" # @jbarde => we should define a proper typology of datasets same as "file type" ?
    metadata$Purpose <- "describe Purpose"
    metadata$Update_frequency <- "annually" # TO BE DONE PROPERLY
    metadata$dataset_access_query <- NULL # @jbarde => Needed to load and browse the data itself (can be SQL query / http or OPeNDAP ACCESS)
    metadata$Credits <- NULL # Credits=NULL # @jbarde should be added ?
    metadata$Parent_Metadata_Identifier  <- NULL
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements to describe the SPATIAL COVERAGE AND RELATED GEOGRAPHIC OBJECTS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    spatial_metadata <-NULL
    spatial_metadata$SRID<-"4326"
    spatial_extent=readWKT(Dublin_Core_metadata$Spatial_Coverage[i])
    xmin <- spatial_extent@bbox[1,1]
    xmax <- spatial_extent@bbox[1,2]
    ymin <- spatial_extent@bbox[2,1]
    ymax <- spatial_extent@bbox[2,2]
    spatial_metadata$dynamic_metadata_spatial_Extent <- data.frame(xmin, ymin, xmax, ymax, stringsAsFactors=FALSE)
    spatial_metadata$dynamic_metadata_count_features <-NULL
    spatial_metadata$geographic_identifier="Mauritius"
    spatial_metadata$Spatial_resolution<-NULL
    spatial_metadata$SpatialRepresentationType <- "vector"
    spatial_metadata$GeometricObjectType="surface"
    # Thumbnail_WMS=paste("http://129.206.228.72/cached/osm?LAYERS=osm_auto:all&STYLES=&SRS=EPSG%3A4326&FORMAT=image%2Fpng&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&BBOX=",xmin,",",ymin,",",xmax,",",ymax,"&WIDTH=256&HEIGHT=256")
    Thumbnail_WMS=paste("https://geoserver-tunaatlas.d4science.org/geoserver/wms?service=WMS&version=1.3.0&request=GetMap&layers=tunaatlas:bathymetry,tunaatlas:continent&styles=&BBOX=",ymin-0.2,",",xmin-0.2,",",ymax+0.2,",",xmax+0.2,"&width=768&height=768&srs=EPSG:4326&format=image/png",sep="")
    
    
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Additionnal Metadata elements to describe the SPATIAL COVERAGE AND RELATED GEOGRAPHIC OBJECTS")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    Temporal_Coverage  <- Dublin_Core_metadata$Temporal_Coverage[i]
    temporal_metadata <-NULL
    Temporal_Coverage <- strsplit(metadata$Temporal_Coverage, split = ";")
    start_date <- as.POSIXct(gsub("start=", "", Temporal_Coverage[[1]][1]),format='%Y')
    end_date <- as.POSIXct(gsub("end=", "", Temporal_Coverage[[1]][2]),format='%Y')
    dynamic_metadata_temporal_Extent <- data.frame(start_date, end_date, stringsAsFactors=FALSE)
    dynamic_metadata_temporal_Extent <- data.frame(start_date, end_date, stringsAsFactors=FALSE)
    temporal_metadata$dynamic_metadata_temporal_Extent <- dynamic_metadata_temporal_Extent
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the CONTACTS AND ROLES")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    all_contacts <- Dublin_Core_metadata$Creator[i]
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
    
    metadata$Subject  <- Dublin_Core_metadata$Subject[i]
    keywords_metadata <-NULL
    all_keywords <-NULL
    static_keywords<-NULL
    list_of_keywords <- metadata$Subject
    list_of_keywords <- gsub("GENERAL=", "", list_of_keywords)
    thesaurus <- c("AGROVOC")
    list_keywords <- strsplit(as.character(list_of_keywords), split = ", ")
    list_keywords <- unlist(list_keywords)
    all_keywords <-data.frame(keyword=list_keywords, thesaurus=thesaurus, stringsAsFactors=FALSE)
    keywords_metadata$all_keywords <- all_keywords
    TopicCategory <- c("biota", "oceans", "environment", "geoscientificInformation","economy")
    keywords_metadata$TopicCategory <- TopicCategory
    
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Set Metadata elements to describe the DCMI RELATION (OGC ONLINE RESOURCES)")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    #Online Resources
    #----------------
    
    metadata$Relation  <- Dublin_Core_metadata$Relation[i]
    Relation <- metadata$Relation # to be done => should be a URL and used to list identifiers of other related reources.
    urls_metadata <- NULL
    http_urls <- NULL
    http_URLs_links=NULL
    http_URLs_names=NULL
    http_URLs_descriptions=NULL
    http_URLs_protocols=NULL
    http_URLs_functions=NULL
    http_urls <-data.frame(http_URLs_links = character(), http_URLs_names = character(),http_URLs_descriptions = character(),http_URLs_protocols = character(), http_URLs_functions = character(),stringsAsFactors=FALSE)
    
    #Add default links to metadata (HTML and XML sheets)
    md_xml_csw <- paste0(config$sdi$geonetwork$url,"/srv/eng/csw?service=CSW&request=GetRecordById&Version=2.0.2&elementSetName=full&outputSchema=http%3A//www.isotc211.org/2005/gmd&id=",metadata$Permanent_Identifier)
    md_html_GN <- sprintf("%s/srv/en/main.home?uuid=%s",config$sdi$geonetwork$url, metadata$Permanent_Identifier)
    http_urls[nrow(http_urls)+1,] <- c(md_html_GN, "OGC metadata: HTML view in Geonetwork","Visualize metadata HTML view in Geonetwork", "WWW:LINK-1.0-http--link","search")
    http_urls[nrow(http_urls)+1,] <- c(md_xml_csw, "OGC metadata: XML view from CSW server","OGC metadata: XML view from CSW server", "WWW:LINK-1.0-http--link","search")
    # http_urls[nrow(http_urls)+1,] <- c(Thumbnail_WMS, "thumbnail","thumbnail", "WWW:LINK-1.0-http--link","search")
    
    #Add as many links as stored in the google doc "Relation" column
    list_Relation <- strsplit(as.character(Relation), split = "\n")
    for(relation in list_Relation[[1]]){
      split_Relation <- strsplit(relation, split = "@")
      http_URLs_links <- split_Relation[[1]][2]
      http_URLs_names <- split_Relation[[1]][1]
      if(http_URLs_names=="thumbnail"){
        http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, "thumbnail","Aperçu", "WWW:LINK-1.0-http--link","image/png")
      } else{
        http_URLs_descriptions <- split_Relation[[1]][1]
        http_URLs_protocols  <- "WWW:LINK-1.0-http--link"
        http_URLs_functions <- "donwload"
        http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, http_URLs_names,http_URLs_descriptions,http_URLs_protocols, http_URLs_functions)
      }
    }
    urls_metadata$http_urls <- http_urls
    
    
    
    
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    logger.info("Workflow step 4: ISO Metadata (19115 & 19119 TOGETHER, 19110 SEPARATELY) generation & publication")
    logger.info("-------------------------------------------------------------------------------------------------------------------")
    
    #ISO 19115
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
      
      setwd(file.path(getwd(), "metadata"))
      saveXML(metatada_sheet_xml, file = xml_file_name)
      logger.info(sprintf("ISO/OGC 19139 XML metadata (ISO 19115) file '%s' has been created!", xml_file_name))
      setwd("..")
      
      #Publication to Geonetwork
      logger.info("Publishing ISO/OGC XML metadata file to Geonetwork")
      metadata_URL <- push_metadata_in_geonetwork(config, metadata$Identifier, ogc_metatada_sheet)
      logger.info(sprintf("URL ?", metadata_URL))
      
      # push_metadata_in_csw_server(config, ogc_metatada_sheet)
      logger.info(sprintf("ISO/OGC 19139 XML metadata (ISO 19115) file '%s' has been published!", xml_file_name))
      
    } else {
      logger.warn("METADATA ISO/OGC 19115 generation/publication DISABLED")
    }
    
  }
  logger.warn("ALL METADATA ISO/OGC 19115 have been created for the google doc")
}
# https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_google_doc_Dublin_Core/scripts/write_R_metadata_from_OGC.R
write_R_metadata_from_OGC <- function(config = NULL,
                                      OGC_metadata = "/home/julien/Bureau/CODES/R_Metadata/metadata_workflow_google_doc_Dublin_Core/jobs/20190124-074759-julien.barde/metadata/template_sampling_area_and_stations.xml"
                                      )
{
  #config shortcuts
  contacts <- config$gsheets$contacts
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  
  logger.info("----------------------------------------------------")  
  logger.info("Geometa : read OGC metadata")  
  logger.info("----------------------------------------------------")  
  
  xml <- xmlParse(OGC_metadata)
  md <- ISOMetadata$new(xml = xml)
  
  logger.info("----------------------------------------------------")  
  logger.info("Geometa : mapping with R metadata")  
  logger.info("----------------------------------------------------")  
  
  R_metadata <- NULL
  metadata <- NULL
  metadata$Identifier  <-   md$identificationInfo[[1]]$citation$identifier$code
  metadata$Permanent_Identifier  <-   md$identificationInfo[[1]]$citation$identifier$code
  metadata$Title  <-  md$identificationInfo[[1]]$citation$title
  metadata$Description <- md$identificationInfo[[1]]$abstract
  metadata$Date  <- md$identificationInfo[[1]]$citation$date[[1]]$date
  metadata$Type  <- md$hierarchyLevel[[1]]$value
  metadata$addHierarchyLevel <- md$hierarchyLevel[[1]]$value
  if(md$identificationInfo[[1]]$language[[1]]$valueDescription=="French"){metadata$Language="fra"}
  #   metadata$Format  <- Dublin_Core_metadata$Format[i]
  
  metadata$Lineage  <- "TBD properly"
#   metadata$Rights  <- Dublin_Core_metadata$Rights[i]
  
  metadata$Dataset_Type  <- "google_doc" # @jbarde => we should define a proper typology of datasets same as "file type" ?
  
  # metadata$Purpose <- "describe Purpose"
  # metadata$Update_frequency <- "annually" # TO BE DONE PROPERLY
  # metadata$dataset_access_query <- NULL # @jbarde => Needed to load and browse the data itself (can be SQL query / http or OPeNDAP ACCESS)
  # metadata$Credits <- NULL # Credits=NULL # @jbarde should be added ?
  # metadata$Parent_Metadata_Identifier  <- NULL
  
  
  metadata
  R_metadata$metadata <-metadata
  
  logger.info("----------------------------------------------------")  
  logger.info("Data frame for thesaurus & keywords")  
  logger.info("----------------------------------------------------")  
  
  keywords_metadata <-NULL
  thesaurus <-NULL
  all_keywords <-NULL
  all_keywords <-data.frame(keyword = character(), thesaurus = character(),stringsAsFactors=FALSE)
  
  for(i in 1:length(md$identificationInfo[[1]]$descriptiveKeywords)){
    thesaurusName <- md$identificationInfo[[1]]$descriptiveKeywords[[i]]$thesaurusName$title
    keywords <- md$identificationInfo[[1]]$descriptiveKeywords[[i]]$keyword
    for (k in keywords){
      all_keywords[nrow(all_keywords)+1,] <- c(k, thesaurusName)
    }
    keywords_metadata$all_keywords <- all_keywords
    # TopicCategory <- c("biota", "oceans", "environment", "geoscientificInformation","economy")
    # keywords_metadata$TopicCategory <- TopicCategory
  }
  
  keywords_metadata
  R_metadata$keywords_metadata <-keywords_metadata
  
  logger.info("----------------------------------------------------")  
  logger.info("Data frame for spatial extent")  
  logger.info("----------------------------------------------------")  
  
  spatial_metadata <-NULL
  spatial_metadata$SRID<-md$referenceSystemInfo[[1]]$referenceSystemIdentifier$code
  xmin <- md$identificationInfo[[1]]$extent[[1]]$geographicElement[[1]]$eastBoundLongitude[1]
  xmax <- md$identificationInfo[[1]]$extent[[1]]$geographicElement[[1]]$westBoundLongitude[1]
  ymin <- md$identificationInfo[[1]]$extent[[1]]$geographicElement[[1]]$southBoundLatitude[1]
  ymax <- md$identificationInfo[[1]]$extent[[1]]$geographicElement[[1]]$northBoundLatitude[1]
  spatial_metadata$dynamic_metadata_spatial_Extent <- data.frame(xmin, ymin, xmax, ymax, stringsAsFactors=FALSE)
  spatial_metadata$Spatial_resolution<-NULL
  if(class(md$spatialRepresentationInfo[[1]])[1]=='ISOVectorSpatialRepresentation'){
    spatial_metadata$SpatialRepresentationType <- "vector"
    spatial_metadata$GeometricObjectType=md$spatialRepresentationInfo[[1]]$geometricObjects[[1]]$geometricObjectType$value
  }
  # spatial_metadata$dynamic_metadata_count_features <-NULL
  # spatial_metadata$geographic_identifier="Mauritius"
  
  
  spatial_metadata
  R_metadata$spatial_metadata <-spatial_metadata
  
  logger.info("----------------------------------------------------")  
  logger.info("Data frame for temporal extent")  
  logger.info("----------------------------------------------------")  
  
  temporal_metadata <-NULL
  start_date <- as.POSIXct(md$identificationInfo[[1]]$extent[[1]]$temporalElement[[1]]$extent$beginPosition$value,format='%Y')
  end_date <- as.POSIXct(md$identificationInfo[[1]]$extent[[1]]$temporalElement[[1]]$extent$endPosition$value,format='%Y')
  dynamic_metadata_temporal_Extent <- data.frame(start_date, end_date, stringsAsFactors=FALSE)
  temporal_metadata$dynamic_metadata_temporal_Extent <- dynamic_metadata_temporal_Extent
  
  temporal_metadata
  R_metadata$temporal_metadata <-temporal_metadata
  
  logger.info("----------------------------------------------------")  
  logger.info("Data frame for contacts")  
  logger.info("----------------------------------------------------")  
  
  contacts_metadata <-NULL
  contacts <-NULL
  contacts <-data.frame(electronicMailAddress = character(),
                        organisationName = character(),
                        positionName = character(),  
                        Name = character(), 
                        firstname= character(),
                        deliveryPoint = character(), 
                        city = character(),  
                        administrativeArea = character(), 
                        postalCode = character(),  
                        country = character(), 
                        voice = character(),  
                        facsimile = character(), 
                        setNameISOOnlineResource = character(), 
                        ISOOnlineResource = character(), 
                        stringsAsFactors=FALSE)
  # for(contact in md$identificationInfo[[1]]$citation$citedResponsibleParty){
  
  the_contact <- md$identificationInfo[[1]]$citation$citedResponsibleParty
  contact_role <- the_contact$role$value
  electronicMailAddress <- the_contact$contactInfo$address$electronicMailAddress
  Name <- the_contact$individualName
  firstname <- the_contact$individualName
  organisationName <- the_contact$organisationName
  positionName<- the_contact$positionName
  deliveryPoint <- the_contact$contactInfo$address$deliveryPoint
  city <- the_contact$contactInfo$address$city
  if(is.null(the_contact$contactInfo$address$administrativeArea)==FALSE){administrativeArea <- the_contact$contactInfo$address$administrativeArea}else{administrativeArea <- "-"}
  postalCode <- the_contact$contactInfo$address$postalCode
  country <- the_contact$contactInfo$address$country
  voice <- the_contact$contactInfo$phone$voice
  if(length(the_contact$contactInfo$phone$facsimile)==0){facsimile <- "-"}else{facsimile <- the_contact$contactInfo$phone$facsimile}
  setNameISOOnlineResource <- the_contact$contactInfo$onlineResource$name
  ISOOnlineResource <- the_contact$contactInfo$onlineResource$linkage$value
  
  # }
  contacts[nrow(contacts)+1,] <- c(electronicMailAddress = electronicMailAddress, 
                                   organisationName = organisationName,
                                   positionName=positionName,
                                   Name=Name,
                                   firstname=firstname,
                                   deliveryPoint=deliveryPoint,
                                   city=city,
                                   administrativeArea=administrativeArea,
                                   postalCode=postalCode,
                                   country=country,
                                   voice=voice,
                                   facsimile=facsimile,
                                   setNameISOOnlineResource=setNameISOOnlineResource,
                                   ISOOnlineResource=ISOOnlineResource)
  
  contacts
    
  contacts_roles <- data.frame(contact=electronicMailAddress, RoleCode=contact_role, dataset=metadata$Identifier,stringsAsFactors=FALSE)
  contacts_metadata$contacts_roles <- contacts_roles
  
  R_metadata$contacts_metadata <-contacts_metadata
  
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Data frame for Relation / References")  
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  
  urls_metadata <- NULL
  http_urls <- NULL
  http_urls <-data.frame(http_URLs_links = character(), 
                         http_URLs_names = character(),
                         http_URLs_descriptions = character(),
                         http_URLs_protocols = character(), 
                         http_URLs_functions = character(),
                         stringsAsFactors=FALSE)
  
  # md$distributionInfo$transferOptions$onLine
  
  for (u in 1:length(md$distributionInfo$transferOptions$onLine)){
    this_link <- md$distributionInfo$transferOptions$onLine[[u]]
    if(class(this_link$linkage)[1]=='ISOURL'){
      http_URLs_links <- this_link$linkage$value
      http_URLs_names <- this_link$name
      http_URLs_descriptions <- this_link$description
      http_URLs_protocols <- this_link$protocol
      http_URLs_functions <- "donwload"
      http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, http_URLs_names,http_URLs_descriptions,http_URLs_protocols,http_URLs_functions)
    }
  }
  ######################################### A FAIRE => GERER LES APERCUS  ######################################### 
  http_urls
  urls_metadata$http_urls <- http_urls
  R_metadata$urls_metadata <-urls_metadata
  
  return(R_metadata)
  
#   contacts_metadata
#   spatial_metadata
#   temporal_metadata
#   keywords_metadata
#   urls_metadata
}



######################################################################################################################################################################
########################################################### TEST DE LA FONCTION POUR REECRIRE LA METADONNEE OGC d'origine##################################################################################
######################################################################################################################################################################

toto <- write_R_metadata_from_OGC(config=CFG)


ogc_metatada_sheet <- write_metadata_OGC_19115_from_Dublin_Core(config=config,
                                                                metadata=toto$metadata,
                                                                contacts_metadata=toto$contacts_metadata,
                                                                spatial_metadata=toto$spatial_metadata,
                                                                temporal_metadata=toto$temporal_metadata,
                                                                keywords_metadata=toto$keywords_metadata,
                                                                urls_metadata=toto$urls_metadata
)
# config=config
# metadata=toto$metadata
# contacts_metadata=toto$contacts_metadata
# spatial_metadata=toto$spatial_metadata
# temporal_metadata=toto$temporal_metadata
# keywords_metadata=toto$keywords_metadata
# urls_metadata=toto$urls_metadata
ogc_metatada_sheet

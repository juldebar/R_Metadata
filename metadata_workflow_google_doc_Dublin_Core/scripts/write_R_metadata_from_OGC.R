#https://github.com/eblondel/zen4R/wiki
write_zenodo_metadata_from_Dublin_Core <- function(config = NULL,
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
  
  metadata <- NULL
  # metadata$Identifier  <- Dublin_Core_metadata$Identifier[i]
  metadata$Title  <-  md$identificationInfo[[1]]$citation$title
  metadata$Description <- md$identificationInfo[[1]]$abstract
  # metadata$Date  <- md$identificationInfo[[1]]$citation$date
#   metadata$Type  <- Dublin_Core_metadata$Type[i]
#   metadata$Format  <- Dublin_Core_metadata$Format[i]
#   metadata$Language  <- Dublin_Core_metadata$Language[i]
#   metadata$Lineage  <- Dublin_Core_metadata$Provenance[i]
#   metadata$Rights  <- Dublin_Core_metadata$Rights[i]
  
  
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
  
  
  logger.info("----------------------------------------------------")  
  logger.info("Data frame for temporal extent")  
  logger.info("----------------------------------------------------")  
  
  temporal_metadata <-NULL
  start_date <- as.POSIXct(md$identificationInfo[[1]]$extent[[1]]$temporalElement[[1]]$extent$beginPosition$value,format='%Y')
  end_date <- as.POSIXct(md$identificationInfo[[1]]$extent[[1]]$temporalElement[[1]]$extent$endPosition$value,format='%Y')
  dynamic_metadata_temporal_Extent <- data.frame(start_date, end_date, stringsAsFactors=FALSE)
  temporal_metadata$dynamic_metadata_temporal_Extent <- dynamic_metadata_temporal_Extent
  temporal_metadata
  
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
    
    
  contacts_roles <- data.frame(contact=contact_email, RoleCode=contact_role, dataset=metadata$Identifier,stringsAsFactors=FALSE)
  contacts_metadata$contacts_roles <- contacts_roles
  
  
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  logger.info("Data frame for Relation / References")  
  logger.info("-------------------------------------------------------------------------------------------------------------------")
  
  Relation <- metadata$Relation # to be done => should be a URL and used to list identifiers of other related reources.
  urls_metadata <- NULL
  http_urls <- NULL
  http_urls <-data.frame(http_URLs_links = character(), http_URLs_names = character(),http_URLs_descriptions = character(),http_URLs_protocols = character(), http_URLs_functions = character(),stringsAsFactors=FALSE)
  http_URLs_links=NULL
  http_URLs_names=NULL
  http_URLs_descriptions=NULL
  http_URLs_protocols=NULL
  http_URLs_functions=NULL
  
  
    
  return(metadata)
  
#   contacts_metadata
#   spatial_metadata
#   temporal_metadata
#   keywords_metadata
#   urls_metadata
}

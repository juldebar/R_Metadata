
return_keywords_and_thesaurus_as_data_frame <- function(all_subjects){
  
  keywords_metadata <-NULL
  thesaurus <-NULL
  all_keywords <-NULL
  all_keywords <-data.frame(keyword = character(), thesaurus = character(),stringsAsFactors=FALSE)
  
  list_subjects <- strsplit(as.character(all_subjects), split = "\n")
  
  for(subjects in list_subjects[[1]]){
    cat(subjects)
    # subjects=list_subjects[[1]][1]
    cat("\n")
    split_subjects <- strsplit(subjects, split = "=")
    thesaurus_name <- split_subjects[[1]][1]
    thesaurus[[length(thesaurus)+1]] <- thesaurus_name
    
    all_subjects <- split_subjects[[1]][2]
    list_keywords <- strsplit(as.character(all_subjects), split = ",")
    list_keywords <- unlist(list_keywords)
    for (k in list_keywords){
      all_keywords[nrow(all_keywords)+1,] <- c(k, thesaurus_name)
    }
    keywords_metadata$all_keywords <- all_keywords
    keywords_metadata$thesaurus <- thesaurus
    TopicCategory <- c("biota", "oceans", "environment", "geoscientificInformation","economy")
    keywords_metadata$TopicCategory <- TopicCategory
  }
  
  return(keywords_metadata)
}

################################################################################


add_contacts_and_roles_OGC_19115 <- function(config, metadata_identifier, contacts_roles, expected_role){
  
  contacts <- config$gsheets$contacts
  
  listContacts = list()
  if(is.null(contacts_roles)==FALSE){
    for(j in expected_role){
      number_row<-nrow(contacts_roles)
      for(i in 1:number_row){
        if(contacts_roles$dataset[i]==metadata_identifier & (contacts_roles$RoleCode[i]==j)){
          the_contact <- contacts[contacts$electronicMailAddress%in%contacts_roles$contact[i],]
          rp <- ISOResponsibleParty$new()
          rp$setIndividualName(paste(as.character(the_contact$Name),as.character(the_contact$firstname),sep=" "))
          rp$setIndividualName(paste(the_contact$Name,the_contact$firstname,sep=" "))
          rp$setOrganisationName(as.character(the_contact$organisationName))
          rp$setPositionName(as.character(the_contact$positionName))
          if(is.null(the_contact$setPositionName)==FALSE){
            rp$setPositionName(as.character(the_contact$setPositionName))
          }
          ###########################################################################################################     
          if (contacts_roles$RoleCode[i]=="pointOfContact"){rp$setRole("pointOfContact")}
          if (contacts_roles$RoleCode[i]=="metadata"){rp$setRole("pointOfContact")}
          if (contacts_roles$RoleCode[i]=="publisher"){rp$setRole("publisher")}
          if (contacts_roles$RoleCode[i]=="data_entry"){rp$setRole("originator")}
          if (contacts_roles$RoleCode[i]=="data_collection"){rp$setRole("resourceProvider")}
          if (contacts_roles$RoleCode[i]=="data"){rp$setRole("owner")}
          if (contacts_roles$RoleCode[i]=="owner"){rp$setRole("author")}
          if (contacts_roles$RoleCode[i]=="originator"){rp$setRole("originator")}
          if (contacts_roles$RoleCode[i]=="principalInvestigator"){rp$setRole("originator")}
          if (contacts_roles$RoleCode[i]=="data_structure_definition"){rp$setRole("processor")}
          if (grepl("processor_step",contacts_roles$RoleCode[i])){rp$setRole("processor")}
          # if (contacts_roles$RoleCode[i]=="pointOfContact"){rp$setRole("originator")}
          ###########################################################################################################      
          contact <- ISOContact$new()
          phone <- ISOTelephone$new()
          phone$setVoice(as.character(the_contact$voice))
          phone$setFacsimile(as.character(the_contact$facsimile))
          contact$setPhone(phone)
          address <- ISOAddress$new()
          address$setDeliveryPoint(as.character(the_contact$deliveryPoint))
          address$setCity(as.character(the_contact$city))
          address$setPostalCode(the_contact$postalCode)
          address$setCountry(the_contact$country)
          address$setEmail(the_contact$electronicMailAddress)
          contact$setAddress(address)
          res <- ISOOnlineResource$new()
          res$setLinkage(the_contact$ISOOnlineResource)
          res$setName(the_contact$setNameISOOnlineResource)
          contact$setOnlineResource(res)
          rp$setContactInfo(contact)
          listContacts[[length(listContacts)+1]] <- rp
          
        }
      }
    }
  }
  return(listContacts)
}


#-----------------------------------------------------------------------------------------------------
#prepareDataQualityWithLineage
#@param config
#@param lineage_statement Statement to describe the overall lineage steps sequence
#@param lineage_steps a "list" object with the step description
#@param processors an object of class "list" giving a list "ISOResponsibleParty" corresponding to the processor(s) (for the time being common to each step)
#@param dataset_integration_date date of integration used commonly for all steps. 'ISOBaseDateTime' or POSIXct/POSIXt object
#@param contacts_roles
#@returns an object of class ISODataQuality
prepareDataQualityWithLineage <- function(config, lineage_statement, lineage_steps, dataset_integration_date, 
                                          metadata_identifier, contacts_roles){
  
  dq <- ISODataQuality$new()
  scope <- ISOScope$new()
  scope$setLevel("dataset")
  dq$setScope(scope)
  
  #add lineage 
  lineage <- ISOLineage$new()
  lineage$setStatement(lineage_statement)
  
  #add processing steps
  stepNb <- 1
  for(step in lineage_steps){
    ps <- ISOProcessStep$new()
    ps$setDescription(sprintf("Step %s - %s", stepNb, step))
    ps$setDateTime(dataset_integration_date)
    #TODO
    role=paste("processor_step",stepNb,sep="")
    expected_role=c(role)
    processors <- add_contacts_and_roles_OGC_19115(config, metadata_identifier, contacts_roles, expected_role)
    for(processor in processors){
      ps$addProcessor(processor)
    }
    lineage$addProcessStep(ps)
    stepNb <- stepNb+1
  }
  
  #process step N: Data Publication in metadata Catalogue
  psN <- ISOProcessStep$new()
  psN$setDescription(sprintf("Step %s - Data Publication in metadata catalogue", stepNb))
  psN$setDateTime(Sys.time())
  #ONLY ONE PROCESSOR IN THIS CASE
  expected_role=c("data_structure_definition")
  processor <- add_contacts_and_roles_OGC_19115(config, metadata_identifier, contacts_roles, expected_role)
  #do we need a processor when there is no data_structure_definition? ie when it's not a detailed dataset, or a dataset not compliant with FDI
  if(length(processor)>0){psN$addProcessor(processor[[1]])}
  lineage$addProcessStep(psN)
  
  dq$setLineage(lineage)
  return(dq)
}


#-----------------------------------------------------------------------------------------------------
#extractLineage
#@param lineage Lineage information as string extracted from spreadsheet / metadata table in "Provenance" column
#       ("step: text1. step: text2. .... step: textN.")
#@returns an object of class "list" with the step contents
extractLineage <- function(lineage){
  lineage_steps <- as.list(unlist(strsplit(lineage, "step[0-9]:"))) #@eblondel 12/08/2017 apply regular expression to detect step nb
  lineage_steps <- lineage_steps[sapply(lineage_steps, function(x){return(nchar(x)>0)})]
  lineage_steps <- lapply(lineage_steps, function(x){
    out <- x
    if(grepl("^ ", x)) out <- substr(x, 2, nchar(x))
    if(grepl(" $", x)) out <- substr(out, nchar(out)-1, nchar(out))
    return(out)
  })
  lineage_steps <- gsub("\n", "", lineage_steps)
  return(lineage_steps)
}


#write_metadata_OGC_19115
#@returns an object metadata (OGC 19115 from geometa package)

write_metadata_OGC_19115_from_Dublin_Core <- function(config = NULL,
                                                      metadata = NULL,
                                                      contacts_metadata = NULL,
                                                      spatial_metadata = NULL,
                                                      temporal_metadata = NULL,
                                                      keywords_metadata = NULL, # DATAFRAME WITH ALL (STATIC & DYNAMIC)  KEYWORDS
                                                      urls_metadata= NULL # LIST OF DYNAMIC / COMMON URLs
)
{
  
  #config shortcuts
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  
  # OGC 19115 SECTION => Metadata entity set information 
  #-------------------------------------------------------------------------------------------------------------------
  logger.info("OGC 19115 SECTION => Metadata entity set information")  
  
  #create the ISO Metadata sheet and fill it with all required elements
  md = ISOMetadata$new()
  md$setFileIdentifier(metadata$Permanent_Identifier)
  if(is.null(metadata$Parent_Metadata_Identifier)==FALSE){md$setParentIdentifier(metadata$Parent_Metadata_Identifier)} #=> TO BE DONE NEW ??? series software service
  md$setLanguage(metadata$Language)# if metadata and resource have the same language
  md$setCharacterSet("utf8")
  # md <- ISOBaseCharacterString$new(value = "utf8") ???
  md$addHierarchyLevel(metadata$addHierarchyLevel)
  # md$setHierarchyLevelName("This datasets is the result of a query in a SQL DataWarehouse")  #  TODO MANAGE "hierarchyLevelName" metadata element @julien
  logger.info("Add the contacts and roles for this METADATA sheet")  
  expected_role=c("pointOfContact","metadata")
  listContacts <- add_contacts_and_roles_OGC_19115(config, metadata$Identifier, contacts_metadata$contacts_roles, expected_role)
  for(listContact in listContacts){
    md$addContact(listContact)
  }
  if(is.null(metadata$Date)==FALSE){
    mdDate <- metadata$Date                   
  } else {mdDate <- Sys.time()}
  md$setDateStamp(mdDate)
  md$setMetadataStandardName("ISO 19115:2003/19139")
  md$setMetadataStandardVersion("1.0")
  # md$setDataSetURI(metadata$Identifier)# @julien => use a DOI instead ?
  
  logger.info("MD_Metadata section is set")  
  
  # OGC 19115 SECTION => Metadata entity set information 
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  logger.info("OGC 19115 SECTION => Spatial Representation")
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  
  #VectorSpatialRepresentation
  
  if (!is.null(spatial_metadata$SpatialRepresentationType)){
    if (spatial_metadata$SpatialRepresentationType == "vector" ){
      VSR <- ISOVectorSpatialRepresentation$new()
      VSR$setTopologyLevel("geometryOnly")
      geomObject <- ISOGeometricObjects$new()
      geomObject$setGeometricObjectType(spatial_metadata$GeometricObjectType)
      if(is.null(spatial_metadata$dynamic_metadata_count_features)==FALSE){
        geomObject$setGeometricObjectCount(spatial_metadata$dynamic_metadata_count_features) #number of features
      }
      # VSR$setGeometricObjects(geomObject)
      VSR$addGeometricObjects(geomObject)
      # md$setSpatialRepresentationInfo(VSR)
      md$addSpatialRepresentationInfo(VSR)
    }
  }
  logger.info("SpatialRepresentation section is set !")  
  
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  logger.info("OGC 19115 SECTION => Reference System ")
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  
  # TO BE DONE MANAGE VECTOR AND RASTER
  if(is.null(spatial_metadata$SRID)==FALSE){
    RS <- ISOReferenceSystem$new()
    RSId <- ISOReferenceIdentifier$new(code = spatial_metadata$SRID[[1]], codeSpace = "EPSG")
    RS$setReferenceSystemIdentifier(RSId)
    md$setReferenceSystemInfo(RS)
  }
  logger.info("ReferenceSystem section is set !")  
  
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  logger.info("OGC 19115 SECTION => Identification Section (MD_Identification) ")  
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  
  IDENT <- ISODataIdentification$new()
  IDENT$setAbstract(metadata$Description)
  #TODO @julien @paul => ADAPT WITH THE CONTENT OF THE "DESCRIPTION" COLUMN
  # if(is.null(metadata$Purpose)==FALSE){
  # IDENT$setPurpose(metadata$Purpose)
  #   }
  # for(i in list_Credits){IDENT$addCredit(i)} # TO be done uncomment
  IDENT$setLanguage(metadata$Language)
  IDENT$setCharacterSet("utf8")
  #topic categories (one or more)
  # for(i in keywords_metadata$TopicCategory){IDENT$addTopicCategory(i)}
  
  #adding a point of contact for the identificaiton
  #organization contact
  logger.info("Write contacts and roles for Data Identification Section")  
  expected_role=c("publisher","principalInvestigator")
  listContacts <- add_contacts_and_roles_OGC_19115(config, metadata$Identifier, contacts_metadata$contacts_roles, expected_role)
  for(listContact in listContacts){
    # SERVICE$pointOfContact <- c(SERVICE$pointOfContact, serviceContact)
    IDENT$addPointOfContact(listContact)
  }
  logger.info("Contacts for IDENTIFICATION SECTION added")  
  
  ct <- ISOCitation$new()
  ct$setTitle(metadata$Title)
  d <- ISODate$new()
  d$setDate(mdDate)
  d$setDateType("revision")
  ct$addDate(d)
  ct$setEdition("1.0")
  ct$setEditionDate(as.Date(mdDate)) #EditionDate should be of Date type
  ct$setIdentifier(ISOMetaIdentifier$new(code = metadata$Permanent_Identifier)) #Julien code à vérifier
  ct$setPresentationForm("tableDigital")# @julien => mapping to be done with DCMI type ?
  
  # TODO @julien CHECK IF ADDED CONTACT IS CORRECT IN THIS CONTEXT (SHOULD NOT => LAST FROM LIST ABOVE)
  ct$setCitedResponsibleParty(listContact)
  IDENT$setCitation(ct)
  
  if(is.null(urls_metadata$http_urls)==FALSE){
    logger.info("Add list of graphic overview")
    number_row<-nrow(urls_metadata$http_urls)
    for (i in 1:number_row){
      # if (startsWith(urls_metadata$http_urls$http_URLs_names[i],"thumbnail")){
      if (grepl("thumbnail",urls_metadata$http_urls$http_URLs_names[i])){
        
        go <- ISOBrowseGraphic$new(
          fileName = urls_metadata$http_urls$http_URLs_links[i],
          fileDescription = urls_metadata$http_urls$http_URLs_descriptions[i],
          fileType = urls_metadata$http_urls$http_URLs_protocols[i]
        )
        IDENT$addGraphicOverview(go)
      }
    }
  }
  
  # Constraint information
  
  #maintenance information
  mi <- ISOMaintenanceInformation$new()
  mi$setMaintenanceFrequency(metadata$Update_frequency)
  IDENT$setResourceMaintenance(mi)
  
  #adding legal constraint(s)
  lc <- ISOLegalConstraints$new()
  lc$addUseLimitation(metadata$Rights)
  # lc$addUseLimitation("Use limitation 2 e.g. Citation guidelines")
  # lc$addUseLimitation("Use limitation 3 e.g. Disclaimer")
  # lc$addAccessConstraint("copyright")
  # lc$addAccessConstraint("license")
  # lc$addUseConstraint("copyright")
  # lc$addUseConstraint("license")
  IDENT$setResourceConstraints(lc)
  
  #adding security constraints
  # sc <- ISOSecurityConstraints$new()
  # sc$setClassification("secret")
  # sc$setUserNote("ultra secret")
  # sc$setClassificationSystem("no classification in particular")
  # sc$setHandlingDescription("description")
  # IDENT$addResourceConstraints(sc)
  
  
  # MD_Constraints
  
  logger.info("Adding SPATIAL and TEMPORAL extent")  
  extent <- ISOExtent$new()
  
  logger.info("Adding SPATIAL extent: WHERE ?")  
  spatialExtent <- ISOGeographicBoundingBox$new(minx=(spatial_metadata$dynamic_metadata_spatial_Extent$xmin-0.001),
                                                miny=(spatial_metadata$dynamic_metadata_spatial_Extent$ymin-0.001),
                                                maxx=(spatial_metadata$dynamic_metadata_spatial_Extent$xmax+0.001),
                                                maxy=(spatial_metadata$dynamic_metadata_spatial_Extent$ymax+0.001)
  ) #or use bbox parameter instead for specifying output of bbox(sp)
  extent$addGeographicElement(spatialExtent)
  logger.info("Bounding Box added!")  
  
  if(is.null(spatial_metadata$geographic_identifier)==FALSE){
    for (i in 1:length(unique(spatial_metadata$geographic_identifier))) { # to be done with emmanuel => parentidentifier instead !!!
      geographicIdentifier <- ISOGeographicDescription$new()
      geographicIdentifier$setGeographicIdentifier(ISOMetaIdentifier$new(code = spatial_metadata$geographic_identifier[i] ))
      extent$addGeographicElement(geographicIdentifier)
    }
  }
  logger.info("Geographic Identifier added!")  
  
  logger.info("Adding temporal extent: WHEN ?")  
  if(is.null(temporal_metadata$dynamic_metadata_temporal_Extent)==FALSE){
    time <- ISOTemporalExtent$new()
    start_date <- temporal_metadata$dynamic_metadata_temporal_Extent$start_date
    end_date <- temporal_metadata$dynamic_metadata_temporal_Extent$end_date
    temporalExtent <- GMLTimePeriod$new(beginPosition = start_date, endPosition = end_date)
    time$setTimePeriod(temporalExtent)
    extent$setTemporalElement(time)
  }
  IDENT$setExtent(extent)
  logger.info("Temporal extent added!")  
  
  logger.info("Adding keywords: WHAT ?")  
  
  logger.info("Adding general static keywords for this dataset")  
  #ISOKeywords" is a group of keyword, each group can get a specific thematic thesaurus (e.g. AGROVOC, GEMET, ASFIS, GEONAMES, etc)
  different_thesaurus <- unique(keywords_metadata$all_keywords$thesaurus)
  number_thesaurus<-length(unique(different_thesaurus))
  for(t in 1:number_thesaurus){
    logger.info(sprintf("Creating a new thesarus keywords set '%s'",different_thesaurus[t])) 
    if(is.null(keywords_metadata$all_keywords)==FALSE){
      dynamic_keywords <- ISOKeywords$new()
      number_row<-nrow(keywords_metadata$all_keywords)
      for (i in 1:number_row) {
        if(keywords_metadata$all_keywords$thesaurus[i]==different_thesaurus[t]){dynamic_keywords$addKeyword(keywords_metadata$all_keywords$keyword[i])}
      }
      dynamic_keywords$setKeywordType("theme") # to be done "place" for spatial Thesaurus..
      # Specifiy Thesaurus  
      th_general_keywords <- ISOCitation$new()
      th_general_keywords$setTitle(different_thesaurus[t])
      th_general_keywords$addDate(d)
      dynamic_keywords$setThesaurusName(th_general_keywords)
      IDENT$addKeywords(dynamic_keywords)
    }
  }
  
  #supplementalInformation
  IDENT$setSupplementalInformation("to add in case additional information")
  #spatial representation type
  #  TODO voir la différence avec l'autre spatial_metadata$SpatialRepresentationType
  if (!is.null(spatial_metadata$SpatialRepresentationType)){
    if (spatial_metadata$SpatialRepresentationType == "vector" ){
      IDENT$addSpatialRepresentationType(spatial_metadata$SpatialRepresentationType)
    }
  }
  
  
  md$addIdentificationInfo(IDENT)
  
  logger.info("Identification information (MD_Identification) section is set!") 
  
  
  logger.info("OGC 19115 SECTION => Identification with ISO 19119 Service Identification not managed in this case") 
  
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  logger.info("OGC 19115 SECTION => Distribution") 
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  
  
  distrib <- ISODistribution$new()
  dto <- ISODigitalTransferOptions$new()  
  
  logger.info("Select the set of URLs to be displayed as OnlineResource: add as many online resources you need (WMS, WFS, website link, etc)")  
  if(is.null(urls_metadata$http_urls)==FALSE){
    number_row<-nrow(urls_metadata$http_urls)
    for (i in 1:number_row) {
      # if (startsWith(urls_metadata$http_urls$http_URLs_names[i],"thumbnail")==FALSE){
        if (grepl("thumbnail",urls_metadata$http_urls$http_URLs_names[i])==FALSE){
          
        newURL <- ISOOnlineResource$new()
        newURL$setLinkage(urls_metadata$http_urls$http_URLs_links[i])
        newURL$setName(urls_metadata$http_urls$http_URLs_names[i])
        newURL$setDescription(urls_metadata$http_urls$http_URLs_descriptions[i])
        newURL$setProtocol(urls_metadata$http_urls$http_URLs_protocols[i])
        dto$addOnlineResource(newURL)
      }
    }
  }
  
  distrib$setDigitalTransferOptions(dto)
  
  format <- ISOFormat$new()
  format$setName(metadata$Format)
  # format$setVersion("Postgres 9 and Postgis 2") # to be done => stored in the spreadsheet ?
  # format$setAmendmentNumber("2")
  # format$setSpecification("specification")
  distrib$addFormat(format)
  
  logger.info("Write DistributionInfo section")
  md$setDistributionInfo(distrib)
  
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  logger.info("OGC 19115 SECTION => Data Quality") 
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  
  
  #add Data  / lineage for steps
  #example of lineage
  lineage_statement <- "Data management workflow description"
  lineage_steps <- list()
  lineage <- metadata$Lineage
  if(!is.na(lineage) & metadata$Dataset_Type!="NetCDF" & metadata$Dataset_Type!="google_doc"){
    logger.info("Add Lineage process steps")  
    #create lineage
    lineage_steps <- extractLineage(lineage)
    DQ1 <- prepareDataQualityWithLineage(config, lineage_statement, lineage_steps, mdDate, metadata$Identifier, contacts_metadata$contacts_roles)
    md$addDataQualityInfo(DQ1)
  }
  
  logger.info("Data Quality Genealogy not managed for now !")
  
  logger.info("Data Quality Info section added")
  
  
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  logger.info("OGC 19115 SECTION => Content Info -> FeatureCatalogueDescription => not managed for now")
  logger.info("-------------------------------------------------------------------------------------------------------------------") 
  
  
  return(md)
}


#push_metadata_in_geonetwork
#@param config
#@param metadata$Permanent_Identifier
#@param md
push_metadata_in_geonetwork <- function(config, metadata_permanent_id, md){
  
  #shortcut for gn config
  GN <- config$sdi$geonetwork$api
  
  #to insert or update a metadata into a geonetwork.
  #An insert has to be done in 2 operations (the insert itself, and the privilege setting to "publish" it either to a restrained group or to public)
  #An update has to be done based on the internal Geonetwork id (that can be queried as well
  privileges <- c("view","dynamic")
  if(is(md, "ISOMetadata")){
    privileges <- c(privileges, "featured")
  }
  metaId <- GN$get(metadata_permanent_id, by = "uuid", output = "id")
  # metaId=NULL
  if(is.null(metaId)){
    #insert metadata (once inserted only visible to the publisher)
    created = GN$insertMetadata(xml = md$encode(), group = "1", category = "datasets")
    
    #config privileges
    config <- GNPrivConfiguration$new()
    config$setPrivileges("all", privileges)
    GN$setPrivConfiguration(id = created, config = config)
  }else{
    #update a metadata
    updated = GN$updateMetadata(id = metaId, xml = md$encode())
    
    #config privileges
    config <- GNPrivConfiguration$new()
    config$setPrivileges("all", privileges)
    GN$setPrivConfiguration(id = metaId, config = config)
  }
  
  md_url <- paste(config$sdi$geonetwork$url, "/srv/eng/catalog.search#/metadata/",metadata_permanent_id,sep="")
  return(md_url)
  
}


push_metadata_in_csw_server <- function(config,metadata_identifier,md){
  
  #shortcut for CSW-T server config
  CSW_URL <- config$sdi$csw_server$url
  CSW_admin <- config$sdi$csw_server$user
  CSW_password <- config$sdi$csw_server$pwd
  csw <- CSWClient$new(CSW_URL, "2.0.2",  user = CSW_admin, CSW_password,logger="INFO")
  record <-NULL
  #get record by id
  record <- csw$getRecordById(metadata_identifier)
  
  if(record){
    cat("The metadata already exists: updating it !")
    update <- csw$updateRecord(record = md)
    update$getResult() #TRUE if updated, FALSE otherwise
  } else{
    cat("The metadata doesn't exist: creating it !")
    insert <- csw$insertRecord(record = md)
  }
  
  return(insert)
}

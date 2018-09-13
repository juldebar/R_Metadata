# DONE BY FOLLOWING ONLINE TUTORIAL https://github.com/ropensci/EML/blob/master/vignettes/creating-EML.Rmd
# https://github.com/ropensci/EML
# GOAL IS TO GENERATE EML FOR GBIF IPT : eg http://vmirdgbif-proto.mpl.ird.fr:8080/ipt/eml.do?r=ecoscope_observation_database&v=6.0

# download.file(url="http://vmirdgbif-proto.mpl.ird.fr:8080/ipt/eml.do?r=ecoscope_observation_database&v=6.0", destfile = "test_eml.xml", method="curl")
# f <- system.file("test_eml.xml", package = "EML")
# f <- system.file("/home/julien.barde/R/x86_64-pc-linux-gnu-library/3.3/EML/xsd/test/eml.xml", package = "EML")
# eml <- read_eml(f)


#write_metadata_OGC_19115
write_EML_metadata_from_Dublin_Core <- function(config = NULL,
                                                metadata = NULL,
                                                contacts_metadata = NULL,
                                                spatial_metadata = NULL,
                                                temporal_metadata = NULL,
                                                keywords_metadata = NULL, # DATAFRAME WITH ALL (STATIC & DYNAMIC)  KEYWORDS
                                                urls_metadata= NULL # LIST OF DYNAMIC / COMMON URLs
)
{
  #config shortcuts
  con <- config$sdi$db$con
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  logger.info("----------------------------------------------------")  
  logger.info("EML: MAIN METADATA ELEMENTS")  
  logger.info("----------------------------------------------------")  
  pubDate <-   as.character(as.Date(metadata$Date))
  title <- metadata$Title
  abstract <- metadata$Description
  intellectualRights <- metadata$Rights 
  logger.info("----------------------------------------------------")  
  logger.info("DATA DICTIONNARY => TO BE DONE => MANAGE COMMON CODE TO GET DATA DICTIONNARY FROM FEATURE CATALOG")  
  logger.info("----------------------------------------------------")  
  # 
  # entityName => entityDescription / physical / attributeList
  #################################################################################  
  # entityName=paste("../",local_subDirCSV,"/",static_metadata_dataset_name,".csv",sep="")
  # entityName="east_pacific_ocean_catch_1954_10_01_2016_01_01_tunaatlasIRD_level1.csv"
  # attributes
  # factors <- "TO BE DONE"
  # attributeList <- set_attributes(attributes, factors, col_classes = NULL)
  # physical <- set_physical(objectName=entityName,numHeaderLines="1",fieldDelimiter=",")
  # physical <- set_physical(entityName)
  # class(entityName)
  # dataTable <- new("dataTable",
  #                  entityName = entityName,
  #                  entityDescription = static_metadata_table_description,
  #                  physical = physical,
  #                  attributeList = attributeList)
  
  #   attributes <- data.frame(
  #     attributeName = c(
  #         "date",
  #         "geom",
  #         "species",
  #         "length"), 
  #     attributeDefinition = c(
  #         "This column contient la date",
  #         "la position",
  #         "l'espèce",
  #         "la taille"),
  #     formatString = c(
  #         "YYYY-DDD-hhmm",     
  #         "DD-MM-SS",     
  #         NA,     
  #         NA),
  #     definition = c(        
  #         "which run number",
  #         NA,
  #         NA,
  #         NA),
  #     unit = c(
  #         NA,
  #         NA,
  #         NA,
  #         "meter"),
  #     numberType = c(
  #         NA,
  #         NA,
  #         NA,
  #         "real"),
  #     stringsAsFactors = FALSE
  #     )
  #   
  #   attributeList <- set_attributes(attributes, NA, col_classes = c("Date", "numeric", "character", "character"))
  
  logger.info("----------------------------------------------------")  
  logger.info("Coverage metadata => TO BE DONE => geographicCoverage / temporalCoverage / taxonomicCoverage.")  
  logger.info("----------------------------------------------------")  
  # TO BE DONE => CHECK IF ONE COVERAGE PER SPECIES
  if(is.null(temporal_metadata$dynamic_metadata_temporal_Extent)==FALSE){
    start_date <- temporal_metadata$dynamic_metadata_temporal_Extent$start_date
    end_date <- temporal_metadata$dynamic_metadata_temporal_Extent$end_date
  }
  
  coverage <- set_coverage(begin = as.character(as.Date(start_date)),
                           end = as.character(as.Date(end_date)),
                           sci_names = "Sarracenia purpurea", # TO BE DONE CHECK THE MEANING AND USE => taxonomicCoverage !!!
                           geographicDescription = "geographic_identifier",  # TO BE DONE REMOVE i
                           west = spatial_metadata$dynamic_metadata_spatial_Extent$xmin,
                           east = spatial_metadata$dynamic_metadata_spatial_Extent$ymax,
                           north = spatial_metadata$dynamic_metadata_spatial_Extent$xmax,
                           south = spatial_metadata$dynamic_metadata_spatial_Extent$ymin,
                           altitudeMin = 0, # TO BE DONE
                           altitudeMaximum = 0, # TO BE DONE
                           altitudeUnits = "meter")
  logger.info("Spatial and Temporal extent added!")  
  
  logger.info("----------------------------------------------------")  
  logger.info("Creating parties => TO BE DONE => MANAGE ALL CONTACTS IN A LOOP.")  
  logger.info("----------------------------------------------------")  
  contacts <- config$gsheets$contacts
  
  number_row<-nrow(contacts_metadata$contacts_roles)
  if(is.null(contacts_metadata$contacts_roles)==FALSE && number_row > 0){
    for(i in 1:number_row){
      if(contacts_metadata$contacts_roles$dataset[i]== metadata$Identifier){#@julien => condition inutile ?
        the_contact <- contacts[contacts$electronicMailAddress%in%contacts_metadata$contacts_roles$contact[i],]
        cat(the_contact$electronicMailAddress)
        cat(contacts_metadata$contacts_roles$RoleCode[i])
        HF_address <- new("address",
                          deliveryPoint = the_contact$deliveryPoint,
                          city = the_contact$city,
                          administrativeArea = the_contact$administrativeArea,
                          postalCode = the_contact$postalCode,
                          country = the_contact$country)
        eml_contact_role <-NULL
        eml_contact_role <- switch(contacts_metadata$contacts_roles$RoleCode[i],
                              "metadata" = "associatedParty",
                              "pointOfContact" = "contact",
                              "principalInvestigator" = "contact",
                              "publisher" = "contact",
                              "owner" = "contact",
                              "originator" = "contact"
        )
        new_eml_contact <-  new(eml_contact_role,
                                individualName = paste(the_contact$Name,the_contact$firstname, sep=" "),
                                electronicMail = the_contact$electronicMailAddress,
                                address = HF_address,
                                organizationName = the_contact$organisationName,
                                phone = the_contact$voice)
      }
      if(is.null(eml_contact_role)){
        logger.info("No mapping has been found for the role of the conctact !")  
        #         the_contact <- contacts[contacts$electronicMailAddress%in%contacts_metadata$contacts_roles$contact[i],]
        #         cat(the_contact$electronicMailAddress)
        #         cat(contacts_metadata$contacts_roles$RoleCode[i])
      }
      
    }
  }
  
  logger.info("----------------------------------------------------")  
  logger.info("ADDING KEYWORDS")  
  logger.info("----------------------------------------------------")  
  # TO BE DONE => MANAGE PROPERLY KEYWORDS FOR SPECIES AS TAXONOMIC COVERAGE...")  
  
  if(is.null(keywords_metadata)==FALSE){
    different_thesaurus <- unique(keywords_metadata$thesaurus)
    number_thesaurus<-length(unique(different_thesaurus))
    all_thesaurus <- vector("list",number_thesaurus)
    # all_thesaurus <- c()
    keywordSet <- c()
    
    for(t in 1:number_thesaurus){
      if(is.null(keywords_metadata)==FALSE){
        number_row_kw<-nrow(keywords_metadata$all_keywords)
        vector <- character(0)
        for (i in 1:number_row_kw) {
          if(keywords_metadata$all_keywords$thesaurus[i]==different_thesaurus[t] & !is.na(keywords_metadata$all_keywords$keyword[i])){
            vector[[length(vector)+1]] <- keywords_metadata$all_keywords$keyword[i]
          }
        }
      }
      all_thesaurus <- new("keywordSet",
                           keywordThesaurus = different_thesaurus[t],
                           keyword = vector)
      keywordSet[[t]]  <-  all_thesaurus
      class(all_thesaurus)
    }
  }
  
  logger.info("----------------------------------------------------")  
  logger.info("WRITE EML METADATA")  
  logger.info("----------------------------------------------------")  
  dataset <- new("dataset",
                 title = title,
                 creator = new_eml_contact,
                 pubDate = pubDate,
                 intellectualRights = intellectualRights,
                 abstract = abstract,
                 associatedParty = new_eml_contact,#@julien => select new_eml_contact where role=associatedParty
                 # associatedParty = new_eml_contact[new_eml_contact$eml_contact_role%in%"associatedParty",],
                 keywordSet = keywordSet,
                 coverage = coverage,
                 contact = new_eml_contact,
                 # methods = methods,
                 dataTable = NULL)
  
  eml <- new("eml",
             packageId = "toto-2619-425e-b8be-8deb6bc6094d",  # from uuid::UUIDgenerate(),
             system = "uuid", # type of identifier
             dataset = dataset)
  
  logger.info("----------------------------------------------------")  
  logger.info("EML metadata has been generated.")  
  logger.info("----------------------------------------------------")  
  return(eml)
  
}
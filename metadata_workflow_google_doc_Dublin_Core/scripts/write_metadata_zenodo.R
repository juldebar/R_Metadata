#https://github.com/eblondel/zen4R/wiki
write_zenodo_metadata_from_Dublin_Core <- function(config = NULL,
                                                metadata = NULL,
                                                contacts_metadata = NULL,
                                                spatial_metadata = NULL,
                                                temporal_metadata = NULL,
                                                keywords_metadata = NULL, # DATAFRAME WITH ALL (STATIC & DYNAMIC)  KEYWORDS
                                                urls_metadata= NULL # LIST OF DYNAMIC / COMMON URLs
)
{
  #config shortcuts
  contacts <- config$gsheets$contacts
  con <- config$sdi$zenodo# julien TO BE DONE
  zenodo_token=con$token
  zenodo_community=con$communities
  
  logger <- config$logger
  logger.info <- config$logger.info
  logger.warn <- config$logger.warn
  logger.error <- config$logger.error
  logger.info("----------------------------------------------------")  
  logger.info("ZENODO : MAIN METADATA ELEMENTS")  
  logger.info("----------------------------------------------------")  
  zenodo <- ZenodoManager$new(
    access_token = zenodo_token, 
    logger = "INFO" # use "DEBUG" to see detailed API operation logs, use NULL if you don't want logs at all
    )
  zenodo_metadata <- NULL
  zenodo_metadata <- ZenodoRecord$new()
  zenodo_metadata$setTitle(metadata$Title)
  zenodo_metadata$setDescription(metadata$Description)
  # zenodo_metadata$setUploadType(metadata$Type)# Mapping here needs to be managed if not equal to "dataset"
  zenodo_metadata$setUploadType("dataset")# Mapping here needs to be managed if not equal to "dataset"
  zenodo_metadata$addCommunity(zenodo_community)
  zenodo_metadata$setLicense("mit")
  # zenodo_metadata$setLicense(metadata$Rights)
  zenodo_metadata$setAccessRight("open")

  # keywords <-return_keywords_and_thesaurus_as_data_frame(metadata$Subject)
  for (k in keywords_metadata$all_keywords$keyword){
    if(substring(k, 1, 1)== " "){k=substring(k, 2, nchar(k))}
    #zenodo_metadata$setKeywords(c("R","package","software"))
    cat(paste0("\n",k))
    zenodo_metadata$setKeywords(k)
    }
  
  # contacts <-return_contacts_as_data_frame(metadata$Creator)
  for (c in contacts_metadata$contacts_roles$contact) {
        the_contact <- contacts[contacts$electronicMailAddress%in%c,]
        zenodo_metadata$addCreator(firstname = the_contact$firstname, lastname = the_contact$Name, affiliation = the_contact$organisationName, orcid="0000-0002-3519-6141")
  }
  # urls <-return_urls_as_data_frame(metadata$Relation)
  for (u in urls_metadata$http_URLs_links) {
    # zenodo_metadata <- XXXXXXXXXXXXXXXXXXXXX
  }
  
  
  ## Publish this record
  print("Deposit the record: metadata + file")
  zenodo$depositRecord(zenodo_metadata)
  #zenodo$uploadFile("/home/julien/test.txt", myrec$id)
  
}

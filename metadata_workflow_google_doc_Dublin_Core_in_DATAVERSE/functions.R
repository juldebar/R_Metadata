#################################### PUBLISH ALL DATASETS IN A GIVEN DATAVERSE #############################################

publish_all_datasets_from_Dublin_Core_spreadsheet_in_a_dataverse <- function(DCMI_metadata,dataverse_name,dataverse_user_name){
  number_row<-nrow(DCMI_metadata)
  for (i in 1:number_row) {
    #################################### LOAD METADATA FROM SPREADSHEET / DATA FRAME #############################################
    metadata <- NULL
    metadata <- DCMI_metadata[i,]
    # metadata$Permanent_Identifier <- metadata$Identifier
    #################################### MAP DATAVERSE AND DCMI METADATA ELEMENTS #############################################
    # CHECK METADATA FOR PROPER MAPPING : https://www.rdocumentation.org/packages/dataverse/versions/0.2.0/topics/initiate_sword_dataset
    Dataverse_metadata <- list(identifier=metadata$Identifier,
                            title = metadata$Title,
                            creator = dataverse_user_name,
                            description = metadata$Description,
                            date=metadata$Date,
                            type = metadata$Type,
                            # language = metadata$Language,
                            # relation = metadata$Relation,
                            extent = paste(metadata$Relation,metadata$Temporal_Coverage,sep=" & "),
                            spatial = metadata$Spatial_Coverage,
                            temporal = metadata$Temporal_Coverage,
                            provenance = metadata$Lineage, 
                            rights = metadata$Rights
                            )
    
    keywords <-return_keywords_and_thesaurus_as_data_frame(metadata$Subject)
    for (k in keywords$all_keywords$keyword) {
      if(substring(k, 1, 1)== " "){k=substring(k, 2, nchar(k))}
      Dataverse_metadata <- c(Dataverse_metadata,subject = k)
    }
    urls <-return_urls_as_data_frame(metadata$Relation)
    for (u in urls$http_URLs_links) {
      Dataverse_metadata <- c(Dataverse_metadata,relation = u)
    }
    
    #################################### ADD THIS DATASET IN THE DATAVERSE #############################################
    add_dataset_with_sword <- dataverse::initiate_sword_dataset(dataverse_name, body = Dataverse_metadata)
    # add_dataset_with_native <- create_dataset(dataverse_name, body = Dataverse_metadata)
  }
  }

#################################### DELETE ALL DATASETS FROM A GIVEN DATAVERSE #############################################

remove_all_datasets_from_a_dataverse <- function(dataverse){
  dataverse_data <- dataverse_contents(dataverse)
  number_row<-length(dataverse_data)
  if(number_row>0){
  for (i in 1:number_row) {
    cat("\n")  
    cat(i)
    cat("\n")  
    this_dataset <- get_dataset(dataverse_data[[i]])
    cat(this_dataset$id)
    delete_dataset(dataverse_data[[i]])
  }
  } else{cat("The dataverse is already empty !")}
}



#################################### COMMON FUNCTIONS FOR SPREADSHEETS (CSV, GOOGLE DOC...) #############################################


return_contacts_as_data_frame <- function(all_contacts){
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
  contacts_roles_data_frame <- data.frame(contact=contact_email, RoleCode=contact_role, dataset=metadata$Identifier,stringsAsFactors=FALSE)
  return(contacts_roles_data_frame)
}

#################################### PROCESS THESAURUS & KEYWORDS #############################################

# the_subjects<-Dublin_Core_metadata$Subject[2]
# test<-return_keywords_and_thesaurus_as_data_frame(the_subjects)
# test$all_keywords$keyword
# all_subjects <- the_subjects

return_keywords_and_thesaurus_as_data_frame <- function(all_subjects){
 
  keywords_metadata <-NULL
  all_keywords <-NULL
  all_keywords <-data.frame(keyword = character(), thesaurus = character(),stringsAsFactors=FALSE)
  
  list_subjects <- strsplit(as.character(all_subjects), split = "\n")
  
  for(subjects in list_subjects[[1]]){
    cat(subjects)
    # subjects=list_subjects[[1]][1]
    cat("\n")
    split_subjects <- strsplit(subjects, split = "=")
    thesaurus_name <- split_subjects[[1]][1]
    all_subjects <- split_subjects[[1]][2]
    list_keywords <- strsplit(as.character(all_subjects), split = ",")
    list_keywords <- unlist(list_keywords)
    for (k in list_keywords){
    all_keywords[nrow(all_keywords)+1,] <- c(k, thesaurus_name)
    }
    keywords_metadata$all_keywords <- all_keywords
    TopicCategory <- c("biota", "oceans", "environment", "geoscientificInformation","economy")
    keywords_metadata$TopicCategory <- TopicCategory
  }
  
  return(keywords_metadata)
}

#################################### PROCESS RELATIONS #############################################

# the_relations<-Dublin_Core_metadata$Relation[1]
# test_relations<-return_urls_as_data_frame(the_relations)
# test_relations
# test_relations$http_URLs_links
# all_relations <- the_relations

return_urls_as_data_frame <- function(all_relations){
  urls_metadata <- NULL
  http_urls <- NULL
  http_URLs_links=NULL
  http_URLs_names=NULL
  http_URLs_descriptions=NULL
  http_URLs_protocols=NULL
  http_URLs_functions=NULL
  http_urls <-data.frame(http_URLs_links = character(), http_URLs_names = character(),http_URLs_descriptions = character(),http_URLs_protocols = character(), http_URLs_functions = character(),stringsAsFactors=FALSE)
  
  #Add as many links as stored in the google doc "Relation" column
  list_Relation <- strsplit(as.character(all_relations), split = "\n")
  for(relation in list_Relation[[1]]){
    split_Relation <- strsplit(relation, split = "@")
    http_URLs_links <- split_Relation[[1]][2]
    http_URLs_names <- split_Relation[[1]][1]
    if(http_URLs_names=="thumbnail"){
      http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, "thumbnail","Aperçu", "WWW:LINK-1.0-http--link","image/png")
    } else{
      if(grepl("\\[",http_URLs_names)==TRUE){
        split_http_URLs_names <- strsplit(http_URLs_names, split = "\\[")
        http_URLs_names <- split_http_URLs_names[[1]][1]
        http_URLs_descriptions <- gsub("\\]","",split_http_URLs_names[[1]][2] )
        }else{
          http_URLs_descriptions <- "Click the link"  
        }
      http_URLs_protocols  <- "WWW:LINK-1.0-http--link"
      http_URLs_functions <- "donwload"
      http_urls[nrow(http_urls)+1,] <- c(http_URLs_links, http_URLs_names,http_URLs_descriptions,http_URLs_protocols, http_URLs_functions)
    }
  }
  # urls_metadata$http_urls <- http_urls
  return(http_urls)
}
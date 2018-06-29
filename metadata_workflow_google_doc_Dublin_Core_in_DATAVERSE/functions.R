#################################### PUBLISH ALL DATASETS IN A GIVEN DATAVERSE #############################################

publish_all_datasets_from_Dublin_Core_spreadsheet_in_a_dataverse <- function(DCMI_metadata,dataverse){
  number_row<-nrow(Dublin_Core_metadata)
  for (i in 1:number_row) {
    # CHECK METADATA FOR PROPER MAPPING : https://www.rdocumentation.org/packages/dataverse/versions/0.2.0/topics/initiate_sword_dataset
    metadata <- NULL
    metadata <- Dublin_Core_metadata[i,]
    
    metadata$Identifier  <- Dublin_Core_metadata$Identifier[i]
    metadata$Permanent_Identifier <- metadata$Identifier
    metadata$Title  <- Dublin_Core_metadata$Title[i]
    metadata$Description <- Dublin_Core_metadata$Description[i]
    metadata$Date  <- Dublin_Core_metadata$Date[i]
    metadata$Type  <- Dublin_Core_metadata$Type[i]
    metadata$Format  <- Dublin_Core_metadata$Format[i]
    metadata$Language  <- Dublin_Core_metadata$Language[i] #  resource_language <- "eng"
    metadata$Lineage  <- Dublin_Core_metadata$Lineage[i]
    metadata$Rights  <- Dublin_Core_metadata$Rights[i] #UseLimitation <- "intellectualPropertyRights"
    if(is.na(metadata$Rights)){metadata$Rights="NO RIGHTS"}
    metadata$Spatial_Coverage  <- Dublin_Core_metadata$Spatial_Coverage[i]
    metadata$Temporal_Coverage  <- Dublin_Core_metadata$Temporal_Coverage[i]
    
    metadata$Subject  <- Dublin_Core_metadata$Subject[i]
    #   keywords_metadata <-NULL
    #   all_keywords <-NULL
    #   static_keywords<-NULL
    list_of_keywords <- metadata$Subject
    list_of_keywords <- gsub("GENERAL=", "", list_of_keywords)
    #   thesaurus <- c("AGROVOC")
    list_keywords <- strsplit(as.character(list_of_keywords), split = ", ")
    list_keywords <- unlist(list_keywords)
    #   all_keywords <-data.frame(keyword=list_keywords, thesaurus=thesaurus, stringsAsFactors=FALSE)
    #   keywords_metadata$all_keywords <- all_keywords
    #   TopicCategory <- c("biota", "oceans", "environment", "geoscientificInformation","economy")
    #   keywords_metadata$TopicCategory <- TopicCategory
    
    julien_metadata <- list(identifier=metadata$Identifier,
                            title = metadata$Title,
                            creator = "Barde, Julien",
                            description = metadata$Description,
                            date=metadata$Date,
                            type = metadata$Type,
                            # language = metadata$Language,
                            # Relation = metadata$Relation,
                            extent = paste(metadata$Relation,metadata$Temporal_Coverage,sep=" & "),
                            spatial = metadata$Spatial_Coverage,
                            temporal = metadata$Temporal_Coverage,
                            provenance = metadata$Lineage, 
                            rights = metadata$Rights
                            )
    for (k in list_keywords) {
      julien_metadata <- c(julien_metadata,subject = k)
    }
    
      # create the dataset
    julien_dataset_sword <- dataverse::initiate_sword_dataset("dataverse_julien_a_mano", body = julien_metadata)
    # dataset_native_julien <- create_dataset("dataverse_julien_a_mano", body = julien_metadata)
  }
  }

#################################### DELETE ALL DATASTES FROM A GIVEN DATAVERSE #############################################

remove_all_datasets_from_a_dataverse <- function(dataverse){
  dataverse_data <- dataverse_contents(dataverse)
  dataverse_data
  
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
  }else{cat("The dataverse is already empty !")}
}




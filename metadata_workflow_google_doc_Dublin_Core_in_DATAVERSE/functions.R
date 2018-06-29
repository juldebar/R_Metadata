#################################### PUBLISH ALL DATASETS IN A GIVEN DATAVERSE #############################################

publish_all_datasets_from_Dublin_Core_spreadsheet_in_a_dataverse <- function(DCMI_metadata,dataverse_name,dataverse_user_name){
  number_row<-nrow(DCMI_metadata)
  for (i in 1:number_row) {
    # CHECK METADATA FOR PROPER MAPPING : https://www.rdocumentation.org/packages/dataverse/versions/0.2.0/topics/initiate_sword_dataset
    metadata <- NULL
    metadata <- DCMI_metadata[i,]
    metadata$Permanent_Identifier <- metadata$Identifier
    # if(is.na(metadata$Rights)){metadata$Rights="NO RIGHTS"}
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
    
    Dataverse_metadata <- list(identifier=metadata$Identifier,
                            title = metadata$Title,
                            creator = dataverse_user_name,
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
      Dataverse_metadata <- c(Dataverse_metadata,subject = k)
    }
    
    # Add the dataset in the dataverse
    add_dataset_with_sword <- dataverse::initiate_sword_dataset(dataverse_name, body = Dataverse_metadata)
    # add_dataset_with_native <- create_dataset(dataverse_name, body = Dataverse_metadata)
  }
  }

#################################### DELETE ALL DATASTES FROM A GIVEN DATAVERSE #############################################

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
  }else{cat("The dataverse is already empty !")}
}




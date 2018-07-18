###################################### LOAD SESSION METADATA ############################################################

metadata_dataframe <- function(Dublin_Core_metadata){
  all_metadata <- NULL
  
  number_row<-nrow(Dublin_Core_metadata)
  for (i in 1:number_row) {
    # metadata <- Dublin_Core_metadata[i,]
    metadata <- NULL
    
    metadata$id_dataset  <- i # if(is.na(metadata$Identifier)){metadata$Identifier="TITLE AND DATASET NAME TO BE FILLED !!"}
    metadata$persistent_identifier <- Dublin_Core_metadata$Identifier[i]
    metadata$related_sql_query <- Dublin_Core_metadata$related_sql_query[i]
    metadata$related_view_name <- Dublin_Core_metadata$related_view_name[i] # @jbarde => if no view create one with name paste("view_", Dublin_Core_metadata$Identifier[i], sep="") ?
    metadata$identifier <- Dublin_Core_metadata$Identifier[i]
    metadata$title  <- Dublin_Core_metadata$Title[i]
    metadata$contacts_and_roles  <- Dublin_Core_metadata$Creator[i]
    metadata$subject  <- Dublin_Core_metadata$Subject[i]
    metadata$description <- Dublin_Core_metadata$Description[i]
    metadata$date  <- Dublin_Core_metadata$Date[i]
    metadata$dataset_type  <- Dublin_Core_metadata$Type[i]
    metadata$format  <- Dublin_Core_metadata$Format[i]
    metadata$language  <- Dublin_Core_metadata$Language[i] #resource_language <- "eng"
    metadata$relation  <- Dublin_Core_metadata$Relation[i]
    metadata$spatial_coverage  <-  Dublin_Core_metadata$Spatial_Coverage[i]
    metadata$temporal_coverage  <-  Dublin_Core_metadata$Temporal_Coverage[i]
    metadata$rights  <- Dublin_Core_metadata$Rights[i] #UseLimitation <- "intellectualPropertyRights"
    metadata$source  <- Dublin_Core_metadata$Source[i]
    metadata$provenance  <- Dublin_Core_metadata$Provenance[i]
    metadata$supplemental_information  <- "TO BE DONE"
    metadata$database_table_name  <- "TABLE NAME"
    
    all_metadata <- bind_rows(all_metadata, metadata)
    
  }
    return(all_metadata)
  }


library(RPostgreSQL)
library(data.table)
library(dplyr)
# source("/home/julien/Bureau/CODES/Deep_mapping/R/credentials_postgres.R")
source("/home/julien/Bureau/CODES/credentials_databases.R")

con_RTTP <- dbConnect(DRV, user=User, password=Password, dbname=Dbname, host=Host)
query_create_table <- paste(readLines("/home/julien/Bureau/CODES/R_Metadata/metadata_workflow_Postgres_Postgis/scripts/SQL/create_table_metadata.sql"), collapse=" ")
create_Table <- dbGetQuery(con_RTTP,query_create_table)

Metadata_RTTP_datasets <- "https://docs.google.com/spreadsheets/d/1FJjab8TncNlksZmlr9Uq0V6e8jzxmqUJTNJlEEStAic/edit?usp=sharing"
RTTP_datasets <- as.data.frame(gsheet::gsheet2tbl(Metadata_RTTP_datasets))
names(RTTP_datasets)


metadata <- metadata_dataframe(Dublin_Core_metadata=RTTP_datasets)
names(metadata)
head(metadata)


dbWriteTable(con_RTTP, "metadata", metadata, row.names=FALSE, append=TRUE)
dbDisconnect(con_RTTP)
on.exit(dbUnloadDriver(DRV), add = TRUE)




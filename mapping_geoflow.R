# geoflow_entities
# https://docs.google.com/spreadsheets/d/1iG7i3CE0W9zVM3QxWfCjoYbqj1dQvKsMnER6kqwDiqM/edit#gid=0
# Geoflow entities Data Structure => Identifier	Title	Description	Subject	Creator	Date	Type	Language	SpatialCoverage	TemporalCoverage	Relation	Rights	Provenance	Data		
# This Data Structure => Identifier	Title	Description	Subject	Creator	Date	Type	Language	SpatialCoverage	TemporalCoverage	Relation	Rights	Provenance	Data	path	gps_file_name	Number_of_Pictures									
############################################################
################### Packages #######################
############################################################
rm(list=ls())

require(stringr)
require(gsheet)
require(dplyr)
require(geoflow)

working_directory <- "/tmp"
setwd(working_directory)

mapping_R_Metadata_geoflow <- function(filename,R_metadata_gsheet){
  R_metadata <- as.data.frame(gsheet::gsheet2tbl(R_metadata_gsheet))
  head(R_metadata,n=2)
  # Geoflow entities Data Structure => Identifier	Title	Description	Subject	Creator	Date	Type	Language	SpatialCoverage	TemporalCoverage	Relation	Rights	Provenance	Data		
  geoflow_metadata <- data.frame(Projet=character(), 
                               Identifier=character(),
                               Title=character(), 
                               Description=character(),
                               Subject=character(), 
                               Creator=character(), 
                               Date=character(),
                               Type=character(),
                               Language=character(),
                               # Format=character(),
                               SpatialCoverage=character(),
                               TemporalCoverage=character(),
                               Relation=character(),
                               Rights=character(),
                               Provenance=character(),
                               Data=character()
                               )
  for (i in 1:nrow(R_metadata)) {
    cat(paste0(" ",i))
    # Projet	Identifier	Title	Creator	Subject	Description	Date	Type	Format	Language	Relation	Spatial_Coverage	Temporal_Coverage	Provenance	Rights											
    Projet <- R_metadata$Projet[i]
    Identifier <- paste0("id:",R_metadata$Identifier[i],";")
    Title <- R_metadata$Title[i]
    Creator <- gsub("=",":",R_metadata$Creator[i])
    Creator <- gsub(";",";\n",Creator)
    Creator <- gsub("metadata:","pointOfContact:",Creator)
    Creator <- gsub("contact:","pointOfContact:",Creator)
    Subject <- gsub("=",":",R_metadata$Subject[i])
    Subject <- gsub("\n",";\n",paste0(Subject,";"))
    Description <- paste0("abstract:",R_metadata$Description[i],";")
    Date <- R_metadata$Date[i]
    Type <- R_metadata$Type[i]
    # Format <- R_metadata$Format[i]
    Language <- R_metadata$Language[i]
    Relation <-  gsub("\n", ";\nhttp:",R_metadata$Relation[i])
    Relation <-  paste0(gsub("http:thumbnail", "thumbnail:Aperçu",paste0("http:",Relation)),";")
    SpatialCoverage <- paste0("SRID=4326;",R_metadata$Spatial_Coverage[i])
    TemporalCoverage <- gsub(";end=","/", gsub("start=","",R_metadata$Temporal_Coverage[i]))
    Rights <- paste0("use:",R_metadata$Rights[i],";")
    Provenance <- paste0("statement:",R_metadata$Provenance[i],";")
    Data <- R_metadata$Format[i]

    # Geoflow entities Data Structure => Identifier	Title	Description	Subject	Creator	Date	Type	Language	SpatialCoverage	TemporalCoverage	Relation	Rights	Provenance	Data		
    newRow <- data.frame(Projet=Projet,
                         Identifier=Identifier,
                         Title=Title,
                         Description=Description,
                         Subject=Subject,
                         Creator=Creator,
                         Date=Date,
                         Type=Type,
                         Language=Language,
                         # Format=Format,
                         SpatialCoverage=SpatialCoverage,
                         TemporalCoverage=TemporalCoverage,
                         Relation=Relation,
                         Rights=Rights,
                         Provenance=Provenance,
                         Data=Data
                         )
    
    geoflow_metadata <- rbind(geoflow_metadata,newRow)
  }

  file_name <-paste0("geoflow_metadata_",project_name,".csv")
  write.csv(geoflow_metadata,file = file_name,row.names = F)
  nrow(geoflow_metadata)
  
  return(geoflow_metadata)
}



projets_COI_gsheet <-"https://docs.google.com/spreadsheets/d/1dQLucq5OAm1qBHPuJv_7mDEOWq9x0Cyknp6ecVtGtS4/edit?usp=sharing"
projets_COI_metadata <- as.data.frame(gsheet::gsheet2tbl(projets_COI_gsheet))
projets_COI_metadata$Projet_Acronym
gsheets <- projets_COI_metadata$Datasets
total=0
for (g in 1:length(gsheets)){
  if(!is.null(gsheets[g]) && grepl(pattern = "docs.google",x = gsheets[g]) && projets_COI_metadata$Projet_Acronym[g]!="PGRNC" && projets_COI_metadata$Projet_Acronym[g]!="Smartfish"){
    project_name <- projets_COI_metadata$Projet_Acronym[g]
    cat(paste0(" \n Project => ",project_name),"\n")
    geoflow_metadata <-  mapping_R_Metadata_geoflow(filename=project_name,R_metadata_gsheet=gsheets[g])
    total=total+nrow(geoflow_metadata)
  }
}
total

# R_metadata_gsheet <-"https://docs.google.com/spreadsheets/d/1GAkcifGlZ-TNDP4vArH7SuwhWaDVkIIMdmgLjsGL8MQ/edit?usp=sharing"
# R_metadata_gsheet <-"https://docs.google.com/spreadsheets/d/1gK2N27VBptzLzYY86zJVoeViO_rsTqvz4w4U7elLkZ4/edit?usp=sharing"
# R_metadata_gsheet <- "https://docs.google.com/spreadsheets/d/1jWRHiNQcpvMgQ_6zrs8NF1614oTzc-iZXeUxQme_XuM/edit?usp=sharing"

# test <- as.data.frame(gsheet::gsheet2tbl(""))
# test <- as.data.frame(gsheet::gsheet2tbl(""))
# test <- as.data.frame(gsheet::gsheet2tbl(""))
test <- as.data.frame(gsheet::gsheet2tbl(gsheets[g]))

mapping_R_Metadata_geoflow(filename=project_name,R_metadata_gsheet=gsheets[g])  

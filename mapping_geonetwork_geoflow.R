# geoflow_entities
# https://docs.google.com/spreadsheets/d/1iG7i3CE0W9zVM3QxWfCjoYbqj1dQvKsMnER6kqwDiqM/edit#gid=0
# Geoflow entities Data Structure => Identifier	Title	Description	Subject	Creator	Date	Type	Language	SpatialCoverage	TemporalCoverage	Relation	Rights	Provenance	Data		
# This Data Structure => Identifier	Title	Description	Subject	Creator	Date	Type	Language	SpatialCoverage	TemporalCoverage	Relation	Rights	Provenance	Data	path	gps_file_name	Number_of_Pictures									
############################################################
################### Packages #######################
############################################################
rm(list=ls())


working_directory <- "/tmp"
setwd(working_directory)

require(stringr)
require(gsheet)
require(dplyr)
require(geoflow)
library(googledrive)
library(httr)
library(XML)


projets_COI_gsheet <-"https://docs.google.com/spreadsheets/d/1dQLucq5OAm1qBHPuJv_7mDEOWq9x0Cyknp6ecVtGtS4/edit?usp=sharing"
projets_COI_metadata <- as.data.frame(gsheet::gsheet2tbl(projets_COI_gsheet))
projets_COI_metadata$Projet_Acronym

# geonetwork_csv_gsheet <-"https://docs.google.com/spreadsheets/d/1fiprnSskIEsEgeL4IEU2cja4O0xSAHFrCgrfgW6LG_U/edit?usp=sharing"
geonetwork_csv_gsheet <-"https://docs.google.com/spreadsheets/d/1EpXhvRG20AsbSlsw0LCxGonrL3-pZ3Kq_0YoAM2ZQbU/edit?usp=sharing"
geonetwork_metadata <- as.data.frame(gsheet::gsheet2tbl(geonetwork_csv_gsheet))
head(geonetwork_metadata)


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
# head(geoflow_metadata)

number_row<-nrow(geonetwork_metadata)
for (i in 1:number_row) {
#   fe834fa6-2b0e-4dab-b819-c676be113ab5.xml
#   fb569ade-6ff5-4199-812d-5661c7f135a8.xml
#   e83a33c1-2f11-4aff-9aba-6a6e20c19a67.xml
#   e61a4407-8441-409b-8bc1-115229043892.xml
#   d0bba57e-bad5-4c0e-b4ec-623f7d053974.xml
#   cf6c0c14-aeff-465f-beb6-baf4ca8b846e.xml
#   b3989639-67ea-4482-b4e7-a668cc1b12ad.xml
#   a7a60757-b19e-4fd9-9765-f500c317bb9b.xml
#   11884899-ccd5-44c3-a977-60706e80e5fe.xml
#   837197a1-d6e5-4945-a9c8-4f0802e3a0ff.xml
#   049879b2-4a6c-4b30-8bd4-30d526221d91.xml
#   682f74cd-a5ba-4f3e-ab23-602c56dbcf01.xml
#   676d69f0-bba2-42e9-84df-135b15942479.xml
#   075b378b-112d-4da8-afc8-5ce1325616cc.xml
#   48a96d90-85c7-4842-8e12-a431fae92378.xml
#   5b62079c-0987-410b-b8ca-6777eb9bd397.xml
#   4a068dbe-f4c7-4617-8813-fdcdc56994aa.xml
#   03eb3cb8-0b8d-4efe-b592-1e24709e5a93.xml
  
  cat(paste0("\nCurrent line: ",i))
  project_name <- geonetwork_metadata$Projet[i]
  this_project <- projets_COI_metadata  %>% filter(Projet_Acronym == project_name)
  project_email <- paste0(tolower(this_project$Projet_Acronym),"@coi-ioc.org")
  # charge_mission_COI <- this_project$Charge_Mission_COI
  charge_mission_COI <- "secretariat@coi-ioc.org"
  Projet <- project_name
  # Identifier <- str_split(stringi::stri_trans_general(tolower(gsub("[\\'-/&\'^() ]+","_",geonetwork_metadata$title[i])), "Latin-ASCII"),pattern = "_")
  Identifier <- str_split(stringi::stri_trans_general(tolower(gsub("[][!#$%()*,.:;<=>@^ `'’|~.{}]","_",geonetwork_metadata$title[i])), "Latin-ASCII"),pattern = "_")
  
  clean_identifier <-""
  for (j in 1:length(Identifier[[1]])){
    if (nchar(Identifier[[1]][j]) > 3 && Identifier[[1]][j]!="pour" && Identifier[[1]][j]!="dans"){
      clean_identifier <- paste0(clean_identifier,"_",Identifier[[1]][j])
    }
    }
  Identifier <- paste0("id:",substr(clean_identifier,2,nchar(clean_identifier)),";")
  
  this_wd<-getwd()
  file_name <- paste0(geonetwork_metadata$uuid[i],".xml")
  setwd("/tmp/OGC_19139_xml_files")
  if (!file.exists(file_name)){
    download.file(paste0("http://thredds.oreme.org:8080/geonetwork/srv/fre/xml.metadata.get?uuid=",geonetwork_metadata$uuid[i]),destfile = file_name)
  }
    OGC_19139 <- ISOMetadata$new()
  #   # OGC_19139 <- geometa::readISO19139(paste0(geonetwork_metadata$uuid[i],".xml"))
  xml <- xmlParse(paste0("/tmp/OGC_19139_xml_files/",geonetwork_metadata$uuid[i],".xml"))
#   # xml <- xmlParse("/tmp/OGC_19139_xml_files/d1ecc38a-9418-4915-870d-58e4751f8af4.xml")
  OGC_19139$decode(xml = xml)
  setwd(this_wd)
  
  
  Title <- geonetwork_metadata$title[i]
  # Creator <- geonetwork_metadata$responsibleParty[i]
  Creator <- paste0("creator:",project_email,";\npublisher:secretariat@coi-ioc.org;\nowner:secretariat@coi-ioc.org;\npointOfContact:julien.barde@ird.fr,alexandre.noel@coi-ioc.org,COI-CdD@coi-ioc.org,",charge_mission_COI,";")
  Subject <- paste0("GENERAL:",paste0("Projet ",project_name," (FED/COI)"),",",gsub("###",",",geonetwork_metadata$keyword[i]),";\ntopicCategory:society,economy,biota,oceans,environment;")
  Description <- paste0("abstract:",gsub("###","",geonetwork_metadata$abstract[i]),";")
  if(Description=="abstract:;"){
    Description="abstract:To be done;"
  }
  Date <- geonetwork_metadata$metadatacreationdate[i]
  Type <- "dataset"
  # Format <- geonetwork_metadata$Format[i]
  Language <- "fra"
  thumbnail <-""
  link <-""
  old_metadata <- paste0("http:OLD metadata@http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/",geonetwork_metadata$uuid[i])
  if(!is.na(this_project$Projet_Logo)){
    logo <- paste0("\nthumbnail:Logo du projet ",project_name,"@",gsub("open", "uc",this_project$Projet_Logo))
  }else{
    logo <- paste0("\nthumbnail:Logo du projet ",project_name,"@","https://www.commissionoceanindien.org/wp-content/uploads/2019/02/french-coi-logo-100px-french-logo.png")
    }
  
  if(!is.na(geonetwork_metadata$link[i])){
    link <- gsub("###","\nhttp:OLD Geonetwork link@",gsub("######", "\nhttp:OLD Geonetwork link@",geonetwork_metadata$link[i]))
    link <- gsub("http:OLD Geonetwork link@https://www.zotero.org","http:OLD Zotero[cf Zotero reference of the document related to this dataset]@https://www.zotero.org",link)
  }
  if(!is.na(geonetwork_metadata$image[i])){old_thumbnails <-  gsub("###", "\nthumbnail:OLD aperçu@",paste0("\nthumbnail:OLD aperçu@",geonetwork_metadata$image[i]))}
  
  old_Relation <-paste0(old_metadata,link,old_thumbnails)
  
  new_Relation <-""  
  relation_geonetwork <- str_split(old_Relation,pattern = "\n")
    for (f in 1:length(relation_geonetwork[[1]])){
      line <- relation_geonetwork[[1]][f]
      prefix <- str_split(line,pattern = "@")[[1]][1]
      url <- sub(".*@","",line)
      #we check if the url comes is delivered by geonetwork  and upload the file in google drive (required to keep the file when metadat will be removed)
      if(grepl("&fname=",url)){
        # cat("Drive\n")
        file_name_drive <- sub('&access=public','',sub('.*&fname=','', url))
        filter=paste0("name contains '",file_name_drive,"'")
        google_drive_file <- drive_find(q = filter)
        # we check if the file already exists on google drive
        if(nrow(google_drive_file)>0){
          same_relation_on_drive <-""
          # we just use the first result if the same file is stored in different drive repositories
          for(file in google_drive_file$id[1]){
            if(is_mine(as_dribble(as_id(file)))){
              google_drive_file_url <- paste0("https://drive.google.com/uc?id=",file)
              if(grepl(".zip",file_name_drive) || grepl(".xls",file_name_drive)){
                same_relation_on_drive <-paste0("http:",file_name_drive,"[Get the file ",file_name_drive," on drive]@",google_drive_file_url)
                # new_line <- paste0(line,"\n",same_relation_on_drive)
                new_line <- paste0(same_relation_on_drive) 
                }else if(prefix=="thumbnail:OLD aperçu"){
                  # same_relation_on_drive <-paste0("thumbnail:NEW aperçu [see ",file_name_drive," on Drive]@",google_drive_file_url)
                  same_relation_on_drive <-paste0("thumbnail:NEW aperçu@",google_drive_file_url)
                  new_line <- paste0(same_relation_on_drive) 
                }else if (grepl(".png",file_name_drive) || grepl(".jpeg",file_name_drive) || grepl(".jpg",file_name_drive)){
                  same_relation_on_drive <-paste0("http:NEW IMAGE [see ",file_name_drive," on Drive]@",google_drive_file_url)
                  # new_line <- paste0(line,"\n",same_relation_on_drive)
                  new_line <- paste0(same_relation_on_drive) 
                }else{
                  same_relation_on_drive <-paste0("http:NEW STUFF [see ",file_name_drive," on drive]@",url)
                  new_line <- paste0(line,"\n",same_relation_on_drive)
                }
            }
            # new_line <- paste0(same_relation_on_drive) 
            # new_line <- paste0(line,"\n",same_relation_on_drive) 
          }
          # if the file is not on google drive we download it to upload it later
          }else{
            cat(paste0("Nothing for: ",file_name_drive,"\n"))
            download_url <- sub("&access=public","",url)
            download.file(download_url, destfile=paste0("/tmp/download/",file_name_drive))
            new_line <- line
          }
        
        # Relation <-paste0(Relation,same_relation_on_drive)
        
      }else{
        # cat("Pas Drive\n")
        new_url <-NULL
        new_url <- switch(url,
                         "https://drive.google.com/file/d/0B0FxQQrHqkh0VC1ZS0huQk1DLW8/view"="https://www.zotero.org/groups/303882/commission_ocean_indien/items/itemKey/I7ZKQRCP",
                         "http://mdst-macroes.ird.fr/COI/www.commissionoceanindien.org/fileadmin/resources/ISLANDSpdf/Review_of_Coral_Reef_Ecosystem_Management_Approaches_in_the_ESA_IO_FINAL_with_Exec_Summ.pdf"="https://www.zotero.org/groups/303882/commission_ocean_indien/items/itemKey/TUMSVSZ9",
                         "http://commissionoceanindien.org/fileadmin/resources/ISLANDSpdf/ISLANDS_Programme_for_financial_protection_against_climatic_and_natural_disasters_Mauritius_Final_Draft_report.pdf"="https://www.zotero.org/groups/commission_ocean_indien/items/itemKey/46QWHMVM",
                         "http://commissionoceanindien.org/fileadmin/resources/ISLANDSpdf/ISLANDS_Programme_for_financial_protection_against_climatic_and_natural_disasters_Madagascar_Final_Draft_report.pdf"="https://www.zotero.org/groups/commission_ocean_indien/items/itemKey/EHZE9FI7",
                         "http://commissionoceanindien.org/fileadmin/resources/ISLANDSpdf/ISLANDS_Programme_for_financial_protection_against_climatic_and_natural_disasters_Comores_Final_Draft_report.pdf"="https://www.zotero.org/groups/commission_ocean_indien/items/itemKey/PFVQRSKF",
                         "http://commissionoceanindien.org/fileadmin/resources/ISLANDSpdf/ISLANDS_Programme_for_financial_protection_against_climatic_and_natural_disasters_Zanzibar_Final_Draft_report.pdf"="https://www.zotero.org/groups/303882/commission_ocean_indien/items/collectionKey/X54RW4PL/itemKey/5RB8E9J3",
                         "http://mdst-macroes.ird.fr/COI/www.commissionoceanindien.org/fileadmin/projets/smartfish/FAO/Fish_Consumption_Survey___Mauritius.pdf"="https://www.zotero.org/groups/303882/commission_ocean_indien/items/collectionKey/VWE2KPMW/itemKey/T2T4ZFDA",
                         "http://mdst-macroes.ird.fr/COI/www.commissionoceanindien.org/fileadmin/projets/smartfish/Rapport/SF46.pdf"="https://www.zotero.org/groups/303882/commission_ocean_indien/items/collectionKey/VWE2KPMW/itemKey/UTZ488FS",
                         "http://mdst-macroes.ird.fr/COI/www.commissionoceanindien.org/fileadmin/resources/ISLANDSpdf/Review_of_Coral_Reef_Ecosystem_Management_Approaches_in_the_ESA_IO_FINAL_with_Exec_Summ.pdf"="https://www.zotero.org/groups/303882/commission_ocean_indien/items/collectionKey/X54RW4PL/itemKey/FKC47KAU",
                         "http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/6aff3a69-62f9-4afb-86b4-2563cf23e18b"="http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/geomorphologie_sensibilite_marine_recifale_sud-est_maurice",
                         "http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/d1ecc38a-9418-4915-870d-58e4751f8af4"="http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/ensemble_points_richesse_ecologique_relative_marine_recifale_sud-est_maurice",
                         "http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/fbb93b89-8e5d-4a45-9c93-b7b3428dd9f4"="http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/couverture_urbaine_villes_moheli_comores"
#                          "http://moi.govmu.org/mesa/"="",
#                          "http://moi.govmu.org/mesa/images/observations/857.JPG"="",
#                          "http://data.unep-wcmc.org/datasets/1"="",
#                          "http://data.unep-wcmc.org/pdfs/1/WCMC-008-CoralReefs2010-ver1.3.pdf?1434713557"
        )
        if (!is.null(new_url) && !grepl("OLD metadata",prefix)){
          # cat("URL à changer \n")
          if(grepl("www.zotero.org",new_url)){
            url_zotero <-paste0("https://api.zotero.org/groups/303882/items/", sub(".*itemKey/","",new_url),"?v=3")
            resp<-GET(url_zotero)
            jsonRespParsed<-content(resp,as="parsed") 
            title_zotero <- jsonRespParsed$data$title
            type_zotero <- jsonRespParsed$data$itemType
            
            new_line <- paste0("http:",paste0(title_zotero,"(",type_zotero,")"),"[Lien vers la référence Zotero d'un document qui mentionne la donnée]@",new_url)
            } else if(grepl("http://thredds.oreme.org:8080/geonetwork/srv/fre/catalog.search#/metadata/",new_url)){
              new_line <- paste0("http:NEW OLD Metadata [related metadata link]@",new_url)
              }
          } else if (grepl("zotero",url)){# a verifier
            url_zotero <-paste0("https://api.zotero.org/groups/303882/items/", sub(".*itemKey/","",url),"?v=3")
            resp<-GET(url_zotero)
            jsonRespParsed<-content(resp,as="parsed") 
            title_zotero <- jsonRespParsed$data$title
            type_zotero <- jsonRespParsed$data$itemType
            new_line <- paste0("http:",paste0(title_zotero,"(",type_zotero,")"),"[Lien vers la référence Zotero d'un document qui mentionne la donnée]@",url)
          } else {# || grepl("OLD metadata",prefix)
              # cat("URL conservé \n")
              cat(paste0(" \n Pas touché : \n ", url, "\n"))
              new_line <- line
              # download.file(paste0("http://thredds.oreme.org:8080/geonetwork/srv/fre/xml.metadata.get?uuid=",geonetwork_metadata$uuid[i]),destfile = paste0(geonetwork_metadata$uuid[i],".xml"))
              # OGC_19139 <- geometa::readISO19139(paste0(geonetwork_metadata$uuid[i],".xml"))
            }
        }
      new_Relation <- paste0(new_Relation,"\n",new_line)
    }
  
  Relation <-paste0(sub("\n", "",new_Relation),logo,";")
  Relation <-gsub("\n", ";\n",Relation)
  
  
  bbox <- str_split(geonetwork_metadata$geoBox[i],pattern = "###")
  xmin <- bbox[[1]][1]
  xmax <- bbox[[1]][2]
  ymin <- bbox[[1]][3]
  ymax <- bbox[[1]][4]
  
  SpatialCoverage <-paste0("SRID=4326;POLYGON((",xmin," ",ymin,",",xmin," ",ymax,",",xmax," ",ymax,",",xmax," ",ymin,",",xmin," ",ymin,"))")
  if(SpatialCoverage=="SRID=4326;POLYGON((,,,,))" || SpatialCoverage== "SRID=4326;POLYGON(( , , , , ))" || SpatialCoverage== "SRID=4326;POLYGON((NA NA,NA NA,NA NA,NA NA,NA NA))"){
    SpatialCoverage <-"SRID=4326;POLYGON((-180 -90,-180 90,180 90,180 -90,-180 -90))"
    }
  if(!is.na(geonetwork_metadata$temporalExtent[i])){
    TemporalCoverage <- paste0(substr(geonetwork_metadata$temporalExtent[i], 1, nchar(geonetwork_metadata$temporalExtent[i])/2),"/",substr(geonetwork_metadata$temporalExtent[i], 1+nchar(geonetwork_metadata$temporalExtent[i])/2, nchar(geonetwork_metadata$temporalExtent[i])))
  } else {TemporalCoverage <- ""}
  ##########################################################################################################################
  Rights <- "use:to be done"
  
  provenance <-NA
  if(length(OGC_19139$dataQualityInfo)>0){
    provenance=OGC_19139$dataQualityInfo[[1]]$lineage$statement[1]
  }
  if(!is.na(provenance)){
    Provenance <- paste0("statement:",provenance)
  }else{
    Provenance <- "statement:to be done"
  }
  Provenance
  
  Data <- "source:test@http://mdst-macroes.ird.fr/tmp/BET_YFT_SKJ.svg;\ntype:other;"
  # Data <- ""
  ##########################################################################################################################
  
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


# file_name <- paste0("geoflow_metadata_",project_name,".csv")
file_name <- paste0("geoflow_metadata_all_projects",".csv")
write.csv(geoflow_metadata,file = file_name,row.names = F)
nrow(geoflow_metadata)
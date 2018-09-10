#################################### EXAMPLES #############################################
rm(list=ls())
################ LIENS#######################################"
# https://github.com/IQSS/dataverse-client-r
################# IRF  FROM GITHUB ( https://www.rdocumentation.org/packages/dataverse/versions/0.2.0 )################################"
if (!require("remotes")) {
  install.packages("remotes")
}
remotes::install_github("iqss/dataverse-client-r")
################################################################"
library("dataverse")
library("gsheet")
################################################################"
my_wd="~/Bureau/CODES/R_Metadata/"
setwd(paste(my_wd,"metadata_workflow_google_doc_Dublin_Core_in_DATAVERSE",sep=""))
source("my_credentials.R")
source("functions.R")
#################################### EXAMPLE 1: PUBLISH ALL DATASETS IN A GIVEN DATAVERSE #############################################
Dublin_Core_spreadsheat <- "https://docs.google.com/spreadsheets/d/1cYzSbiuGuvl0civWgFh7PftdfXCVMRa8dC4QRw6L42E/edit#gid=0"

Dublin_Core_metadata <- as.data.frame(gsheet::gsheet2tbl(Dublin_Core_spreadsheat))
# contacts <- as.data.frame(gsheet::gsheet2tbl(google_sheet_contacts))

publish_all_datasets_from_Dublin_Core_spreadsheet_in_a_dataverse(Dublin_Core_metadata,dataverse_name,dataverse_user_name)

#################################### EXAMPLE 2: DELETE ALL DATASETS FROM A GIVEN DATAVERSE #############################################
my_dataverse <- get_dataverse(dataverse_name)
remove_all_datasets_from_a_dataverse(my_dataverse)
#################################### EXAMPLE 2: DELETE ALL DATASETS FROM A GIVEN DATAVERSE #############################################
Titles<-Dublin_Core_metadata$Title[15]
Titles
multilingual_data_frame <- return_multilingual_data_frame(Titles)
multilingual_data_frame
#################################### EXAMPLE 2: DELETE ALL DATASETS FROM A GIVEN DATAVERSE #############################################





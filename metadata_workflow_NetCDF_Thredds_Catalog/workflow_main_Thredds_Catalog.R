# Dublin Core Workflow
# @authors
#   Emmanuel Blondel (FAO) <emmanuel.blondel@fao.org>
#   Julien Barde (IRD) <julien.barde@ird.fr>
rm(list=ls())

#options
options(stringsAsFactors = FALSE)

#working directory
wd <- "~/R_Metadata-master/metadata_workflow_NetCDF_Thredds_Catalog/"
setwd(wd)

#Resources
source("workflow_utils.R")
config_file <- "workflow_configuration_Thredds_catalog.json"

#1. Init the workflow based on configuration file
########################################################################################################################
CFG <- initWorkflow(config_file)

#2. Inits workflow job (create directories)
########################################################################################################################
initWorkflowJob(CFG)

#3. Execute the workflow job
########################################################################################################################
# executeWorkflowJob(CFG)
Thredds <-NULL
Thredds$url <-CFG$sdi$thredds$url_thredds_template
browse_sub_catalog(CFG,Thredds)
  
#4. close workflow
########################################################################################################################
closeWorkflow(CFG)


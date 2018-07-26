# Dublin Core Workflow
# @authors
#   Emmanuel Blondel (FAO) <emmanuel.blondel@fao.org>
#   Julien Barde (IRD) <julien.barde@ird.fr>
rm(list=ls())

#options
options(stringsAsFactors = FALSE)

#working directory
wd <- "~/Bureau/CODES/R_Metadata/metadata_workflow_Postgres_Postgis/"
setwd(wd)

#Resources
source("workflow_utils.R")
config_file <- paste("workflow_configuration_Postgres.json",sep="")

#1. Init the workflow based on configuration file
########################################################################################################################
CFG <- initWorkflow(config_file)

#2. Inits workflow job (create directories)
########################################################################################################################
initWorkflowJob(CFG)

#3. Execute the workflow job
########################################################################################################################
executeWorkflowJob(CFG)

#4. close workflow
########################################################################################################################

closeWorkflow(CFG)

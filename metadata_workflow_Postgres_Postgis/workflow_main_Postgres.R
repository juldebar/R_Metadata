# Dublin Core Workflow
# @authors
#   Emmanuel Blondel (FAO) <emmanuel.blondel@fao.org>
#   Julien Barde (IRD) <julien.barde@ird.fr>
rm(list=ls())

#options
options(stringsAsFactors = FALSE)

#working directory
setwd("~/metadata_workflow_Postgres_RTTP/")

#Resources
source("workflow_utils.R")
config_file <- "workflow_configuration_Postgres.json"

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


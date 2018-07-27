# Implementation of FAIR data management plans with R programming language and usual data sources in scientific context

This repository provides examples of metadata (compliant with [OGC](http://www.opengeospatial.org/) standards) generated with R scripts from different data sources. Metadata can be pushed directly from R to CSW server (eg geonetwork) and data can be published in Geoserver (WMS/WFS).

Each sub-folder contains an example of worfklow dedicated to a specific kind of data source:
- [Flat files: CSV/Google Spreadsheet](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_google_doc_Dublin_Core)
  - simple CSV / local access
  - example in a google spreadsheet to get a collaborative edition tool
- [SQL / Relationnal database / RDBMS](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_Postgres_Postgis)
  - Postgres and Postgis,
  - no other RDMBS for now,
- [NetCDF files / OPeNDAP accesible on Thredds sever](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_NetCDF_Thredds_Catalog)
  - local access
  - `accessible` with OPeNDAP on a Thredds server

The scripts use following R packages:

- OGC related: [geometa](https://github.com/eblondel/geometa), [geosapi](https://github.com/eblondel/geosapi), [geonapi](https://github.com/eblondel/geonapi), [ows4R](https://github.com/eblondel/ows4R) 
- Postgres related: [RPostgreSQL](RPostgreSQL)
- NetCDF related: [ncdf4](ncdf4)
- GBIF related: [eml](eml)
- Dataverse related: [dataverse]()

Other R packages (in the R console):
 
```{r setup, include=FALSE}
if (!require("pacman")) install.packages("pacman")
pacman::p_load(uuid,raster,ncdf4,gsheet,XML,RFigisGeo,devtools,RPostgreSQL,jsonlite,googleVis)
```

Configuration of R on Linux requires the installation of following packages (tested on Debian / Ubuntu):
```{r setup, include=FALSE}
(sudo) apt-get install libcurl4-openssl-dev  libssl-dev r-cran-ncdf4 libxml2-dev libgdal-dev gdal-bin libgeos-dev udunits-bin libudunits2-dev
```




##  Execution of R codes can be done online

All codes can be executed online in RStudio server provided by D4science infrastructure. If you want to try, please [ask a login](https://bluebridge.d4science.org/web/sdi_lab/) (and briefly explain why): 


#  Pre-requisites / How to start

As a start, ** it is recommended to execute the [workflow using a google spreadsheet as a data source](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_google_doc_Dublin_Core) ** since it is the easiest.

Make sure that following pre-requisites are ok:
- change the working directory in the [main script for the workflow](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_google_doc_Dublin_Core/workflow_main_Dublin_Core_gsheet.R) to fit the  actual path on your PC,
- you have set up all packages (R and OS packages, check list above  when starting from scratch) <!-- following [list of potential issues](https://docs.google.com/document/d/1ngZGiMGcTeGvHTmHDttekaQsL9NOHbozyWtlbGWna5c/edit?usp=sharing) -->
- you have created **your own google spreadsheets** to describe:
  - your **contacts** (by **making a copy** of the [template for contacts](https://docs.google.com/spreadsheets/d/1dzxposSSN5nZ0NCdmomxa7KTLHWc4gR3geAoSq1Hku8/edit?usp=sharing))
  - the main metadata elements (Dublin Core) of **your datasets** (by **making a copy** of the [template for metadata](https://docs.google.com/spreadsheets/d/1s8ntQAzgGagixZ-o9TMe6_8I4N0uARJz22Nbw7TLhWU/edit?usp=sharing))
- if you want to use the D4science infrastructure components (eg geoserver / geonetwork) you should use your **personal token** from D4science infrastructure (you need to [register first](https://bluebridge.d4science.org/web/sdi_lab/))



<!-- - virer package raster-->

Once done: 
- edit the content of the [json configuration file template](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_Postgres_Postgis/workflow_configuration_Postgres_template.json) (there is one specific json file per workflow / type of data source) to specify how to connect the components of your spatial data infrastructure and the URLs of the google spreadsheets you created (see pre-requisites above).
  - set the token of you personal account for BlueBridge infrastructure
  - set the credentials of your URLs of your google spreadsheet
  - set the credentials of your Postgres server
  - set the credentials of your Geonetwork or CSW server
  - set the credentials of your Geoserver
- rename this file as following :" **workflow_configuration_Postgres.json** "
- Execute the [main script of the workflow](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_google_doc_Dublin_Core/workflow_main_Dublin_Core_gsheet.R) and check that third applicatoins (eg Postgres, Geonetwork, Geoserver) are accessible from R (check logs when executing the [main script of the workflow](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_google_doc_Dublin_Core/workflow_main_Dublin_Core_gsheet.R))

When it works, you can try other workflows for other data sources (Postgres and Thredds / NetCDF files).


# Usual Errors

- Contacts are not properly described in the google spreadsheet (or not even in the spreadsheet)
- Your token is not set if you use Geonetwork / Geoserver in the BlueBridge infrasrtructure
- Syntactic aspects 
  - contacts
  - provenance

<!-- 

- uuid VS identifier a mano 
- "Mauritius"
- "Provenance"
- enlever le template
dateStamp Emilie
-->


# Main scripts

Once you have been able to executer the workflow with the templates and your SDI, you can customize the workflow to fit your specific needs.
The most important scripts are the following 
- [write_Dublin_Core_metadata.R]() is the file in charge of processing the DCMI metadata elements to create metadata sheets (OGC in particular)
- [write_metadata_OGC_19115_from_Dublin_Core.R]() is the file which contains functions called in [write_Dublin_Core_metadata.R]()


##  Postgres data source use case

In this case, it is required:
- to prepare the list of queries with which datasets can be physically extracted (and stored as CSV files)
- to specify a user who can create tables :
  - the metadata table which describes the list of datasets for which we will create metadata (OGC 19115 in geonetwork) and access protocols (OGC WMS/WFS from geoserver)
  - one view per dataset where columns are renamed as following:
   - the name of date colum "AS dat"e
   - the name of geometry colum "AS geom"
  
  
  

<img style="position: absolute; top: 0; right: 0; border: 0;" src="http://mdst-macroes.ird.fr/tmp/logo_IRD.svg" width="100">

[![ForTheBadge powered-by-electricity](http://ForTheBadge.com/images/badges/powered-by-electricity.svg)](http://ForTheBadge.com)

<!-- 

https://github.com/Naereen/badges

[![DOI:10.1007/978-3-319-76207-4_15](https://zenodo.org/badge/DOI/10.1007/978-3-319-76207-4_15.svg)](https://doi.org/10.1007/978-3-319-76207-4_15)
-->




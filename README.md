# Implementation of FAIR data management plans with R programming language and usual data sources in scientific context

This repository provides 3 examples of workflows to generate metadata (compliant with [OGC](http://www.opengeospatial.org/) standards) from different data sources by using R scripts. Metadata can be pushed directly from R to a CSW server (eg geonetwork) and data managed in a Postgres database can be also published in Geoserver (WMS/WFS) from R.

Each sub-folder contains an example of worfklow dedicated to a specific kind of data source:
- [Flat files: CSV/Google Spreadsheet](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_google_doc_Dublin_Core) which is used to edit metadata for different datasets, the data structure of the spreadsheet relies on DCMI main metadata elements (one column per type of element), This workflow can either work with a simple CSV file (local access) or with the same file stored in a collaborative environment to facilitate online edition by multiple users without versionning issues (we give an example in a google spreadsheet),
- [SQL / Relationnal database / RDBMS](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_Postgres_Postgis): this workflow uses a "metadata" table (with a similar structure as the spreadsheet used in the previous workflow) and is only implemented with Postgres and Postgis RDBMS (other RDBMS could be easily added, eg MySQL).
- [NetCDF files / OPeNDAP accesible on Thredds sever](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_NetCDF_Thredds_Catalog): this worklow can either extract metadata from NetCDF files stored locally or remotely `accessible` through OPeNDAP protocol (eg frome a Thredds server).




<img style="position: absolute; top: 0; right: 0; border: 0;" src="https://drive.google.com/uc?id=12o3kEeYbqgJumpouwB6dtlSptN24qVhp" width="1000">

##  These R codes can be executed online

All codes can be executed online in RStudio server provided by D4science infrastructure. If you want to try, please [ask a login](https://bluebridge.d4science.org/web/sdi_lab/) (and briefly explain why): 


#  How to start


##  Pre-requisites

Make sure that following pre-requisites are ok:

- The scripts use following R packages:
  - OGC related: [geometa](https://github.com/eblondel/geometa), [geosapi](https://github.com/eblondel/geosapi), [geonapi](https://github.com/eblondel/geonapi), [ows4R](https://github.com/eblondel/ows4R) 
  - Postgres related: [RPostgreSQL](RPostgreSQL)
  - NetCDF related: [ncdf4](ncdf4)
  - GBIF related: [eml](eml)
  - Dataverse related: [dataverse]()
- Other R packages (in the R console):
```{r setup, include=FALSE}
if (!require("pacman")) install.packages("pacman")
pacman::p_load(uuid,raster,ncdf4,gsheet,XML,devtools,RPostgreSQL,jsonlite,googleVis,rgeos,rgdal,sf)
install_github("RFigisGeo", "openfigis")
```
If rgdal is not available for your version of R install it from source or update your R version.

Installation of R packages on Linux might require the installation of following OS underlying packages (tested on Debian / Ubuntu):
```{r setup, include=FALSE}
(sudo) apt-get install libcurl4-openssl-dev  libssl-dev r-cran-ncdf4 libxml2-dev libgdal-dev gdal-bin libgeos-dev udunits-bin libudunits2-dev
```
 <!-- following [list of potential issues](https://docs.google.com/document/d/1ngZGiMGcTeGvHTmHDttekaQsL9NOHbozyWtlbGWna5c/edit?usp=sharing) -->


## Step 1: Execute the default workflow: spreadsheet use case

Once you have set up all packages, as a first start, **it is recommended to execute the worklow** [using a google spreadsheet as a data source](https://github.com/juldebar/R_Metadata/tree/master/metadata_workflow_google_doc_Dublin_Core) since it is the easiest and it will help you to understand how to deal with the json configuration file as well as to understand the logics of all workflows.

Once done with pre-requisites : 
- **change the working directory** in the [main script for the workflow](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_google_doc_Dublin_Core/workflow_main_Dublin_Core_gsheet.R#L11) to fit the  actual path of this github repository on your PC,
- edit the content of the [json configuration file template](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_Postgres_Postgis/workflow_configuration_Postgres_template.json) (there is one specific json file per workflow / type of data source) to specify how to connect the components of your spatial data infrastructure and the URLs of the google spreadsheets you created (see pre-requisites above).
  - if you want to use the BlueBridge / D4science infrastructure components (eg RStudio server, geoserver / geonetwork) you have to set the **token** of your personal account : you need to [register first](https://bluebridge.d4science.org/web/sdi_lab/),
  - at this stage, it is recommanded to let the default URLs of the google spreadsheets (you will update them with yours once you checked that the workflow can be executed as it is set by default),
  - set the credentials of your Geonetwork or CSW server
```json
    "geonetwork": {
      "url": "http://mygeonetwork.org/geonetwork",
      "user": "********",
      "pwd": "********",
      "version": "3.0.4"
    },
```
  - rename this file as following :" **workflow_configuration_Postgres.json** "
- Execute the [main script of the workflow](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_google_doc_Dublin_Core/workflow_main_Dublin_Core_gsheet.R), read the logs and check that Geonetwork is accessible from R.

If it works properly, you should see the datasets listed in the google spreadsheet [dublin_core_gsheet](https://docs.google.com/spreadsheets/d/1s8ntQAzgGagixZ-o9TMe6_8I4N0uARJz22Nbw7TLhWU/edit?usp=sharing) published in the geonetwork / CSW server.

Once done, you can start tuning the workflow to plug your data sources and (meta)data servers.
  
# Step 2 : Tune the workflow to fit your needs


# Main scripts

Once you have been able to execute the workflow with the templates and your SDI, you can customize the workflow to fit your specific needs.
The most important scripts are the following 
- see previous section: edit the content of **json configuration files templates** (one specific json file per workflow / type of data source) to indicate how to connect the components of your spatial data infrastructure and the URLs of the google spreadsheets you created,
- [write_Dublin_Core_metadata.R]() is the file in charge of processing the DCMI metadata elements to load a metadata object in R,
- [write_metadata_OGC_19115_from_Dublin_Core.R]() is the file which contains functions called in [write_Dublin_Core_metadata.R]() to turn the R metadata object into OGC metadata and push it into geonetwork or any CSW server.


## Plug your data sources (spreadsheets, Postgres database, Thredds server) and your applications

When it works, you can try to execute the same worflow with your spreadsheets and other workflows with additional data sources (Postgres and Thredds / NetCDF files).
- you have created **your own google spreadsheets** to describe:
  - your **contacts** (by **making a copy** of the [template for contacts](https://docs.google.com/spreadsheets/d/1dzxposSSN5nZ0NCdmomxa7KTLHWc4gR3geAoSq1Hku8/edit?usp=sharing))
  - the main metadata elements (Dublin Core) of **your datasets** (by **making a copy** of the [template for metadata](https://docs.google.com/spreadsheets/d/1s8ntQAzgGagixZ-o9TMe6_8I4N0uARJz22Nbw7TLhWU/edit?usp=sharing))
- For Postgres workflow, you have to specify how to use the additional applications:
  - set the credentials of your Postgres server,
  - set the credentials of your Geoserver which will be used to make datasets available with WMS / WMFS access protocols.
  - Execute the [main script of the workflow](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_Postgres_Postgis/workflow_main_Postgres.R) and read logs to check that third applications (eg Postgres, Geonetwork, Geoserver) are accessible from R.
  
## (Des)activatation of the different steps


The different steps of the workflow can be (des)activated independantly according to the values "actions" listed" in the json configuration file: 

```json
  "actions": {
    "create_metadata_table": false,
    "create_sql_view_for_each_dataset": true,
    "data_wms_wfs": true,
    "data_csv": false,
    "metadata_iso_19115": false,
    "metadata_iso_19110": false,
    "write_metadata_EML": false,
    "main": "write_Dublin_Core_metadata"
  }
```



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


##  Postgres data source use case

In this case, it is required:
- to prepare the list of SQL queries with which your datasets can be physically extracted from the Postgres database (and stored as CSV files)
- to specify a user who can create tables :
  - the **metadata** table which describes the list of datasets for which we will create metadata (OGC 19115 in geonetwork) and access protocols (OGC WMS/WFS from geoserver)
  - one view per dataset where columns are renamed as following:
    - the name of date colum "AS date"
    - the name of geometry colum "AS geom"





  

<img style="position: absolute; top: 0; right: 0; border: 0;" src="http://mdst-macroes.ird.fr/tmp/logo_IRD.svg" width="100">

[![ForTheBadge powered-by-electricity](http://ForTheBadge.com/images/badges/powered-by-electricity.svg)](http://ForTheBadge.com)

<!-- 

https://github.com/Naereen/badges

[![DOI:10.1007/978-3-319-76207-4_15](https://zenodo.org/badge/DOI/10.1007/978-3-319-76207-4_15.svg)](https://doi.org/10.1007/978-3-319-76207-4_15)
-->

<img style="position: absolute; top: 0; right: 0; border: 0;" src="https://drive.google.com/uc?id=1xyaPHGU9m7-zP3iymwD1lGVWU3D0yUGf" width="800">



<!-- - virer package raster-->




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

- OGC related: [geometa](https://github.com/eblondel/geometa), [geosapi](https://github.com/eblondel/geosapi), [geonapi](https://github.com/eblondel/geonapi) 
- Postgres related: [RPostgreSQL](RPostgreSQL)
- NetCDF related: [ncdf4](ncdf4)
- GBIF related: [eml](eml)
- Dataverse related: [dataverse]()

##  Execution of R codes can be done online

All codes can be executed online in RStudio server provided by D4science infrastructure. If you want to try, please log in (and explain why): https://bluebridge.d4science.org/web/sdi_lab/ 


#  Postgres use case

Make sure that following pre-requisites are ok:
- you have set up all packages (R and OS packages, check following [list of potential issues] (https://docs.google.com/document/d/1ngZGiMGcTeGvHTmHDttekaQsL9NOHbozyWtlbGWna5c/edit?usp=sharing) when starting from scratch
- you have created **your own google spreadsheats** to describe:
  - your contacts (by **making a copy** of the [template for contacts](https://docs.google.com/spreadsheets/d/1dzxposSSN5nZ0NCdmomxa7KTLHWc4gR3geAoSq1Hku8/edit?usp=sharing))
  - the metadata of your datasets (by **making a copy** of the [template for metadata](https://docs.google.com/spreadsheets/d/1s8ntQAzgGagixZ-o9TMe6_8I4N0uARJz22Nbw7TLhWU/edit?usp=sharing))
- Postgres server is accessible from R (check logs when executing the [main script](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_Postgres_Postgis/workflow_main_Postgres.R))



Once done, adapt accordingly the content of the [json configuration file template](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_Postgres_Postgis/workflow_configuration_Postgres_template.json) to specify how to connect the components of your spatial data infrastructure and the URLs of the google spreadsheets you created (see pre-requisites above).


#  Examples

```{r setup, include=FALSE}

```



<img style="position: absolute; top: 0; right: 0; border: 0;" src="http://mdst-macroes.ird.fr/tmp/logo_IRD.svg" width="100">

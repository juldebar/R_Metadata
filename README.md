Examples of Metadata generated from R packages. Each folder is a worfklow dedicated to a specific data source (CSV/Google Spreadsheet | RDBMS SQL Postgres & Postgis server| NetCDF/OPeNDAP Thredds sever)

##  In this repository

Some samples to generate metadata from various sources
- flat files / spreadsheets
  - simple CSV / local access
  - example in a google spreadsheet to get a collaborative edition tool
- Relationnal database
  - Postgres and Postgis,
  - no other RDMBS for now,
- NetCDF files
  - local access
  - `accessible` with OPeNDAP on a Thredds server

##  Underlying R packages

Some samples to generate metadata from various sources
- OGC related: [geometa](https://github.com/eblondel/geometa), [geosapi](https://github.com/eblondel/geosapi), [geonapi](https://github.com/eblondel/geonapi) 
- Postgres related: [RPostgreSQL](RPostgreSQL)
- NetCDF related: [ncdf4](ncdf4)
- GBIF related: [eml](eml)
- Dataverse related: [dataverse]()

##  Execution of R codes can be done online

All codes can be executed online in RStudio server provided by D4science infrastructure. If you want to try, please log in (and explain why): https://bluebridge.d4science.org/web/sdi_lab/ 

#  Examples

```{r setup, include=FALSE}

```

#  Postgres use case

Make sure that following pre-requisites are ok:
- you have set up all packages (R and OS packages):
- you have created **your own google spreadsheats** to describe:
  - your contacts (by **making a copy** of the [template for contacts](https://docs.google.com/spreadsheets/d/1dzxposSSN5nZ0NCdmomxa7KTLHWc4gR3geAoSq1Hku8/edit?usp=sharing))
  - the metadata of your datasets (by **making a copy** of the [template for metadata](https://docs.google.com/spreadsheets/d/1s8ntQAzgGagixZ-o9TMe6_8I4N0uARJz22Nbw7TLhWU/edit?usp=sharing))
- Postgres server is accessible from R (check logs when executing the [main script](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_Postgres_Postgis/workflow_main_Postgres.R))



Once done, adapt accordingly the content of the [json configuration file template](https://github.com/juldebar/R_Metadata/blob/master/metadata_workflow_Postgres_Postgis/workflow_configuration_Postgres_template.json) to specify how to connect the components of your spatial data infrastructure and the URLs of the google spreadsheets you created (see pre-requisites above).




<img style="position: absolute; top: 0; right: 0; border: 0;" src="http://mdst-macroes.ird.fr/tmp/logo_IRD.svg" width="100">

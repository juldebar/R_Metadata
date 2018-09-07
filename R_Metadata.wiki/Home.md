Welcome to the R_Metadata wiki!


# Syntactic conventions for spreadsheets

The workflow can be reused with similar data sources (spreadsheets, SQL databases, Thredds servers) as long as inputs comply with naming conventions and syntactic aspects for valuation of metadata. Rules are the same for spreadsheets and databases. NetCDF and NCML files have to comply with CF-conventions and specific valuation rules.

## Contacts spreadsheet

Basically, contacts are described with all metadata elements provided by ISO 19115. The email is used as a key to identify contacts in metadata.

## Metadata spreadsheet

Metadata elements used in the workflow mainly come from [Dublin Core Metadata Initiative (DCMI)](http://www.dublincore.org/documents/usageguide/elements/
).
Here is the list of metadata elements (columns) in the metadata spreadsheet (or dedicated table in a SQL database)

 - **Identifier**: free text (add permanent identifier)
 - **Title | Description | Type**: free text
 - **Creator**: controlled syntax 
```{r setup, include=FALSE}
owner=ird@ird.fr;publisher=ird@ird.fr;originator=ird@ird.fr;metadata=julien.barde@ird.fr;principalInvestigator=frederique.menard@ird.fr;principalInvestigator=michel.potier@ird.fr
```
 -**Subject**: controlled syntax 
```{r setup, include=FALSE}
GENERAL=antea,abraliopsis sp,acanthephyra sanguinea,acanthephyra sp,alepisaurus ferox....
AGROVOC=keyword1,keyword2....
```
 -**Date**: controlled syntax 
```{r setup, include=FALSE}
start=1984-12-31;end=2007-12-30
``` 
 -**Type**: free text
 -**Format**: free text
 -**Language**: free text
 -**Relation**: controlled syntax
```{r setup, include=FALSE}
Previous metadata sheet@http://thredds.oreme.org:8080/geonetwork/srv/eng/catalog.search#/metadata/db_Stomac_19115
thumbnail@http://mdst-macroes.ird.fr/documentation/databases/dbStomac/thumbnail_stomac.jpeg
thumbnail@http://mdst-macroes.ird.fr/documentation/databases/dbStomac/dbStomacSpatialExtent_thumbnail.jpg
IRD@http://www.ird.fr/
``` 
 -**Lineage**: controlled syntax
```{r setup, include=FALSE}
step1=
```
 -**Rights**: free text but might be automated for CC
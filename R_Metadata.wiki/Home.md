Welcome to the R_Metadata wiki!


# Syntactic conventions for spreadsheets

The workflow can be reused with similar data sources (spreadsheets, SQL databases, Thredds servers) as long as inputs comply with naming conventions and syntactic aspects for valuation of metadata. Rules are the same for spreadsheets and databases. NetCDF and NCMLF files comply with CF-conventions and specific valuation rules.

## Contacts spreadsheet

Basically, contacts are described with all metadata elements provided by ISO 19115. The email is used as a key to identify contacts in metadata.

## Metadata spreadsheet

Here is the list of metadata elements (columns) in the metadata spreadsheet (or dedicated table in a SQL database)

 - ** Identifier **: free text (add permanent identifier)
 - ** Title | Description | Type  ** : free text
 - ** Creator **: controlled syntax 
 - ** Subject **: controlled syntax 
 - ** Date **: controlled syntax 
 - ** Type **: free text
 - ** Format **: free text
 - ** Language ** : free text
 - ** Relation ** : controlled syntax
 - ** Lineage **: controlled syntax
 - ** Rights **: free text but might be automated for CC
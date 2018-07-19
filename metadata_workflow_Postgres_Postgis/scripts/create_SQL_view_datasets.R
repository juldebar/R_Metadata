# Function to create one view per dataset listed in the metadata table

All_datasets_for_metadata <- "https://docs.google.com/spreadsheets/d/1MLemH3IC8ezn5T1a1AYa5Wfa1s7h6Wz_ACpFY3NvyrM/edit#gid=0"
datasets_catalog <- as.data.frame(gsheet::gsheet2tbl(All_datasets_for_metadata))
number_row<-nrow(datasets_catalog)


for (i in 1:number_row ) {
  view_name <- datasets_catalog$Title[i]
  sql_view <- datasets_catalog$related_sql_query
  # sql_view <- paste('SELECT ogc_fid, wkb_geometry AS geom, filename, gpslatitud AS lat,gpslongitu AS lon, gpsdatetim AS date,lightvalue,imagesize,model,path,parent_dir FROM "public"."photos_metadata" WHERE parent_dir = \'',view_name,'\';')
  SQLquery <- paste('DROP VIEW IF EXISTS ',view_name,' CASCADE ; CREATE VIEW ',view_name,' AS ', sql_view, sep="");
  res_dimensions_and_variables <- dbGetQuery(con, SQLquery)
  
}


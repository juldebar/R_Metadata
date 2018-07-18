DROP TABLE IF EXISTS metadata CASCADE;

CREATE TABLE metadata
(
  id_dataset serial NOT NULL,
  persistent_identifier text,
  related_sql_query text, 
  related_view_name text,
  identifier text,
  title text,
  contacts_and_roles text,  
  subject text,
  description text,
  date text,
  dataset_type text,
  format text,
  language text,
  relation text,
  spatial_coverage text,
  temporal_coverage text,
  rights text,
  source text,
  provenance text,
  supplemental_information text,
  database_table_name text,
  CONSTRAINT metadata_pkey PRIMARY KEY (id_dataset),
  CONSTRAINT unique_identifier UNIQUE (identifier)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE metadata OWNER TO "invRTTP";
GRANT SELECT ON TABLE metadata TO "invRTTP";
GRANT ALL ON TABLE metadata TO "invRTTP";

COMMENT ON TABLE metadata IS 'Table containing the metadata on all the datasets available in the database';
COMMENT ON COLUMN metadata.id_dataset IS 'internal identifier for the table';
COMMENT ON COLUMN metadata.persistent_identifier IS 'when a dataset has multiple versions (eg yearly versions) the    persistent identifier is for the last version (up to date)';
COMMENT ON COLUMN metadata.related_sql_query IS 'the SQL query to be executed to get this dataset';
COMMENT ON COLUMN metadata.related_view_name IS 'the name of the view to directly access this dataset (if it exists)';
COMMENT ON COLUMN metadata.identifier IS 'identifier" metadata element of the metadata_sheet';
COMMENT ON COLUMN metadata.title IS '"title" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.contacts_and_roles IS 'customized field includes all contacts as defined by Dublin Core Metadata Initiative (Creator , ….)';
COMMENT ON COLUMN metadata.subject IS '"subject" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.description IS '"description" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.date IS '"date" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.dataset_type IS '"type" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.format IS '"format" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.language IS '"language" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.relation IS '"relation" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.spatial_coverage IS '"spatial" metadata element as defined by Dublin Core Metadata Initiative (which refines coverage)';
COMMENT ON COLUMN metadata.temporal_coverage IS '"temporal" metadata element as defined by Dublin Core Metadata Initiative (which refines coverage)';
COMMENT ON COLUMN metadata.rights IS '"rights" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.source IS '"source" metadata element  as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.provenance IS '"provenance" metadata element as defined by Dublin Core Metadata Initiative';
COMMENT ON COLUMN metadata.supplemental_information IS 'additional comments ?';
COMMENT ON COLUMN metadata.database_table_name IS 'inutile ? => ici à cause du modèle de Sardara  ?';

-- COLUMNS TO BE ADDED  ? => Permanent_Identifier, Parent_Metadata_Identifier, Purpose, Update_frequency, Credits, 


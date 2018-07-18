DROP TABLE metadata_data_dictionnary IF EXISTS CASCADE;


CREATE TABLE metadata_data_dictionnary
(
  id_feature serial text,
  feature_definition text, -- when a dataset has multiple versions (eg yearly versions) the persistent identifier is for the last version (up to date)

  CONSTRAINT metadata_data_dictionnary_pkey PRIMARY KEY (id_feature)
--,
--  CONSTRAINT unique_identifier UNIQUE (identifier)
)
WITH (OIDS=FALSE);


ALTER TABLE metadata_data_dictionnary OWNER TO invRTTP;
GRANT SELECT ON TABLE metadata_data_dictionnary TO invRTTP;
GRANT ALL ON TABLE metadata_data_dictionnary TO invRTTP;
COMMENT ON TABLE metadata_data_dictionnary IS 'Table containing the metadata on all the datasets available in the database';

COMMENT ON COLUMN metadata_data_dictionnary.id_feature IS 'internal identifier for the table';
COMMENT ON COLUMN metadata_data_dictionnary.feature_definition IS 'add comments...';
-- COLUMNS TO BE ADDED  ? 


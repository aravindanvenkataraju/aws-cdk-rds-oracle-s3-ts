CREATE TABLE custom_users_ext (
  user_id      NUMBER,
  user_name  VARCHAR2(50),
  user_num   VARCHAR2(50)
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY CUSTOM_FILES_DIR
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL
    (user_id,user_name,user_num)
  )
  LOCATION ('users.csv')
)
PARALLEL
REJECT LIMIT UNLIMITED;
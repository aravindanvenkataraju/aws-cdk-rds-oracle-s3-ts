--create custom directory
EXEC rdsadmin.rdsadmin_util.create_directory(p_directory_name => 'CUSTOM_FILES_DIR');

--download file from s3:
select rdsadmin.rdsadmin_s3_tasks.download_from_s3(p_bucket_name => :bucket_name, p_directory_name => 'CUSTOM_FILES_DIR', p_s3_prefix => :filename) as task_id
from dual;

-- log from above execution:
SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-<task_id>.log'));
/*
2022-07-17 03:16:55.658 UTC [INFO ] This task is about to list the Amazon S3 objects for AWS Region us-east-1, bucket name cdkrdsoracletsstack-oracledbbucket9fe6a988-1uxnmg7u617xc, and prefix .
2022-07-17 03:16:55.728 UTC [INFO ] The task successfully listed the Amazon S3 objects for AWS Region us-east-1, bucket name cdkrdsoracletsstack-oracledbbucket9fe6a988-1uxnmg7u617xc, and prefix .
2022-07-17 03:16:55.746 UTC [INFO ] The task finished successfully.
*/

/*

2022-07-17 03:23:57.722 UTC [INFO ] This task is about to list the Amazon S3 objects for AWS Region us-east-1, bucket name cdkrdsoracletsstack-oracledbbucket9fe6a988-1uxnmg7u617xc, and prefix users_17072022.csv.
2022-07-17 03:23:57.807 UTC [INFO ] The task successfully listed the Amazon S3 objects for AWS Region us-east-1, bucket name cdkrdsoracletsstack-oracledbbucket9fe6a988-1uxnmg7u617xc, and prefix users_17072022.csv.
2022-07-17 03:23:57.825 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/userdirs/01 from bucket name cdkrdsoracletsstack-oracledbbucket9fe6a988-1uxnmg7u617xc and key users_17072022.csv.
2022-07-17 03:23:57.950 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name cdkrdsoracletsstack-oracledbbucket9fe6a988-1uxnmg7u617xc with key users_17072022.csv to the location /rdsdbdata/userdirs/01.
2022-07-17 03:23:57.951 UTC [INFO ] The task finished successfully.
*/

-- list files in db directory
SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'CUSTOM_FILES_DIR'));

--rename file
exec utl_file.frename(
    src_location => 'CUSTOM_FILES_DIR',
    src_filename => 'users_17072022.csv',
    dest_location => 'CUSTOM_FILES_DIR',
    dest_filename => 'users.csv'
);

--read from external table:
select * from CUSTOM_USERS_EXT;
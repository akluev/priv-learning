BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'DEF_CRED_NAME',
    username => 'akluev@hotmail.com',
    password => 'tRYoRACLEcLOUD20$'
  );
END;
/

commit;


ALTER DATABASE PROPERTY SET DEFAULT_CREDENTIAL = 'ADMIN.DEF_CRED_NAME'
/

--- Install untilmail

cd C:\oracle\product\19.0.0\client_1\rdbms\admin

sqlplus Admin/testDBA2020$@test1_high @utlmail.sql
sqlplus Admin/testDBA2020$@test1_high @prvtmail.plb


grant execute on utl_mail to public 
create or replace public synonym utl_mail for  admin.utl_mail

create or replace public synonym OP_PKG for  efis_etl.op_pkg

GRANT execute on dbms_lock  to efis

GRANT execute on dbms_lock  to efis_etl


cd C:\oracle\product\instantclient_18_5

--- EFIS_DW

impdp Admin/testDBA2020$@test1_high logfile=import.log directory=data_pump_dir credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/q6shvmKvRKY0Y9xIYjWuvAenNyNUJIAmGNmz_uq4ZHY/n/yz6tenlj3noa/b/upload/o/efis_dw.dmp 

impdp Admin/testDBA2020$@test1_high logfile=import.log directory=data_pump_dir CONTENT=DATA_ONLY TABLE_EXISTS_ACTION=TRUNCATE credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/q6shvmKvRKY0Y9xIYjWuvAenNyNUJIAmGNmz_uq4ZHY/n/yz6tenlj3noa/b/upload/o/efis_dw.dmp 

--- EFIS
https://objectstorage.ca-toronto-1.oraclecloud.com/p/h5wwbWIjOfmFKgfyqkxC0Vi7ziX7wY3DF_et711nF44/n/yz6tenlj3noa/b/upload/o/efis.dmp

impdp Admin/testDBA2020$@test1_high logfile=efis_import.log directory=data_pump_dir CONTENT=METADATA_ONLY TABLE_EXISTS_ACTION=TRUNCATE  REMAP_TABLESPACE=EFIS_DATA:DATA credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/h5wwbWIjOfmFKgfyqkxC0Vi7ziX7wY3DF_et711nF44/n/yz6tenlj3noa/b/upload/o/efis.dmp 

impdp Admin/testDBA2020$@test1_high logfile=efis_import.log directory=data_pump_dir CONTENT=DATA_ONLY TABLE_EXISTS_ACTION=TRUNCATE  REMAP_TABLESPACE=EFIS_DATA:DATA credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/h5wwbWIjOfmFKgfyqkxC0Vi7ziX7wY3DF_et711nF44/n/yz6tenlj3noa/b/upload/o/efis.dmp 


--- missed doc_set 
impdp Admin/testDBA2020$@test1_high logfile=efis_ds_import.log directory=data_pump_dir CONTENT=DATA_ONLY TABLE_EXISTS_ACTION=TRUNCATE  REMAP_TABLESPACE=EFIS_DATA:DATA INCLUDE=TABLE:\"IN ('DOC_SET')\" credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/h5wwbWIjOfmFKgfyqkxC0Vi7ziX7wY3DF_et711nF44/n/yz6tenlj3noa/b/upload/o/efis.dmp 



impdp Admin/testDBA2020$@test1_high ATTACH=SYS_IMPORT_FULL_02
--- EFIS_ETL
https://objectstorage.ca-toronto-1.oraclecloud.com/p/pmU0nyfq_uWL9QwBCfongg8xp3_zQFSAXA5693C63i8/n/yz6tenlj3noa/b/upload/o/efisefis_etl.dmp


impdp Admin/testDBA2020$@test1_high logfile=efis_etl_import.log directory=data_pump_dir CONTENT=METADATA_ONLY TABLE_EXISTS_ACTION=TRUNCATE  REMAP_TABLESPACE=EFIS_DATA:DATA credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/pmU0nyfq_uWL9QwBCfongg8xp3_zQFSAXA5693C63i8/n/yz6tenlj3noa/b/upload/o/efisefis_etl.dmp
 
--- grants
impdp Admin/testDBA2020$@test1_high logfile=efis_import.log directory=data_pump_dir CONTENT=METADATA_ONLY INCLUDE=GRANT credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/h5wwbWIjOfmFKgfyqkxC0Vi7ziX7wY3DF_et711nF44/n/yz6tenlj3noa/b/upload/o/efis.dmp 


impdp Admin/testDBA2020$@test1_high logfile=import_efis_dw.log directory=data_pump_dir CONTENT=METADATA_ONLY INCLUDE=GRANT credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/q6shvmKvRKY0Y9xIYjWuvAenNyNUJIAmGNmz_uq4ZHY/n/yz6tenlj3noa/b/upload/o/efis_dw.dmp 
 
impdp Admin/testDBA2020$@test1_high logfile=import_efis_dw.log directory=data_pump_dir CONTENT=METADATA_ONLY INCLUDE=GRANT credential=def_cred_name  dumpfile=https://objectstorage.ca-toronto-1.oraclecloud.com/p/pmU0nyfq_uWL9QwBCfongg8xp3_zQFSAXA5693C63i8/n/yz6tenlj3noa/b/upload/o/efisefis_etl.dmp
 


https://objectstorage.ca-toronto-1.oraclecloud.com/p/q6shvmKvRKY0Y9xIYjWuvAenNyNUJIAmGNmz_uq4ZHY/n/yz6tenlj3noa/b/upload/o/efis_dw.dmp

https://objectstorage.ca-toronto-1.oraclecloud.com/n/yz6tenlj3noa/b/upload/o/efis_dw.dmp

encryption_pwd_prompt=yes 

     
     transform=segment_attributes:n \      
     exclude=cluster,db_link
     

BEGIN
  DBMS_CLOUD.PUT_OBJECT(
    credential_name => 'DEF_CRED_NAME',
    object_uri => 'https://objectstorage.ca-toronto-1.oraclecloud.com/n/yz6tenlj3noa/b/upload/o/import.log',
    directory_name  => 'DATA_PUMP_DIR',
    file_name => 'import.log');
END;
/     


expdp \'/ as sysdba\' schemas=efis directory=FULL_EXPORT_DIR dumpfile=efis.dmp logfile=efis.log

expdp \'/ as sysdba\' schemas=efis_etl directory=FULL_EXPORT_DIR dumpfile=efis_etl.dmp logfile=efis_etl.log

expdp \'/ as sysdba\' schemas=efis_dw directory=FULL_EXPORT_DIR dumpfile=efis_dw.dmp logfile=efis_dw.log  SAMPLE=1


expdp \'/ as sysdba\' schemas=efis_dw directory=FULL_EXPORT_DIR  logfile=efis_dw1.log   EXCLUDE=TABLE:\"LIKE \'LD%\' \"  EXCLUDE=TABLE:\"LIKE \'ST%\' \" ESTIMATE_ONLY=Yes

expdp \'/ as sysdba\' schemas=efis_dw directory=FULL_EXPORT_DIR  logfile=efis_dw1.log   EXCLUDE=TABLE:\"LIKE \'LD%\' \"  EXCLUDE=TABLE:\"LIKE \'ST%\' \" dumpfile=efis_dw1.dmp





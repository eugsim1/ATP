

select s.sid, s.serial#, s.status, p.spid
from v$session s, v$process p
where s.username = 'atpc_user'
and p.addr (+) = s.paddr;

select job from dba_jobs where log_user='atpc_user';

SELECT SID,SERIAL#,STATUS from v$session where username='atpc_user';

/*
  1- Create a atp user 
  2 -grant the dwrole
  3 -copy data to the use space
*/

drop user atpc_user cascade;
create user atpc_user identified by "Welcome1#1234";
grant dwrole to atpc_user;
conn atpc_user/Welcome1#1234@esatp1_high;
show user;
conn admin/Welcome1#1234@esatp1_high;
show user;


/* test if there are some residuals ... */
select  * from user_credentials;
conn atpc_user/Welcome1#1234@esatp1_high;
select  * from user_credentials;

/* clean all temp credentails / tables created during previous tests */
begin
    DBMS_CLOUD.DROP_CREDENTIAL (credential_name => 'OBJ_STORE_CRED');
end;
/

begin
    DBMS_CLOUD.DELETE_ALL_OPERATIONS ();
end;
/

/*
  Generate new credentials => Generate first new token and store it to the users secure config
*/
  
/* yYpfK-rx)s-c9p>oRYid */
begin
	DBMS_CLOUD.create_credential (
	credential_name => 'OBJ_STORE_CRED',
	username => 'oracleidentitycloudservice/eugene.simos@oracle.com',
	password => 'yYpfK-rx)s-c9p>oRYid'
	) ;
end;
/
select  * from user_credentials;

/* create table CHANNELS */
/* upload the channels.txt to the object storage bucket */
/* check the reference =>  https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/oraseemeatechse/b/es1/o/channels.txt */
/* generate pre auth https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/stclVx1CFXH87gn0tnYKQL2mqcNZjInLOAeHLeBpWNA/n/oraseemeatechse/b/es1/o/channels.txt */
/* https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/kH85eoSIz3DNCVkVCfFqsiVL-inZVkYEanKFOWzxxwk/n/oraseemeatechse/b/es1/o/channels.csv */
/* load the data with sqldeveloper then with dbms_cloud.copy_data */
/* add ; to sqldevelop correction */
/* https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/AKfTbyuMxhq2E_XU3_jgMT99cvMU6mTLg1EAMVWrexU/n/oraseemeatechse/b/es1/o/ */

select table_name from atpc_user.user_tables;

select * from channels;


drop table channels;
CREATE TABLE channels ( CHANNEL_ID NUMBER(38),
  CHANNEL_DESC VARCHAR2(26),
  CHANNEL_CLASS VARCHAR2(26),
  CHANNEL_CLASS_ID NUMBER(38),
  CHANNEL_TOTAL VARCHAR2(26),
  CHANNEL_TOTAL_ID NUMBER(38)) ;
  
begin
	dbms_cloud.copy_data(
	table_name =>'CHANNELS',
	credential_name =>'OBJ_STORE_CRED',
	file_uri_list =>'https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/stclVx1CFXH87gn0tnYKQL2mqcNZjInLOAeHLeBpWNA/n/oraseemeatechse/b/es1/o/channels.txt',
	format => json_object('delimiter' value ',', 'recorddelimiter' value ''';''', 'skipheaders' value '1', 'quote' value '\"', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 'ignoreblanklines' value 'false', 'ignoremissingcolumns' value 'true')); 
end;
/
select * from channels;

drop table channels_cloud_proc;
CREATE TABLE channels_cloud_proc ( CHANNEL_ID NUMBER(38),
  CHANNEL_DESC VARCHAR2(26),
  CHANNEL_CLASS VARCHAR2(26),
  CHANNEL_CLASS_ID NUMBER(38),
  CHANNEL_TOTAL VARCHAR2(26),
  CHANNEL_TOTAL_ID NUMBER(38)) ;
begin
	dbms_cloud.copy_data(
	table_name =>'channels_cloud_proc',
	credential_name =>'OBJ_STORE_CRED',
	file_uri_list =>'https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/kH85eoSIz3DNCVkVCfFqsiVL-inZVkYEanKFOWzxxwk/n/oraseemeatechse/b/es1/o/channels.csv',
	schema_name => 'ATPC_USER',
format => json_object('delimiter' value ',', 'recorddelimiter' value '''\r\n''', 'skipheaders' value '1', 'quote' value '\"', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 'ignoreblanklines' value 'false', 'ignoremissingcolumns' value 'true')); 
end;
/
select count(*) from channels_cloud_proc;
select table_name from user_tables;

/* access log files generated during this operation  from ATP ==> object storage */

BEGIN
	DBMS_CLOUD.PUT_OBJECT(
	credential_name => 'OBJ_STORE_CRED',
	object_uri => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/AKfTbyuMxhq2E_XU3_jgMT99cvMU6mTLg1EAMVWrexU/n/oraseemeatechse/b/es1/o/COPY$24_80388.log',
	directory_name => 'DATA_PUMP_DIR',
	file_name => 'COPY$24_80388.log');
END;
/


/* swingbench */
/*  curl http://www.dominicgiles.com/swingbench/swingbench261082.zip -o swingbench.zip */
/*  unzip swingbench.zip */



SELECT * FROM DBMS_CLOUD.LIST_FILES('DATA_PUMP_DIR');



BEGIN
DBMS_CLOUD.PUT_OBJECT('OBJ_STORE_CRED','https://swiftobjectstorage.us-phoenix-1.oraclecloud.com/v1/oraseemeatechse/es1/EXPDAT01-22_47_12.DMP','DATA_PUMP_DIR','EXPDAT01-22_47_12.DMP');
END;
/
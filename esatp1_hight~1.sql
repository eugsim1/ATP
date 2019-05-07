SET sqlformat csv
spool C:\Users\root\Downloads\atp-training\atp_data.csv

/* Check if the database is a multitenant container database. */
 SELECT name, cdb, con_id from v$database;

/* Check the instance name */
SELECT INSTANCE_NAME, STATUS, CON_ID from v$instance;

/* List the services automatically created for our container */
SELECT name, con_id from v$services;

/* Display the pluggable databases. Use a new view V$PDBS */
SELECT CON_ID, NAME, OPEN_MODE from v$pdbs;


/* View new family of views CDB_xxx: */
col PDB_NAME format a8
col CON_ID format 999999
SELECT PDB_ID, PDB_NAME, DBID, GUID, CON_ID
from cdb_pdbs order by 1;

/* View the redo log files of the CDB */
SELECT GROUP#, MEMBER, CON_ID from v$logfile;

/* View the control files of the CDB */
SELECT name, con_id from v$controlfile;

/* View all data files of the CDB, including those of the root and all PDBs, with
CDB_DATA_FILES view */
SELECT FILE_NAME, TABLESPACE_NAME, FILE_ID, con_id
 from cdb_data_files
 order by con_id ;
 
 SELECT FILE_NAME, TABLESPACE_NAME, FILE_ID
 from dba_data_files;
 
 
/*  View all common and local users in cdb2 */ 
 col username format a20
select USERNAME, COMMON, CON_ID from cdb_users;

select USERNAME, COMMON,CON_ID from cdb_users
where username = 'SYSTEM';

select distinct username from cdb_users
 where common='YES';
 
select username,con_id from cdb_users
 where common='NO'; 
 
create user C##_USER identified by x CONTAINER=ALL ; 

create user local_user identified by Welcome1#1234
 CONTAINER=CURRENT;
 
create user C##_USER2 identified by  Welcome1#1234 CONTAINER=ALL; 



ALTER SESSION SET CONTAINER=cdb$root;

 
 select username, common, con_id from cdb_users
 
 select distinct username, CON_ID from cdb_users
 where common ='NO';
 
 
/* Create an audit policy AUDIT_TABLESPACE for any CREATE TABLESPACE operation in ATP */ 
 CREATE AUDIT POLICY audit_tablespace
 ACTIONS create tablespace;
 
 spool off;
 
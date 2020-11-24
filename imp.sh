#!/bin/sh

# 查看当前用户的缺省表空间
# select username,default_tablespace from user_users;
# ce shi
# 创建wsdb用户、表空间
mkdir -p /mnt/1/Myspace
chown -R oracle:oinstall /mnt/1/Myspace
su - oracle <<eofJTC
sqlplus '/as sysdba'
	CREATE TABLESPACE WSDB DATAFILE '/mnt/1/Myspace/wsdb.dbf' 
	SIZE 32M AUTOEXTEND ON NEXT 32M MAXSIZE UNLIMITED 
	EXTENT MANAGEMENT LOCAL;

	CREATE USER wsdb IDENTIFIED BY wsdb ACCOUNT UNLOCK DEFAULT TABLESPACE WSDB;

	GRANT CONNECT,RESOURCE TO wsdb;
	GRANT EXP_FULL_DATABASE,IMP_FULL_DATABASE TO wsdb;
	GRANT DBA TO wsdb;
eofJTC

# create table
su - oracle <<eofJTC
sqlplus wsdb/wsdb 
  create table dept(
	deptno number(2)    primary key,
	dname  varchar2(14) not null,
	loc    varchar2(14)
  )tablespace WSDB;
insert all into dept 
	values(10,'network','hadoop') into dept
	values(20,'sales','spark') into dept
	values(30,'systemctl','Hive') select 1 from dual;
commit;
eofJTC


# 完全model恢复 
imp wsdb/wsdb rows=y indexes=n commit=y full=y ignore=y buffer=65536 file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log

# 用户model恢复 
imp wsdb/wsdb fromuser=wsdb touser=wsdb rows=y indexes=n commit=y buffer=65536 file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log

# 表model恢复 
imp wsdb/wsdb fromuser=wsdb touser=wsdb rows=y indexes=n commit=y buffer=65536 file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log




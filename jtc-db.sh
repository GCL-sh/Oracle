#!/bin/sh

#

mkdir -p /u01/Myspace
chmod 755 /u01/Myspace
sleep 1
su - oracle <<eofJTC
sqlplus '/as sysdba'
	CREATE TABLESPACE JTC DATAFILE '/u01/Myspace/JTC.DBF' 
	SIZE 32M AUTOEXTEND ON NEXT 32M MAXSIZE UNLIMITED 
	EXTENT MANAGEMENT LOCAL;

	CREATE USER jtcadmin IDENTIFIED BY 123456 ACCOUNT UNLOCK DEFAULT TABLESPACE JTC;

	GRANT CONNECT,RESOURCE TO jtcadmin;
	GRANT EXP_FULL_DATABASE,IMP_FULL_DATABASE TO jtcadmin;
	GRANT DBA TO jtcadmin;
	shutdown immediate;
eofJTC

chown -R oracle /u01/Myspace/JTC.DBF

su - oracle <<eofJTC	
sqlplus '/as sysdba'
	startup mount;
	alter system enable restricted session;
	alter system set job_queue_processes=0;
	alter system set aq_tm_processes=0;
	alter database open;
	alter database character set AL32UTF8;
	alter database character set INTERNAL_USE AL32UTF8;
	alter database character set internal_convert AL32UTF8;
eofJTC

su - oracle <<eofdmp
sqlplus '/as sysdba'
	shutdown;
	startup;
eofdmp

#使用导入命令导入dmp文件到指定用户
imp jtcadmin/123456@localhost/orcl fromuser=jtcadmin file=/root/Desktop/exp.imp_Oracle/jtc-db.dmp ignore=y


# Oracle 用户密码过期,修改为永不过期

# 查看当前密码过期策略:
# select * from dba_profiles s where s.profile='DEFAULT' and resource_name='PASSWORD_LIFE_TIME';
# 修改密码过期策略:
# alter profile default limit password_life_time unlimited;
# 如果用户密码过期不能登录：
# sqlplus '/as sysdba'
# alter user 用户名 identified by 密码;


# Oracle 用exp命令导出数据库时出现 EXP-00091 错误的解决办法

# 产生原因：服务器端字符集和环境变量下的字符集不一样.
# 查看服务器端：SELECT * FROM V$NLS_PARAMETERS WHERE PARAMETER='NLS_CHARACTERSET';
# PARAMETER
# --------------------
# VALUE
# --------------------
# NLS_CHARACTERSET
# AL32UTF8
# 修改Oracle的环境变量 vim /home/oracle/.bash_profile 中的与服务器中的一致.
# export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
# 

# Oracle 11g 开始不推荐使用imp/exp 替代的为
























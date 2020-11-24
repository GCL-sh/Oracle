#!/bin/sh

su - oracle <<eofExpdp
sqlplus '/as sysdba'
	drop directory impdp_dmp;
	drop directory expdp_dmp;
	create directory expdp_dmp as '/u01/Myspace';
	select *from dba_directories;
	grant read,write on directory expdp_dmp to jtcadmin;
eofExpdp

# 删除备份数据
rm -r /u01/Myspace/expdp*

# 导出数据
expdp jtcadmin/123456@localhost/orcl directory=expdp_dmp dumpfile=expdp.dmp logfile=expdp.log

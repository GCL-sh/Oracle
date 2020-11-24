#!/bin/sh

# 完全备份 model
exp wsdb/wsdb@localhost/orcl rows=y indexes=n compress=n full=y file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log buffer=65536

# 用户备份 model
exp wsdb/wsdb@localhost/orcl rows=y indexes=n compress=n owner=wsdb file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log buffer=65536

# 表备份  model
exp wsdb/wsdb@localhost/orcl rows=y indexes=n compress=n file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log buffer=65536

# delect WSDB and DataFile
su - oracle <<eofIMP
sqlplus '/as sysdba'
	drop tablespace WSDB including contents and datafiles cascade constraint;
eofIMP


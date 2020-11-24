# 备份oracle中的数据. oracleBackUp.log中记录的是上一次oracle备份的时间。
# 1.先检测是否存在oracleBackUp日志，没有就是新的控制器/首次运行。
# 2.判断当前时间与上一次备份时间比较 是否>=3 满足再次备份.

if [ ! -d /mnt/1/Myspace ];then
	mkdir -p /mnt/1/Myspace
	chown -R oracle:oinstall /mnt/1/Myspace
fi

if [ ! -f /mnt/1/Myspace/oracleBackUp.log ];then
	date +%Y/%m/%d >/mnt/1/Myspace/oracleBackUp.log
	exp wsdb/wsdb@localhost/orcl owner=wsdb rows=y indexes=n compress=n file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log buffer=65536
	date +%Y/%m/%d-%H:%M:%S >/mnt/1/Myspace/oracleBackUp.date
	echo "get hadoop"
fi

sumber=`cat /mnt/1/Myspace/oracleBackUp.log|wc -c`

if [ $sumber -ge 9 ];then
  start=`cat /mnt/1/Myspace/oracleBackUp.log`
  end=$(date +%Y/%m/%d)
  timeout=$(($end - $start))
  if [ $timeout -ge 3 ];then
	exp wsdb/wsdb@localhost/orcl owner=wsdb rows=y indexes=n compress=n file=/mnt/1/Myspace/exp.dmp log=/mnt/1/Myspace/exp.log buffer=65536
	date +%Y/%m/%d-%H:%M:%S >/mnt/1/Myspace/oracleBackUp.date
	echo "get spark"
  fi
fi


# if [ ! -d xxx ];then 	判断文件夹是否存在
# if [ ! -f xxx ];then	判断文件是否存在
# if [ ! -x xxx ];then	判断文件/文件夹是否有执行权限

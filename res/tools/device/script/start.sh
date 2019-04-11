#!/bin/sh

START_CMD="carrier-server-static"

SINFO_KO_PATH=/lib/modules
SENSOR_DRV_PATH=/lib/modules
ISP_DRV_PATH=/lib/modules

check_return()
{
	if [ $? -ne 0 ] ;then
		echo err: $1
		echo exit
		exit
	fi
}

lsmod | grep "sinfo" > /dev/null
if [ $? -ne 0 ] ;then
	insmod ${SINFO_KO_PATH/%\//}/sinfo.ko
	check_return "insmod sinfo"
fi

echo 1 >/proc/jz/sinfo/info
check_return "start sinfo"

SENSOR_INFO=`cat /proc/jz/sinfo/info`
check_return "get sensor type"
echo ${SENSOR_INFO}

SENSOR=${SENSOR_INFO#*:}

lsmod | grep "tx_isp" > /dev/null
if [ $? -ne 0 ] ;then
	insmod ${ISP_DRV_PATH/%\//}/tx-isp.ko
	check_return "insmod isp drv"
fi

lsmod | grep ${SENSOR} > /dev/null
if [ $? -ne 0 ] ;then
	insmod ${SENSOR_DRV_PATH/%\//}/sensor_${SENSOR}.ko
	check_return "insmod sensor drv"
fi

echo ${START_CMD##*/} start
${START_CMD} --st=${SENSOR}
echo ${START_CMD##*/} exit


#work dir
WPATH=/usr/local/scripts/wasstat
WSADMIN=/washome/was/profiles/dmgr01/bin/wsadmin.sh
INTERVAL=60 #seconds
USRNAME=wsadmin
PASSWD=wsadmin


function restart_collector {
    for pid in `ps -ef|grep 'colWasStats.jy'|grep jython|awk '{print $2}'`; do
        kill -9 $pid
    done
    nohup $WSADMIN -lang jython -user $USRNAME -password $PASSWD -f ./colWasStats.jy $INTERVAL >>run.log 2>&1 &
}

cd "$WPATH" && mkdir output 2>/dev/null
if [ -d "$WPATH/output" ] # Folder exist
    cd "$WPATH/output"
else
    echo `date "+%Y-%m-%d %T"` "Error to create output directory" >>run.log
    exit -1
fi

# If 10 minites not updating, then restart the program, otherwise, log to run.log
wc=`find $WPATH -name "jvm.txt" -mmin -10|wc -l`;
if [ $wc -eq 0 ]; then
echo `date "+%Y-%m-%d %T"` "Detect that datafile is not updating, Restarting Collector ..." >>run.log
restart_collector
fi

# If parameter is 0, restart it rightaway
if [[ -n "$1" && "$1" -eq 0 ]]; then
    echo `date "+%Y-%m-%d %T"` "Restarting Collector ..." |tee run.log
    restart_collector
fi

echo `date "+%Y-%m-%d %T"` "Collecting operating OK" >>run.log


# Delete old data:
find "$WPATH"/output -name "*.csv" -mtime +7 -exec rm -f {} \;

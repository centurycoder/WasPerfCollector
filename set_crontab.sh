#!/usr/bin/env ksh
#
#set crontab on linux and AIX
#


typeset SN=$(hostname)


export TZ=BEIST-8
function get_time { date +%Y-%m-%d' '%T; }

function set_crontab {
    if [ `whoami` != "root" ]; then
        echo "Please run as root"
        exit
    fi

    # check if crontab has been set
    if [[ ! -z $(crontab -l 2>/dev/null|grep "/usr/local/scripts/wasstat/colWasStats.sh") ]]
    then
        echo "crontab has been set already"
        return
    fi

    cd /usr/local/scripts/wasstat/

    # backup crontab first
    typeset fname="crontab.sav.$(date +%Y%m%d.%H%M%S)"
    typeset newcronfile="crontab.new"
    crontab -l >$fname 2>/dev/null
    cp $fname $newcronfile

    function echo_content {
        echo "#"
        echo "# collect WAS performance data @$(get_time)"
        echo "#"
        echo "0 * * * * /bin/sh /usr/local/scripts/wasstat/colWasStats.sh 1>/dev/null 2>&1"
    }
    echo_content >> $newcronfile
    crontab $newcronfile
}


function main {
   set_crontab 
}


main

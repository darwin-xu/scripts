#!/bin/zsh

(( goodCount = 0 ))
(( badCount = 0 ))
(( last = 1 ))
(( duration = 0 ))

while true; do

    ping -c 1 192.168.2.1 2>&1 1> /dev/null 

    if [ "$?" != 0 ]; then
        #osascript -e 'display notification "又乒不到路由器了" with title "嗨"'
        (( badCount = $badCount + 1 ))
        if [ "$last" = 1 ]; then
            start=`date +%s`
        fi
        echo -ne "Last update: [" `date` "] good count: [" $goodCount "] bad count: [" $badCount "], last error duration: [" $duration "s]\r"
        (( last = 0 ))
    else
        (( goodCount = $goodCount + 1 ))
        if [ "$last" = 0 ]; then
            end=`date +%s`
            (( duration = $end - $start ))
            echo "Last update: [" `date` "] good count: [" $goodCount "] bad count: [" $badCount "], last error duration: [" $duration "s]\r"
        else
            echo -ne "Last update: [" `date` "] good count: [" $goodCount "] bad count: [" $badCount "], last error duration: [" $duration "s]\r"
        fi
        (( last = 1 ))
    fi

    echo -ne "Last update: [" `date` "] good count: [" $goodCount "] bad count: [" $badCount "], last error duration: [" $duration "s]\r"

    sleep 1

done


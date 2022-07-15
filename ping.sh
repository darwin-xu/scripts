#!/bin/zsh

(( goodCount = 0 ))
(( badCount = 0 ))
(( lastResult = 1 ))
(( duration = 0 ))
(( totalDur = 0 ))
(( newline = 0))

while true; do

    pingtime=`date +%s`
    #ping -s 8000 -c 1 -t 1 192.168.100.129 2>&1 1> /dev/null
    ping -s 8000 -c 1 -t 1 $1 2>&1 1> /dev/null

    if [ "$?" != 0 ]; then
        #osascript -e 'display notification "又ping不到路由器了" with title "嗨"'
        (( badCount = $badCount + 1 ))
        if [ "$lastResult" = 1 ]; then
            start=$pingtime
        fi
        (( lastResult = 0 ))
    else
        (( goodCount = $goodCount + 1 ))
        if [ "$lastResult" = 0 ]; then
            end=`date +%s`
            (( duration = $end - $start ))
            (( totalDur = $totalDur + $duration))
            (( newline = 1 ))
        else
        fi
        (( lastResult = 1 ))
    fi
    
    (( rate = $badCount * 1.0 / $goodCount ))
    echo -n "Last update: ["`date`"], good count:["$goodCount"], bad count:["$badCount"], last error duration:["$duration"s], total error duration:["$totalDur"s], error rate:["$rate"]  \r"
    if [ "$newline" = 1 ]; then
        echo
        (( newline = 0 ))
        (( duration = 0 ))
    fi

    #sleep 1

done

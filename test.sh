#!/bin/bash

if [[ -f 76309/*.tmp ]]; then
	echo "exist"
else
	echo "do not exist"
fi

exit

last=100
now=101

if [[ ($last == $now  &&  $now < 1000) ]]; then
	echo "true"
fi

exit;
# tot=`cat $x | awk '{print $1}'`
# cur=`cat $x | awk '{print $2}'`
# max=`cat $x | awk '{print $3}'`

echo ${#x}
exit

echo $tot
echo $cur
echo $max

#pct=`echo "$(printf %3d $((cur*100/tot)))%"`

printf "$(printf %2d 3)%%"
echo

exit

moved=true
x=ffffffee
y=eee
if [ $moved = true ]; then
	#echo -n "moved\r"
	#echo -n "111"
	printf "xxx\r"
	printf "11\r"
	echo ""
	echo ""

	echo ${#x}
	echo "$(printf %${#x}s $y)"
fi

exit

trap 'show' INT

sleep 100

show() {
    echo "haha"
    echo "lets"
}

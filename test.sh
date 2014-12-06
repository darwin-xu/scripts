#!/bin/bash

moved=true

if [ $moved = true ]; then
	echo "moved"
fi

exit

trap 'show' INT

sleep 100

show() {
    echo "haha"
    echo "lets"
}

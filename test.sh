#!/bin/bash

trap 'show' INT

sleep 100

show() {
    echo "haha"
    echo "lets"
}

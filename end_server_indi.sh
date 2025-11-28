#!/usr/bin/bash

DEVICE_FILE="$HOME/.svbony_device"

# DEVICE をファイルから読む
if [ ! -f "$DEVICE_FILE" ]; then
    echo "ERROR: $DEVICE_FILE がありません"
    echo "先に svbony_init.sh を実行してください"
    exit 1
fi
DEVICE=$(cat "$DEVICE_FILE")

indi_setprop "${DEVICE}.CONNECTION.DISCONNECT=On"
sleep 1
pkill indiserver

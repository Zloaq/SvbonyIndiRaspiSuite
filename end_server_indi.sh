#!/usr/bin/bash

DEVICE_FILE="$HOME/.svbony_config"

# DEVICE をファイルから読む
if [ ! -f "$DEVICE_FILE" ]; then
    echo "ERROR: $DEVICE_FILE がありません"
    echo "先に svbony_init.sh を実行してください"
    exit 1
fi

DEVICE=$(indi_getprop | grep -m1 "SVBONY CCD")
if [ -z "$devline" ]; then
    echo "ERROR: SVBONY CCD デバイスが見つかりませんでした"
    exit 1
fi

indi_setprop "${DEVICE}.CONNECTION.DISCONNECT=On"
sleep 1
pkill indiserver

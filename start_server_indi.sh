#!/usr/bin/bash

DEVICE_FILE="$HOME/.svbony_device"

# indiserver 起動
if pgrep -f indiserver >/dev/null 2>&1; then
    echo "indiserver is already running."
else
    echo "Starting indiserver..."
    nohup indiserver indi_svbony_ccd >/dev/null 2>&1 &
    sleep 5
fi

# SVBONY デバイス名自動検出
devline=$(indi_getprop | grep -m1 "SVBONY CCD")
if [ -z "$devline" ]; then
    echo "ERROR: SVBONY CCD デバイスが見つかりませんでした"
    exit 1
fi

DEVICE="${devline%%.*}"
echo "$DEVICE" > "$DEVICE_FILE"
echo "Detected DEVICE: $DEVICE"
echo "Saved to $DEVICE_FILE"

#!/bin/bash

DEVICE_FILE="$HOME/.svbony_device"

# DEVICE をファイルから読む
if [ ! -f "$DEVICE_FILE" ]; then
    echo "ERROR: $DEVICE_FILE がありません"
    echo "start_server_indi.sh を実行してください"
    exit 1
fi
DEVICE=$(cat "$DEVICE_FILE")


# 引数パース (--display は順不同, 残り1つを露光時間とみなす)
SHOW_DS9=0
EXPTIME=""
for arg in "$@"; do
    if [ "$arg" = "--display" ]; then
        SHOW_DS9=1
    else
        EXPTIME="$arg"
    fi
done

if [ -z "$EXPTIME" ]; then
    echo "Usage: $0 <exposure_value> [--display]"
    exit 1
fi

# UPLOAD_DIR を取得
prop=$(indi_getprop "${DEVICE}.UPLOAD_SETTINGS.UPLOAD_DIR")
if [ -z "$prop" ]; then
    echo "ERROR: UPLOAD_DIR を取得できませんでした"
    echo "start_server_indi.sh でサーバーを起動してください"
    exit 1
fi

WATCH_DIR=${prop#*=}

if [ ! -d "$WATCH_DIR" ]; then
    echo "ERROR: UPLOAD_DIR がディレクトリとして存在しません: $WATCH_DIR"
    exit 1
fi

# 露光開始前時点での最新ファイルを覚えておく（無ければ空）
before_newest=$(ls -t "$WATCH_DIR"/*.fits 2>/dev/null | head -n 1)
if [ -n "$before_newest" ]; then
    before_mtime=$(stat -c %Y "$before_newest")
else
    before_mtime=0
fi

# 露光開始
indi_setprop "${DEVICE}.CCD_EXPOSURE.CCD_EXPOSURE_VALUE=${EXPTIME}"
sleep ${EXPTIME}

TIMEOUT=20
elapsed=0

while true; do
    newest=$(ls -t "$WATCH_DIR"/*.fits 2>/dev/null | head -n 1)
    if [ -n "$newest" ]; then
        newest_mtime=$(stat -c %Y "$newest")
        if [ "$newest" != "$before_newest" ] || [ "$newest_mtime" -gt "$before_mtime" ]; then
            break
        fi
    fi
    sleep 0.5
    elapsed=$((elapsed + 1))
    if [ "$elapsed" -ge "$TIMEOUT" ]; then
        echo "ERROR: ${TIMEOUT}回チェックしても新しいファイルが検出されませんでした"
        exit 1
    fi
done

echo "検出したファイル名: $newest"

if [ $SHOW_DS9 -eq 1 ]; then
    xpaset -p ds9 file "$newest"
    sleep 0.2
    xpaset -p ds9 scale zscale
    xpaset -p ds9 zoom to fit
fi

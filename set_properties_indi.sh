#!/usr/bin/bash

DEVICE_FILE="$HOME/.svbony_device"

# DEVICE をファイルから読む
if [ ! -f "$DEVICE_FILE" ]; then
    echo "ERROR: $DEVICE_FILE がありません"
    echo "先に svbony_init.sh を実行してください"
    exit 1
fi

prop=$(indi_getprop "${DEVICE}.UPLOAD_SETTINGS.UPLOAD_DIR")
if [ -z "$prop" ]; then
    echo "start_server_indi.sh でサーバーを起動してください"
    exit 1
fi

DEVICE=$(cat "$DEVICE_FILE")
echo "Using DEVICE: $DEVICE"


#----ほとんど変えないであろう設定-------
indi_setprop "${DEVICE}.CONNECTION.CONNECT=On"
indi_setprop "${DEVICE}.CCD_ABORT_EXPOSURE.ABORT=Off"
indi_setprop "${DEVICE}.CCD_FRAME.X=0"
indi_setprop "${DEVICE}.CCD_FRAME.Y=0"
indi_setprop "${DEVICE}.CCD_FRAME.WIDTH=1608"
indi_setprop "${DEVICE}.CCD_FRAME.HEIGHT=1104"
indi_setprop "${DEVICE}.CCD_BINNING.HOR_BIN=1"
indi_setprop "${DEVICE}.CCD_BINNING.VER_BIN=1"

indi_setprop "${DEVICE}.CCD_TEMP_RAMP.RAMP_SLOPE=0"
indi_setprop "${DEVICE}.CCD_TEMP_RAMP.RAMP_THRESHOLD=0.2000000000000000111"
indi_setprop "${DEVICE}.CCD_COOLER_POWER.CCD_COOLER_VALUE=0"

indi_setprop "${DEVICE}.CCD_FRAME_TYPE.FRAME_LIGHT=On"
indi_setprop "${DEVICE}.CCD_FRAME_TYPE.FRAME_BIAS=Off"
indi_setprop "${DEVICE}.CCD_FRAME_TYPE.FRAME_DARK=Off"
indi_setprop "${DEVICE}.CCD_FRAME_TYPE.FRAME_FLAT=Off"

indi_setprop "${DEVICE}.CCD_INFO.CCD_MAX_X=1608"
indi_setprop "${DEVICE}.CCD_INFO.CCD_MAX_Y=1104"
indi_setprop "${DEVICE}.CCD_INFO.CCD_PIXEL_SIZE=9"
indi_setprop "${DEVICE}.CCD_INFO.CCD_PIXEL_SIZE_X=9"
indi_setprop "${DEVICE}.CCD_INFO.CCD_PIXEL_SIZE_Y=9"
indi_setprop "${DEVICE}.CCD_INFO.CCD_BITSPERPIXEL=16"

#svbony の限界解像度
indi_setprop "${DEVICE}.ADC_DEPTH.BITS=12"

indi_setprop "${DEVICE}.CCD_CAPTURE_FORMAT.SVB_IMG_Y8=Off"
indi_setprop "${DEVICE}.CCD_CAPTURE_FORMAT.SVB_IMG_Y16=On"

indi_setprop "${DEVICE}.CCD_TRANSFER_FORMAT.FORMAT_FITS=On"
indi_setprop "${DEVICE}.CCD_TRANSFER_FORMAT.FORMAT_NATIVE=Off"
#indi_setprop "${DEVICE}.CCD_TRANSFER_FORMAT.=Off"

indi_setprop "${DEVICE}.CCD_COMPRESSION.INDI_ENABLED=Off"
indi_setprop "${DEVICE}.CCD_COMPRESSION.INDI_DISABLED=On"

indi_setprop "${DEVICE}.UPLOAD_MODE.UPLOAD_CLIENT=Off"
indi_setprop "${DEVICE}.UPLOAD_MODE.UPLOAD_LOCAL=On"
indi_setprop "${DEVICE}.UPLOAD_MODE.UPLOAD_BOTH=Off"

indi_setprop "${DEVICE}.CCD_FAST_TOGGLE.INDI_ENABLED=Off"
indi_setprop "${DEVICE}.CCD_FAST_TOGGLE.INDI_DISABLED=On"
indi_setprop "${DEVICE}.CCD_FAST_COUNT.FRAMES=1"

#----要チェック一応先生に確認----
indi_setprop "${DEVICE}.CCD_CONTROLS.Gain=0"
indi_setprop "${DEVICE}.CCD_CONTROLS.Contrast=50"
indi_setprop "${DEVICE}.CCD_CONTROLS.Sharpness=0"
indi_setprop "${DEVICE}.CCD_CONTROLS.Gamma=100"
indi_setprop "${DEVICE}.CCD_CONTROLS.Frame speed=2"
indi_setprop "${DEVICE}.CCD_CONTROLS.Offset=0"
indi_setprop "${DEVICE}.CCD_CONTROLS.Auto exposure target=100"
indi_setprop "${DEVICE}.CCD_CONTROLS.Bad pixel correction=0"
indi_setprop "${DEVICE}.CCD_CONTROLS.Bad pixel correction threshold=60"


#----変更する可能性のあるコマンド----
indi_setprop "${DEVICE}.FLIP.FLIP_HORIZONTAL=Off"
indi_setprop "${DEVICE}.FLIP.FLIP_VERTICAL=Off"


#----ファイル保存に関するコマンド----
# ↓ これで保存するディレクトリを編集する
indi_setprop "${DEVICE}.UPLOAD_SETTINGS.UPLOAD_DIR=$HOME"

#ファイル名(${DEVICE}.CCD_FILE_PATH.FILE_PATH)はUPLOAD_PREFIXに沿って積分後に勝手に更新される
#${DEVICE}.CCD_FILE_PATH.FILE_PATHは次の画像名ではなくて最後に保存したファイル名っぽい
#${DEVICE}.CCD_FILE_PATH.FILE_PATHを直接変更することはできない
# ↓ これを編集しても保存ファイル名は変更できない
#indi_setprop "${DEVICE}.CCD_FILE_PATH.FILE_PATH=/home/pi/svbony/data/IMAGE_008.fits"
# ↓ これを編集することで保存ファイル名を変更できる
indi_setprop "${DEVICE}.UPLOAD_SETTINGS.UPLOAD_PREFIX=IMAGE_XXX"
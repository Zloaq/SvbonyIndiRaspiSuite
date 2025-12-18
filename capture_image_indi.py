#!/usr/bin/env python3

import argparse
import glob
import os
import subprocess
import sys
import time
from pathlib import Path

import astropy.io.fits as fits
import numpy as np


DEVICE_FILE = Path.home() / ".svbony_config"


def run_cmd(cmd: list[str]) -> str:
    """外部コマンドを実行して stdout を返す（失敗時は例外）"""
    r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if r.returncode != 0:
        raise RuntimeError(f"command failed: {' '.join(cmd)}\n{r.stderr.strip()}")
    return r.stdout.strip()


def read_config() -> dict[str, str]:
    if not DEVICE_FILE.exists():
        print(f"ERROR: {DEVICE_FILE} がありません", file=sys.stderr)
        print("start_server_indi.sh を実行してください", file=sys.stderr)
        sys.exit(1)

    config: dict[str, str] = {}

    with DEVICE_FILE.open("r", encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            config[key] = value

    if not config:
        print(f"ERROR: {DEVICE_FILE} に有効な設定が見つかりません", file=sys.stderr)
        sys.exit(1)

    return config


def config_truthy(config: dict[str, str], key: str) -> bool:
    """
    config の値（文字列）を真偽値として解釈する。
    例: 1/true/yes/on (大小無視) を True、0/false/no/off/空を False
    """
    v = config.get(key, "")
    if v is None:
        return False
    v = str(v).strip().lower()
    return v in ("1", "true", "yes", "y", "on")


def newest_fits(watch_dir: str) -> str | None:
    files = glob.glob(os.path.join(watch_dir, "*.fits"))
    if not files:
        return None
    # mtime の降順
    return max(files, key=lambda p: os.stat(p).st_mtime)


def main():
    p = argparse.ArgumentParser(
        description="INDI で露光して、保存された最新 .fits を検出する"
    )
    p.add_argument("exposure_value", type=float, help="露光時間（秒）")
    p.add_argument("--display", action="store_true", help="ds9 に表示する")
    args = p.parse_args()

    config = read_config()
    device = config.get("DEVICE")

    if not device:
        print(f"ERROR: {DEVICE_FILE} に DEVICE= が見つかりません", file=sys.stderr)
        sys.exit(1)

    # UPLOAD_DIR を取得
    try:
        prop = run_cmd(["indi_getprop", f"{device}.UPLOAD_SETTINGS.UPLOAD_DIR"])
    except Exception:
        print("ERROR: UPLOAD_DIR を取得できませんでした", file=sys.stderr)
        print("start_server_indi.sh でサーバーを起動してください", file=sys.stderr)
        sys.exit(1)

    # "xxx=PATH" を想定
    if "=" not in prop:
        print(f"ERROR: UPLOAD_DIR の形式が想定外です: {prop}", file=sys.stderr)
        sys.exit(1)

    watch_dir = prop.split("=", 1)[1]
    if not os.path.isdir(watch_dir):
        print(f"ERROR: UPLOAD_DIR がディレクトリとして存在しません: {watch_dir}", file=sys.stderr)
        sys.exit(1)

    # 露光開始前の最新ファイルと mtime を覚える（無ければ 0）
    before_newest = newest_fits(watch_dir)
    before_mtime = os.stat(before_newest).st_mtime if before_newest else 0

    # 露光開始
    try:
        run_cmd(["indi_setprop", f"{device}.CCD_EXPOSURE.CCD_EXPOSURE_VALUE={args.exposure_value}"])
    except Exception as e:
        print(f"ERROR: 露光開始に失敗: {e}", file=sys.stderr)
        sys.exit(1)

    time.sleep(args.exposure_value)

    # 保存された最新ファイルを検出
    TIMEOUT = 20        # bash版と同じ「回数」
    INTERVAL = 0.5
    elapsed = 0

    while True:
        newest = newest_fits(watch_dir)
        if newest:
            newest_mtime = os.stat(newest).st_mtime
            if (before_newest is None) or (newest != before_newest) or (newest_mtime > before_mtime):
                break

        time.sleep(INTERVAL)
        elapsed += 1
        if elapsed >= TIMEOUT:
            print(f"ERROR: {TIMEOUT}回チェックしても新しいファイルが検出されませんでした", file=sys.stderr)
            sys.exit(1)

    if config_truthy(config, "ROTATE_IMAGE_90"):
        with fits.open(newest, mode="update") as hdul:
            hdu = hdul[0]
            if hdu.data is None:
                raise RuntimeError("FITS に画像データがありません (HDU[0].data is None)")
            hdu.data = np.rot90(hdu.data, k=1)  # 90度反時計回り
            hdu.header["NAXIS1"] = hdu.data.shape[1]
            hdu.header["NAXIS2"] = hdu.data.shape[0]
            hdul.flush()

    print(f"検出したファイル名: {newest}")

    if args.display:
        # ds9 に表示（bash版と同じ）
        try:
            run_cmd(["xpaset", "-p", "ds9", "file", newest])
            time.sleep(0.2)
            run_cmd(["xpaset", "-p", "ds9", "scale", "zscale"])
            run_cmd(["xpaset", "-p", "ds9", "zoom", "to", "fit"])
        except Exception as e:
            print(f"WARNING: ds9 表示に失敗: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
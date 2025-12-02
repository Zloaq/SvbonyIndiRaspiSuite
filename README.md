# SVBONY + INDI Setup for Raspberry Pi

Raspberry Pi 上で INDI と SVBONY カメラを使うためのセットアップと撮像手順のまとめ。  
コマンドラインから撮像できるようにするためのものです。  
静止画像モードに特化しています。


---
## 基本的な使用の流れ

1. **(初回のみ)**  
   下記の「インストール」手順に従って  
   - INDI 本体と 3rdparty、Svbony ドライバ群をビルド・インストールする。  
   - 使う人は saods9 と xpa-tools も install  
   - このリポジトリを好きなディレクトリに clone したらスクリプトが入る。  
   `git clone https://github.com/Zloaq/SvbonyIndiRaspiSuite`  

2. **カメラを接続**  
   Svbony カメラを Raspberry Pi の USB ポートに接続する。  

3. **INDI サーバーを起動**  
   `./start_server_indi.sh`  

4. **撮像の設定**  
    これの中を編集して実行。  
   `./set_properties_indi.sh`  
   
5. **撮像**  
    取りたい分だけ撮像 (積分時間 と ds9に表示するオプション)  
    `./capture_image_indi.sh [exptime] [--display]`  

6. **終了**  
    `./end_server_indi.sh`  

---

## スクリプト一覧

INDI サーバー を用いて Svbony カメラの撮像を  
コマンドラインから簡単に扱うためのシェルスクリプトが入っています。  
基本的に上から順に実行します。

- `start_server_indi.sh`  
   INDI サーバーを起動し、  
   接続されているデバイスの名前を "$HOME/.svbony_device" に保存。

- `set_properties_indi.sh`  
   カメラの gain や冷却、ファイル保存先・命名ルール等を設定するスクリプト。  
   意図に合わせて編集して、実行する。

- `capture_image_indi.sh [exptime] [--display]`  
   積分時間を引数に取り、積分が開始されます。  
   --display をつけると xpaset で ds9 に飛ばします。  

- `end_server_indi.sh`  
   起動中の INDI サーバーを停止するスクリプト。 
   全て終了するときに実行。

- `update_from_github.sh`  
   このリポジトリを GitHub の最新状態に更新するためのスクリプト。  
   バグ修正や機能追加を取り込みたいときに実行します。  
   GitHub 上と全く同じ状態になります。

---



## インストール（最初の1回だけ、コピペで実行OK）

**saods9, xpa-tools のインストール**  
```bash
sudo apt install saods9 xpa-tools
```

**INDI 本体と 3rdparty, Svbony ドライバ群のビルド・インストール**  

```bash
#0. 先にまとめて apt install
sudo apt update
sudo apt install git cmake build-essential libusb-1.0-0-dev zlib1g-dev \
  libev-dev libcfitsio-dev libnova-dev libcurl4-openssl-dev libgsl-dev \
  libjpeg-dev libfftw3-dev libraw-dev libftdi1-dev libdc1394-dev \
  libgps-dev libgphoto2-dev libzmq3-dev libudev-dev

#1. INDI 本体のビルド & インストール
#sudo apt update
#sudo apt install git cmake build-essential libusb-1.0-0-dev zlib1g-dev
git clone https://github.com/indilib/indi.git
cd indi
mkdir build
cd build
#sudo apt install libev-dev
#sudo apt install libcfitsio-dev libnova-dev
#sudo apt install libcurl4-openssl-dev
#sudo apt install libgsl-dev
#sudo apt install libjpeg-dev
#sudo apt install libfftw3-dev
cmake ..
make -j4
sudo make install
sudo ldconfig
which indiserver
indiserver -v

#2. INDI 3rdparty のビルド & インストール
cd ~
git clone https://github.com/indilib/indi-3rdparty.git
cd indi-3rdparty
mkdir build
cd build
#sudo apt install libraw-dev
#sudo apt install libftdi1-dev
#sudo apt install libdc1394-dev
#sudo apt install libgps-dev
#sudo apt install libgphoto2-dev libzmq3-dev
#sudo apt install libudev-dev
cmake ..
make -j4
sudo make install
sudo ldconfig

#3. Svbony 関連ドライバの個別ビルド & インストール
# 1) libsvbony
cd ~/indi-3rdparty
mkdir -p build-libsvbony
cd build-libsvbony
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../libsvbony
make -j4
sudo make install
sudo ldconfig

# 2) libsvbonycam
cd ~/indi-3rdparty
mkdir -p build-libsvbonycam
cd build-libsvbonycam
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../libsvbonycam
make -j4
sudo make install
sudo ldconfig

# 3) indi-svbony ドライバ本体
cd ~/indi-3rdparty
mkdir -p build-indi-svbony
cd build-indi-svbony
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../indi-svbony
make -j4
sudo make install
sudo ldconfig
```

---
## indi の基本的なコマンドの使い方

**`indi_getprop`（プロパティ確認）**
- 全部表示  
  ```
  indi_getprop
  ```
- 一部表示  
  ```
  indi_getprop "<パラメータ名>"
  ```



**`indi_setprop`（プロパティ設定）**
- 基本書式  
  ```
  indi_setprop "<パラメータ名>=<設定したい値>"
  ```

- 保存ファイル名  
  ```
  SVBONY CCD <デバイス名>.CCD_FILE_PATH.FILE_PATH=<filepath>  
  これは直接変更できなかった。
  SVBONY CCD <デバイス名>.UPLOAD_SETTINGS.UPLOAD_PREFIX=IMAGE_XXX  
  保存ファイル名を変更するなら、こっちのパラメータを変更する。  
  ```
  

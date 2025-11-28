# INDI + SVBONY Setup (Raspberry Pi)

Raspberry Pi 上で INDI と SVBONY カメラを使うためのセットアップと撮像手順のまとめ。
コマンドラインから撮像できるようにするためのものです。
静止画像モードに特化しています。


---

## スクリプト一覧

INDI サーバー を用いて Svbony カメラの撮像を  
コマンドラインから簡単に扱うためのシェルスクリプトが入っています。  
基本的に上から順に実行します。

- `start_server_indi.sh`  
   INDI サーバーを起動し、接続されているデバイスの名前を "$HOME/.svbony_device" に保存。

- `set_properties_indi.sh`  
   カメラの gain や冷却、ファイル保存先・命名ルール等を設定するスクリプト。
   意図に合わせて編集する。

- `capture_image_indi.sh [exptime]`  
   積分時間を引数に取り、保存されたファイルを検出し、saods9 に xpaset で飛ばします。
   xpaset いらない人はごめんコメントアウトしといて。
   これを編集して、ファイル名を毎回指示するのもありだと思う。

- `end_server_indi.sh`  
   起動中の INDI サーバーを停止するスクリプト。 
   全て終了するときに実行。
  

- `update_from_github.sh`  
   このリポジトリを GitHub の最新状態に更新するためのスクリプト。  
   バグ修正や機能追加を取り込みたいときに実行します。

---

## 基本的な使用の流れ

1. **(初回のみ)** 
   下記の「インストール」手順に従って 
   saods9 と xpa-tools をインストール ( fits画像の表示と通信コマンド )
   INDI 本体と 3rdparty、Svbony ドライバ群をビルド・インストールする。

2. **カメラを接続**  
   Svbony カメラを Raspberry Pi の USB ポートに接続する。

3. **INDI サーバーを起動**  
   リポジトリ直下で:
   
   `./start_server_indi.sh`  
   `./set_properties_indi.sh`  
   
4. **撮像**  
    取りたい分だけ撮像  
    `./capture_image_indi.sh [exptime]`

5. **終了**  
    `update_from_github.sh`  
---

## インストール（最初の1回だけ、コピペで実行OK）

**saods9, xpa-tools のインストール**
`sudo apt install saods9 xpa-tools`

**INDI 本体と 3rdparty、Svbony ドライバ群のビルド・インストール**

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



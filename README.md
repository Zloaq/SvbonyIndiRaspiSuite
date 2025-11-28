# INDI + Svbony Setup (Raspberry Pi)

Raspberry Pi 上で INDI と Svbony カメラを使うためのセットアップと撮像手順のまとめ。  
インストールは最初の 1 回だけで、以降は撮像スクリプトのみで運用できる。







---

## インストール（最初の1回だけ、コピペで実行OK）

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



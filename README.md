# Debos recipes for Fairphone 2

This repository allows you to build a debian or ubuntu image to be flashed on the fairphone 2 userdata partition.
It uses a pre-built kernel and initramfs.

After building, you should use `img2simg` to create a sparse image before flashing it with fastboot.

It is part of the `android-sdk-libsparse-utils` on debian bookworm so be sure to install it with:
```
sudo apt install android-sdk-libsparse-utils
```

Or the equivalent for your linux distribution and version.

## Prerequisite

You need to have lk2nd flashed on the boot partition of your fairphone 2 for these images to work. Download it [here](https://github.com/msm8916-mainline/lk2nd/releases/download/20.0/lk2nd-msm8974.img) and run:
```
fastboot flash boot lk2nd-msm8974.img
fastboot reboot
```

## Building

```
debos debian.yml # or ubuntu.yml
img2simg debian-fp2.img sparse-debian-fp2.img # or ubuntu.img ...
fastboot flash userdata sparse-debian-fp2.img
fastboot reboot
# Enjoy running debian or ubuntu on your fairphone
```

## Flashing pre built images

Go to releases on this github page, select one, download either `sparse-debian-fp2.img` or `sparse-ubuntu-fp2.img` and flash it with fastboot as explained above.

## Connecting to your fp2 via usb

A static IP is assigned to the `usb0` interface with a dhcp server on the phone so you can just plug your fp2 to your host via usb and use:
```
ssh root@10.0.42.1
# password is root
```

## Using Wifi

The networking setup is done with `systemd-networkd` and to have wifi working you will need to ssh to your fp2 using the method above and edit two files as follows:

1. Uncomment everything in `/etc/network/interfaces.d/wlan0`
```
auto wlan0
iface wlan0 inet dhcp
  pre-up wpa_supplicant -i wlan0 -c /etc/wpa_supplicant.conf -B
  post-down killall -q wpa_supplicant
```
2. Set your SSID and passkey in `/etc/wpa_supplicant.conf`
```
disable_scan_offload=1
tdls_external_control=1
driver_param=use_p2p_group_interface=1

network={
    #key_mgmt=WPA-PSK
    ssid="your ssid here"
    psk="your psk here"
}
```
3. Restart networking
```
systemctl restart networking
```

You should now be connected to your wifi network.

## Resizing the rootfs to take all the userdata empty space

By default, the image rootfs is only a few 100MB. In order to extend it to the full remaining size of the userdata partition, run the following:
```
kpartx -d /dev/mapper/mmcblk0p20p2
growpart /dev/mmcblk0p20 2
kpartx -asf /dev/mmcblk0p20
resize2fs /dev/mmcblk0p20p2
```

if it fails the first time (it happes, I don't know why yet), then run those commands a second time and you should see your `/` taking several GB now.

## Disclaimer
This is a very early stage support. Use it at your own risk.

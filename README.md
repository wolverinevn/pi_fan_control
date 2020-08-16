# pi_fan_control
Control cooling fan speed on Rasperry Pi using a mosfet.

Guide-VI: https://konnected.vn/tech/raspberry-pi-tan-nhiet-chu-dong-theo-cpu-2020-08-16

Including:
+ python program to controll Fan speed
+ Configuration file
+ Installer script to install all dependencies and enable program at boot
+ Program will be auto-run with highest priority


## WIRING

![panel card screenshot](https://github.com/wolverinevn/pi_fan_control/blob/master/konnected_vn_Pi-Fan-Control-8-16-2020.jpg?raw=true "Wriring Diagram")

## INSTALL

```
curl -sL https://github.com/wolverinevn/pi_fan_control/releases/download/v0.1/pi_fan.zip -o pi_fan.zip
unzip pi_fan.zip && rm pi_fan.zip
cd pi_fan
sudo ./install.sh
```
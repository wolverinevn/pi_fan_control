#! /bin/bash
if [ "$EUID" -ne 0 ]
  then echo "[WARN] Please run as root. Use sudo: sudo ./install.sh"
  exit 1;
fi

bin_dir="/usr/share/pi_fan"
working_dir=$(cd `dirname $0` && pwd)

echo "Install PWM CPU Fan Control Script for Raspberry Pi 3B/3B+/4B"
echo "by konnect ED Vietnam (konnected.vn)"
echo "Config file will be found at ${bin_dir}"

#print out wiring info
schematic_help () {

  if [ `which pinout` ]; then
    echo "Your Pi Revision and Pinout"
    echo ""
    pinout
    sleep 1
  fi
  
  echo ""
  echo "*** Wiring Diagram"
  echo -e "Control PIN is GPIO17(pin11)"
  echo -e "     \033[47m+5V-----------------------------+5V(pin2)\033[m"
  echo -e "\033[42m[FAN]\033[m       \033[47m|--G pin-------------GPIO17(pin11)\033[m  \033[43m[PI]\033[m"
  echo -e "     \033[47mGND-------D pin\033[m  \033[46m[MOSFET]\033[m"
  echo -e "            \033[47m|--S pin-----------------GND(pin9)\033[m"
  echo "(more resistors and diodes maybe needed)"
  echo ""
  echo -e "\033[31mNEVER ever connect Fan wires directly to GPIO pins, except for +5V, +3.3V and GND\033[m"
  echo "***"
}

#check arguments
arg=$1

if [ "$arg" == "--uninstall" ] || [ "$arg" == "-u" ]; then
  echo "Stop and remove script from system"
  systemctl stop pi_fan
  /bin/rm -rf /lib/systemd/system/pi_fan.service
  systemctl daemon-reload
  /bin/rm -rf $$bin_dir/pi_fan.py
  /bin/rm -rf $$bin_dir/config.json
  echo "Done."
  exit 0;
fi

if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
  schematic_help
  echo ""
  echo -e "  ./install.sh    \t Install in interactive mode, on default control gpio (17)"
  echo -e "  ./install.sh -a \t Install automatically, no human-interact needed"
  echo -e "  ./install.sh -u \t Stop and remove script"
  echo -e "  ./install.sh -h \t Print this help"
  echo "GPIO can be changed by modifying pin value in $working_dir/config.json before installation"
  echo "or $bin_dir/config.json after successful installation"
  exit 0;
fi

#install needed package
python3_install=""
rpigpio_install=""

#check if python3 was install
python3_status=$(dpkg-query -W --showformat='${Status}\n' python3|grep "install ok installed")
#or [ ! `which python3` ]

if [ "" == "$python3_status" ]; then
  echo "Python3 is not installed yet. Install now? (Y/n)"
  if [ ! "$arg" == "-a" ]; then
    read python3_install
  fi
  
  if [ "$python3_install" == "y" ] || [ "$python3_install" == "Y" ] || [ "$python3_install" == "" ]; then
    apt-get --force-yes --yes install python3
  else
    echo "Exit. CPU Fan Control is not installed."
    exit 1;
  fi
fi

#check if rpi.gpio is enabled
rpigpio_status=$( python3 -c "import RPi.GPIO" )
if [ $? == 1 ]; then
  echo "RPI.GPIO is not installed yet. Install now? (Y/n)"
  if [ ! "$arg" == "-a" ]; then
    read rpigpio_install
  fi
  
  if [ "$rpigpio_install" == "y" ] || [ "$rpigpio_install" == "Y" ] || [ "$rpigpio_install" == "" ]; then
    sudo apt-get install python3-rpi.gpio
  else
    echo "Exit. CPU Fan Control is not installed."
    exit 1;
  fi
fi

schematic_help

#main install
proceed=""
if [ ! "$arg" == "-a" ]; then
  echo "Proceed installation? (Y/n)"
  read proceed
fi

if [ "$proceed" == "y" ] || [ "$proceed" == "Y" ] || [ "$proceed" == "" ]; then
  echo "Copy script to $bin_dir"
  /bin/mkdir -p $bin_dir
  /bin/cp -rf "$working_dir/pi_fan.py" $bin_dir
  /bin/cp -rf "$working_dir/config.json" $bin_dir

  echo "Enable script on startup"

#create systemd service file
  touch -f /lib/systemd/system/pi_fan.service
#truncate content of service file
  echo "" > /lib/systemd/system/pi_fan.service

  cat <<EOT >> /lib/systemd/system/pi_fan.service
[Unit]
Description=CPU Fan Control
After=multi-user.target

[Service]
Type=idle
ExecStart=/usr/bin/python3 ${bin_dir}/pi_fan.py
CPUSchedulingPolicy=rr
CPUSchedulingPriority=60

[Install]
WantedBy=multi-user.target
EOT

  systemctl daemon-reload
  systemctl enable pi_fan
  systemctl restart pi_fan

  echo "Script status:"
  systemctl status pi_fan

  echo "Done installing."
else
  echo "Exit. CPU Fan Control is not installed."
fi

  exit 0;
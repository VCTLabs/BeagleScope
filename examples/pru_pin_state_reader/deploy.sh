#! /bin/bash
# The script builds the pru_pin_state_reader project and configures the pinmuxing for P8_45

#Do not change until you are making required changes in the firmware code.  
HEADER=P8_
PIN_NUMBER=45
#The firmware will need significant changes to port it to PRU_CORE 2
PRU_CORE=1

echo "*******************************************************"
echo "This must be compiled on the BEAGLEBONE BLACK itself"
echo "It was tested on 4.4.11-ti-r29 kernel version"
echo -e "The program makes PRU continously read P8_45 and output \"CHANGED\" if the state of pin changes"
echo "The firmware source is based on pru-software-support-package by TI and can be cloned from"
echo "git clone git://git.ti.com/pru-software-support-package/pru-software-support-package.git"
echo "******NOTE: use a resistor >470 ohms to connect to the LED, I have alredy made this mistake."
echo "To continue, press any key:"
read

echo "-Building project"
	cd PRU_PIN_STATE_READER
	make clean
	make

echo "-Placing the firmware"
	cp gen/*.out /lib/firmware/am335x-pru$PRU_CORE-fw

echo "-Configuring pinmux"
	config-pin -a $HEADER$PIN_NUMBER pruin
	config-pin -q $HEADER$PIN_NUMBER

echo "-Rebooting"
	if [ $PRU_CORE -eq 0 ]
	then
		echo "Rebooting pru-core 0"
		echo "4a334000.pru0" > /sys/bus/platform/drivers/pru-rproc/unbind 2>/dev/null
		echo "4a334000.pru0" > /sys/bus/platform/drivers/pru-rproc/bind
	else
		echo "Rebooting pru-core 1"
		echo "4a338000.pru1"  > /sys/bus/platform/drivers/pru-rproc/unbind 2> /dev/null
		echo "4a338000.pru1" > /sys/bus/platform/drivers/pru-rproc/bind
	fi

echo "********************************************************"
echo -e "Done. Now \"echo S > /dev/rpmsg_pru31 && cat /dev/rpmsg_pru31\" and change the logical state of P8_45"
echo "********************************************************"
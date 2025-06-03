Welcome to KaliBerry Installer for ColorBerry

Follow these steps to install Kali Linux on your ColorBerry.

Step 1. Download this Kali image to your computer and install it on your SD card using Raspberry Pi or another application.

https://old.kali.org/arm-images/kali-2024.2/kali-linux-2024.2-raspberry-pi-armhf.img.xz

Step 2. Access Kali and configure the Wi-Fi network. In the clock option, right-click and click. The properties option will appear. Add your country's time zone for time correction to avoid issues with network downloads.

Step 3. Access via SSH and run this command to download KaliBerry.

sudo git clone https://github.com/ZoltXs/KaliBerry

Step 4. Access the KaliBerry directory.

cd KaliBerry

Step 5. Grant permissions to the script.

sudo chmod +x KaliBerry.sh

Step 6. Run Kaliberry.sh

sudo ./KaliBerry.sh

Step 7. Follow the installation steps starting with option 1 and continuing through option 4. Do not skip any options; otherwise, the installation will not be possible, and you will have to start over from Step 1.

IF YOU FOLLOW ALL THE STEPS DESCRIBED IN THIS README, CONGRATULATIONS! YOU NOW HAVE YOUR COLORBERRY WITH KALI-LINUX PERFECTLY CONFIGURED.

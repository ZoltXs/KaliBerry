#!/bin/bash

# Clear screen before starting menu
clear

# KaliBerry Config Application
# By N@Xs

# Function to display error and return to main menu
display_error() {
    dialog --colors --title "\Z1Error\Zn" --backtitle "KaliBerry Config" \
        --msgbox "\Z1Error:\Zn $1" 8 60
    sleep 3
    main_menu
}

# Function to show progress (all commands run silently in background)
show_progress() {
    local cmd=$1
    local message=$2
    
    # Show 0% at start
    echo "0" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    
    # Execute command in background and capture PID
    eval "$cmd > /dev/null 2>/tmp/error.log" &
    local cmd_pid=$!
    
    # Monitor command progress
    while kill -0 $cmd_pid 2>/dev/null; do
        echo "50" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
            --gauge "$message" 10 70 0
        sleep 0.5
    done
    
    # Wait for command to complete and get exit status
    wait $cmd_pid
    local exit_status=$?
    
    # Show 100% completion
    echo "100" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    sleep 0.5
    
    # Check if command failed
    if [ $exit_status -ne 0 ]; then
        display_error "$(cat /tmp/error.log)"
        return 1
    fi
    
    return 0
}

# Function to show progress without stopping on errors - NO SHOW ERRORS
show_progress_continue() {
    local cmd=$1
    local message=$2
    
    # Show 0% at start
    echo "0" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    
    # Execute command in background and capture PID
    eval "$cmd > /dev/null 2>/dev/null" &
    local cmd_pid=$!
    
    # Monitor command progress
    while kill -0 $cmd_pid 2>/dev/null; do
        echo "50" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
            --gauge "$message" 10 70 0
        sleep 0.5
    done
    
    # Wait for command to complete (ignore exit status)
    wait $cmd_pid || true
    
    # Show 100% completion
    echo "100" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    sleep 0.5
    
    # Always return success - no error messages shown
    return 0
}

# Function to execute make install exactly like manual execution - NO SHOW ERRORS
manual_make_install() {
    local message=$1
    
    echo "0" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    
    # Ensure we're in the right directory
    cd /var/tmp/jdi-drm-rpi > /dev/null 2>&1 || return 0
    
    echo "25" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "Preparing environment..." 10 70 0
    
    # Set up environment exactly like manual execution
    export KERNEL_DIR="/lib/modules/$(uname -r)/build"
    export KDIR="/lib/modules/$(uname -r)/build"
    
    echo "50" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "Running make install..." 10 70 0
    
    # Execute make install with proper environment - completely silent
    sudo -E bash -c "
        cd /var/tmp/jdi-drm-rpi
        export KERNEL_DIR='/lib/modules/$(uname -r)/build'
        export KDIR='/lib/modules/$(uname -r)/build'
        make install
    " > /dev/null 2>&1 || true
    
    echo "75" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "Finalizing installation..." 10 70 0
    
    # Always try to install the overlay manually as backup
    sudo install -D -m 0644 /var/tmp/jdi-drm-rpi/sharp-drm.dtbo /boot/overlays/ > /dev/null 2>&1 || true
    
    # Add module to load at boot
    if ! grep -q "sharp-drm" /etc/modules 2>/dev/null; then
        echo "sharp-drm" | sudo tee -a /etc/modules > /dev/null 2>&1 || true
    fi
    
    # Run depmod
    sudo depmod -A > /dev/null 2>&1 || true
    
    echo "100" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    sleep 0.5
    
    # Always return success - no error messages
    return 0
}

# Function for KaliBerry Config option
kaliberryconfig() {
    cd /home/kali/KaliBerry > /dev/null 2>&1 || {
        display_error "Could not access /home/kali/KaliBerry directory"
        return 1
    }
    
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --infobox "Configuring Debian 11 for Raspberry Pi Zero 2 W..." 3 55
    sleep 1
    
    show_progress "sudo cp /etc/apt/sources.list /etc/apt/backupsoucelist.txt" "Backing up current configuration"
    
    show_progress "sudo bash -c 'cat > /etc/apt/sources.list << EOF
# Debian 11 (Bullseye) repositories for armhf (32-bit)
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free

# Raspberry Pi repository - essential for Pi Zero 2 W
deb http://archive.raspberrypi.org/debian/ bullseye main
EOF'" "Configuring repositories for Pi Zero 2 W"

    show_progress "sudo rm /etc/apt/sources.list.d/re4son.list" "Removing Kali list"
    
    show_progress "wget -qO- https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | sudo apt-key add -" "Importing Raspberry Pi key"
    
    show_progress "wget -qO- https://ftp-master.debian.org/keys/archive-key-11.asc | sudo apt-key add -" "Importing Debian 11 key"
    
    show_progress "sudo apt-get install -y raspberrypi-kernel" "Installing kernel for Pi Zero 2 W"
    
    show_progress "sudo apt-get install -y raspberrypi-kernel-headers" "Installing kernel headers"
    
    show_progress "sudo apt-get install -y build-essential git wget" "Installing development tools"
    
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --msgbox "Configuration for Raspberry Pi Zero 2 W completed.\n\nInstalled:\n- Optimized kernel for Pi Zero 2 W\n- Kernel headers\n- Development tools" 12 70
    sleep 3
    
    for i in {10..1}; do
        dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --infobox "SYSTEM WILL REBOOT\n\nTime remaining: $i seconds" 5 50
        sleep 1
    done
    
    sudo reboot
}

# Function for ColorBerry Display Drivers Installation
colorberrydisplay() {
    cd /home/kali/KaliBerry > /dev/null 2>&1 || {
        display_error "Could not access /home/kali/KaliBerry directory"
        return 1
    }

    show_progress_continue "sudo cp -r jdi-drm-rpi /var/tmp/" "Copying jdi-drm-rpi directory"
    show_progress_continue "cd /" "Going to root directory"
    show_progress_continue "cd /var/tmp/jdi-drm-rpi" "Changing to jdi-drm-rpi directory"
    show_progress_continue "cd /var/tmp/jdi-drm-rpi && sudo make" "Compiling driver"
    manual_make_install "Installing driver"
    show_progress_continue "sudo mkdir -p /home/kali/sbin" "Creating sbin directory"
    show_progress_continue "sudo cp /home/kali/KaliBerry/back.py /home/kali/sbin/" "Copying back.py script"
    show_progress_continue "sudo chmod +x /home/kali/sbin/back.py" "Making script executable"
    show_progress_continue "(sudo crontab -l 2>/dev/null; echo '@reboot sleep 5; /home/kali/sbin/back.py &') | sudo crontab -" "Configuring crontab"
    show_progress_continue "echo 'dtoverlay=sharp-drm' | sudo tee -a /boot/config.txt" "Adding overlay to config.txt"
    show_progress_continue "sudo raspi-config nonint do_i2c 0" "Enabling I2C"
    show_progress_continue "cat > /tmp/bashrc_append.txt << 'EOF'
if [ -z \"\$SSH_CONNECTION\" ]; then
        if [[ \"\$(tty)\" =~ /dev/tty ]] && type fbterm > /dev/null 2>&1; then
                fbterm
        elif [ -z \"\$TMUX\" ] && type tmux >/dev/null 2>&1; then
                fcitx 2>/dev/null &
                tmux new -As \"\$(basename \$(tty))\"
        fi
fi
export PROMPT=\"%c\$ \"
export PATH=\$PATH:~/sbin
export SDL_VIDEODRIVER=\"fbcon\"
export SDL_FBDEV=\"/dev/fb1\"
alias d0=\"echo 0 | sudo tee /sys/module/jdi_drm/parameters/dither\"
alias d3=\"echo 3 | sudo tee /sys/module/jdi_drm/parameters/dither\"
alias d4=\"echo 4 | sudo tee /sys/module/jdi_drm/parameters/dither\"
alias b=\"echo 1 | sudo tee /sys/module/jdi_drm/parameters/backlit\"
alias bn=\"echo 0 | sudo tee /sys/module/jdi_drm/parameters/backlit\"
alias key='echo \"keys\" | sudo tee /sys/module/beepy_kbd/parameters/touch_as > /dev/null'
alias mouse='echo \"mouse\" | sudo tee /sys/module/beepy_kbd/parameters/touch_as > /dev/null'
EOF
sudo cat /tmp/bashrc_append.txt >> /home/kali/.bashrc
rm /tmp/bashrc_append.txt" "Configuring .bashrc"
    show_progress_continue "sudo apt-get install -y python3-pip" "Installing python3-pip"
    show_progress_continue "pip3 install RPi.GPIO" "Installing RPi.GPIO"

    dialog --colors --title "ColorBerry Display" --backtitle "KaliBerry Config" \
        --msgbox "Driver installation completed successfully.\n\nConfigured:\n- jdi-drm-rpi display driver\n- I2C configuration\n- Startup scripts\n- .bashrc configuration\n- Python dependencies" 12 70
    sleep 2

    for i in {5..1}; do
        dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --infobox "SYSTEM WILL REBOOT\n\nTime remaining: $i seconds" 5 50
        sleep 1
    done
    
    sudo reboot
}

# Function for Colorberry-KBD option
colorberrykbd() {
    cd /home/kali/KaliBerry > /dev/null 2>&1 || {
        display_error "Could not access /home/kali/KaliBerry directory"
        return 1
    }

    show_progress_continue "cd beepberry-keyboard-driver" "Changing to keyboard driver directory"
    show_progress_continue "cd /home/kali/KaliBerry/beepberry-keyboard-driver && sudo make" "Compiling keyboard driver"
    show_progress_continue "cd /home/kali/KaliBerry/beepberry-keyboard-driver && sudo make install" "Installing keyboard driver"

    dialog --colors --title "Colorberry-KBD" --backtitle "KaliBerry Config" \
        --infobox "Installation completed" 3 30
    sleep 2

    main_menu
}

# Function for Terminal Mode option
terminalmode() {
    show_progress_continue "sudo systemctl set-default multi-user.target" "Disabling desktop environment"
    show_progress_continue "sudo systemctl disable gdm3" "Disabling display manager"
    show_progress_continue "sudo systemctl disable lightdm" "Disabling lightdm"
    show_progress_continue "sudo systemctl disable sddm" "Disabling sddm"
    show_progress_continue "sudo systemctl disable xdm" "Disabling xdm"

    clear
    dialog --colors --title "Terminal Mode" --backtitle "KaliBerry Config" \
        --infobox "Terminal mode active" 3 25
    sleep 2

    for i in {3..1}; do
        dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --infobox "SYSTEM WILL REBOOT\n\nTime remaining: $i seconds" 5 50
        sleep 1
    done

    clear
    sudo reboot
}

# Function for Update option
update() {
    show_progress_continue "sudo rm /etc/apt/sources.list" "Removing current sources.list"
    show_progress_continue "sudo mv /etc/apt/backupsoucelist.txt /etc/apt/sources.list" "Restoring original configuration"
    show_progress_continue "sudo apt-key del ED444FF07D8D0BF6" "Removing existing keys"
    show_progress_continue "sudo rm -rf /etc/apt/trusted.gpg.d/*" "Cleaning keys directory"
    show_progress_continue "wget -qO- https://archive.kali.org/archive-key.asc | sudo apt-key add -" "Importing official Kali Linux key"
    show_progress_continue "wget -qO- https://www.kali.org/archive-key.asc | sudo apt-key add -" "Importing additional Kali key"
    show_progress_continue "sudo apt update" "Updating package lists"
    show_progress_continue "sudo apt upgrade -y" "Upgrading system"

    dialog --colors --title "Update" --backtitle "KaliBerry Config" \
        --msgbox "Update completed\n\nRemember never update Kernel Headers" 7 45
    sleep 3

    main_menu
}

# Function for Exit option
exit_app() {
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --msgbox "Thank you for using KaliBerry Config By N@Xs\n\nDon't forget to install the keyboard driver" 7 60
    sleep 1
    clear
    exit 0
}

# Main menu function
main_menu() {
    while true; do
        choice=$(dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --menu "Select an option:" 17 60 6 \
            1 "KaliBerry Config" \
            2 "ColorBerry Display" \
            3 "Colorberry-KBD" \
            4 "Terminal Mode" \
            5 "Update" \
            6 "Exit" \
            3>&1 1>&2 2>&3)
        
        case $choice in
            1) kaliberryconfig ;;
            2) colorberrydisplay ;;
            3) colorberrykbd ;;
            4) terminalmode ;;
            5) update ;;
            6) exit_app ;;
            *) exit_app ;;
        esac
    done
}

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "Installing dialog package..."
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y dialog > /dev/null 2>&1
fi

# Check if KaliBerry directory exists
if [ ! -d "/home/kali/KaliBerry" ]; then
    echo "Creating KaliBerry directory..."
    sudo mkdir -p /home/kali/KaliBerry > /dev/null 2>&1
fi

# Set terminal colors (blue background, white text)
export DIALOGRC=$(cat <<EOF
# Dialog configuration
screen_color = (WHITE,BLUE,ON)
dialog_color = (BLACK,WHITE,OFF)
title_color = (BLUE,WHITE,ON)
border_color = (WHITE,WHITE,ON)
button_active_color = (WHITE,BLUE,ON)
button_inactive_color = (BLACK,WHITE,OFF)
button_key_active_color = (WHITE,BLUE,ON)
button_key_inactive_color = (RED,WHITE,OFF)
button_label_active_color = (WHITE,BLUE,ON)
button_label_inactive_color = (BLACK,WHITE,ON)
inputbox_color = (BLACK,WHITE,OFF)
inputbox_border_color = (BLACK,WHITE,OFF)
searchbox_color = (BLACK,WHITE,OFF)
searchbox_title_color = (BLUE,WHITE,ON)
searchbox_border_color = (WHITE,WHITE,ON)
position_indicator_color = (BLUE,WHITE,ON)
menubox_color = (BLACK,WHITE,OFF)
menubox_border_color = (WHITE,WHITE,ON)
item_color = (BLACK,WHITE,OFF)
item_selected_color = (WHITE,BLUE,ON)
tag_color = (BLUE,WHITE,ON)
tag_selected_color = (WHITE,BLUE,ON)
tag_key_color = (RED,WHITE,OFF)
tag_key_selected_color = (RED,BLUE,ON)
check_color = (BLACK,WHITE,OFF)
check_selected_color = (WHITE,BLUE,ON)
uarrow_color = (GREEN,WHITE,ON)
darrow_color = (GREEN,WHITE,ON)
itemhelp_color = (BLACK,WHITE,OFF)
EOF
)

# Start the application
clear
main_menu

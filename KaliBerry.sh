#!/bin/bash

# KaliBerry Config Application
# By N@Xs

# Function to display error and return to main menu
display_error() {
    dialog --colors --title "\Z1Error\Zn" --backtitle "KaliBerry Config" \
        --msgbox "\Z1Error:\Zn $1" 8 60
    sleep 3
    main_menu
}

# Function to show progress
show_progress() {
    local cmd=$1
    local message=$2
    local total=100
    local progress=0
    
    (
        while [ $progress -lt 100 ]; do
            echo $progress
            progress=$((progress + 10))
            sleep 0.2
        done
    ) | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    
    # Execute the actual command
    eval "$cmd" 2>/tmp/error.log || {
        display_error "$(cat /tmp/error.log)"
        return 1
    }
    return 0
}

# Function to show progress without stopping on errors
show_progress_continue() {
    local cmd=$1
    local message=$2
    local total=100
    local progress=0
    
    (
        while [ $progress -lt 100 ]; do
            echo $progress
            progress=$((progress + 10))
            sleep 0.2
        done
    ) | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    
    # Execute the actual command
    eval "$cmd" 2>/tmp/error.log || {
        dialog --colors --title "\Z1Warning\Zn" --backtitle "KaliBerry Config" \
            --msgbox "\Z1Error en comando:\Zn $cmd\n\n\Z1Mensaje:\Zn $(cat /tmp/error.log)\n\nContinuando con la instalación..." 10 70
        sleep 2
        return 0
    }
    return 0
}

# Function for KaliBerry Config option
kaliberryconfig() {
    # First ensure we're in the correct directory
    cd /home/kali/KaliBerry || {
        display_error "No se pudo acceder al directorio /home/kali/KaliBerry"
        return 1
    }
    
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --infobox "Instalando, aproveche a tomarse un cafe!!!" 3 50
    sleep 2
    
    # Command 1
    show_progress "sudo mv /etc/apt/sources.list.d/re4son.list /etc/apt/sources.list.d/re4son.list.bak" "Renombrando re4son.list (10%)"
    sleep 2
    
    # Command 2
    show_progress "echo \"deb [signed-by=/usr/share/keyrings/raspberrypi-archive-keyring.gpg] http://archive.raspberrypi.org/debian bullseye main\" | sudo tee /etc/apt/sources.list.d/raspi.list" "Añadiendo repositorio Raspberry Pi (30%)"
    sleep 2
    
    # Command 3
    show_progress "curl -fsSL https://ftp-master.debian.org/keys/archive-key-11.asc | gpg --dearmor | sudo tee /usr/share/keyrings/debian-archive-keyring.gpg >/dev/null" "Añadiendo llave Debian (50%)"
    sleep 2
    
    # Command 4
    show_progress "sudo apt update" "Actualizando listas de paquetes (70%)"
    sleep 2
    
    # Command 5
    show_progress "sudo apt-get install -y raspberrypi-kernel" "Instalando kernel Raspberry Pi (90%)"
    
    # Countdown for reboot
    for i in {10..1}; do
        dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --infobox "EL EQUIPO SE VA A REINICIAR\n\nTiempo restante: $i segundos" 5 50
        sleep 1
    done
    
    # Return to main menu instead of actual reboot for this script
    main_menu
}

# Function for ColorBerry Display option
colorberrydisplay() {
    # First ensure we're in the correct directory
    cd /home/kali/KaliBerry || {
        display_error "No se pudo acceder al directorio /home/kali/KaliBerry"
        return 1
    }
    
    # Command 1
    show_progress_continue "sudo cp -r jdi-drm-rpi /var/tmp/" "Copiando directorio jdi-drm-rpi (10%)"
    sleep 2
    
    # Command 2
    show_progress_continue "cd /" "Cambiando al directorio raíz (20%)"
    sleep 2
    
    # Command 3
    show_progress_continue "cd /var/tmp/jdi-drm-rpi" "Cambiando al directorio jdi-drm-rpi (30%)"
    sleep 2
    
    # Command 4
    show_progress_continue "sudo make" "Compilando driver (40%)"
    sleep 2
    
    # Command 5
    show_progress_continue "sudo make install" "Instalando driver (50%)"
    sleep 2
    
    # Command 6
    show_progress_continue "sudo mkdir -p /home/kali/sbin" "Creando directorio sbin (60%)"
    sleep 2
    
    # Command 7
    show_progress_continue "sudo mv back.py /home/kali/sbin" "Moviendo script back.py (70%)"
    sleep 2
    
    # Command 8
    show_progress_continue "cd .." "Cambiando al directorio superior (75%)"
    sleep 2
    
    # Command 9
    show_progress_continue "cd sbin" "Cambiando al directorio sbin (80%)"
    sleep 2
    
    # Command 10
    show_progress_continue "sudo chmod +x /home/kali/sbin/back.py" "Haciendo ejecutable el script (85%)"
    sleep 2
    
    # Command 11
    show_progress_continue "(crontab -l 2>/dev/null; echo '@reboot sleep 5; /home/kali/sbin/back.py &') | crontab -" "Configurando crontab (90%)"
    sleep 2
    
    # Command 12 - Enable i2c
    show_progress_continue "sudo raspi-config nonint do_i2c 0" "Activando I2C (100%)"
    sleep 2
    
    # Success message
    clear
    dialog --colors --title "ColorBerry Display" --backtitle "KaliBerry Config" \
        --infobox "Instalación Exitosa" 3 30
    sleep 4
    
    main_menu
}

# Function for Colorberry-KBD option
colorberrykbd() {
    # First ensure we're in the correct directory
    cd /home/kali/KaliBerry || {
        display_error "No se pudo acceder al directorio /home/kali/KaliBerry"
        return 1
    }
    
    # Command 1
    show_progress "cd beepberry-keyboard-driver" "Cambiando al directorio del driver de teclado (25%)"
    sleep 2
    
    # Command 2
    show_progress "sudo make" "Compilando driver de teclado (50%)"
    sleep 2
    
    # Command 3
    show_progress "sudo make install" "Instalando driver de teclado (100%)"
    sleep 2
    
    # Success message
    clear
    dialog --colors --title "Colorberry-KBD" --backtitle "KaliBerry Config" \
        --infobox "Instalación Exitosa" 3 30
    sleep 4
    
    main_menu
}

# Function for Exit option
exit_app() {
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --infobox "Gracias por utilizar KaliBerry Config By N@Xs" 3 50
    sleep 2
    clear
    exit 0
}

# Main menu function
main_menu() {
    while true; do
        choice=$(dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --menu "Seleccione una opción:" 15 60 4 \
            1 "KaliBerry Config" \
            2 "ColorBerry Display" \
            3 "Colorberry-KBD" \
            4 "Salir" \
            3>&1 1>&2 2>&3)
        
        case $choice in
            1) kaliberryconfig ;;
            2) colorberrydisplay ;;
            3) colorberrykbd ;;
            4) exit_app ;;
            *) exit_app ;;
        esac
    done
}

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "Installing dialog package..."
    sudo apt-get update
    sudo apt-get install -y dialog
fi

# Check if KaliBerry directory exists
if [ ! -d "/home/kali/KaliBerry" ]; then
    echo "Creating KaliBerry directory..."
    sudo mkdir -p /home/kali/KaliBerry
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

#!/bin/bash

# Limpiar pantalla antes de iniciar el menú
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
    if [[ "$cmd" == *"make"* ]]; then
        # Run make commands with complete redirection in a subshell
        ( eval "$cmd" > /dev/null 2>/tmp/error.log ) &
        local cmd_pid=$!
    else
        # Execute other commands silently in background
        eval "$cmd > /dev/null 2>/tmp/error.log" &
        local cmd_pid=$!
    fi
    
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

# Function to show progress without stopping on errors (all commands run silently in background)
show_progress_continue() {
    local cmd=$1
    local message=$2
    
    # Show 0% at start
    echo "0" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    
    # Execute command in background and capture PID
    if [[ "$cmd" == *"make"* ]]; then
        # Run make commands with complete redirection in a subshell
        ( eval "$cmd" > /dev/null 2>/tmp/error.log ) &
        local cmd_pid=$!
    else
        # Execute other commands silently in background
        eval "$cmd > /dev/null 2>/tmp/error.log" &
        local cmd_pid=$!
    fi
    
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
    
    # Check if command failed but continue anyway
    if [ $exit_status -ne 0 ]; then
        dialog --colors --title "\Z1Warning\Zn" --backtitle "KaliBerry Config" \
            --msgbox "\Z1Error en comando:\Zn $cmd\n\n\Z1Mensaje:\Zn $(cat /tmp/error.log)\n\nContinuando con la instalación..." 10 70
        sleep 1
    fi
    
    return 0
}

# Function to show progress for make commands - ignores all errors silently
show_progress_make_silent() {
    local cmd=$1
    local message=$2
    
    # Show 0% at start
    echo "0" | dialog --colors --title "$message" --backtitle "KaliBerry Config" \
        --gauge "$message" 10 70 0
    
    # Execute make commands completely silently, ignore all errors
    eval "$cmd > /dev/null 2>&1" &
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
    
    return 0
}

# Function for KaliBerry Config option
kaliberryconfig() {
    # First ensure we're in the correct directory
    cd /home/kali/KaliBerry > /dev/null 2>&1 || {
        display_error "No se pudo acceder al directorio /home/kali/KaliBerry"
        return 1
    }
    
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --infobox "Configurando Debian 11 para Raspberry Pi Zero 2 W..." 3 55
    sleep 1
    
    # Command 1 - Backup current configuration
    show_progress "sudo cp /etc/apt/sources.list /etc/apt/backupsoucelist.txt" "Respaldando configuración actual"
    sleep 1
    
    # Command 2 - Configure repositories for Raspberry Pi Zero 2 W
    show_progress "sudo bash -c 'cat > /etc/apt/sources.list << EOF
# Debian 11 (Bullseye) repositories for armhf (32-bit)
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free

# Raspberry Pi repository - essential for Pi Zero 2 W
deb http://archive.raspberrypi.org/debian/ bullseye main
EOF'" "Configurando repositorios para Pi Zero 2 W"
    sleep 1
    
    # Command 3 - Download Raspberry Pi archive key directly
    show_progress "wget -qO- https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | sudo apt-key add -" "Importando clave Raspberry Pi"
    sleep 1
    
    # Command 4 - Download Debian archive key
    show_progress "wget -qO- https://ftp-master.debian.org/keys/archive-key-11.asc | sudo apt-key add -" "Importando clave Debian 11"
    sleep 1
    
    # Command 5 - Update package lists
    # show_progress "sudo apt-get update" "Actualizando listas de paquetes"
    # sleep 1
    
    # Command 6 - Install Raspberry Pi kernel packages for Zero 2 W
    show_progress "sudo apt-get install -y raspberrypi-kernel" "Instalando kernel para Pi Zero 2 W"
    sleep 1
    
    # Command 7 - Install kernel headers
    show_progress "sudo apt-get install -y raspberrypi-kernel-headers" "Instalando headers del kernel"
    sleep 1
    
    # Command 8 - Install essential development tools
    show_progress "sudo apt-get install -y build-essential git wget" "Instalando herramientas de desarrollo"
    
    # Success message
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --msgbox "Configuración para Raspberry Pi Zero 2 W completada.\n\nSe ha instalado:\n- Kernel optimizado para Pi Zero 2 W\n- Headers del kernel\n- Herramientas de desarrollo" 12 70
    sleep 3
    
    # Countdown for reboot
    for i in {10..1}; do
        dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --infobox "EL EQUIPO SE VA A REINICIAR\n\nTiempo restante: $i segundos" 5 50
        sleep 1
    done
    
    # Actually reboot the system
    sudo reboot
}

# Function for ColorBerry Display Drivers Instalation
colorberrydisplay() {
    # First ensure we're in the correct directory
    cd /home/kali/KaliBerry > /dev/null 2>&1 || {
        display_error "No se pudo acceder al directorio /home/kali/KaliBerry"
        return 1
    }

    # Command 1
    show_progress_continue "sudo cp -r jdi-drm-rpi /var/tmp/" "Copiando directorio jdi-drm-rpi"
    sleep 1

     # Command 2
    show_progress_continue "cd /" "Saliendo al directorio Raiz"
    sleep 1
    
    # Command 3
    show_progress_continue "cd /var/tmp/jdi-drm-rpi" "Cambiando al directorio jdi-drm-rpi"
    sleep 1
    
    
    # Command 4 - Make command with silent error handling
    show_progress_make_silent "sudo make" "Compilando driver"
    sleep 1
    
    # Command 5 - Make install command with silent error handling
    show_progress_make_silent "sudo make install" "Instalando driver"
    sleep 1
    
    # Command 6
    show_progress_continue "sudo mkdir -p /home/kali/sbin" "Creando directorio sbin"
    sleep 1
    
    # Command 7
    show_progress_continue "sudo cp /home/kali/KaliBerry/back.py /home/kali/sbin/" "Copiando script back.py"
    sleep 1
    
    # Command 8
    show_progress_continue "sudo chmod +x /home/kali/sbin/back.py" "Haciendo ejecutable el script"
    sleep 1
    
    # Command 9
    show_progress_continue "(crontab -l 2>/dev/null; echo '@reboot sleep 5; /home/kali/sbin/back.py &') | crontab -" "Configurando crontab"
    sleep 1
    
    # Command 10 - Enable i2c
    show_progress_continue "sudo raspi-config nonint do_i2c 0" "Activando I2C"
    sleep 1
    
    # Command 11 - Add configuration to .bashrc using a temporary file approach
    show_progress_continue "cat > /tmp/bashrc_append.txt << 'EOF'
if [ -z \"$SSH_CONNECTION\" ]; then
        if [[ \"$(tty)\" =~ /dev/tty ]] && type fbterm > /dev/null 2>&1; then
                fbterm
        # otherwise, start/attach to tmux
        elif [ -z \"$TMUX\" ] && type tmux >/dev/null 2>&1; then
                fcitx 2>/dev/null &
                tmux new -As \"$(basename $(tty))\"
        fi
fi
export PROMPT=\"%c$ \"
export PATH=$PATH:~/sbin
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
rm /tmp/bashrc_append.txt" "Configurando .bashrc"
    sleep 1
    
    # Command 12 - Install python3-pip
    show_progress_continue "sudo apt-get install -y python3-pip" "Instalando python3-pip"
    sleep 1
    
    # Command 13 - Install RPi.GPIO
    show_progress_continue "pip3 install RPi.GPIO" "Instalando RPi.GPIO"
    sleep 1

    # Clear screen and show success message
    clear
    dialog --colors --title "ColorBerry Display" --backtitle "KaliBerry Config" \
        --msgbox "Instalación de drivers completada exitosamente.\n\nSe ha configurado:\n- Driver de pantalla jdi-drm-rpi\n- Configuración I2C\n- Scripts de arranque\n- Configuración .bashrc\n- Dependencias Python" 12 70
    sleep 2

    # Clear screen again before reboot countdown
    clear

    # Countdown for reboot
    for i in {5..1}; do
        dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
            --infobox "EL EQUIPO SE VA A REINICIAR\n\nTiempo restante: $i segundos" 5 50
        sleep 1
    done
    
    # Actually reboot the system
    sudo reboot
}
# Function for Colorberry-KBD option
colorberrykbd() {
    # First ensure we're in the correct directory
    cd /home/kali/KaliBerry > /dev/null 2>&1 || {
        display_error "No se pudo acceder al directorio /home/kali/KaliBerry"
        return 1
    }

    # Cambiar al directorio del driver (usa show_progress_continue por si no existe el directorio o hay fallo menor)
    show_progress_continue "cd beepberry-keyboard-driver" "Cambiando al directorio del driver de teclado"
    sleep 1
    
    # Compilar driver sin detenerse ante errores
    show_progress_make_silent "sudo make" "Compilando driver de teclado"
    sleep 1

    # Instalar driver sin detenerse ante errores
    show_progress_make_silent "sudo make install" "Instalando driver de teclado"
    sleep 1

    # Mensaje de éxito
    clear
    dialog --colors --title "Colorberry-KBD" --backtitle "KaliBerry Config" \
        --infobox "Instalación finalizada (errores ignorados)" 3 40
    sleep 2

    main_menu
}

# Function for Exit option
exit_app() {
    dialog --colors --title "KaliBerry Config" --backtitle "KaliBerry Config" \
        --infobox "Gracias por utilizar KaliBerry Config By N@Xs" 3 50
        --infobox "No se olvide de instalar el driver del teclado" 13 50
    sleep 1
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

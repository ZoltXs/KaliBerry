#!/bin/bash

# Verificar si es root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse con sudo o como root."
   exec sudo "$0" "$@"
   exit 1
fi

# Tamaño mínimo para terminal
resize -s 30 80 >/dev/null 2>&1

# Colores personalizados para dialog
export DIALOGRC=$(mktemp)
cat <<EOF > $DIALOGRC
use_shadow = no
screen_color = blue
shadow_color = black
dialog_color = white
EOF

# Función para mostrar progreso
function show_progress() {
    local steps=(${!1})
    local count=${#steps[@]}
    local percent=0
    local i=0

    for cmd in "${steps[@]}"; do
        i=$((i+1))
        percent=$((i * 100 / count))
        echo $percent
        echo "XXX"
        if [[ $2 == "coffee" ]]; then
            echo "Instalando, aproveche a tomarse un cafe !!!"
        else
            echo "Instalando..."
        fi
        echo "XXX"
        eval "$cmd"
        sleep 2
    done
}

# Función para mostrar mensaje de instalación exitosa
function success_message() {
    clear
    echo -e "\n\n\n\t\tInstalación Exitosa"
    sleep 4
}

# Función para reinicio con cuenta regresiva
function countdown_reboot() {
    for i in $(seq 10 -1 1); do
        clear
        echo -e "\n\n\n\t\tEL EQUIPO SE VA A REINICIAR EN $i SEGUNDOS"
        sleep 1
    done
    sudo reboot
}

# Opción 1: KaliBerry Config
function kaliberry_config() {
    cmds=(
        "sudo mv /etc/apt/sources.list.d/re4son.list /etc/apt/sources.list.d/re4son.list.bak"
        "echo 'deb [signed-by=/usr/share/keyrings/raspberrypi-archive-keyring.gpg] http://archive.raspberrypi.org/debian bullseye main' | sudo tee /etc/apt/sources.list.d/raspi.list"
        "curl -fsSL https://ftp-master.debian.org/keys/archive-key-11.asc | gpg --dearmor | sudo tee /usr/share/keyrings/debian-archive-keyring.gpg >/dev/null"
        "sudo apt update"
    )
    cmds+=("sudo apt-get install -y raspberrypi-kernel")

    (show_progress cmds[@] "coffee") | dialog --title "KaliBerry Config" --gauge "Instalando..." 10 60 0
    countdown_reboot
}

# Opción 2: ColorBerry Display
function colorberry_display() {
    cmds=(
        "cd jdi-drm-rpi"
        "sudo make"
        "sudo make install"
        "sudo mkdir -p /home/kali/sbin"
        "sudo mv back.py /home/kali/sbin"
        "cd .."
        "cd sbin"
        "sudo chmod +x /home/kali/sbin/back.py"
        "(crontab -l 2>/dev/null; echo '@reboot sleep 5; /home/kali/sbin/back.py &') | crontab -"
        "sudo raspi-config nonint do_i2c 0"
    )

    (show_progress cmds[@]) | dialog --title "ColorBerry Display" --gauge "Instalando..." 10 60 0
    success_message
}

# Opción 3: Colorberry-KBD
function colorberry_kbd() {
    cmds=(
        "cd .."
        "cd beepberry-keyboard-driver"
        "sudo make"
        "sudo make install"
    )

    (show_progress cmds[@]) | dialog --title "Colorberry-KBD" --gauge "Instalando..." 10 60 0
    success_message
}

# Menú principal
while true; do
    OPTION=$(dialog --stdout --title "KaliBerry Config" \
        --menu "Seleccione una opción:" 15 50 5 \
        1 "KaliBerry Config" \
        2 "ColorBerry Display" \
        3 "Colorberry-KBD" \
        4 "Salir")

    case $OPTION in
        1)
            kaliberry_config
            ;;
        2)
            colorberry_display
            ;;
        3)
            colorberry_kbd
            ;;
        4)
            clear
            echo -e "\n\n\n\t\tGracias por utilizar KaliBerry Config By N@Xs"
            sleep 2
            clear
            exit 0
            ;;
        *)
            break
            ;;
    esac

done

# Limpiar archivo DIALOGRC temporal
rm -f $DIALOGRC

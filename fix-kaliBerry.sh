#!/bin/bash
# Script para corregir la instalación de KaliBerry

# Colores para los mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin Color

# Función para mostrar mensajes de progreso
show_status() {
    echo -e "${GREEN}[✓] $1${NC}"
}

# Función para mostrar advertencias
show_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Función para mostrar errores
show_error() {
    echo -e "${RED}[✗] $1${NC}"
}

echo "====================================================="
echo "      Reparación de KaliBerry                        "
echo "====================================================="
echo ""

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
    show_error "Este script debe ejecutarse como root (sudo)."
    exit 1
fi

# Ubicación de la instalación
INSTALL_DIR="/opt/kaliBerry"

# Verificar si KaliBerry está instalado
if [ ! -d "$INSTALL_DIR" ]; then
    show_error "KaliBerry no está instalado en $INSTALL_DIR."
    exit 1
fi

# Corregir el archivo config.py
echo "Corrigiendo el archivo config.py..."

cat > "$INSTALL_DIR/config.py" << 'EOF'
#!/usr/bin/env python3
"""
Configuración para KaliBerry
"""

import os
from pathlib import Path

# Información de la aplicación
TITLE = "KaliBerry"
VERSION = "1.0.0"
THEME = "dark"

# Directorios y archivos
HOME_DIR = str(Path.home())
CONFIG_DIR = os.path.join(HOME_DIR, ".config", "kaliBerry")
TOOLS_CACHE_FILE = os.path.join(CONFIG_DIR, "tools_cache.json")

# Directorios donde buscar herramientas de Kali
KALI_TOOLS_DIRS = [
    "/usr/share/kali-menu/applications",
    "/usr/share/applications",
    "/usr/bin",
    "/usr/local/bin"
]

# Categorías y herramientas conocidas de Kali Linux
TOOL_CATEGORIES = {
    "information-gathering": ["nmap", "whois", "dig", "recon-ng", "maltego", "theharvester", "amass", "spiderfoot"],
    "vulnerability-analysis": ["nikto", "nessus", "openvas", "lynis", "wpscan", "sqlmap", "legion", "sparta"],
    "web-application": ["burpsuite", "owasp-zap", "skipfish", "wfuzz", "dirb", "dirbuster", "gobuster", "ffuf"],
    "database-assessment": ["sqlmap", "sqlninja", "sqlsus", "oscanner", "sidguesser", "sqldict", "sqlbf"],
    "password-attacks": ["hydra", "john", "hashcat", "medusa", "ncrack", "ophcrack", "rainbowcrack", "crunch"],
    "wireless-attacks": ["aircrack-ng", "kismet", "wifite", "fern-wifi-cracker", "pixiewps", "reaver", "bully"],
    "exploitation-tools": ["metasploit", "searchsploit", "beef", "armitage", "set", "routersploit", "commix"],
    "sniffing-spoofing": ["wireshark", "ettercap", "bettercap", "dsniff", "netsniff-ng", "macchanger", "mitmproxy"],
    "post-exploitation": ["empire", "weevely", "powersploit", "mimikatz", "proxychains", "veil", "shellter"],
    "forensics": ["autopsy", "sleuthkit", "volatility", "foremost", "binwalk", "scalpel", "bulk-extractor"],
    "reporting-tools": ["dradis", "faraday", "pipal", "metagoofil", "maltego", "casefile", "cherrytree"],
    "social-engineering": ["social-engineer-toolkit", "beef", "maltego", "backdoor-factory", "gophish"],
    "reverse-engineering": ["ghidra", "radare2", "apktool", "dex2jar", "jd-gui", "ollydbg", "gdb"],
    "other-tools": []  # Categoría para herramientas que no encajan en las anteriores
}
EOF

# Verificar si se corrigió correctamente
if [ $? -eq 0 ]; then
    show_status "Archivo config.py corregido correctamente."
else
    show_error "No se pudo corregir el archivo config.py."
    exit 1
fi

# Establecer permisos correctos
echo "Estableciendo permisos correctos..."
chmod 755 "$INSTALL_DIR"/*.py
chmod 644 "$INSTALL_DIR"/styles.css
chmod -R 755 "$INSTALL_DIR"

show_status "Permisos establecidos correctamente."

# Crear directorio de configuración si no existe
mkdir -p "$HOME/.config/kaliBerry"
show_status "Directorio de configuración verificado."

echo ""
echo "====================================================="
echo "      ¡Reparación de KaliBerry completada!           "
echo "====================================================="
echo ""
echo "Ahora puedes ejecutar KaliBerry escribiendo:"
echo ""
echo "  kaliBerry"
echo ""
echo "en cualquier terminal."
echo ""

# Preguntar si desea ejecutar KaliBerry ahora
read -p "¿Deseas ejecutar KaliBerry ahora? (s/n): " RUN_NOW
if [[ $RUN_NOW == "s" || $RUN_NOW == "S" ]]; then
    echo "Iniciando KaliBerry..."
    kaliBerry
fi

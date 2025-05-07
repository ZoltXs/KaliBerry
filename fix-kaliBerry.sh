#!/bin/bash
# Script para arreglar KaliBerry de una vez por todas

# Colores para los mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin Color

echo -e "${GREEN}=== Arreglando KaliBerry de una vez por todas ===${NC}"
echo ""

# Eliminar todo lo anterior
echo -e "${YELLOW}Eliminando instalación anterior...${NC}"
sudo rm -rf /opt/kaliBerry
sudo rm -f /usr/local/bin/kaliBerry
rm -rf ~/.config/kaliBerry

# Crear directorios
echo -e "${YELLOW}Creando directorios...${NC}"
sudo mkdir -p /opt/kaliBerry
mkdir -p ~/.config/kaliBerry

# Crear caché de herramientas mínimo
echo -e "${YELLOW}Creando caché de herramientas mínimo...${NC}"
cat > ~/.config/kaliBerry/tools_cache.json << 'EOF'
{
  "information-gathering": [
    {
      "name": "nmap",
      "description": "Herramienta de escaneo de redes",
      "command": "/usr/bin/nmap"
    },
    {
      "name": "whois",
      "description": "Cliente whois para consultar información de dominios",
      "command": "/usr/bin/whois"
    },
    {
      "name": "dig",
      "description": "Herramienta de consulta DNS",
      "command": "/usr/bin/dig"
    }
  ],
  "vulnerability-analysis": [
    {
      "name": "nikto",
      "description": "Escáner de vulnerabilidades web",
      "command": "/usr/bin/nikto"
    }
  ],
  "web-application": [
    {
      "name": "dirb",
      "description": "Escáner de directorios web",
      "command": "/usr/bin/dirb"
    },
    {
      "name": "sqlmap",
      "description": "Herramienta de detección y explotación de inyección SQL",
      "command": "/usr/bin/sqlmap"
    }
  ],
  "password-attacks": [
    {
      "name": "john",
      "description": "John the Ripper - Herramienta de cracking de contraseñas",
      "command": "/usr/bin/john"
    },
    {
      "name": "hydra",
      "description": "Herramienta de fuerza bruta para múltiples servicios",
      "command": "/usr/bin/hydra"
    }
  ],
  "wireless-attacks": [
    {
      "name": "wifite",
      "description": "Herramienta automatizada para auditorías WiFi",
      "command": "/usr/bin/wifite"
    },
    {
      "name": "aircrack-ng",
      "description": "Suite para auditoría de redes inalámbricas",
      "command": "/usr/bin/aircrack-ng"
    }
  ],
  "other-tools": [
    {
      "name": "vim",
      "description": "Editor de texto avanzado",
      "command": "/usr/bin/vim"
    },
    {
      "name": "nano",
      "description": "Editor de texto simple",
      "command": "/usr/bin/nano"
    },
    {
      "name": "git",
      "description": "Sistema de control de versiones",
      "command": "/usr/bin/git"
    }
  ]
}
EOF

# Copiar archivos
echo -e "${YELLOW}Copiando archivos...${NC}"
sudo cp kaliBerry.py tool_manager.py config.py ui_manager.py styles.css /opt/kaliBerry/

# Establecer permisos
echo -e "${YELLOW}Estableciendo permisos...${NC}"
sudo chmod 755 /opt/kaliBerry/*.py
sudo chmod 644 /opt/kaliBerry/styles.css

# Crear script ejecutable
echo -e "${YELLOW}Creando script ejecutable...${NC}"
sudo bash -c 'cat > /usr/local/bin/kaliBerry << EOF
#!/bin/bash
cd /opt/kaliBerry
python3 /opt/kaliBerry/kaliBerry.py "\$@"
EOF'

sudo chmod 755 /usr/local/bin/kaliBerry

echo -e "${GREEN}¡KaliBerry ha sido arreglado!${NC}"
echo ""
echo "Ahora puedes ejecutar KaliBerry escribiendo:"
echo ""
echo "  kaliBerry"
echo ""
echo "en cualquier terminal."
echo ""
echo "NUEVA FUNCIONALIDAD: Ahora puedes añadir herramientas manualmente"
echo "desde dentro de KaliBerry seleccionando 'Añadir Herramienta' en el"
echo "menú principal o presionando la tecla 'a'."
echo ""

# Preguntar si desea ejecutar KaliBerry ahora
read -p "¿Deseas ejecutar KaliBerry ahora? (s/n): " RUN_NOW
if [[ $RUN_NOW == "s" || $RUN_NOW == "S" ]]; then
    echo "Iniciando KaliBerry..."
    kaliBerry
fi

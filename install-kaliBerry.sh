#!/bin/bash
# Script de instalación automática para KaliBerry
# Este script instala KaliBerry y lo configura para que pueda ejecutarse desde cualquier ubicación

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

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "====================================================="
echo "      Instalador Automático de KaliBerry v1.0        "
echo "====================================================="
echo ""
echo "Este script instalará KaliBerry y lo configurará para"
echo "que puedas ejecutarlo desde cualquier terminal."
echo ""
echo "El proceso tomará unos minutos..."
echo ""

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Este script debe ejecutarse como root (sudo).${NC}"
    exit 1
fi

# Crear directorio de instalación
echo -e "${GREEN}Creando directorio de instalación...${NC}"
mkdir -p /opt/kaliBerry

# Copiar archivos
echo -e "${GREEN}Copiando archivos...${NC}"
cp kaliBerry.py tool_manager.py config.py ui_manager.py styles.css /opt/kaliBerry/

# Establecer permisos
echo -e "${GREEN}Estableciendo permisos...${NC}"
chmod 755 /opt/kaliBerry/*.py
chmod 644 /opt/kaliBerry/styles.css

# Crear directorio de configuración
echo -e "${GREEN}Creando directorio de configuración...${NC}"
mkdir -p ~/.config/kaliBerry

# Crear script ejecutable
echo -e "${GREEN}Creando script ejecutable...${NC}"
cat > /usr/local/bin/kaliBerry << 'EOF'
#!/bin/bash
cd /opt/kaliBerry
python3 /opt/kaliBerry/kaliBerry.py "$@"
EOF

chmod 755 /usr/local/bin/kaliBerry

echo -e "${GREEN}¡Instalación completada!${NC}"
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

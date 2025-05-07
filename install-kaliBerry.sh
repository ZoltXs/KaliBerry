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

# Eliminar instalación anterior
show_status "Eliminando instalación anterior (si existe)..."
rm -rf /opt/kaliBerry
rm -f /usr/local/bin/kaliBerry
rm -rf ~/.config/kaliBerry

# Crear directorio de instalación
show_status "Creando directorio de instalación..."
mkdir -p /opt/kaliBerry

# Copiar archivos
show_status "Copiando archivos..."
cp kaliBerry.py tool_manager.py config.py ui_manager.py styles.css /opt/kaliBerry/

# Establecer permisos
show_status "Estableciendo permisos..."
chmod 755 /opt/kaliBerry/*.py
chmod 644 /opt/kaliBerry/styles.css

# Crear directorio de configuración
show_status "Creando directorio de configuración..."
mkdir -p ~/.config/kaliBerry

# Crear script ejecutable
show_status "Creando script ejecutable..."
cat > /usr/local/bin/kaliBerry << 'EOF'
#!/bin/bash
cd /opt/kaliBerry
python3 /opt/kaliBerry/kaliBerry.py "$@"
EOF

chmod 755 /usr/local/bin/kaliBerry

# Instalar dependencias
show_status "Instalando dependencias..."
pip3 install textual

show_status "¡Instalación completada!"
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

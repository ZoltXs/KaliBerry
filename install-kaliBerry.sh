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
    show_warning "Este script necesita permisos de administrador."
    show_warning "Ejecutando con sudo..."
    
    # Intentar ejecutar el mismo script con sudo
    exec sudo "$0" "$@"
    
    # Si llegamos aquí, sudo falló
    show_error "No se pudo obtener permisos de administrador. Por favor ejecuta:"
    echo "sudo $0"
    exit 1
fi

# Verificar requisitos previos
echo "Verificando requisitos previos..."

# Verificar Python 3
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    show_status "Python $PYTHON_VERSION encontrado"
else
    show_error "Python 3 no está instalado. Instalando..."
    apt-get update && apt-get install -y python3
    
    if [ $? -ne 0 ]; then
        show_error "No se pudo instalar Python 3. Por favor, instálalo manualmente."
        exit 1
    fi
    show_status "Python 3 instalado correctamente"
fi

# Verificar pip3
if command_exists pip3; then
    show_status "pip3 encontrado"
else
    show_error "pip3 no está instalado. Instalando..."
    apt-get update && apt-get install -y python3-pip
    
    if [ $? -ne 0 ]; then
        show_error "No se pudo instalar pip3. Por favor, instálalo manualmente."
        exit 1
    fi
    show_status "pip3 instalado correctamente"
fi

# Verificar git
if command_exists git; then
    show_status "git encontrado"
else
    show_error "git no está instalado. Instalando..."
    apt-get update && apt-get install -y git
    
    if [ $? -ne 0 ]; then
        show_error "No se pudo instalar git. Por favor, instálalo manualmente."
        exit 1
    fi
    show_status "git instalado correctamente"
fi

# Crear directorio de instalación
INSTALL_DIR="/opt/kaliBerry"
echo "Creando directorio de instalación..."

if [ -d "$INSTALL_DIR" ]; then
    show_warning "El directorio $INSTALL_DIR ya existe. Actualizando instalación existente..."
    rm -rf "$INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"
show_status "Directorio de instalación creado en $INSTALL_DIR"

# Descargar KaliBerry
echo "Descargando KaliBerry..."
git clone https://github.com/yourusername/kaliBerry.git "$INSTALL_DIR" 2>/dev/null

# Si el repositorio no existe, crear los archivos manualmente
if [ $? -ne 0 ]; then
    show_warning "No se pudo clonar el repositorio. Creando archivos manualmente..."
    
    # Crear directorio de configuración
    mkdir -p "$HOME/.config/kaliBerry"
    
    # Copiar los archivos actuales al directorio de instalación
    if [ -f "kaliBerry.py" ] && [ -f "tool_manager.py" ] && [ -f "ui_manager.py" ] && [ -f "config.py" ] && [ -f "styles.css" ]; then
        cp kaliBerry.py tool_manager.py ui_manager.py config.py styles.css "$INSTALL_DIR/"
        show_status "Archivos copiados al directorio de instalación"
    else
        show_error "No se encontraron los archivos necesarios en el directorio actual."
        show_error "Por favor, ejecuta este script desde el directorio que contiene los archivos de KaliBerry."
        exit 1
    fi
else
    show_status "KaliBerry descargado correctamente"
fi

# Instalar dependencias
echo "Instalando dependencias..."

# Intentar instalar textual con --break-system-packages (para versiones nuevas de pip)
pip3 install --break-system-packages textual 2>/dev/null

# Si falla, intentar sin esa opción
if [ $? -ne 0 ]; then
    show_warning "Instalando textual con método alternativo..."
    pip3 install textual
    
    if [ $? -ne 0 ]; then
        show_error "No se pudo instalar textual. Intentando con sudo..."
        sudo pip3 install textual
        
        if [ $? -ne 0 ]; then
            show_error "No se pudo instalar textual. Por favor, instálalo manualmente con:"
            echo "sudo pip3 install textual"
            exit 1
        fi
    fi
fi

show_status "Dependencias instaladas correctamente"

# Establecer permisos
echo "Configurando permisos..."
chmod -R 755 "$INSTALL_DIR"
chmod 755 "$INSTALL_DIR"/*.py
chmod 644 "$INSTALL_DIR"/styles.css
show_status "Permisos configurados correctamente"

# Crear script ejecutable
echo "Creando script ejecutable..."
cat > "/usr/local/bin/kaliBerry" << 'EOF'
#!/bin/bash
# Script ejecutable para KaliBerry

# Verificar si textual está instalado
python3 -c "import textual" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: La biblioteca 'textual' no está instalada."
  echo "Por favor, instálela con:"
  echo "sudo pip3 install textual"
  exit 1
fi

# Ejecutar KaliBerry
cd /opt/kaliBerry
python3 /opt/kaliBerry/kaliBerry.py "$@"
EOF

chmod 755 "/usr/local/bin/kaliBerry"
show_status "Script ejecutable creado en /usr/local/bin/kaliBerry"

# Crear caché de herramientas
echo "Configurando caché de herramientas..."
mkdir -p "$HOME/.config/kaliBerry"

# Verificar la instalación
echo "Verificando la instalación..."
if [ -f "/usr/local/bin/kaliBerry" ] && [ -x "/usr/local/bin/kaliBerry" ]; then
    show_status "Script ejecutable creado correctamente"
else
    show_error "Error al crear el script ejecutable"
fi

if [ -f "$INSTALL_DIR/kaliBerry.py" ]; then
    show_status "Archivos de programa copiados correctamente"
else
    show_error "Error al copiar los archivos del programa"
fi

echo ""
echo "====================================================="
echo "      ¡Instalación de KaliBerry completada!          "
echo "====================================================="
echo ""
echo "Ahora puedes ejecutar KaliBerry escribiendo:"
echo ""
echo "  kaliBerry"
echo ""
echo "en cualquier terminal."
echo ""
echo "Si encuentras algún problema, ejecuta:"
echo ""
echo "  sudo kaliBerry"
echo ""
echo "¡Disfruta de KaliBerry!"
echo ""

# Preguntar si desea ejecutar KaliBerry ahora
read -p "¿Deseas ejecutar KaliBerry ahora? (s/n): " RUN_NOW
if [[ $RUN_NOW == "s" || $RUN_NOW == "S" ]]; then
    echo "Iniciando KaliBerry..."
    kaliBerry
fi

# KaliBerry

KaliBerry es una interfaz de línea de comandos (CLI) para Kali Linux que facilita el acceso y la gestión de las herramientas de auditoría. Inspirada en la estética de [bebbleberry](https://github.com/alliraine/bebbleberry), KaliBerry ofrece una experiencia de usuario más agradable y eficiente para el uso de las herramientas de Kali Linux.

## Características

- **Detección automática de herramientas**: KaliBerry detecta e incorpora automáticamente las herramientas de Kali Linux sin necesidad de configuración manual.
- **Interfaz intuitiva**: Navegación sencilla mediante teclado o ratón.
- **Sistema de desplazamiento**: Permite navegar fácilmente por la lista de herramientas, especialmente útil para aquellas que no caben en la pantalla.
- **Categorización automática**: Las herramientas se organizan automáticamente en categorías según su funcionalidad.
- **Información detallada**: Muestra descripciones y detalles de cada herramienta.
- **Navegación rápida**: Incluye botones para salir y volver al menú principal desde cualquier herramienta seleccionada.
- **Estética moderna**: Diseño inspirado en bebbleberry con colores atractivos y una interfaz limpia.

## Requisitos

- Kali Linux (o cualquier distribución basada en Debian con herramientas de Kali)
- Python 3.7 o superior
- Biblioteca Textual para Python

## Guía de Instalación para Principiantes

### Paso 1: Abrir la Terminal

Primero, necesitas abrir una terminal en tu sistema Kali Linux:
- Haz clic en el icono de la terminal en la barra de tareas, o
- Presiona `Ctrl+Alt+T` en tu teclado

### Paso 2: Descargar KaliBerry

Copia y pega los siguientes comandos en la terminal, presionando Enter después de cada uno:

\`\`\`bash
# Descargar KaliBerry
git clone https://github.com/yourusername/kaliBerry.git

# Entrar al directorio de KaliBerry
cd kaliBerry
\`\`\`

### Paso 3: Instalar Dependencias

KaliBerry necesita la biblioteca Textual para funcionar. Instálala con este comando:

\`\`\`bash
# Instalar la biblioteca Textual
pip3 install --break-system-packages textual
\`\`\`

Si ves algún mensaje de error, prueba con este comando alternativo:

\`\`\`bash
# Alternativa para instalar Textual
sudo pip3 install textual
\`\`\`

### Paso 4: Ejecutar KaliBerry

Ahora puedes ejecutar KaliBerry directamente:

\`\`\`bash
# Ejecutar KaliBerry
python3 kaliBerry.py
\`\`\`

### Paso 5 (Opcional): Crear un Acceso Directo

Para poder ejecutar KaliBerry desde cualquier ubicación, puedes crear un acceso directo:

\`\`\`bash
# Hacer el archivo ejecutable
chmod +x kaliBerry.py

# Crear un enlace en /usr/local/bin (requiere permisos de administrador)
sudo ln -s "$(pwd)/kaliBerry.py" /usr/local/bin/kaliBerry
\`\`\`

Después de este paso, podrás iniciar KaliBerry simplemente escribiendo `kaliBerry` en cualquier terminal.

### Solución de Problemas Comunes

1. **Error "Permission denied"**: 
   - Asegúrate de tener permisos para ejecutar el archivo con `chmod +x kaliBerry.py`

2. **Error "Command not found"**:
   - Verifica que estás en el directorio correcto con `pwd`
   - Asegúrate de escribir correctamente el comando: `python3 kaliBerry.py`

3. **Error al instalar Textual**:
   - Intenta actualizar pip: `pip3 install --upgrade pip`
   - Luego vuelve a intentar instalar Textual

4. **No se muestran herramientas**:
   - Ejecuta KaliBerry con permisos de administrador: `sudo kaliBerry`
   - Esto puede ser necesario la primera vez para detectar todas las herramientas

## Uso

- Utilice las teclas de flecha o `j`/`k` para navegar por las listas.
- Presione `Enter` para seleccionar una categoría o herramienta.
- Presione `Esc` para volver atrás.
- Presione `h` para volver al menú principal.
- Presione `q` para salir de la aplicación.
- Presione `?` para mostrar la ayuda.

## Personalización

Puede personalizar KaliBerry editando los siguientes archivos:

- `config.py`: Configuración general y categorías de herramientas.
- `styles.css`: Estilos y colores de la interfaz.

## Contribuir

Las contribuciones son bienvenidas. Por favor, siéntase libre de enviar pull requests o abrir issues para mejorar KaliBerry.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - vea el archivo LICENSE para más detalles.

## Agradecimientos

- Inspirado en [bebbleberry](https://github.com/alliraine/bebbleberry)
- Desarrollado para la comunidad de Kali Linux

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

## Instalación

1. Clone el repositorio:
   \`\`\`bash
   git clone https://github.com/yourusername/kaliBerry.git
   cd kaliBerry
   \`\`\`

2. Instale las dependencias:
   \`\`\`bash
   pip3 install --break-system-packages textual
   \`\`\`

3. Ejecute KaliBerry:
   \`\`\`bash
   python3 kaliBerry.py
   \`\`\`

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

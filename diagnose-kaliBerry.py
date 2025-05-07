#!/usr/bin/env python3
"""
Script de diagnóstico para KaliBerry
"""

import os
import sys
import json
import shutil
import subprocess
from pathlib import Path

# Colores para los mensajes
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'  # Sin Color

def print_status(message):
    print(f"{GREEN}[✓] {message}{NC}")

def print_warning(message):
    print(f"{YELLOW}[!] {message}{NC}")

def print_error(message):
    print(f"{RED}[✗] {message}{NC}")

def check_python():
    """Verificar la instalación de Python."""
    print("Verificando Python...")
    python_version = sys.version
    print_status(f"Python {python_version}")
    
    try:
        import textual
        print_status(f"Textual {textual.__version__} está instalado")
    except ImportError:
        print_error("Textual no está instalado")
        print("Instálalo con: pip3 install --break-system-packages textual")

def check_directories():
    """Verificar directorios importantes."""
    print("\nVerificando directorios...")
    
    # Verificar directorio de instalación
    install_dir = "/opt/kaliBerry"
    if os.path.exists(install_dir):
        print_status(f"Directorio de instalación {install_dir} existe")
        
        # Verificar archivos principales
        files = ["kaliBerry.py", "tool_manager.py", "ui_manager.py", "config.py", "styles.css"]
        for file in files:
            file_path = os.path.join(install_dir, file)
            if os.path.exists(file_path):
                print_status(f"Archivo {file} existe")
            else:
                print_error(f"Archivo {file} no existe")
    else:
        print_error(f"Directorio de instalación {install_dir} no existe")
    
    # Verificar directorio de configuración
    config_dir = os.path.join(str(Path.home()), ".config", "kaliBerry")
    if os.path.exists(config_dir):
        print_status(f"Directorio de configuración {config_dir} existe")
        
        # Verificar caché de herramientas
        cache_file = os.path.join(config_dir, "tools_cache.json")
        if os.path.exists(cache_file):
            print_status(f"Archivo de caché {cache_file} existe")
            
            # Verificar contenido del caché
            try:
                with open(cache_file, 'r') as f:
                    cache_data = json.load(f)
                    tool_count = sum(len(tools) for tools in cache_data.values())
                    print_status(f"Caché contiene {tool_count} herramientas")
            except json.JSONDecodeError:
                print_error(f"El archivo de caché no es un JSON válido")
            except Exception as e:
                print_error(f"Error al leer el caché: {e}")
        else:
            print_warning(f"Archivo de caché {cache_file} no existe")
    else:
        print_warning(f"Directorio de configuración {config_dir} no existe")

def check_tools():
    """Verificar herramientas comunes de Kali."""
    print("\nVerificando herramientas comunes...")
    
    common_tools = [
        "nmap", "whois", "dig", "nikto", "dirb", "john", "hydra", 
        "wireshark", "metasploit", "aircrack-ng", "sqlmap"
    ]
    
    found_tools = []
    missing_tools = []
    
    for tool in common_tools:
        if shutil.which(tool):
            found_tools.append(tool)
        else:
            missing_tools.append(tool)
    
    if found_tools:
        print_status(f"Herramientas encontradas: {', '.join(found_tools)}")
    
    if missing_tools:
        print_warning(f"Herramientas no encontradas: {', '.join(missing_tools)}")

def check_kali_dirs():
    """Verificar directorios de Kali Linux."""
    print("\nVerificando directorios de Kali Linux...")
    
    kali_dirs = [
        "/usr/share/kali-menu/applications",
        "/usr/share/applications",
        "/usr/bin",
        "/usr/local/bin",
        "/bin",
        "/sbin",
        "/usr/sbin",
        "/opt/metasploit-framework/bin"
    ]
    
    for directory in kali_dirs:
        if os.path.exists(directory) and os.path.isdir(directory):
            print_status(f"Directorio {directory} existe")
            
            # Contar archivos
            try:
                file_count = len(os.listdir(directory))
                print_status(f"  Contiene {file_count} archivos/directorios")
            except:
                print_warning(f"  No se puede acceder al contenido")
        else:
            print_warning(f"Directorio {directory} no existe")

def create_minimal_cache():
    """Crear un caché mínimo de herramientas."""
    print("\nCreando caché mínimo de herramientas...")
    
    config_dir = os.path.join(str(Path.home()), ".config", "kaliBerry")
    os.makedirs(config_dir, exist_ok=True)
    
    cache_file = os.path.join(config_dir, "tools_cache.json")
    
    # Herramientas básicas que deberían estar en cualquier sistema
    minimal_tools = {
        "information-gathering": [
            {"name": "nmap", "description": "Herramienta de escaneo de redes", "command": "nmap"}
        ],
        "vulnerability-analysis": [
            {"name": "nikto", "description": "Escáner de vulnerabilidades web", "command": "nikto"}
        ],
        "web-application": [
            {"name": "dirb", "description": "Escáner de directorios web", "command": "dirb"}
        ],
        "other-tools": [
            {"name": "vim", "description": "Editor de texto avanzado", "command": "vim"},
            {"name": "git", "description": "Sistema de control de versiones", "command": "git"},
            {"name": "tmux", "description": "Multiplexor de terminal", "command": "tmux"}
        ]
    }
    
    # Filtrar solo las herramientas que existen en el sistema
    filtered_tools = {}
    for category, tools in minimal_tools.items():
        filtered_tools[category] = []
        for tool in tools:
            if shutil.which(tool["command"]):
                filtered_tools[category].append(tool)
    
    # Guardar en caché
    try:
        with open(cache_file, 'w') as f:
            json.dump(filtered_tools, f, indent=2)
        print_status(f"Caché mínimo creado en {cache_file}")
    except Exception as e:
        print_error(f"Error al crear caché mínimo: {e}")

def main():
    """Función principal."""
    print("===================================================")
    print("      Diagnóstico de KaliBerry                     ")
    print("===================================================")
    print("")
    
    check_python()
    check_directories()
    check_tools()
    check_kali_dirs()
    create_minimal_cache()
    
    print("\n===================================================")
    print("      Diagnóstico completado                       ")
    print("===================================================")
    print("")
    print("Si KaliBerry sigue sin funcionar correctamente, prueba:")
    print("1. Eliminar el caché: rm -f ~/.config/kaliBerry/tools_cache.json")
    print("2. Ejecutar KaliBerry con: kaliBerry")
    print("")
    print("Si el problema persiste, ejecuta KaliBerry en modo de depuración:")
    print("TEXTUAL_LOG=debug kaliBerry")
    print("")

if __name__ == "__main__":
    main()

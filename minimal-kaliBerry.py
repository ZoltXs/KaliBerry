#!/usr/bin/env python3
"""
KaliBerry - Versión mínima sin dependencias externas
"""
import os
import sys
import subprocess
import json
from pathlib import Path

# Configuración básica
CONFIG_DIR = os.path.join(str(Path.home()), ".config", "kaliBerry")
TOOLS_CACHE_FILE = os.path.join(CONFIG_DIR, "tools_cache.json")

# Asegurar que el directorio de configuración existe
os.makedirs(CONFIG_DIR, exist_ok=True)

# Categorías de herramientas
CATEGORIES = [
    "information-gathering",
    "vulnerability-analysis",
    "web-application",
    "database-assessment",
    "password-attacks",
    "wireless-attacks",
    "exploitation-tools",
    "sniffing-spoofing",
    "post-exploitation",
    "forensics",
    "reporting-tools",
    "social-engineering",
    "reverse-engineering",
    "other-tools"
]

def create_minimal_cache():
    """Crear un caché mínimo con herramientas básicas."""
    print("Creando caché mínimo...")
    
    # Herramientas básicas
    minimal_tools = {
        "information-gathering": [
            {"name": "nmap", "description": "Herramienta de escaneo de redes", "command": "nmap"}
        ],
        "wireless-attacks": [
            {"name": "wifite", "description": "Herramienta para auditorías WiFi", "command": "wifite"}
        ],
        "other-tools": [
            {"name": "vim", "description": "Editor de texto", "command": "vim"}
        ]
    }
    
    # Filtrar solo las herramientas que existen
    tools = {}
    for category, category_tools in minimal_tools.items():
        tools[category] = []
        for tool in category_tools:
            if os.system(f"which {tool['command']} > /dev/null 2>&1") == 0:
                tools[category].append(tool)
    
    # Guardar en caché
    with open(TOOLS_CACHE_FILE, 'w') as f:
        json.dump(tools, f, indent=2)
    
    return tools

def load_tools():
    """Cargar herramientas desde el caché o crear un caché mínimo."""
    if os.path.exists(TOOLS_CACHE_FILE):
        try:
            with open(TOOLS_CACHE_FILE, 'r') as f:
                return json.load(f)
        except:
            print("Error al cargar el caché. Creando uno nuevo...")
    
    return create_minimal_cache()

def display_menu(tools):
    """Mostrar menú de categorías y herramientas."""
    print("\n=== KaliBerry - Menú Principal ===\n")
    
    # Mostrar categorías con herramientas
    categories = [cat for cat in CATEGORIES if cat in tools and tools[cat]]
    
    for i, category in enumerate(categories, 1):
        print(f"{i}. {category.replace('-', ' ').title()} ({len(tools[category])} herramientas)")
    
    print("\n0. Salir")
    
    # Obtener selección del usuario
    try:
        choice = int(input("\nSelecciona una categoría (0-{}): ".format(len(categories))))
        if choice == 0:
            return False
        elif 1 <= choice <= len(categories):
            display_tools(tools, categories[choice-1])
        else:
            print("Opción no válida.")
    except ValueError:
        print("Por favor, introduce un número.")
    except KeyboardInterrupt:
        print("\nSaliendo...")
        return False
    
    return True

def display_tools(tools, category):
    """Mostrar herramientas de una categoría."""
    while True:
        print(f"\n=== Herramientas de {category.replace('-', ' ').title()} ===\n")
        
        category_tools = tools[category]
        for i, tool in enumerate(category_tools, 1):
            print(f"{i}. {tool['name']}: {tool['description']}")
        
        print("\n0. Volver al menú principal")
        
        # Obtener selección del usuario
        try:
            choice = int(input("\nSelecciona una herramienta (0-{}): ".format(len(category_tools))))
            if choice == 0:
                return
            elif 1 <= choice <= len(category_tools):
                launch_tool(category_tools[choice-1])
            else:
                print("Opción no válida.")
        except ValueError:
            print("Por favor, introduce un número.")
        except KeyboardInterrupt:
            print("\nVolviendo al menú principal...")
            return

def launch_tool(tool):
    """Lanzar una herramienta."""
    print(f"\nEjecutando {tool['name']}...")
    os.system(f"clear && {tool['command']}")
    input("\nPresiona Enter para continuar...")

def main():
    """Función principal."""
    print("Iniciando KaliBerry...")
    
    # Cargar herramientas
    tools = load_tools()
    
    # Mostrar menú principal
    while display_menu(tools):
        pass
    
    print("¡Gracias por usar KaliBerry!")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nSaliendo de KaliBerry...")
    except Exception as e:
        print(f"Error: {e}")

#!/usr/bin/env python3
"""
Script para encontrar herramientas de Kali Linux en el sistema
"""

import os
import json
import shutil
from pathlib import Path

# Directorios donde buscar herramientas
SEARCH_DIRS = [
    "/usr/bin",
    "/usr/sbin",
    "/bin",
    "/sbin",
    "/usr/local/bin",
    "/usr/local/sbin"
]

# Herramientas comunes de Kali Linux
COMMON_TOOLS = {
    "information-gathering": ["nmap", "whois", "dig", "host", "traceroute", "netcat", "nc"],
    "vulnerability-analysis": ["nikto", "wpscan", "sqlmap", "lynis"],
    "web-application": ["dirb", "dirbuster", "gobuster", "wfuzz", "burpsuite", "zaproxy"],
    "password-attacks": ["john", "hashcat", "hydra", "medusa", "ncrack", "crunch"],
    "wireless-attacks": ["wifite", "aircrack-ng", "aireplay-ng", "airodump-ng", "kismet"],
    "exploitation-tools": ["metasploit", "msfconsole", "searchsploit", "beef", "set"],
    "other-tools": ["vim", "nano", "git", "curl", "wget", "ssh", "netstat", "ifconfig", "ip"]
}

def find_tools():
    """Encontrar herramientas de Kali Linux en el sistema."""
    print("Buscando herramientas de Kali Linux...")
    
    found_tools = {}
    
    # Inicializar categorías
    for category in COMMON_TOOLS:
        found_tools[category] = []
    
    # Buscar herramientas en los directorios
    for directory in SEARCH_DIRS:
        if os.path.exists(directory) and os.path.isdir(directory):
            print(f"Buscando en {directory}...")
            
            for category, tools in COMMON_TOOLS.items():
                for tool in tools:
                    tool_path = os.path.join(directory, tool)
                    if os.path.exists(tool_path) and os.access(tool_path, os.X_OK):
                        print(f"Encontrada herramienta: {tool} en {tool_path}")
                        
                        # Verificar si ya existe en la lista
                        if not any(t.get("name") == tool for t in found_tools[category]):
                            found_tools[category].append({
                                "name": tool,
                                "description": f"Herramienta de Kali Linux: {tool}",
                                "command": tool_path
                            })
    
    # Buscar herramientas usando which
    for category, tools in COMMON_TOOLS.items():
        for tool in tools:
            tool_path = shutil.which(tool)
            if tool_path:
                print(f"Encontrada herramienta (which): {tool} en {tool_path}")
                
                # Verificar si ya existe en la lista
                if not any(t.get("name") == tool for t in found_tools[category]):
                    found_tools[category].append({
                        "name": tool,
                        "description": f"Herramienta de Kali Linux: {tool}",
                        "command": tool_path
                    })
    
    # Eliminar categorías vacías
    empty_categories = []
    for category in found_tools:
        if not found_tools[category]:
            empty_categories.append(category)
    
    for category in empty_categories:
        del found_tools[category]
    
    # Guardar en archivo
    config_dir = os.path.join(str(Path.home()), ".config", "kaliBerry")
    os.makedirs(config_dir, exist_ok=True)
    
    cache_file = os.path.join(config_dir, "tools_cache.json")
    with open(cache_file, 'w') as f:
        json.dump(found_tools, f, indent=2)
    
    print(f"Herramientas encontradas guardadas en {cache_file}")
    
    # Mostrar resumen
    total_tools = sum(len(tools) for tools in found_tools.values())
    print(f"Total de herramientas encontradas: {total_tools}")
    for category in found_tools:
        print(f"  {category}: {len(found_tools[category])} herramientas")

if __name__ == "__main__":
    find_tools()

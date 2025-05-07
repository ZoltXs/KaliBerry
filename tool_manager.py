#!/usr/bin/env python3
"""
Gestor de herramientas para KaliBerry
"""

import os
import subprocess
import json
import shutil
import traceback
from pathlib import Path
from typing import Dict, List, Optional
from config import TOOLS_CACHE_FILE, CONFIG_DIR, TOOL_CATEGORIES

class ToolManager:
    """Clase para gestionar las herramientas de Kali Linux."""
    
    def __init__(self):
        self.tools = {}
        self.categories = list(TOOL_CATEGORIES.keys())
        self.load_tools()
    
    def load_tools(self) -> None:
        """Cargar las herramientas desde el caché o crear un caché predefinido."""
        # Inicializar con categorías vacías
        self.tools = {category: [] for category in self.categories}
        
        try:
            # Asegurarse de que el directorio de caché existe
            os.makedirs(os.path.dirname(TOOLS_CACHE_FILE), exist_ok=True)
            
            # Intentar cargar desde el caché
            if os.path.exists(TOOLS_CACHE_FILE) and os.path.getsize(TOOLS_CACHE_FILE) > 0:
                try:
                    with open(TOOLS_CACHE_FILE, 'r') as f:
                        cache_data = json.load(f)
                        if isinstance(cache_data, dict):
                            self.tools.update(cache_data)
                            print("Caché de herramientas cargado correctamente.")
                            return
                except Exception as e:
                    print(f"Error al cargar el caché: {e}")
            
            # Si no se pudo cargar el caché, crear uno predefinido
            print("Creando caché predefinido...")
            self._create_predefined_cache()
        except Exception as e:
            print(f"Error al cargar herramientas: {e}")
            traceback.print_exc()
            # En caso de error, crear un caché predefinido
            self._create_predefined_cache()
    
    def _create_predefined_cache(self) -> None:
        """Crear un caché predefinido con herramientas comunes de Kali."""
        # Herramientas predefinidas con rutas absolutas
        predefined_tools = {
            "information-gathering": [
                {"name": "nmap", "description": "Herramienta de escaneo de redes", "command": "/usr/bin/nmap"},
                {"name": "whois", "description": "Cliente whois para consultar información de dominios", "command": "/usr/bin/whois"},
                {"name": "dig", "description": "Herramienta de consulta DNS", "command": "/usr/bin/dig"}
            ],
            "vulnerability-analysis": [
                {"name": "nikto", "description": "Escáner de vulnerabilidades web", "command": "/usr/bin/nikto"}
            ],
            "web-application": [
                {"name": "dirb", "description": "Escáner de directorios web", "command": "/usr/bin/dirb"},
                {"name": "sqlmap", "description": "Herramienta de detección y explotación de inyección SQL", "command": "/usr/bin/sqlmap"}
            ],
            "password-attacks": [
                {"name": "john", "description": "John the Ripper - Herramienta de cracking de contraseñas", "command": "/usr/bin/john"},
                {"name": "hydra", "description": "Herramienta de fuerza bruta para múltiples servicios", "command": "/usr/bin/hydra"}
            ],
            "wireless-attacks": [
                {"name": "wifite", "description": "Herramienta automatizada para auditorías WiFi", "command": "/usr/sbin/wifite"},
                {"name": "aircrack-ng", "description": "Suite para auditoría de redes inalámbricas", "command": "/usr/bin/aircrack-ng"}
            ],
            "exploitation-tools": [
                {"name": "metasploit", "description": "Framework de explotación", "command": "/usr/bin/msfconsole"},
                {"name": "searchsploit", "description": "Buscador de exploits", "command": "/usr/bin/searchsploit"}
            ],
            "other-tools": [
                {"name": "vim", "description": "Editor de texto avanzado", "command": "/usr/bin/vim"},
                {"name": "nano", "description": "Editor de texto simple", "command": "/usr/bin/nano"},
                {"name": "git", "description": "Sistema de control de versiones", "command": "/usr/bin/git"}
            ]
        }
        
        # Verificar qué herramientas existen realmente en el sistema
        for category, tools_list in predefined_tools.items():
            self.tools[category] = []
            for tool in tools_list:
                command_path = tool["command"]
                if os.path.exists(command_path):
                    # La herramienta existe, añadirla al caché
                    self.tools[category].append(tool)
                    print(f"Añadida herramienta: {tool['name']}")
                else:
                    # Intentar encontrar la herramienta en el PATH
                    command_name = os.path.basename(command_path)
                    command_in_path = shutil.which(command_name)
                    if command_in_path:
                        # Actualizar la ruta al comando
                        tool["command"] = command_in_path
                        self.tools[category].append(tool)
                        print(f"Añadida herramienta (en PATH): {tool['name']}")
        
        # Verificar si hay herramientas en cada categoría
        empty_categories = []
        for category in self.categories:
            if not self.tools.get(category, []):
                empty_categories.append(category)
        
        # Eliminar categorías vacías
        for category in empty_categories:
            if category in self.tools:
                del self.tools[category]
        
        # Asegurarse de que al menos hay una categoría con herramientas
        if all(len(tools) == 0 for tools in self.tools.values()):
            print("No se encontraron herramientas. Añadiendo herramientas básicas del sistema...")
            
            # Buscar herramientas básicas del sistema
            basic_tools = ["ls", "cat", "grep", "find", "ps", "top", "htop", "ifconfig", "ip"]
            self.tools["other-tools"] = []
            
            for tool in basic_tools:
                tool_path = shutil.which(tool)
                if tool_path:
                    self.tools["other-tools"].append({
                        "name": tool,
                        "description": f"Herramienta básica del sistema: {tool}",
                        "command": tool_path
                    })
                    print(f"Añadida herramienta básica: {tool}")
        
        # Guardar en caché
        self._save_cache()
    
    def _save_cache(self) -> None:
        """Guardar las herramientas en caché."""
        try:
            # Asegurarse de que el directorio existe
            os.makedirs(os.path.dirname(TOOLS_CACHE_FILE), exist_ok=True)
            
            # Guardar el caché
            with open(TOOLS_CACHE_FILE, 'w') as f:
                json.dump(self.tools, f, indent=2)
            
            print("Caché guardado correctamente.")
        except Exception as e:
            print(f"Error al guardar el caché: {e}")
            traceback.print_exc()
    
    def get_categories(self) -> List[str]:
        """Obtener las categorías disponibles."""
        # Filtrar categorías vacías
        return [category for category in self.tools.keys() if self.tools.get(category, [])]
    
    def get_all_categories(self) -> List[str]:
        """Obtener todas las categorías, incluso las vacías."""
        return list(self.categories)
    
    def get_tools_by_category(self, category: str) -> List[Dict]:
        """Obtener herramientas por categoría."""
        return self.tools.get(category, [])
    
    def get_tool_info(self, tool_name: str) -> Optional[Dict]:
        """Obtener información de una herramienta específica."""
        for category in self.tools:
            for tool in self.tools[category]:
                if tool.get("name") == tool_name:
                    return tool
        return None
    
    def add_tool(self, name: str, description: str, command: str, category: str) -> bool:
        """Añadir una herramienta manualmente."""
        try:
            # Verificar que la categoría existe
            if category not in self.categories:
                print(f"Categoría {category} no válida.")
                return False
            
            # Verificar que el comando existe
            if not os.path.exists(command) and not shutil.which(command):
                print(f"Comando {command} no encontrado.")
                return False
            
            # Asegurarse de que la categoría existe en el diccionario
            if category not in self.tools:
                self.tools[category] = []
            
            # Verificar si la herramienta ya existe
            for tool in self.tools[category]:
                if tool.get("name") == name:
                    print(f"La herramienta {name} ya existe en la categoría {category}.")
                    return False
            
            # Añadir la herramienta
            self.tools[category].append({
                "name": name,
                "description": description or f"Herramienta: {name}",
                "command": command
            })
            
            # Guardar en caché
            self._save_cache()
            
            print(f"Herramienta {name} añadida correctamente a la categoría {category}.")
            return True
        except Exception as e:
            print(f"Error al añadir herramienta: {e}")
            traceback.print_exc()
            return False
    
    def launch_tool(self, tool_name: str) -> None:
        """Lanzar una herramienta."""
        tool_info = self.get_tool_info(tool_name)
        if tool_info:
            command = tool_info["command"]
            print(f"Ejecutando: {command}")
            os.system(f"clear && {command}")

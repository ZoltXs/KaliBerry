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
from config import TOOLS_CACHE_FILE, KALI_TOOLS_DIRS, TOOL_CATEGORIES, CONFIG_DIR

class ToolManager:
    """Clase para gestionar las herramientas de Kali Linux."""
    
    def __init__(self):
        self.tools = {}
        self.categories = list(TOOL_CATEGORIES.keys())
        self.load_tools()
    
    def load_tools(self) -> None:
        """Cargar las herramientas desde el caché o detectarlas."""
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
            
            # Si no se pudo cargar el caché, crear uno mínimo
            print("Creando caché mínimo...")
            self._create_minimal_cache()
        except Exception as e:
            print(f"Error al cargar herramientas: {e}")
            traceback.print_exc()
            # En caso de error, crear un caché mínimo
            self._create_minimal_cache()
    
    def _create_minimal_cache(self) -> None:
        """Crear un caché mínimo con herramientas básicas."""
        # Herramientas básicas
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
            "password-attacks": [
                {"name": "john", "description": "John the Ripper - Cracking de contraseñas", "command": "john"}
            ],
            "wireless-attacks": [
                {"name": "wifite", "description": "Herramienta para auditorías WiFi", "command": "wifite"},
                {"name": "aircrack-ng", "description": "Suite para auditoría WiFi", "command": "aircrack-ng"}
            ],
            "other-tools": [
                {"name": "vim", "description": "Editor de texto avanzado", "command": "vim"},
                {"name": "nano", "description": "Editor de texto simple", "command": "nano"}
            ]
        }
        
        # Filtrar solo las herramientas que existen
        for category, tools_list in minimal_tools.items():
            if category not in self.tools:
                self.tools[category] = []
                
            for tool in tools_list:
                command = tool["command"]
                if self._command_exists(command):
                    self.tools[category].append(tool)
                    print(f"Añadida herramienta: {tool['name']}")
        
        # Guardar en caché
        self._save_cache()
    
    def _command_exists(self, command: str) -> bool:
        """Verificar si un comando existe en el sistema."""
        try:
            return shutil.which(command) is not None
        except Exception:
            return False
    
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
        return [category for category in self.categories if self.tools.get(category, [])]
    
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
    
    def launch_tool(self, tool_name: str) -> None:
        """Lanzar una herramienta."""
        tool_info = self.get_tool_info(tool_name)
        if tool_info:
            command = tool_info["command"]
            print(f"Ejecutando: {command}")
            os.system(f"clear && {command}")

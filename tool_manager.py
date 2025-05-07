#!/usr/bin/env python3
"""
Gestor de herramientas para KaliBerry
"""

import os
import subprocess
import json
import re
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple
from config import TOOLS_CACHE_FILE, KALI_TOOLS_DIRS, TOOL_CATEGORIES

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
            if os.path.exists(TOOLS_CACHE_FILE):
                try:
                    with open(TOOLS_CACHE_FILE, 'r') as f:
                        cache_data = json.load(f)
                        # Verificar que el caché tiene el formato correcto
                        if isinstance(cache_data, dict):
                            self.tools.update(cache_data)
                except Exception as e:
                    print(f"Error al cargar el caché: {e}")
                    # En caso de error, usar herramientas predefinidas
                    self._initialize_with_predefined_tools()
            else:
                # Si no existe el caché, usar herramientas predefinidas
                self._initialize_with_predefined_tools()
                # Intentar detectar más herramientas
                self.detect_tools()
        except Exception as e:
            print(f"Error al inicializar: {e}")
            # En caso de cualquier error, usar herramientas predefinidas
            self._initialize_with_predefined_tools()
    
    def _initialize_with_predefined_tools(self) -> None:
        """Inicializar con herramientas predefinidas."""
        # Herramientas básicas que deberían estar en cualquier sistema
        common_tools = {
            "information-gathering": [
                {"name": "nmap", "description": "Herramienta de escaneo de redes", "command": "nmap"},
                {"name": "whois", "description": "Cliente whois para consultar información de dominios", "command": "whois"},
                {"name": "dig", "description": "Herramienta de consulta DNS", "command": "dig"}
            ],
            "vulnerability-analysis": [
                {"name": "nikto", "description": "Escáner de vulnerabilidades web", "command": "nikto"}
            ],
            "web-application": [
                {"name": "dirb", "description": "Escáner de directorios web", "command": "dirb"}
            ],
            "password-attacks": [
                {"name": "john", "description": "John the Ripper - Herramienta de cracking de contraseñas", "command": "john"}
            ],
            "other-tools": [
                {"name": "vim", "description": "Editor de texto avanzado", "command": "vim"},
                {"name": "git", "description": "Sistema de control de versiones", "command": "git"},
                {"name": "tmux", "description": "Multiplexor de terminal", "command": "tmux"}
            ]
        }
        
        # Añadir herramientas predefinidas a las categorías
        for category, tools_list in common_tools.items():
            if category in self.tools:
                for tool in tools_list:
                    # Verificar si la herramienta existe en el sistema
                    if self._command_exists(tool["command"]):
                        # Evitar duplicados
                        if not any(t["name"] == tool["name"] for t in self.tools[category]):
                            self.tools[category].append(tool)
        
        # Intentar guardar en caché
        try:
            self._save_cache()
        except Exception as e:
            print(f"Error al guardar el caché inicial: {e}")
    
    def detect_tools(self) -> None:
        """Detectar todas las herramientas de Kali Linux."""
        try:
            # Método 1: Detectar herramientas usando which para comandos conocidos
            for category, tools_list in TOOL_CATEGORIES.items():
                for tool in tools_list:
                    if self._command_exists(tool):
                        description = self._get_tool_description(tool)
                        # Evitar duplicados
                        if not any(t["name"] == tool for t in self.tools[category]):
                            self.tools[category].append({
                                "name": tool,
                                "description": description,
                                "command": tool
                            })
            
            # Método 2: Buscar archivos .desktop en directorios de aplicaciones de Kali
            for directory in KALI_TOOLS_DIRS:
                if os.path.exists(directory) and os.path.isdir(directory):
                    self._scan_directory_for_tools(directory)
            
            # Método 3: Usar apt para listar paquetes de Kali instalados
            self._detect_kali_packages()
            
            # Guardar en caché
            self._save_cache()
        except Exception as e:
            print(f"Error al detectar herramientas: {e}")
    
    def _command_exists(self, command: str) -> bool:
        """Verificar si un comando existe en el sistema."""
        return shutil.which(command) is not None
    
    def _scan_directory_for_tools(self, directory: str) -> None:
        """Escanear un directorio en busca de herramientas de Kali."""
        try:
            for root, dirs, files in os.walk(directory):
                for file in files:
                    if file.endswith(".desktop"):
                        desktop_file = os.path.join(root, file)
                        tool_info = self._parse_desktop_file(desktop_file)
                        if tool_info:
                            category = self._categorize_tool(tool_info["name"], tool_info["description"])
                            # Evitar duplicados
                            if not any(t["name"] == tool_info["name"] for t in self.tools[category]):
                                self.tools[category].append(tool_info)
        except Exception as e:
            print(f"Error al escanear directorio {directory}: {e}")
    
    def _parse_desktop_file(self, desktop_file: str) -> Optional[Dict]:
        """Parsear un archivo .desktop para obtener información de la herramienta."""
        try:
            name = ""
            description = ""
            command = ""
            
            with open(desktop_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if line.startswith("Name="):
                        name = line.split("=", 1)[1].strip()
                    elif line.startswith("Comment=") or line.startswith("GenericName="):
                        description = line.split("=", 1)[1].strip()
                    elif line.startswith("Exec="):
                        command_line = line.split("=", 1)[1].strip()
                        # Limpiar parámetros del comando
                        command = command_line.split(" ")[0]
                        if "/" in command:
                            command = os.path.basename(command)
            
            if name and command:
                return {
                    "name": name,
                    "description": description or f"Herramienta de Kali Linux: {name}",
                    "command": command
                }
            return None
        except Exception as e:
            print(f"Error al parsear archivo .desktop {desktop_file}: {e}")
            return None
    
    def _detect_kali_packages(self) -> None:
        """Detectar paquetes de Kali instalados usando apt."""
        try:
            result = subprocess.run(
                ["apt", "list", "--installed"], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                text=True
            )
            
            if result.returncode == 0:
                for line in result.stdout.split('\n'):
                    if "kali" in line.lower():
                        parts = line.split('/')
                        if len(parts) > 0:
                            package_name = parts[0].strip()
                            # Verificar si el paquete tiene un comando ejecutable
                            command = package_name.split(':')[0]  # Eliminar versión de arquitectura si existe
                            if self._command_exists(command):
                                description = self._get_tool_description(command)
                                category = self._categorize_tool(command, description)
                                
                                # Evitar duplicados
                                if not any(tool["name"] == command for tool in self.tools[category]):
                                    self.tools[category].append({
                                        "name": command,
                                        "description": description,
                                        "command": command
                                    })
        except Exception as e:
            print(f"Error al detectar paquetes de Kali: {e}")
    
    def detect_new_tools(self) -> None:
        """Detectar nuevas herramientas que no estén en el caché."""
        # Por simplicidad, volvemos a detectar todas las herramientas
        self.detect_tools()
    
    def _categorize_tool(self, tool_name: str, description: str = "") -> str:
        """Categorizar una herramienta basada en su nombre y descripción."""
        tool_lower = tool_name.lower()
        desc_lower = description.lower()
        
        # Verificar si la herramienta está en alguna categoría predefinida
        for category, tools_list in TOOL_CATEGORIES.items():
            if tool_lower in [t.lower() for t in tools_list]:
                return category
        
        # Categorizar por palabras clave en el nombre o descripción
        keywords = {
            "information-gathering": ["scan", "recon", "info", "gather", "enum", "discover"],
            "vulnerability-analysis": ["vuln", "analysis", "assess", "scan", "audit"],
            "web-application": ["web", "http", "proxy", "sql", "xss", "csrf", "injection"],
            "database-assessment": ["sql", "db", "database", "postgres", "mysql", "oracle"],
            "password-attacks": ["pass", "crack", "brute", "hash", "password"],
            "wireless-attacks": ["wifi", "wireless", "wpa", "bluetooth", "radio"],
            "exploitation-tools": ["exploit", "payload", "shell", "backdoor"],
            "sniffing-spoofing": ["sniff", "spoof", "mitm", "packet", "network"],
            "post-exploitation": ["post", "privilege", "escalation", "maintain"],
            "forensics": ["forensic", "recover", "memory", "analysis", "evidence"],
            "reporting-tools": ["report", "document", "evidence", "note"],
            "social-engineering": ["social", "phish", "spear", "pretexting"],
            "reverse-engineering": ["reverse", "disassemble", "debug", "binary"],
        }
        
        for category, kw_list in keywords.items():
            for kw in kw_list:
                if kw in tool_lower or kw in desc_lower:
                    return category
        
        # Si no se puede categorizar, usar "other-tools"
        return "other-tools"
    
    def _get_tool_description(self, tool: str) -> str:
        """Obtener la descripción de una herramienta."""
        # Método 1: Usar --help
        try:
            result = subprocess.run(
                [tool, "--help"], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                text=True,
                timeout=1
            )
            
            output = result.stdout if result.returncode == 0 else result.stderr
            
            # Buscar la primera línea que parece una descripción
            lines = output.split('\n')
            for line in lines[:10]:  # Revisar solo las primeras líneas
                line = line.strip()
                if len(line) > 15 and not line.startswith('-') and not line.startswith('Usage'):
                    return line
        except:
            pass
        
        # Método 2: Usar man
        try:
            result = subprocess.run(
                ["man", "-f", tool], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                text=True,
                timeout=1
            )
            
            if result.returncode == 0:
                return result.stdout.strip()
        except:
            pass
        
        # Método 3: Usar apt show
        try:
            result = subprocess.run(
                ["apt", "show", tool], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                text=True,
                timeout=1
            )
            
            if result.returncode == 0:
                for line in result.stdout.split('\n'):
                    if line.startswith("Description:"):
                        return line.split(":", 1)[1].strip()
        except:
            pass
        
        # Si todo falla, devolver una descripción genérica
        return f"Herramienta de Kali Linux: {tool}"
    
    def _save_cache(self) -> None:
        """Guardar las herramientas en caché."""
        try:
            # Asegurarse de que el directorio existe
            os.makedirs(os.path.dirname(TOOLS_CACHE_FILE), exist_ok=True)
            
            # Guardar el caché
            with open(TOOLS_CACHE_FILE, 'w') as f:
                json.dump(self.tools, f, indent=2)
                
            # Verificar que el archivo se guardó correctamente
            if not os.path.exists(TOOLS_CACHE_FILE) or os.path.getsize(TOOLS_CACHE_FILE) == 0:
                print("Advertencia: El archivo de caché parece estar vacío o no se guardó correctamente.")
        except Exception as e:
            print(f"Error al guardar el caché: {e}")
    
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
                if tool["name"] == tool_name:
                    return tool
        return None
    
    def launch_tool(self, tool_name: str) -> None:
        """Lanzar una herramienta."""
        tool_info = self.get_tool_info(tool_name)
        if tool_info:
            command = tool_info["command"]
            os.system(f"clear && {command}")

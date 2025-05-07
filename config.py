#!/usr/bin/env python3
"""
Configuración para KaliBerry
"""

import os
from pathlib import Path

# Información de la aplicación
TITLE = "KaliBerry"
VERSION = "1.0.0"
THEME = "dark"

# Directorios y archivos
HOME_DIR = str(Path.home())
CONFIG_DIR = os.path.join(HOME_DIR, ".config", "kaliBerry")
TOOLS_CACHE_FILE = os.path.join(CONFIG_DIR, "tools_cache.json")

# Directorios donde buscar herramientas de Kali
KALI_TOOLS_DIRS = [
    "/usr/share/kali-menu/applications",
    "/usr/share/applications",
    "/usr/bin",
    "/usr/sbin",
    "/usr/local/bin",
    "/bin",
    "/sbin"
]

# Categorías y herramientas conocidas de Kali Linux
TOOL_CATEGORIES = {
    "information-gathering": ["nmap", "whois", "dig", "recon-ng", "maltego", "theharvester"],
    "vulnerability-analysis": ["nikto", "nessus", "openvas", "lynis", "wpscan", "sqlmap"],
    "web-application": ["burpsuite", "owasp-zap", "skipfish", "wfuzz", "dirb", "dirbuster"],
    "database-assessment": ["sqlmap", "sqlninja", "sqlsus", "oscanner", "sidguesser"],
    "password-attacks": ["hydra", "john", "hashcat", "medusa", "ncrack", "ophcrack"],
    "wireless-attacks": ["aircrack-ng", "kismet", "wifite", "fern-wifi-cracker", "pixiewps"],
    "exploitation-tools": ["metasploit", "searchsploit", "beef", "armitage", "set"],
    "sniffing-spoofing": ["wireshark", "ettercap", "bettercap", "dsniff", "netsniff-ng"],
    "post-exploitation": ["empire", "weevely", "powersploit", "mimikatz", "proxychains"],
    "forensics": ["autopsy", "sleuthkit", "volatility", "foremost", "binwalk"],
    "reporting-tools": ["dradis", "faraday", "pipal", "metagoofil", "maltego"],
    "social-engineering": ["social-engineer-toolkit", "beef", "maltego", "gophish"],
    "reverse-engineering": ["ghidra", "radare2", "apktool", "dex2jar", "jd-gui"],
    "other-tools": []  # Categoría para herramientas que no encajan en las anteriores
}

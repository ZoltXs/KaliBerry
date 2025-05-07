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
    "/usr/local/bin"
]

# Categorías y herramientas conocidas de Kali Linux
TOOL_CATEGORIES = {
    "information-gathering": ["nmap", "whois", "dig", "recon-ng", "maltego", "theharvester", "amass", "spiderfoot"],
    "vulnerability-analysis": ["nikto", "nessus", "openvas", "lynis", "wpscan", "sqlmap", "legion", "sparta"],
    "web-application": ["burpsuite", "owasp-zap", "skipfish", "wfuzz", "dirb", "dirbuster", "gobuster", "ffuf"],
    "database-assessment": ["sqlmap", "sqlninja", "sqlsus", "oscanner", "sidguesser", "sqldict", "sqlbf"],
    "password-attacks": ["hydra", "john", "hashcat", "medusa", "ncrack", "ophcrack", "rainbowcrack", "crunch"],
    "  ["hydra", "john", "hashcat", "medusa", "ncrack", "ophcrack", "rainbowcrack", "crunch"],
    "wireless-attacks": ["aircrack-ng", "kismet", "wifite", "fern-wifi-cracker", "pixiewps", "reaver", "bully"],
    "exploitation-tools": ["metasploit", "searchsploit", "beef", "armitage", "set", "routersploit", "commix"],
    "sniffing-spoofing": ["wireshark", "ettercap", "bettercap", "dsniff", "netsniff-ng", "macchanger", "mitmproxy"],
    "post-exploitation": ["empire", "weevely", "powersploit", "mimikatz", "proxychains", "veil", "shellter"],
    "forensics": ["autopsy", "sleuthkit", "volatility", "foremost", "binwalk", "scalpel", "bulk-extractor"],
    "reporting-tools": ["dradis", "faraday", "pipal", "metagoofil", "maltego", "casefile", "cherrytree"],
    "social-engineering": ["social-engineer-toolkit", "beef", "maltego", "backdoor-factory", "gophish"],
    "reverse-engineering": ["ghidra", "radare2", "apktool", "dex2jar", "jd-gui", "ollydbg", "gdb"],
    "other-tools": []  # Categoría para herramientas que no encajan en las anteriores
}

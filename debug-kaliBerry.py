#!/usr/bin/env python3
"""
Script para ejecutar KaliBerry en modo de depuración
"""

import os
import sys
import subprocess
import traceback

# Establecer variables de entorno para depuración
os.environ["TEXTUAL_LOG"] = "debug"

# Directorio de instalación
INSTALL_DIR = "/opt/kaliBerry"

def main():
    """Función principal."""
    print("===================================================")
    print("      KaliBerry - Modo de Depuración               ")
    print("===================================================")
    print("")
    
    # Verificar que estamos en el directorio correcto
    if os.path.exists(INSTALL_DIR):
        os.chdir(INSTALL_DIR)
        print(f"Cambiado al directorio: {INSTALL_DIR}")
    else:
        print(f"Error: No se encontró el directorio de instalación {INSTALL_DIR}")
        sys.exit(1)
    
    # Verificar que los archivos necesarios existen
    required_files = ["kaliBerry.py", "tool_manager.py", "ui_manager.py", "config.py", "styles.css"]
    for file in required_files:
        if not os.path.exists(file):
            print(f"Error: No se encontró el archivo {file}")
            sys.exit(1)
    
    # Ejecutar KaliBerry con depuración
    try:
        print("Ejecutando KaliBerry en modo de depuración...")
        print("Los mensajes de depuración se mostrarán a continuación.")
        print("")
        
        # Ejecutar el script principal
        subprocess.run([sys.executable, "kaliBerry.py"], check=True)
    except Exception as e:
        print(f"Error al ejecutar KaliBerry: {e}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

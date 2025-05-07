#!/usr/bin/env python3
"""
KaliBerry - CLI para herramientas de auditoría en Kali Linux
"""

import os
import sys
import importlib.util

# Verificar si textual está instalado
try:
    import textual
except ImportError:
    print("Error: La biblioteca 'textual' no está instalada.")
    print("Por favor, instálela con:")
    print("sudo pip3 install --break-system-packages textual")
    sys.exit(1)

from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Button, Static, ListView, ListItem
from textual.containers import Container, Horizontal, Vertical
from textual.reactive import reactive
from textual.binding import Binding
from textual import events

# Verificar que podemos importar los módulos necesarios
try:
    # Obtener el directorio del script actual
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Añadir el directorio del script al path
    if script_dir not in sys.path:
        sys.path.insert(0, script_dir)
    
    # Intentar importar los módulos
    from tool_manager import ToolManager
    from ui_manager import CategoryView, ToolView, AboutView
    from config import TITLE, VERSION, THEME
except ImportError as e:
    print(f"Error al importar módulos: {e}")
    print(f"Directorio actual: {os.getcwd()}")
    print(f"Directorio del script: {script_dir}")
    print(f"Contenido del directorio: {os.listdir(script_dir)}")
    print(f"PYTHONPATH: {sys.path}")
    sys.exit(1)

class KaliBerryApp(App):
    """Aplicación principal de KaliBerry."""
    
    TITLE = TITLE
    
    # Buscar el archivo CSS en el mismo directorio que el script
    css_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "styles.css")
    if os.path.exists(css_path):
        CSS_PATH = css_path
    else:
        print(f"Advertencia: No se encontró el archivo CSS en {css_path}")
        print(f"Contenido del directorio: {os.listdir(os.path.dirname(os.path.abspath(__file__)))}")
    
    BINDINGS = [
        Binding("q", "quit", "Salir"),
        Binding("h", "home", "Inicio"),
        Binding("j", "down", "Abajo"),
        Binding("k", "up", "Arriba"),
        Binding("enter", "select", "Seleccionar"),
        Binding("escape", "back", "Atrás"),
        Binding("?", "toggle_help", "Ayuda"),
    ]
    
    current_view = reactive("main")
    selected_category = reactive("")
    selected_tool = reactive("")
    
    def __init__(self):
        super().__init__()
        try:
            self.tool_manager = ToolManager()
        except Exception as e:
            print(f"Error al inicializar el gestor de herramientas: {e}")
            import traceback
            traceback.print_exc()
            sys.exit(1)
    
    def compose(self) -> ComposeResult:
        """Crear la interfaz de usuario."""
        yield Header(show_clock=True)
        
        with Container(id="main-container"):
            yield CategoryView(self.tool_manager.get_categories())
            yield ToolView(self.tool_manager)
            yield AboutView()
        
        yield Footer()
    
    def on_mount(self) -> None:
        """Evento que se ejecuta al montar la aplicación."""
        self.query_one(CategoryView).display = True
        self.query_one(ToolView).display = False
        self.query_one(AboutView).display = False
    
    def action_home(self) -> None:
        """Volver al menú principal."""
        self.current_view = "main"
        self.query_one(CategoryView).display = True
        self.query_one(ToolView).display = False
        self.query_one(AboutView).display = False
    
    def action_back(self) -> None:
        """Volver a la vista anterior."""
        if self.current_view == "tools":
            self.current_view = "main"
            self.query_one(CategoryView).display = True
            self.query_one(ToolView).display = False
        elif self.current_view == "tool_detail":
            self.current_view = "tools"
            self.query_one(ToolView).show_tools_list()
    
    def action_select(self) -> None:
        """Seleccionar el elemento actual."""
        if self.current_view == "main":
            selected = self.query_one(CategoryView).get_selected()
            if selected == "about":
                self.current_view = "about"
                self.query_one(CategoryView).display = False
                self.query_one(AboutView).display = True
            else:
                self.selected_category = selected
                self.current_view = "tools"
                self.query_one(CategoryView).display = False
                self.query_one(ToolView).display = True
                self.query_one(ToolView).show_category(selected)
        elif self.current_view == "tools":
            selected = self.query_one(ToolView).get_selected()
            if selected:
                self.selected_tool = selected
                self.current_view = "tool_detail"
                self.query_one(ToolView).show_tool_detail(selected)
        elif self.current_view == "tool_detail":
            self.tool_manager.launch_tool(self.selected_tool)
    
    def on_button_pressed(self, event: events.Button.Pressed) -> None:
        """Manejar eventos de botones."""
        button_id = event.button.id
        if button_id == "run-tool-btn" and self.selected_tool:
            self.tool_manager.launch_tool(self.selected_tool)

def main():
    """Función principal."""
    try:
        app = KaliBerryApp()
        app.run()
    except Exception as e:
        print(f"Error al ejecutar KaliBerry: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

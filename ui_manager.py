#!/usr/bin/env python3
"""
Gestor de interfaz de usuario para KaliBerry
"""

from textual.widget import Widget
from textual.widgets import Static, Button, ListView, ListItem, Label
from textual.containers import Container, Vertical, Horizontal
from textual.reactive import reactive
from typing import List, Dict, Optional
import os

class CategoryView(Static):
    """Vista de categorías de herramientas."""
    
    display = reactive(True)
    
    def __init__(self, categories: List[str]):
        super().__init__()
        self.categories = categories if categories else ["No se encontraron categorías"]
        self.selected_index = 0
    
    def compose(self):
        """Componer la vista de categorías."""
        with Container(id="category-container"):
            yield Label("KaliBerry - Categorías de Herramientas", id="title")
            
            with ListView(id="category-list"):
                if not self.categories or len(self.categories) == 0:
                    yield ListItem(Label("No se encontraron categorías"), id="category-none")
                else:
                    for category in self.categories:
                        yield ListItem(Label(self._format_category_name(category)), id=f"category-{category}")
            
            yield ListItem(Label("Acerca de KaliBerry"), id="category-about")
    
    def _format_category_name(self, category: str) -> str:
        """Formatear el nombre de la categoría para mostrar."""
        return category.replace("-", " ").title()
    
    def get_selected(self) -> str:
        """Obtener la categoría seleccionada."""
        try:
            selected = self.query_one("#category-list").highlighted
            if selected and selected.id and selected.id.startswith("category-"):
                return selected.id.replace("category-", "")
        except Exception as e:
            print(f"Error al obtener categoría seleccionada: {e}")
        return ""
    
    def watch_display(self, display: bool) -> None:
        """Observar cambios en la propiedad display."""
        if display:
            self.add_class("visible")
            self.remove_class("hidden")
        else:
            self.add_class("hidden")
            self.remove_class("visible")

class ToolView(Static):
    """Vista de herramientas."""
    
    display = reactive(False)
    view_mode = reactive("list")  # list o detail
    
    def __init__(self, tool_manager):
        super().__init__()
        self.tool_manager = tool_manager
        self.current_category = ""
        self.current_tool = ""
    
    def compose(self):
        """Componer la vista de herramientas."""
        with Container(id="tool-container"):
            yield Label("", id="tool-title")
            
            with Container(id="tool-list-container"):
                yield ListView(id="tool-list")
            
            with Container(id="tool-detail-container"):
                yield Label("", id="tool-detail-name")
                yield Label("", id="tool-detail-description")
                yield Button("Ejecutar Herramienta", id="run-tool-btn")
    
    def watch_display(self, display: bool) -> None:
        """Observar cambios en la propiedad display."""
        if display:
            self.add_class("visible")
            self.remove_class("hidden")
        else:
            self.add_class("hidden")
            self.remove_class("visible")
    
    def watch_view_mode(self, view_mode: str) -> None:
        """Observar cambios en el modo de vista."""
        if view_mode == "list":
            self.query_one("#tool-list-container").add_class("visible")
            self.query_one("#tool-list-container").remove_class("hidden")
            self.query_one("#tool-detail-container").add_class("hidden")
            self.query_one("#tool-detail-container").remove_class("visible")
        else:
            self.query_one("#tool-list-container").add_class("hidden")
            self.query_one("#tool-list-container").remove_class("visible")
            self.query_one("#tool-detail-container").add_class("visible")
            self.query_one("#tool-detail-container").remove_class("hidden")
    
    def show_category(self, category: str) -> None:
        """Mostrar herramientas de una categoría."""
        self.current_category = category
        self.view_mode = "list"
        
        # Actualizar título
        self.query_one("#tool-title").update(f"Herramientas de {self._format_category_name(category)}")
        
        # Limpiar lista actual
        tool_list = self.query_one("#tool-list")
        tool_list.clear()
        
        # Agregar herramientas
        tools = self.tool_manager.get_tools_by_category(category)
        if not tools or len(tools) == 0:
            item = ListItem(Label("No se encontraron herramientas en esta categoría"), id="tool-none")
            tool_list.append(item)
        else:
            for tool in tools:
                item = ListItem(Label(tool["name"]), id=f"tool-{tool['name']}")
                tool_list.append(item)
    
    def show_tool_detail(self, tool_name: str) -> None:
        """Mostrar detalles de una herramienta."""
        self.current_tool = tool_name
        self.view_mode = "detail"
        
        tool_info = self.tool_manager.get_tool_info(tool_name)
        if tool_info:
            self.query_one("#tool-detail-name").update(tool_info["name"])
            self.query_one("#tool-detail-description").update(tool_info["description"])
    
    def show_tools_list(self) -> None:
        """Volver a la lista de herramientas."""
        self.view_mode = "list"
    
    def get_selected(self) -> str:
        """Obtener la herramienta seleccionada."""
        try:
            selected = self.query_one("#tool-list").highlighted
            if selected and selected.id and selected.id.startswith("tool-"):
                return selected.id.replace("tool-", "")
        except Exception as e:
            print(f"Error al obtener herramienta seleccionada: {e}")
        return ""
    
    def _format_category_name(self, category: str) -> str:
        """Formatear el nombre de la categoría para mostrar."""
        return category.replace("-", " ").title()

class AboutView(Static):
    """Vista de información sobre KaliBerry."""
    
    display = reactive(False)
    
    def compose(self):
        """Componer la vista de información."""
        with Container(id="about-container"):
            yield Label("Acerca de KaliBerry", id="about-title")
            
            with Vertical(id="about-content"):
                yield Label("KaliBerry es una interfaz de línea de comandos para Kali Linux")
                yield Label("que facilita el acceso y la gestión de herramientas de auditoría.")
                yield Label("")
                yield Label("Características principales:")
                yield Label("• Detección automática de herramientas de Kali Linux")
                yield Label("• Interfaz intuitiva y fácil de usar")
                yield Label("• Navegación sencilla entre categorías y herramientas")
                yield Label("• Información detallada sobre cada herramienta")
                yield Label("")
                yield Label("Inspirado en la estética de bebbleberry")
                yield Label("https://github.com/alliraine/bebbleberry")
    
    def watch_display(self, display: bool) -> None:
        """Observar cambios en la propiedad display."""
        if display:
            self.add_class("visible")
            self.remove_class("hidden")
        else:
            self.add_class("hidden")
            self.remove_class("visible")

import sys
import os
import json
import re
import logging

from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,
    QPushButton, QTextEdit, QComboBox, QFileDialog, QGroupBox, QFormLayout,
    QListWidget, QListWidgetItem, QMessageBox, QSplitter
)
from PyQt6.QtGui import QFont
from PyQt6.QtCore import Qt, QUrl
from PyQt6.QtWebEngineWidgets import QWebEngineView

import lupa
from lupa import LuaRuntime

# -------------------------------------------------------------------
# Logging konfigurace
# -------------------------------------------------------------------
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# -------------------------------------------------------------------
# MOCK funkce pro interpretaci fxmanifest.lua v Lupa
# -------------------------------------------------------------------
MOCK_FUNCS = r"""
-- Fake funkce, které FiveM/RedM používá v manifestu, ale v čisté Lua normálně neexistují
function fx_version(...) end
function game(...) end
function games(...) end
function rdr3_warning(...) end
function lua54(...) end

function ui_page(val)
    -- Uložíme do globální tabulky _G
    _G["ui_page"] = val
end

function files(val)
    _G["files"] = val
end

function client_scripts(val)
    _G["client_scripts"] = val
end

function server_scripts(val)
    _G["server_scripts"] = val
end

-- Pokud by v manifestu byla i shared_scripts, author, description, version apod., definuj je taky:
-- function shared_scripts(val) _G["shared_scripts"] = val end
-- function author(val) end
-- function description(val) end
-- function version(val) end
"""

# -------------------------------------------------------------------
# Jednoduchá třída NUIMessage
# -------------------------------------------------------------------
class NUIMessage:
    """Reprezentuje NUI zprávu (action + data)."""
    def __init__(self, action, data=None):
        self.action = action
        self.data = data or {}

    def __str__(self):
        return f"Action: {self.action}, Data: {json.dumps(self.data)}"

# -------------------------------------------------------------------
# ResourceAnalyzer: parsuje manifest, hledá NUI eventy, atd.
# -------------------------------------------------------------------
class ResourceAnalyzer:
    def __init__(self, resource_path):
        self.resource_path = resource_path
        self.fxmanifest_path = os.path.join(resource_path, "fxmanifest.lua")
        self.client_scripts = []
        self.nui_events = set()
        self.ui_files = []
        self.data = {}  # sem uložíme zjištěné info z manifestu: ui_page, files, client_scripts atp.

    def analyze(self):
        """ Hlavní metoda - načte fxmanifest + extrahuje client skripty + najde NUI eventy + UI files. """
        self.load_fxmanifest()
        self.load_client_scripts()
        self.extract_nui_events()
        self.extract_ui_files()
        return self.data

    def load_fxmanifest(self):
        """ Načte a interpretuje fxmanifest.lua pomocí Lupy s definovanými mock funkcemi. """
        if not os.path.exists(self.fxmanifest_path):
            raise FileNotFoundError(f"fxmanifest.lua nenalezen v: {self.resource_path}")

        with open(self.fxmanifest_path, "r", encoding="utf-8") as f:
            manifest_content = f.read()
        print("DEBUG: length of manifest_content =", len(manifest_content))
        print("DEBUG: manifest_content repr =", repr(manifest_content))
        # Přilepíme dohromady mock funkce + manifest
        lua_code = MOCK_FUNCS + "\n" + manifest_content

        # (Volitelný debug - abys viděl, co Lupa dostává)
        print("DEBUG: EXECUTED LUA CODE:\n")
        print(lua_code)

        lua_runtime = LuaRuntime()
        try:
            # Spustíme kód
            lua_runtime.execute(lua_code)
            # Všechno, co 'ui_page', 'files', 'client_scripts' z manifestu definovalo,
            # se ocitlo v lua_runtime.globals()
            g = lua_runtime.globals()

            self.data = {}
            # Vytáhneme potřebné klíče, pokud tam jsou
            if g.get("ui_page") is not None:
                self.data["ui_page"] = g["ui_page"]
            if g.get("files") is not None:
                self.data["files"] = g["files"]
            if g.get("client_scripts") is not None:
                self.data["client_scripts"] = g["client_scripts"]
            if g.get("server_scripts") is not None:
                self.data["server_scripts"] = g["server_scripts"]

            logging.info("fxmanifest.lua načten (přes mock funkce) a analyzován.")

        except Exception as e:
            logging.error(f"Chyba při parsování fxmanifest.lua: {e}")
            raise Exception(f"Chyba při parsování fxmanifest.lua: {e}")

    def load_client_scripts(self):
        """ 
        Z `client_scripts` extrahujeme cesty k Lua souborům 
        (pokud existují), abychom je potom mohli prohledat na NUI eventy.
        """
        if "client_scripts" in self.data:
            cs = self.data["client_scripts"]
            # FiveM povoluje definice jako string nebo list. V mocku je pak val = "string" nebo table.
            if isinstance(cs, str):
                # Jeden script
                script_path = os.path.join(self.resource_path, cs)
                if os.path.exists(script_path):
                    self.client_scripts.append(script_path)
                else:
                    logging.warning(f"Client script nenalezen: {script_path}")

            elif isinstance(cs, list):
                # Lua table je v Lupa obvykle mapován na Python list
                for item in cs:
                    if isinstance(item, str):
                        script_path = os.path.join(self.resource_path, item)
                        if os.path.exists(script_path):
                            self.client_scripts.append(script_path)
                        else:
                            logging.warning(f"Client script nenalezen: {script_path}")
                    else:
                        logging.warning(f"Client script není string: {item}")

            else:
                logging.warning(f"client_scripts: nepodporovaný typ {type(cs)}")

        logging.info(f"Nalezeny client_scripts: {self.client_scripts}")

    def extract_nui_events(self):
        """ 
        V klientských skriptech vyhledáme `RegisterNUICallback('eventName', ...)`.
        """
        for script_path in self.client_scripts:
            with open(script_path, "r", encoding="utf-8") as f:
                content = f.read()
            # jednoruchý regex:
            matches = re.findall(r"RegisterNUICallback\s*\(\s*['\"]([^'\"]+)['\"]", content)
            for m in matches:
                self.nui_events.add(m)

        logging.info(f"Extrahované NUI eventy: {self.nui_events}")

    def extract_ui_files(self):
        """
        Z `ui_page` a `files` vybereme všechny .html, .css, .js (pokud existují).
        """
        # Zkusíme ui_page
        if "ui_page" in self.data and isinstance(self.data["ui_page"], str):
            up = self.data["ui_page"]
            path = os.path.join(self.resource_path, up)
            if os.path.exists(path):
                self.ui_files.append(path)
            else:
                logging.warning(f"UI page neexistuje: {path}")

        # Zkusíme files
        if "files" in self.data:
            ff = self.data["files"]
            # Může to být list, string atp.
            if isinstance(ff, list):
                for item in ff:
                    if isinstance(item, str):
                        path = os.path.join(self.resource_path, item)
                        if os.path.exists(path) and any(path.endswith(ext) for ext in [".html", ".css", ".js"]):
                            self.ui_files.append(path)
                    else:
                        logging.warning(f"Soubor v 'files' není string: {item}")

            elif isinstance(ff, str):
                # Jediný string
                path = os.path.join(self.resource_path, ff)
                if os.path.exists(path) and any(path.endswith(ext) for ext in [".html", ".css", ".js"]):
                    self.ui_files.append(path)

        logging.info(f"UI soubory: {self.ui_files}")

# -------------------------------------------------------------------
# Hlavní PyQt6 okno NUITester
# -------------------------------------------------------------------
class NUITester(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("RedM/FiveM NUI Tester")
        self.setGeometry(100, 100, 1400, 900)

        self.resource_analyzer = None
        self.nui_events = []
        self.ui_files = []
        self.nui_messages = []
        self.current_nui_message_index = 0
        self.history_file = "nui_message_history.json"
        self.html_content = ""

        self.init_ui()
        self.load_history()

    def init_ui(self):
        main_layout = QVBoxLayout()

        # 1) Zóna pro zadání resource cesty
        resource_group = QGroupBox("Resource")
        resource_layout = QHBoxLayout()

        self.resource_path_input = QLineEdit()
        self.resource_path_input.setPlaceholderText("Cesta k resource...")
        resource_layout.addWidget(self.resource_path_input)

        self.load_resource_button = QPushButton("Načíst Resource")
        self.load_resource_button.clicked.connect(self.load_resource)
        resource_layout.addWidget(self.load_resource_button)

        resource_group.setLayout(resource_layout)
        main_layout.addWidget(resource_group)

        # Hlavní splitter - vlevo info, vpravo web
        splitter = QSplitter(Qt.Orientation.Horizontal)
        main_layout.addWidget(splitter)

        # Levá část
        left_widget = QWidget()
        left_layout = QVBoxLayout()

        # 2) Info o resource
        info_group = QGroupBox("Informace o Resource")
        info_layout = QVBoxLayout()

        self.nui_events_list = QListWidget()
        info_layout.addWidget(QLabel("NUI Events:"))
        info_layout.addWidget(self.nui_events_list)

        self.ui_files_list = QListWidget()
        info_layout.addWidget(QLabel("UI Files:"))
        info_layout.addWidget(self.ui_files_list)

        info_group.setLayout(info_layout)
        left_layout.addWidget(info_group)

        # 3) Testování NUI eventů
        test_group = QGroupBox("Testování NUI Eventů")
        test_layout = QFormLayout()

        self.event_combo = QComboBox()
        test_layout.addRow("NUI Event:", self.event_combo)

        self.data_input = QTextEdit()
        self.data_input.setPlaceholderText("JSON data pro event...")
        test_layout.addRow("Data (JSON):", self.data_input)

        self.send_button = QPushButton("Odeslat NUI Message")
        self.send_button.clicked.connect(self.send_nui_message)
        test_layout.addRow(self.send_button)

        test_group.setLayout(test_layout)
        left_layout.addWidget(test_group)

        # 4) Historie NUI zpráv
        history_group = QGroupBox("Historie NUI Zpráv")
        history_layout = QVBoxLayout()

        self.history_list = QListWidget()
        history_layout.addWidget(self.history_list)
        self.history_list.itemClicked.connect(self.load_nui_message_from_history)

        nav_layout = QHBoxLayout()
        self.prev_button = QPushButton("Předchozí")
        self.prev_button.clicked.connect(self.show_previous_message)
        nav_layout.addWidget(self.prev_button)

        self.next_button = QPushButton("Další")
        self.next_button.clicked.connect(self.show_next_message)
        nav_layout.addWidget(self.next_button)

        history_layout.addLayout(nav_layout)
        history_group.setLayout(history_layout)
        left_layout.addWidget(history_group)

        left_widget.setLayout(left_layout)
        splitter.addWidget(left_widget)

        # Pravá část - WebEngineView
        self.web_view = QWebEngineView()
        splitter.addWidget(self.web_view)
        splitter.setSizes([600, 800])

        self.setLayout(main_layout)

    def load_resource(self):
        """Spustí analýzu resource a zobrazí informace."""
        resource_path = self.resource_path_input.text().strip()
        if not os.path.isdir(resource_path):
            QMessageBox.critical(self, "Chyba", "Neplatná cesta k resource!")
            return

        try:
            self.resource_analyzer = ResourceAnalyzer(resource_path)
            data = self.resource_analyzer.analyze()

            self.nui_events = list(self.resource_analyzer.nui_events)
            self.ui_files = self.resource_analyzer.ui_files

            # Zobrazíme eventy a files
            self.nui_events_list.clear()
            for event in self.nui_events:
                self.nui_events_list.addItem(event)

            self.ui_files_list.clear()
            for file in self.ui_files:
                self.ui_files_list.addItem(file)

            self.event_combo.clear()
            self.event_combo.addItems(self.nui_events)

            # Zkusíme načíst .html do web_view
            html_files = [f for f in self.ui_files if f.endswith(".html")]
            if html_files:
                html_file = html_files[0]
                with open(html_file, "r", encoding="utf-8") as f:
                    self.html_content = f.read()
                base_url = QUrl.fromLocalFile(os.path.dirname(html_file) + os.sep)
                self.web_view.setHtml(self.html_content, base_url)

            QMessageBox.information(self, "Úspěch", "Resource načten!")
            logging.info("Resource načten, manifest analyzován.")

        except FileNotFoundError as e:
            QMessageBox.critical(self, "Chyba", str(e))
            logging.error(f"Chyba: {e}")

        except Exception as e:
            QMessageBox.critical(self, "Chyba", f"Chyba při analýze: {e}")
            logging.error(f"Chyba při analýze: {e}")

    def send_nui_message(self):
        """Simulace posílání NUI zprávy do webview (přes window.postMessage)."""
        event = self.event_combo.currentText()
        data_text = self.data_input.toPlainText()

        try:
            payload = json.loads(data_text) if data_text.strip() else {}
            nui_message = NUIMessage(event, payload)
            msg_str = str(nui_message)

            # Přidáme do historie
            self.nui_messages.append({"event": event, "data": payload})
            self.update_history_list()
            self.save_history()

            # Zavoláme v JS: window.postMessage({ type: event, data: payload }, "*");
            js_code = f"window.postMessage({{type: '{event}', data: {json.dumps(payload)}}}, '*');"
            self.web_view.page().runJavaScript(js_code)

            print(f"Odeslána NUI message: {msg_str}")
            QMessageBox.information(self, "Odesláno", f"Odeslána NUI message:\n{msg_str}")
            logging.info(f"Odeslána NUI message: {msg_str}")

        except json.JSONDecodeError as e:
            QMessageBox.critical(self, "Chyba", f"Neplatný JSON: {e}")
            logging.error(f"Neplatný JSON: {e}")
        except Exception as e:
            QMessageBox.critical(self, "Chyba", f"Chyba: {e}")
            logging.error(f"Chyba: {e}")

    def update_history_list(self):
        """Aktualizuje zobrazení historie."""
        self.history_list.clear()
        for msg in self.nui_messages:
            item_text = f"Event: {msg['event']}"
            item = QListWidgetItem(item_text)
            self.history_list.addItem(item)

    def load_history(self):
        """Načte historii z JSON souboru."""
        if os.path.exists(self.history_file):
            try:
                with open(self.history_file, "r", encoding="utf-8") as f:
                    self.nui_messages = json.load(f)
                self.update_history_list()
                logging.info("Historie načtena.")
            except Exception as e:
                logging.error(f"Error loading history: {e}")

    def save_history(self):
        """Uloží historii do JSON souboru."""
        try:
            with open(self.history_file, "w", encoding="utf-8") as f:
                json.dump(self.nui_messages, f, indent=2, ensure_ascii=False)
            logging.info("Historie uložena.")
        except Exception as e:
            logging.error(f"Error saving history: {e}")

    def load_nui_message_from_history(self, item):
        """Když klikneme na položku v historii, načteme ji do vstupních polí."""
        index = self.history_list.row(item)
        if 0 <= index < len(self.nui_messages):
            msg = self.nui_messages[index]
            self.event_combo.setCurrentText(msg['event'])
            self.data_input.setText(json.dumps(msg['data'], indent=4, ensure_ascii=False))

    def show_previous_message(self):
        """Cyklicky zobrazí předchozí zprávu z historie."""
        if self.nui_messages:
            self.current_nui_message_index = (self.current_nui_message_index - 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def show_next_message(self):
        """Cyklicky zobrazí další zprávu z historie."""
        if self.nui_messages:
            self.current_nui_message_index = (self.current_nui_message_index + 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def load_message_from_index(self, index):
        """Pomocná funkce pro načtení zprávy podle indexu."""
        if 0 <= index < len(self.nui_messages):
            msg = self.nui_messages[index]
            self.event_combo.setCurrentText(msg['event'])
            self.data_input.setText(json.dumps(msg['data'], indent=4, ensure_ascii=False))
            self.history_list.setCurrentRow(index)


# -------------------------------------------------------------------
# Spuštění aplikace
# -------------------------------------------------------------------
if __name__ == "__main__":
    app = QApplication(sys.argv)
    tester = NUITester()
    tester.show()
    sys.exit(app.exec())

import sys
import os
import json
import re
from PyQt6.QtWidgets import (QApplication, QWidget, QVBoxLayout, QHBoxLayout,
                             QLabel, QLineEdit, QPushButton, QTextEdit,
                             QComboBox, QFileDialog, QScrollArea, QGroupBox,
                             QFormLayout, QListWidget, QListWidgetItem, QMessageBox,
                             QSplitter)
from PyQt6.QtGui import QFont, QPixmap
from PyQt6.QtCore import Qt, QSize, QUrl
from PyQt6.QtWebEngineWidgets import QWebEngineView  # QWebEngineView pro zobrazení HTML
import lupa  # Vyžaduje instalaci: pip install lupa
import requests
import logging  # Logování

# Konfigurace logování
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def sanitize_fxmanifest(content: str) -> str:
    """
    Některé řádky ve fxmanifest.lua nejsou validní Lua (fx_version, game, rdr3_warning...).
    Pomocí této funkce je zakomentujeme, aby je Lupa nespustila.
    """
    lines = []
    for line in content.splitlines():
        stripped = line.strip()
        # Pokud řádek začíná klíčovými slovy, která Lupa nejspíš nestráví, zakomentujeme ho.
        if stripped.startswith("fx_version") \
           or stripped.startswith("game") \
           or stripped.startswith("games") \
           or stripped.startswith("rdr3_warning") \
           or stripped.startswith("lua54"):
            line = "-- " + line  # Zakomentujeme
        lines.append(line)
    return "\n".join(lines)


class NUIMessage:
    """
    Reprezentuje NUI zprávu (action + data).
    """
    def __init__(self, action, data=None):
        self.action = action
        self.data = data or {}

    def __str__(self):
        return f"Action: {self.action}, Data: {json.dumps(self.data)}"


class ResourceAnalyzer:
    """
    Analyzuje RedM/FiveM resource, extrahuje informace z fxmanifest.lua
    a z klientských skriptů (NUI eventy).
    """

    def __init__(self, resource_path):
        self.resource_path = resource_path
        self.fxmanifest_path = os.path.join(resource_path, "fxmanifest.lua")
        self.client_scripts = []
        self.nui_events = set()
        self.ui_files = []
        self.data = {}

    def analyze(self):
        """
        Provede analýzu resource a vrátí dictionary s obsahem manifestu.
        """
        self.load_fxmanifest()
        self.load_client_scripts()
        self.extract_nui_events()
        self.extract_ui_files()
        return self.data

    def load_fxmanifest(self):
        """
        Načte a parsuje fxmanifest.lua pomocí Lupy (po lehké 'sanitizaci').
        """
        if not os.path.exists(self.fxmanifest_path):
            raise FileNotFoundError(f"fxmanifest.lua nenalezen v: {self.resource_path}")

        with open(self.fxmanifest_path, "r", encoding="utf-8") as f:
            manifest_content = f.read()

        # Předzpracování (zakomentování) řádků, které by Lupu rozhodily:
        manifest_content = sanitize_fxmanifest(manifest_content)

        # Spustíme LupaRuntime
        lua_runtime = lupa.LuaRuntime()

        try:
            # Pustíme celý fxmanifest jako Lua skript
            self.data = lua_runtime.execute(manifest_content)
            logging.info("fxmanifest.lua načten a analyzován.")
        except Exception as e:
            logging.error(f"Chyba při parsování fxmanifest.lua: {e}")
            raise Exception(f"Chyba při parsování fxmanifest.lua: {e}")

    def load_client_scripts(self):
        """
        Najde cesty ke client scriptům z (možného) pole `client_scripts` ve fxmanifestu.
        """
        # Ověř, že self.data vůbec obsahuje klíč `client_scripts`
        if "client_scripts" in self.data:
            cs = self.data["client_scripts"]

            # `client_scripts` může být string, seznam, nebo cokoliv jiného
            if isinstance(cs, str):
                script_path = os.path.join(self.resource_path, cs)
                if os.path.exists(script_path):
                    self.client_scripts.append(script_path)
                else:
                    logging.warning(f"Client script nenalezen: {script_path}")

            elif isinstance(cs, list):
                for script in cs:
                    if isinstance(script, str):
                        script_path = os.path.join(self.resource_path, script)
                        if os.path.exists(script_path):
                            self.client_scripts.append(script_path)
                        else:
                            logging.warning(f"Client script nenalezen: {script_path}")
                    else:
                        logging.warning(f"Client script není string: {script}")

            else:
                logging.warning(f"Typ client_scripts není podporován: {type(cs)}")

        logging.info(f"Nalezeny client_scripts: {self.client_scripts}")

    def extract_nui_events(self):
        """
        Pomocí regulárních výrazů vyhledá `RegisterNUICallback("...")` v každém client scriptu.
        """
        for script_path in self.client_scripts:
            with open(script_path, "r", encoding="utf-8") as f:
                script_content = f.read()
            # Hledáme RegisterNUICallback('eventName', ...)
            matches = re.findall(r"RegisterNUICallback\s*\(\s*['\"]([^'\"]*)['\"]", script_content)
            self.nui_events.update(matches)
        logging.info(f"NUI events extrahovány: {self.nui_events}")

    def extract_ui_files(self):
        """
        Zjistí `ui_page` a `files` z manifestu a uloží je do self.ui_files (jen .html, .css, .js).
        """
        # 1) ui_page
        if "ui_page" in self.data:
            ui_page = self.data["ui_page"]
            if isinstance(ui_page, str):
                path = os.path.join(self.resource_path, ui_page)
                if os.path.exists(path):
                    self.ui_files.append(path)
                else:
                    logging.warning(f"UI page neexistuje: {path}")
            else:
                logging.warning(f"ui_page není string: {type(ui_page)}")

        # 2) files
        if "files" in self.data:
            ff = self.data["files"]
            if isinstance(ff, str):
                # Jediný string
                path = os.path.join(self.resource_path, ff)
                if os.path.exists(path) and any(path.endswith(ext) for ext in [".html", ".css", ".js"]):
                    self.ui_files.append(path)
            elif isinstance(ff, list):
                # Seznam souborů
                for file_item in ff:
                    if isinstance(file_item, str):
                        path = os.path.join(self.resource_path, file_item)
                        # Přidáme jen pokud je relevantní koncovka
                        if os.path.exists(path) and any(path.endswith(ext) for ext in [".html", ".css", ".js"]):
                            self.ui_files.append(path)
                    else:
                        logging.warning(f"Soubor v 'files' není string: {file_item}")
            else:
                logging.warning(f"Typ 'files' není podporován: {type(ff)}")

        logging.info(f"UI files extrahovány: {self.ui_files}")


class NUITester(QWidget):
    """
    Hlavní okno aplikace pro testování NUI.
    """

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
        self.html_content = ""  # Pro uložení obsahu HTML
        self.init_ui()
        self.load_history()

    def init_ui(self):
        """
        Inicializuje uživatelské rozhraní.
        """
        main_layout = QVBoxLayout()

        # 1. Sekce pro načtení resource
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

        # Hlavní rozdělení okna: vlevo info a test, vpravo webview
        splitter = QSplitter(Qt.Orientation.Horizontal)
        main_layout.addWidget(splitter)

        # Levá část
        left_widget = QWidget()
        left_layout = QVBoxLayout()

        # 2. Sekce s informacemi o resource
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

        # 3. Sekce pro testování NUI eventů
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

        # 4. Sekce pro historii NUI zpráv
        history_group = QGroupBox("Historie NUI Zpráv")
        history_layout = QVBoxLayout()

        self.history_list = QListWidget()
        history_layout.addWidget(self.history_list)
        self.history_list.itemClicked.connect(self.load_nui_message_from_history)

        # Navigační tlačítka (předchozí/další)
        navigation_layout = QHBoxLayout()
        self.prev_button = QPushButton("Předchozí")
        self.prev_button.clicked.connect(self.show_previous_message)
        navigation_layout.addWidget(self.prev_button)

        self.next_button = QPushButton("Další")
        self.next_button.clicked.connect(self.show_next_message)
        navigation_layout.addWidget(self.next_button)

        history_layout.addLayout(navigation_layout)
        history_group.setLayout(history_layout)
        left_layout.addWidget(history_group)

        left_widget.setLayout(left_layout)
        splitter.addWidget(left_widget)

        # Pravá část - WebView
        self.web_view = QWebEngineView()
        splitter.addWidget(self.web_view)

        # Poměr
        splitter.setSizes([600, 800])

        self.setLayout(main_layout)

    def load_resource(self):
        """
        Načte resource a zobrazí informace o nalezených NUI eventech a souborech.
        """
        resource_path = self.resource_path_input.text()
        if not os.path.isdir(resource_path):
            QMessageBox.critical(self, "Chyba", "Neplatná cesta k resource!")
            return

        try:
            self.resource_analyzer = ResourceAnalyzer(resource_path)
            data = self.resource_analyzer.analyze()

            self.nui_events = list(self.resource_analyzer.nui_events)
            self.ui_files = self.resource_analyzer.ui_files

            # Naplníme listy
            self.nui_events_list.clear()
            for event in self.nui_events:
                self.nui_events_list.addItem(event)

            self.ui_files_list.clear()
            for file in self.ui_files:
                self.ui_files_list.addItem(file)

            self.event_combo.clear()
            self.event_combo.addItems(self.nui_events)

            # Zkusíme načíst .html do WebView
            html_files = [f for f in self.ui_files if f.endswith(".html")]
            if html_files:
                # Vezmeme první HTML, co najdeme
                html_file = html_files[0]
                with open(html_file, "r", encoding="utf-8") as f:
                    self.html_content = f.read()

                # Nastav baseUrl na složku, kde je HTML, aby šly relativní cesty ke skriptům atd.
                base_url = QUrl.fromLocalFile(os.path.dirname(html_file) + os.sep)
                self.web_view.setHtml(self.html_content, base_url)

            QMessageBox.information(self, "Úspěch", "Resource načten!")
            logging.info("Resource načten.")

        except FileNotFoundError as e:
            QMessageBox.critical(self, "Chyba", str(e))
            logging.error(f"Chyba: {e}")
        except Exception as e:
            QMessageBox.critical(self, "Chyba", f"Chyba při analýze: {e}")
            logging.error(f"Chyba při analýze: {e}")

    def send_nui_message(self):
        """
        Simulace odeslání NUI message (window.postMessage) do načteného HTML.
        """
        event = self.event_combo.currentText()
        data_text = self.data_input.toPlainText()

        try:
            data = json.loads(data_text) if data_text.strip() else {}
            nui_message = NUIMessage(event, data)
            message_string = str(nui_message)

            # Přidáme zprávu do historie
            self.nui_messages.append({"event": event, "data": data})
            self.update_history_list()
            self.save_history()

            # Simulujeme odeslání do NUI
            # -> uvnitř HTML (script.js) lze odchytávat: window.addEventListener('message', e => ...)
            js_code = f"window.postMessage({{type: '{event}', data: {json.dumps(data)}}}, '*');"
            self.web_view.page().runJavaScript(js_code)

            print(f"Odeslána NUI message: {message_string}")
            QMessageBox.information(self, "Odesláno", f"Odeslána NUI message:\n{message_string}")
            logging.info(f"Odeslána NUI message: {message_string}")

        except json.JSONDecodeError as e:
            QMessageBox.critical(self, "Chyba", f"Neplatný JSON: {e}")
            logging.error(f"Neplatný JSON: {e}")
        except Exception as e:
            QMessageBox.critical(self, "Chyba", f"Chyba: {e}")
            logging.error(f"Chyba: {e}")

    def update_history_list(self):
        """
        Obnoví vizuální seznam historie NUI zpráv.
        """
        self.history_list.clear()
        for msg in self.nui_messages:
            item_text = f"Event: {msg['event']}"
            item = QListWidgetItem(item_text)
            self.history_list.addItem(item)

    def load_history(self):
        """
        Načte historii NUI zpráv ze JSON souboru (self.history_file).
        """
        try:
            if os.path.exists(self.history_file):
                with open(self.history_file, "r", encoding="utf-8") as f:
                    self.nui_messages = json.load(f)
                self.update_history_list()
            logging.info("Historie načtena.")
        except Exception as e:
            logging.error(f"Error loading history: {e}")

    def save_history(self):
        """
        Uloží historii NUI zpráv do JSON souboru (self.history_file).
        """
        try:
            with open(self.history_file, "w", encoding="utf-8") as f:
                json.dump(self.nui_messages, f, indent=2, ensure_ascii=False)
            logging.info("Historie uložena.")
        except Exception as e:
            logging.error(f"Error saving history: {e}")

    def load_nui_message_from_history(self, item):
        """
        Když uživatel klikne na položku v historii, načteme ji do vstupních polí.
        """
        index = self.history_list.row(item)
        if 0 <= index < len(self.nui_messages):
            message = self.nui_messages[index]
            self.event_combo.setCurrentText(message['event'])
            self.data_input.setText(json.dumps(message['data'], indent=4, ensure_ascii=False))

    def show_previous_message(self):
        """
        Zobrazí předchozí zprávu z historie (cyklicky).
        """
        if self.nui_messages:
            self.current_nui_message_index = (self.current_nui_message_index - 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def show_next_message(self):
        """
        Zobrazí následující zprávu z historie (cyklicky).
        """
        if self.nui_messages:
            self.current_nui_message_index = (self.current_nui_message_index + 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def load_message_from_index(self, index):
        """
        Pomocná funkce: načte zprávu z historie dle indexu do GUI.
        """
        if 0 <= index < len(self.nui_messages):
            message = self.nui_messages[index]
            self.event_combo.setCurrentText(message['event'])
            self.data_input.setText(json.dumps(message['data'], indent=4, ensure_ascii=False))
            self.history_list.setCurrentRow(index)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    tester = NUITester()
    tester.show()
    sys.exit(app.exec())

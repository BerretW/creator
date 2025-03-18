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
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# -------------------------------------------------------------------
# MOCK funkce pro interpretaci fxmanifest.lua v Lupa
# -------------------------------------------------------------------
MOCK_FUNCS = r"""
function fx_version(...) end
function game(...) end
function games(...) end
function rdr3_warning(...) end
function lua54(...) end

function ui_page(val)
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
"""

# -------------------------------------------------------------------
# Pomocné funkce
# -------------------------------------------------------------------


def is_lua_table(obj) -> bool:
    return "LuaTable" in type(obj).__name__


def lua_table_to_list(lua_table):
    result = []
    for k in lua_table.keys():
        result.append(lua_table[k])
    return result

# -------------------------------------------------------------------
# NUIMessage
# -------------------------------------------------------------------


class NUIMessage:
    def __init__(self, action, data=None):
        self.action = action
        self.data = data or {}

    def __str__(self):
        return f"Action: {self.action}, Data: {json.dumps(self.data)}"

# -------------------------------------------------------------------
# ResourceAnalyzer
# -------------------------------------------------------------------


class ResourceAnalyzer:
    def __init__(self, resource_path):
        self.resource_path = resource_path
        self.fxmanifest_path = os.path.join(resource_path, "fxmanifest.lua")
        self.client_scripts = []
        self.nui_events = set()
        self.ui_files = []
        self.data = {}

    def analyze(self):
        logging.info(f"Analyzuji resource v cestě: {self.resource_path}")
        self.load_fxmanifest()
        # Teď už je self.data naplněné + konvertované
        logging.info(
            f"DEBUG: po load_fxmanifest, self.data['client_scripts'] = {self.data.get('client_scripts', None)} (typ: {type(self.data.get('client_scripts', None))})")

        self.load_client_scripts()
        self.extract_nui_events()
        self.extract_ui_files()
        return self.data

    def load_fxmanifest(self):
        if not os.path.exists(self.fxmanifest_path):
            raise FileNotFoundError(
                f"fxmanifest.lua nenalezen v: {self.resource_path}")

        with open(self.fxmanifest_path, "r", encoding="utf-8") as f:
            manifest_content = f.read()

        logging.info(
            f"Načten fxmanifest.lua, délka: {len(manifest_content)} znaků.")

        lua_code = MOCK_FUNCS + "\n" + manifest_content
        lua_runtime = LuaRuntime()
        lua_runtime.execute(lua_code)
        g = lua_runtime.globals()
        self.data = {}

        # 1) ui_page
        if "ui_page" in g:
            val = g["ui_page"]
            if val is not None:
                if is_lua_table(val):
                    logging.info(
                        "ui_page je LuaTable, konvertuji na list/string.")
                    val = lua_table_to_list(val)
                self.data["ui_page"] = val
                logging.info(f"fxmanifest: ui_page -> {val}")

        # 2) files
        if "files" in g:
            val = g["files"]
            if val is not None:
                if is_lua_table(val):
                    python_list = lua_table_to_list(val)
                    self.data["files"] = python_list
                    logging.info(
                        f"fxmanifest: files -> {val} => {python_list}")
                else:
                    self.data["files"] = val
                    logging.info(f"fxmanifest: files -> {val}")

        # 3) client_scripts
        if "client_scripts" in g:
            print("### DEBUG: client_scripts klíč byl nalezen v globals")
            val = g["client_scripts"]
            if val is not None:
                if is_lua_table(val):
                    python_list = lua_table_to_list(val)
                    self.data["client_scripts"] = python_list
                    logging.info(
                        f"fxmanifest: client_scripts -> {val} => {python_list}")
                else:
                    self.data["client_scripts"] = val
                    logging.info(f"fxmanifest: client_scripts -> {val}")

        # 4) server_scripts
        if "server_scripts" in g:
            val = g["server_scripts"]
            if val is not None:
                if is_lua_table(val):
                    python_list = lua_table_to_list(val)
                    self.data["server_scripts"] = python_list
                    logging.info(
                        f"fxmanifest: server_scripts -> {val} => {python_list}")
                else:
                    self.data["server_scripts"] = val
                    logging.info(f"fxmanifest: server_scripts -> {val}")

    def load_client_scripts(self):
        cs = self.data.get("client_scripts")
        if cs is None:
            logging.info("Nebyla definována žádná client_scripts v manifestu.")
            return

        logging.info(f"DEBUG: load_client_scripts() -> {cs} (typ: {type(cs)})")

        if isinstance(cs, str):
            script_path = os.path.join(self.resource_path, cs)
            if os.path.exists(script_path):
                self.client_scripts.append(script_path)
                logging.info(f"Byl nalezen client script: {script_path}")
            else:
                logging.warning(f"Client script nenalezen: {script_path}")

        elif isinstance(cs, list):
            for item in cs:
                if isinstance(item, str):
                    script_path = os.path.join(self.resource_path, item)
                    if os.path.exists(script_path):
                        self.client_scripts.append(script_path)
                        logging.info(
                            f"Byl nalezen client script: {script_path}")
                    else:
                        logging.warning(
                            f"Client script nenalezen: {script_path}")
                else:
                    logging.warning(f"Client script není string: {item}")
        else:
            logging.warning(f"client_scripts: nepodporovaný typ {type(cs)}")

        logging.info(f"Nalezeny client_scripts: {self.client_scripts}")

    def extract_nui_events(self):
        total_found = 0
        for script_path in self.client_scripts:
            try:
                with open(script_path, "r", encoding="utf-8") as f:
                    content = f.read()
                matches = re.findall(
                    r"RegisterNUICallback\s*\(\s*['\"]([^'\"]+)['\"]", content)
                for m in matches:
                    self.nui_events.add(m)
                logging.info(
                    f"V souboru {script_path} nalezeno {len(matches)} NUI eventů.")
                total_found += len(matches)
            except Exception as e:
                logging.error(f"Chyba při čtení {script_path}: {e}")

        logging.info(
            f"Extrahované NUI eventy celkem: {self.nui_events} (počet: {total_found})")

    def extract_ui_files(self):
        ui_page_val = self.data.get("ui_page")
        if isinstance(ui_page_val, str):
            path = os.path.join(self.resource_path, ui_page_val)
            if os.path.exists(path):
                self.ui_files.append(path)
            else:
                logging.warning(f"UI page neexistuje: {path}")

        ff = self.data.get("files")
        if ff is None:
            ff = []
        if isinstance(ff, str):
            path = os.path.join(self.resource_path, ff)
            if os.path.exists(path) and any(path.endswith(ext) for ext in [".html", ".css", ".js"]):
                self.ui_files.append(path)
        elif isinstance(ff, list):
            for item in ff:
                if isinstance(item, str):
                    path = os.path.join(self.resource_path, item)
                    if os.path.exists(path) and any(path.endswith(ext) for ext in [".html", ".css", ".js"]):
                        self.ui_files.append(path)
                else:
                    logging.warning(f"Soubor v 'files' není string: {item}")

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

        # 1) Resource path
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

        splitter = QSplitter(Qt.Orientation.Horizontal)
        main_layout.addWidget(splitter)

        # Levá část
        left_widget = QWidget()
        left_layout = QVBoxLayout()

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

        # Testování NUI
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

        # Historie
        history_group = QGroupBox("Historie NUI Zpráv")
        history_layout = QVBoxLayout()

        self.history_list = QListWidget()
        history_layout.addWidget(self.history_list)
        self.history_list.itemClicked.connect(
            self.load_nui_message_from_history)

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
        resource_path = self.resource_path_input.text().strip()
        if not os.path.isdir(resource_path):
            QMessageBox.critical(self, "Chyba", "Neplatná cesta k resource!")
            return

        try:
            self.resource_analyzer = ResourceAnalyzer(resource_path)
            # <- Tady dojde k load_fxmanifest, konverzi atd.
            data = self.resource_analyzer.analyze()

            # Po analyze:
            # - self.resource_analyzer.nui_events by měly být vyplněné
            # - self.resource_analyzer.ui_files taky

            # Dej debug, jestli byly client_scripts
            if "client_scripts" in data:
                logging.info(
                    f"Nalezené client_scripts: {data['client_scripts']}")

            self.nui_events = list(self.resource_analyzer.nui_events)
            self.ui_files = self.resource_analyzer.ui_files

            self.nui_events_list.clear()
            for event in self.nui_events:
                self.nui_events_list.addItem(event)

            self.ui_files_list.clear()
            for file in self.ui_files:
                self.ui_files_list.addItem(file)

            self.event_combo.clear()
            self.event_combo.addItems(self.nui_events)

            html_files = [f for f in self.ui_files if f.endswith(".html")]
            if html_files:
                html_file = html_files[0]
                logging.info(
                    f"Načítám HTML soubor do QWebEngineView: {html_file}")
                with open(html_file, "r", encoding="utf-8") as f:
                    self.html_content = f.read()
                base_url = QUrl.fromLocalFile(
                    os.path.dirname(html_file) + os.sep)
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
        event = self.event_combo.currentText()
        data_text = self.data_input.toPlainText()

        try:
            payload = json.loads(data_text) if data_text.strip() else {}
            nui_message = NUIMessage(event, payload)
            msg_str = str(nui_message)

            self.nui_messages.append({"event": event, "data": payload})
            self.update_history_list()
            self.save_history()

            js_code = f"window.postMessage({{type: '{event}', data: {json.dumps(payload)}}}, '*');"
            self.web_view.page().runJavaScript(js_code)

            print(f"Odeslána NUI message: {msg_str}")
            QMessageBox.information(
                self, "Odesláno", f"Odeslána NUI message:\n{msg_str}")
            logging.info(f"Odeslána NUI message: {msg_str}")

        except json.JSONDecodeError as e:
            QMessageBox.critical(self, "Chyba", f"Neplatný JSON: {e}")
            logging.error(f"Neplatný JSON: {e}")
        except Exception as e:
            QMessageBox.critical(self, "Chyba", f"Chyba: {e}")
            logging.error(f"Chyba: {e}")

    def update_history_list(self):
        self.history_list.clear()
        for msg in self.nui_messages:
            item_text = f"Event: {msg['event']}"
            item = QListWidgetItem(item_text)
            self.history_list.addItem(item)

    def load_history(self):
        if os.path.exists(self.history_file):
            try:
                with open(self.history_file, "r", encoding="utf-8") as f:
                    self.nui_messages = json.load(f)
                self.update_history_list()
                logging.info("Historie načtena.")
            except Exception as e:
                logging.error(f"Error loading history: {e}")

    def save_history(self):
        try:
            with open(self.history_file, "w", encoding="utf-8") as f:
                json.dump(self.nui_messages, f, indent=2, ensure_ascii=False)
            logging.info("Historie uložena.")
        except Exception as e:
            logging.error(f"Error saving history: {e}")

    def load_nui_message_from_history(self, item):
        index = self.history_list.row(item)
        if 0 <= index < len(self.nui_messages):
            msg = self.nui_messages[index]
            self.event_combo.setCurrentText(msg['event'])
            self.data_input.setText(json.dumps(
                msg['data'], indent=4, ensure_ascii=False))

    def show_previous_message(self):
        if self.nui_messages:
            self.current_nui_message_index = (
                self.current_nui_message_index - 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def show_next_message(self):
        if self.nui_messages:
            self.current_nui_message_index = (
                self.current_nui_message_index + 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def load_message_from_index(self, index):
        if 0 <= index < len(self.nui_messages):
            msg = self.nui_messages[index]
            self.event_combo.setCurrentText(msg['event'])
            self.data_input.setText(json.dumps(
                msg['data'], indent=4, ensure_ascii=False))
            self.history_list.setCurrentRow(index)


if __name__ == "__main__":
    # Pomůže ověřit, že spouštíš tento soubor
    print("### I'm the new code ###")
    app = QApplication(sys.argv)
    tester = NUITester()
    tester.show()
    sys.exit(app.exec())

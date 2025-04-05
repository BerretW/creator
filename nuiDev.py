import sys
import os
import json
import re
import logging
import glob

from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,
    QPushButton, QTextEdit, QComboBox, QFileDialog, QGroupBox, QFormLayout,
    QListWidget, QListWidgetItem, QMessageBox, QSplitter, QGridLayout
)
from PyQt6.QtGui import QFont, QColor
from PyQt6.QtCore import Qt, QUrl
from PyQt6.QtWebEngineWidgets import QWebEngineView

import lupa
from lupa import LuaRuntime, LuaSyntaxError

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# MOCK funkce pro interpretaci fxmanifest.lua
MOCK_FUNCS = r"""
function fx_version(...) end
function game(...) end
function games(...) end
function rdr3_warning(...) end
function lua54(...) end
function author(...) end
function version(...) end
function description(...) end
function this_is_a_map(...) end
function jo_libs(...) end
function export(...) end
function vorp_checker(...) end
function vorp_name(...) end
function vorp_github(...) end
function repository(...) end

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

function shared_scripts(val)
    _G["shared_scripts"] = val
end

function dependencies(val)
    _G["dependencies"] = val
end

function escrow_id(val)
    _G["escrow_id"] = val
end

function data_file(val)
    _G["data_file"] = val
end
"""

def is_lua_table(obj) -> bool:
    return "LuaTable" in type(obj).__name__

def lua_table_to_dict(lua_table):
    """
    Převádí LuaTabulku do python dictionary (klíče+hodnoty).
    Pozor, nenačítá rekurzivně do hloubky - jen top-level klíče.
    """
    if not is_lua_table(lua_table):
        return lua_table

    result = {}
    for k in lua_table.keys():
        val = lua_table[k]
        if is_lua_table(val):
            # Můžeš rekurzivně volat, ale tady stačí top-level
            result[k] = lua_table_to_dict(val)
        else:
            result[k] = val
    return result

class ResourceAnalyzer:
    def __init__(self, resource_path):
        self.resource_path = resource_path
        self.fxmanifest_path = os.path.join(resource_path, "fxmanifest.lua")
        self.client_scripts = []
        self.nui_events = set()
        self.nui_send_calls = []
        self.ui_files = []
        self.data = {}

    def analyze(self):
        logging.info(f"Analyzuji resource v cestě: {self.resource_path}")
        self.load_fxmanifest()
        self.load_client_scripts()
        self.extract_nui_events()
        self.extract_ui_files()
        self.extract_send_nui_messages()
        return self.data

    def load_fxmanifest(self):
        if not os.path.exists(self.fxmanifest_path):
            raise FileNotFoundError(f"fxmanifest.lua nenalezen v: {self.resource_path}")

        with open(self.fxmanifest_path, "r", encoding="utf-8") as f:
            manifest_content = f.read()
        logging.info(f"Načten fxmanifest.lua, délka: {len(manifest_content)} znaků.")

        lua_code = MOCK_FUNCS + "\n" + manifest_content
        lua_runtime = lupa.LuaRuntime()
        lua_runtime.execute(lua_code)
        g = lua_runtime.globals()
        self.data = {}

        def extract_value(key):
            if key in g:
                val = g[key]
                if val is not None and is_lua_table(val):
                    val = lua_table_to_dict(val)
                self.data[key] = val
                logging.debug(f"fxmanifest: {key} -> {val}")

        for k in ["ui_page", "files", "client_scripts", "server_scripts", "shared_scripts", "dependencies", "escrow_id", "data_file"]:
            extract_value(k)

    def load_client_scripts(self):
        cs = self.data.get("client_scripts")
        if not cs:
            logging.info("Nebyla definována žádná client_scripts v manifestu.")
            return

        def add_script(path_str):
            full_path = os.path.join(self.resource_path, path_str)
            if os.path.exists(full_path):
                self.client_scripts.append(full_path)
                logging.info(f"Byl nalezen client script: {full_path}")
            else:
                logging.warning(f"Client script nenalezen: {full_path}")

        if isinstance(cs, str):
            add_script(cs)
        elif isinstance(cs, list):
            for item in cs:
                if isinstance(item, str):
                    add_script(item)
                else:
                    logging.warning(f"Client script není string: {item}")
        elif isinstance(cs, dict):
            for _, item in cs.items():
                if isinstance(item, str):
                    add_script(item)
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
                matches = re.findall(r"RegisterNUICallback\s*\(\s*['\"]([^'\"]+)['\"]", content)
                for m in matches:
                    self.nui_events.add(m)
                logging.info(f"V souboru {script_path} nalezeno {len(matches)} NUI eventů.")
                total_found += len(matches)
            except Exception as e:
                logging.error(f"Chyba při čtení {script_path}: {e}")

        logging.info(f"Extrahované NUI eventy celkem: {self.nui_events} (počet: {total_found})")

    def extract_ui_files(self):
        ui_page_val = self.data.get("ui_page", "")
        files_val = self.data.get("files", [])

        ui_files_to_check = []

        def add_ui_file(file_path):
            full = os.path.join(self.resource_path, file_path)
            if os.path.exists(full):
                self.ui_files.append(full)
            else:
                logging.warning(f"UI soubor neexistuje: {full}")

        if isinstance(ui_page_val, str):
            add_ui_file(ui_page_val)
        elif isinstance(ui_page_val, list):
            for page in ui_page_val:
                if isinstance(page, str):
                    add_ui_file(page)
        elif isinstance(ui_page_val, dict):
            for _, page in ui_page_val.items():
                if isinstance(page, str):
                    add_ui_file(page)

        if isinstance(files_val, str):
            add_ui_file(files_val)
        elif isinstance(files_val, list):
            for f in files_val:
                if isinstance(f, str):
                    add_ui_file(f)
        elif isinstance(files_val, dict):
            for _, f in files_val.items():
                if isinstance(f, str):
                    add_ui_file(f)

        # Odstranění duplicit
        self.ui_files = list(set(self.ui_files))

        logging.info(f"UI soubory: {self.ui_files}")

    def extract_send_nui_messages(self):
        pattern = r"SendNUIMessage\s*\(\s*\{\s*((?:.|\n)*?)\}\s*\)"

        self.nui_send_calls = []
        for script_path in self.client_scripts:
            try:
                with open(script_path, "r", encoding="utf-8") as f:
                    content = f.read()
                raw_bodies = re.findall(pattern, content)
                for raw in raw_bodies:
                    logging.debug(f"Nalezen SendNUIMessage body: {raw}")
                    lua_code = f"return {{{raw}}}"
                    try:
                        rt = lupa.LuaRuntime()
                        parsed_lua = rt.execute(lua_code)
                        parsed_dict = lua_table_to_dict(parsed_lua)
                        logging.debug(f"parsed_lua => {parsed_dict}")
                        self.nui_send_calls.append({
                            "script": script_path,
                            "raw_body": raw.strip(),
                            "parsed_data": parsed_dict
                        })
                    except LuaSyntaxError as e:
                        logging.warning(f"Nepodařilo se parse body: {raw} => {e}")
                        self.nui_send_calls.append({
                            "script": script_path,
                            "raw_body": raw.strip(),
                            "parsed_data": None
                        })
            except Exception as e:
                logging.error(f"Chyba při čtení {script_path}: {e}")

        logging.info(f"Nalezeno {len(self.nui_send_calls)} volání SendNUIMessage.")

class NUITester(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("RedM/FiveM NUI Tester (Univerzálnější SendNUIMessage)")
        self.setGeometry(100, 100, 1400, 900)

        self.resource_analyzer = None
        self.nui_events = []
        self.nui_send_calls = []
        self.ui_files = []
        self.nui_messages = []
        self.current_nui_message_index = 0
        self.history_file = "nui_message_history.json"
        self.html_content = ""
        self.current_resource_name = ""  # Uchováváme název resource

        self.init_ui()
        self.load_history()

    def init_ui(self):
        main_layout = QVBoxLayout()

        # Resource group
        resource_group = QGroupBox("Resource")
        resource_layout = QHBoxLayout()

        self.resource_path_input = QLineEdit()
        self.resource_path_input.setPlaceholderText("Cesta k resource...")
        resource_layout.addWidget(self.resource_path_input)

        self.browse_resource_button = QPushButton("Procházet...")
        self.browse_resource_button.clicked.connect(self.browse_resource)
        resource_layout.addWidget(self.browse_resource_button)

        self.load_resource_button = QPushButton("Načíst Resource")
        self.load_resource_button.clicked.connect(self.load_resource)
        resource_layout.addWidget(self.load_resource_button)

        resource_group.setLayout(resource_layout)
        main_layout.addWidget(resource_group)

        splitter = QSplitter(Qt.Orientation.Horizontal)
        main_layout.addWidget(splitter)

        # Levá strana
        left_widget = QWidget()
        left_layout = QVBoxLayout()

        # NUI Events + Tlačítka
        events_group = QGroupBox("NUI Events (RegisterNUICallback)")
        ev_layout = QVBoxLayout()
        self.nui_events_list = QListWidget()
        ev_layout.addWidget(self.nui_events_list)

        # Přidáme layout pro tlačítka
        self.nui_events_buttons_layout = QGridLayout()
        ev_layout.addLayout(self.nui_events_buttons_layout)

        events_group.setLayout(ev_layout)
        left_layout.addWidget(QLabel("RegisterNUICallback:"))
        left_layout.addWidget(events_group)


        # UI Files
        ui_group = QGroupBox("UI Files")
        ui_layout = QVBoxLayout()
        self.ui_files_list = QListWidget()
        ui_layout.addWidget(self.ui_files_list)
        ui_group.setLayout(ui_layout)
        left_layout.addWidget(ui_group)

        # NUI Send calls
        send_group = QGroupBox("SendNUIMessage calls")
        send_layout = QVBoxLayout()

        self.nui_send_list = QComboBox()
        self.nui_send_list.currentIndexChanged.connect(self.on_send_call_selected)
        send_layout.addWidget(self.nui_send_list)

        self.nui_send_json = QTextEdit()
        self.nui_send_json.setPlaceholderText("Zde se zobrazí JSON z parsed_data. Můžeš ho upravit.")
        send_layout.addWidget(self.nui_send_json)

        self.send_nui_button = QPushButton("Odeslat do NUI (SendNUIMessage)")
        self.send_nui_button.clicked.connect(self.send_nui_message_parsed)
        send_layout.addWidget(self.send_nui_button)

        send_group.setLayout(send_layout)
        left_layout.addWidget(send_group)

        # Historie poslaných zpráv
        history_group = QGroupBox("Historie poslaných zpráv (ručně z UI)")
        history_layout = QVBoxLayout()
        self.history_list = QListWidget()
        self.history_list.itemClicked.connect(self.load_nui_message_from_history)
        history_layout.addWidget(self.history_list)

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

        # Pravá část - QWebEngineView
        self.web_view = QWebEngineView()
        splitter.addWidget(self.web_view)
        splitter.setSizes([600, 800])

        self.setLayout(main_layout)

    def browse_resource(self):
        folder = QFileDialog.getExistingDirectory(self, "Vyber složku resource")
        if folder:
            self.resource_path_input.setText(folder)

    def load_resource(self):
        resource_path = self.resource_path_input.text().strip()
        if not os.path.isdir(resource_path):
            QMessageBox.critical(self, "Chyba", "Neplatná cesta k resource!")
            return

        try:
            self.resource_analyzer = ResourceAnalyzer(resource_path)
            data = self.resource_analyzer.analyze()

            # Získáme název resource
            self.current_resource_name = os.path.basename(resource_path)

            # Získáme NUI eventy, send calls, UI files
            self.nui_events = list(self.resource_analyzer.nui_events)
            self.nui_send_calls = self.resource_analyzer.nui_send_calls
            self.ui_files = self.resource_analyzer.ui_files

            # Naplníme do GUI - NUI Events
            self.nui_events_list.clear()
            # Vyčistíme tlačítka
            self.clear_nui_event_buttons()
            for row, ev in enumerate(self.nui_events):
                self.nui_events_list.addItem(ev)
                # Tlačítko pro každý event
                btn = QPushButton(f"Spustit {ev}")
                btn.clicked.connect(lambda checked, event=ev: self.trigger_nui_event(event))  # Používáme lambda
                # Umístíme tlačítko
                self.nui_events_buttons_layout.addWidget(btn, row, 0) #row, column



            # Naplníme do GUI - UI Files
            self.ui_files_list.clear()
            for f in self.ui_files:
                self.ui_files_list.addItem(f)

            # Naplníme combobox pro SendNUI
            self.nui_send_list.clear()
            for call_info in self.nui_send_calls:
                base = os.path.basename(call_info["script"])
                show_code = call_info["raw_body"].replace("\n", " ")[:60] + "..."
                self.nui_send_list.addItem(f"{base}: {show_code}")

            # Načteme HTML a přidáme mock funkci GetParentResourceName.  Použijeme self.current_resource_name
            html_candidates = [x for x in self.ui_files if x.lower().endswith(".html")]
            if html_candidates:
                html_file = html_candidates[0]
                try:
                    with open(html_file, "r", encoding="utf-8") as ff:
                        self.html_content = ff.read()

                    mock_js = f"""
<script>
function GetParentResourceName() {{
    return "{self.current_resource_name}";
}}
</script>
"""
                    self.html_content = mock_js + self.html_content

                    base_url = QUrl.fromLocalFile(os.path.dirname(html_file) + os.sep)
                    self.web_view.setHtml(self.html_content, base_url)
                except Exception as e:
                    QMessageBox.critical(self, "Chyba HTML", str(e))

            QMessageBox.information(self, "OK", "Resource načten!")
        except Exception as e:
            QMessageBox.critical(self, "Chyba", str(e))
            logging.error(f"Chyba: {e}")

    def clear_nui_event_buttons(self):
        """Odstraní všechna tlačítka z grid layoutu."""
        for i in reversed(range(self.nui_events_buttons_layout.count())):
            widget_to_remove = self.nui_events_buttons_layout.itemAt(i).widget()
            # Odstraníme widget z layoutu
            self.nui_events_buttons_layout.removeWidget(widget_to_remove)
            # Odstraníme widget z paměti
            widget_to_remove.setParent(None)

    def trigger_nui_event(self, event_name):
        """Spustí NUI event v QWebEngineView."""
        js_code = f"""
            window.postMessage({{ type: '{event_name}' }}, '*');
        """
        self.web_view.page().runJavaScript(js_code)
        logging.info(f"Spuštěn NUI event: {event_name}")

        # Uložit do historie (pokud chceš)
        self.nui_messages.append({"event": event_name, "data": {"type": event_name}})
        self.update_history_list()
        self.save_history()

    def on_send_call_selected(self, idx):
        if idx < 0 or idx >= len(self.nui_send_calls):
            return
        call_info = self.nui_send_calls[idx]
        if call_info["parsed_data"] is not None:
            try:
                txt = json.dumps(call_info["parsed_data"], indent=2, ensure_ascii=False)
            except:
                txt = str(call_info["parsed_data"])
        else:
            txt = f"-- Nepodařilo se parse:\n{call_info['raw_body']}"
        self.nui_send_json.setText(txt)
        self.nui_send_json.setStyleSheet("")

    def send_nui_message_parsed(self):
        raw_text = self.nui_send_json.toPlainText().strip()
        if not raw_text:
            QMessageBox.warning(self, "Chyba", "Prázdný JSON pro SendNUIMessage.")
            self.nui_send_json.setStyleSheet("background-color: lightcoral;")
            return

        try:
            data_json = json.loads(raw_text)
            self.nui_send_json.setStyleSheet("background-color: lightgreen;")
        except json.JSONDecodeError as e:
            QMessageBox.critical(self, "JSON chyba", f"Neplatné JSON: {e}")
            self.nui_send_json.setStyleSheet("background-color: lightcoral;")
            return

        js_code = f"""
window.postMessage({json.dumps(data_json)}, "*");
"""
        self.web_view.page().runJavaScript(js_code)
        logging.info(f"Odeslána NUI message (parsed) -> {data_json}")
        QMessageBox.information(self, "OK", f"Odesláno do NUI:\n{data_json}")

        self.nui_messages.append({"event": data_json.get("action", "unknown"), "data": data_json})
        self.update_history_list()
        self.save_history()

    def update_history_list(self):
        self.history_list.clear()
        for msg in self.nui_messages:
            ev = msg['event']
            self.history_list.addItem(f"Event: {ev}")

    def load_history(self):
        if os.path.exists(self.history_file):
            try:
                with open(self.history_file, "r", encoding="utf-8") as f:
                    self.nui_messages = json.load(f)
                self.update_history_list()
            except Exception as e:
                logging.error(f"Chyba při load_history: {e}")

    def save_history(self):
        try:
            with open(self.history_file, "w", encoding="utf-8") as f:
                json.dump(self.nui_messages, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logging.error(f"Chyba při save_history: {e}")

    def load_nui_message_from_history(self, item):
        idx = self.history_list.row(item)
        if 0 <= idx < len(self.nui_messages):
            data = self.nui_messages[idx]["data"]
            txt = json.dumps(data, indent=2, ensure_ascii=False)
            self.nui_send_json.setText(txt)

            for i, call_info in enumerate(self.nui_send_calls):
                if call_info["parsed_data"] == data:
                    self.nui_send_list.setCurrentIndex(i)
                    break
                else:
                    self.nui_send_list.setCurrentIndex(-1)

            self.nui_send_json.setStyleSheet("")


    def show_previous_message(self):
        if self.nui_messages:
            self.current_nui_message_index = (self.current_nui_message_index - 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def show_next_message(self):
        if self.nui_messages:
            self.current_nui_message_index = (self.current_nui_message_index + 1) % len(self.nui_messages)
            self.load_message_from_index(self.current_nui_message_index)

    def load_message_from_index(self, index):
        if 0 <= index < len(self.nui_messages):
            data = self.nui_messages[index]["data"]
            txt = json.dumps(data, indent=2, ensure_ascii=False)
            self.nui_send_json.setText(txt)
            self.history_list.setCurrentRow(index)
            self.nui_send_json.setStyleSheet("")

if __name__ == "__main__":
    print("### I'm the new code ###")
    app = QApplication(sys.argv)
    tester = NUITester()
    tester.show()
    sys.exit(app.exec())
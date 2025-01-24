from PyQt5 import QtWidgets, QtGui, QtCore

class RecipeGraphsDialog(QtWidgets.QDialog):
    def __init__(self, graphs):
        super().__init__()
        self.setWindowTitle("Vizualizace Receptů")
        self.resize(800, 600)
        self.init_ui(graphs)

    def init_ui(self, graphs):
        layout = QtWidgets.QVBoxLayout()
        tab_widget = QtWidgets.QTabWidget()
        for category_name, png_data in graphs.items():
            label = QtWidgets.QLabel()
            pixmap = QtGui.QPixmap()
            pixmap.loadFromData(png_data)
            label.setPixmap(pixmap)
            label.setAlignment(QtCore.Qt.AlignCenter)

            scroll_area = QtWidgets.QScrollArea()
            scroll_area.setWidget(label)
            scroll_area.setWidgetResizable(True)

            tab_widget.addTab(scroll_area, category_name)

        layout.addWidget(tab_widget)
        self.setLayout(layout)

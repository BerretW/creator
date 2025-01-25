const contentEditableLeft = document.querySelector('.left-page .content');
const contentEditableRight = document.querySelector('.right-page .content');
const currentPageElement = document.getElementById('currentPage');
const pageCountElement = document.getElementById('pageCount');
const fontSelector = document.getElementById('fontSelector');
const bookmarksContainer = document.querySelector('.bookmarks');
const toolbar = document.querySelector('.toolbar');
const floatingToolbar = document.querySelector('.floating-toolbar');
const titlePage = document.querySelector('.title-page');
const pagesContainer = document.querySelector('.pages-container');
const diaryNameInput = document.getElementById('diaryName');
const saveNameButton = document.getElementById('saveNameButton');
const bookmarkButton = document.getElementById('bookmarkButton');

let currentDiaryData = {};
let currentPage = 1;
let currentColors = {};
let hasPen = false;
let isFirstOpen = true;

let textColorButton = document.getElementById('textColorButton');
let colorPickerModal = document.getElementById('colorPickerModal');
let colorModal = document.getElementById('colorModal');
let closeModal = document.querySelector('.close');

// Fyzická tlačítka pro přepínání stránek
const prevPageButton = document.getElementById('prevPageButton');
const nextPageButton = document.getElementById('nextPageButton');

// Event listeners for toolbar buttons
toolbar.addEventListener('click', function (event) {
    if (event.target.tagName === 'BUTTON') {
        const format = event.target.dataset.format;
        if (format === 'link') {
            let url = prompt("Zadej URL:");
            if (url) {
                document.execCommand('createLink', false, url);
            }
        } else {
            document.execCommand(format);
        }
    }
});

// Event listener for font selector
fontSelector.addEventListener('change', function () {
    contentEditableLeft.style.fontFamily = fontSelector.value;
    contentEditableRight.style.fontFamily = fontSelector.value;
});

// Event listeners for page navigation buttons
prevPageButton.addEventListener('click', function () {
    if (isFirstOpen) {
        isFirstOpen = false;
        updateUI();
    } else {
        changePage('prev');
    }
});

nextPageButton.addEventListener('click', function () {
    if (isFirstOpen) {
        isFirstOpen = false;
        updateUI();
    } else {
        changePage('next');
    }
});

// Event listener for bookmark button
bookmarkButton.addEventListener('click', function () {
    addBookmark(currentPage);
});

// Event listener for save name button
saveNameButton.addEventListener("click", function () {
    currentDiaryData.custom_name = diaryNameInput.value;
    console.log("Uložení názvu deníku:", currentDiaryData.custom_name); // Debug výpis
    sendData();
    isFirstOpen = false;
    updateUI();
});

// Event listener for close button
document.getElementById('closeButton').addEventListener('click', function () {
    console.log("Zavření deníku pomocí tlačítka"); // Debug výpis
    sendData();
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
    });
});

// Event listeners for color picker modal
textColorButton.addEventListener('click', () => {
    console.log("Barva textu tlačítko kliknuto"); // Debug výpis
    if (hasPen) {
        colorModal.style.display = 'block';
    } else {
        alert('Nemáš tužku, nemůžeš měnit barvu!');
    }
});

// Zavření modálního okna při kliknutí na "x"
closeModal.addEventListener('click', () => {
    colorModal.style.display = 'none';
});

// Zavření modálního okna při kliknutí mimo obsah
window.addEventListener('click', (event) => {
    if (event.target == colorModal) {
        colorModal.style.display = 'none';
    }
});

// Zpracování výběru barvy v modálním okně
colorPickerModal.addEventListener('input', () => {
    const color = colorPickerModal.value;
    console.log("Vybraná barva v modálním okně:", color); // Debug výpis
    document.execCommand('foreColor', false, color);
    colorModal.style.display = 'none';
});

// Event listener for messages from server
window.addEventListener('message', function (event) {
    const action = event.data.action;
    const data = event.data;
    if (action === 'open') {
        console.log("Otevírání deníku:", data); // Debug výpis
        document.body.style.display = 'flex';
        isFirstOpen = true;
        currentDiaryData = data.data;
        currentColors = data.colors;
        currentPage = data.page;
        hasPen = currentColors.length > 0;
        updateUI();
    } else if (action === 'close') {
        console.log("Zavírání deníku"); // Debug výpis
        document.body.style.display = 'none';
        sendData();
    } else if (action === 'updatePage') {
        currentPage = data.page;
        updateUI();
    }
});

// Event listener for keydown (Escape)
document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
        console.log("Escape klávesa stisknuta"); // Debug výpis
        // Zabránění defaultní akci
        event.preventDefault();
        // Zavolání funkce pro uložení a zavření deníku
        sendData();
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
        });
    }
});

// Event listener for text selection to show floating toolbar
document.addEventListener('selectionchange', () => {
    const selection = window.getSelection();
    if (!selection.isCollapsed && (contentEditableLeft.contains(selection.anchorNode) || contentEditableRight.contains(selection.anchorNode))) {
        floatingToolbar.style.display = 'flex';
    } else {
        floatingToolbar.style.display = 'none';
    }
});

// Event listeners for floating toolbar buttons
floatingToolbar.addEventListener('click', function (event) {
    if (event.target.tagName === 'BUTTON') {
        const format = event.target.dataset.format;
        document.execCommand(format);
    }
});

// Function to update UI
function updateUI() {
    if (isFirstOpen) {
        titlePage.style.display = 'flex';
        pagesContainer.style.display = 'none';
        diaryNameInput.value = currentDiaryData.custom_name;
    } else {
        titlePage.style.display = 'none';
        pagesContainer.style.display = 'flex';
    }

    // Implementace Markdown s DOMPurify
    const leftContent = currentDiaryData.data[currentPage] || "";
    const rightContent = currentDiaryData.data[currentPage + 1] || "";

    contentEditableLeft.innerHTML = DOMPurify.sanitize(marked.parse(leftContent));
    contentEditableRight.innerHTML = DOMPurify.sanitize(marked.parse(rightContent));

    if (currentPage === currentDiaryData.pages) {
        contentEditableRight.innerHTML = "";
    }

    currentPageElement.textContent = currentPage;
    pageCountElement.textContent = currentDiaryData.pages;
    bookmarksContainer.innerHTML = '';
    if (currentDiaryData.marks) {
        for (const page in currentDiaryData.marks) {
            const markName = currentDiaryData.marks[page];
            const bookmarkElement = document.createElement('div');
            bookmarkElement.classList.add('bookmark');
            bookmarkElement.textContent = markName;
            bookmarkElement.dataset.page = page;
            bookmarkElement.addEventListener('click', function () {
                currentPage = parseInt(this.dataset.page, 10);
                updateUI();
            });
            bookmarksContainer.appendChild(bookmarkElement);
        }
    }

    console.log("Updating UI with Pages:", currentDiaryData.pages); // Debug výpis

    contentEditableLeft.focus();
    window.scrollTo(0, 0);
}

// Function to send data to server
function sendData() {
    // Uložit obsah textových polí jako Markdown text
    currentDiaryData.data[currentPage] = contentEditableLeft.innerText;
    currentDiaryData.data[currentPage + 1] = contentEditableRight.innerText;
    console.log("Sending Diary Data:", currentDiaryData); // Debug výpis
    fetch(`https://${GetParentResourceName()}/saveData`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
        },
        body: JSON.stringify(currentDiaryData),
    });
}

// Function to change page
function changePage(direction) {
    if (direction === 'next' && currentPage < currentDiaryData.pages) {
        currentPage += 1;
        updateUI();
    } else if (direction === 'prev' && currentPage > 1) {
        currentPage -= 1;
        updateUI();
    }
}

// Function to add a bookmark
function addBookmark(page) {
    const markName = prompt("Zadej název záložky:");
    if (markName) {
        if (!currentDiaryData.marks) {
            currentDiaryData.marks = {};
        }
        currentDiaryData.marks[page] = markName;
        console.log(`Přidána záložka na stránku ${page} s názvem "${markName}"`); // Debug výpis
        updateUI();
    }
}

// Udržování fokusu NUI
document.addEventListener('focus', () => {
    fetch(`https://${GetParentResourceName()}/nuiFocus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
        },
        body: JSON.stringify(true),
    });
});
document.addEventListener('blur', () => {
    fetch(`https://${GetParentResourceName()}/nuiFocus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
        },
        body: JSON.stringify(false),
    });
});

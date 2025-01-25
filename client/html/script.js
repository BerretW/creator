const contentEditableLeft = document.querySelector('.left-page .content');
const contentEditableRight = document.querySelector('.right-page .content');
const currentPageElement = document.getElementById('currentPage');
const pageCountElement = document.getElementById('pageCount');
const fontSelector = document.getElementById('fontSelector');
const bookmarksContainer = document.querySelector('.bookmarks');
const toolbar = document.querySelector('.toolbar');
const titlePage = document.querySelector('.title-page');
const pagesContainer = document.querySelector('.pages-container');
const diaryNameInput = document.getElementById('diaryName');
const saveNameButton = document.getElementById('saveNameButton')

let currentDiaryData = {};
let currentPage = 1;
let currentColors = {};
let hasPen = false;
let isFirstOpen = true;

let textColorButton = document.getElementById('textColorButton');
let colorPicker = document.getElementById('colorPicker');

toolbar.addEventListener('click', function (event) {
  if (event.target.tagName === 'BUTTON') {
    const format = event.target.dataset.format;
    document.execCommand(format);
  }
});
fontSelector.addEventListener('change', function () {
    contentEditableLeft.style.fontFamily = fontSelector.value;
     contentEditableRight.style.fontFamily = fontSelector.value;
});
function updateUI() {
    if (isFirstOpen) {
        titlePage.style.display = 'flex';
        pagesContainer.style.display = 'none';
         diaryNameInput.value = currentDiaryData.custom_name;
    } else {
       titlePage.style.display = 'none';
      pagesContainer.style.display = 'flex';
    }
    
    
   contentEditableLeft.innerHTML = currentDiaryData.data[currentPage] || "";
      contentEditableRight.innerHTML = currentDiaryData.data[currentPage + 1] || "";
   if(currentPage === currentDiaryData.pages){
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
  
   contentEditableLeft.focus();
    window.scrollTo(0, 0);
}
textColorButton.addEventListener('click', () => {
  if (hasPen) {
    colorPicker.style.display = 'block';
    colorPicker.click();
  } else {
    alert('Nemáš tužku, nemůžeš měnit barvu!');
  }
});
colorPicker.addEventListener('input', () => {
  const color = colorPicker.value;
     document.execCommand('foreColor', false, color);
  colorPicker.style.display = 'none';
});
window.addEventListener('message', function (event) {
  const action = event.data.action;
  const data = event.data;
  if (action === 'open') {
    document.body.style.display = 'flex';
      isFirstOpen = true;
    currentDiaryData = data.data;
    currentColors = data.colors;
    currentPage = data.page;
    hasPen = currentColors.length > 0;
    updateUI();
  } else if (action === 'close') {
    document.body.style.display = 'none';
    sendData();
  } else if (action === 'updatePage') {
    currentPage = data.page;
    updateUI();
  }
});
saveNameButton.addEventListener("click", function(){
       currentDiaryData.custom_name = diaryNameInput.value
    sendData();
     isFirstOpen = false;
    updateUI();
})
  document.getElementById('closeButton').addEventListener('click', function () {
    sendData();
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
    });
});
contentEditableLeft.addEventListener('blur', sendData);
contentEditableRight.addEventListener('blur', sendData);
function sendData() {
    currentDiaryData.data[currentPage] = contentEditableLeft.innerHTML;
    currentDiaryData.data[currentPage + 1] = contentEditableRight.innerHTML;
     fetch(`https://${GetParentResourceName()}/saveData`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
         body: JSON.stringify(currentDiaryData),
    });
}
window.addEventListener('keydown', function (event) {
    if (event.key === 'ArrowLeft') {
        if(isFirstOpen){
             isFirstOpen = false;
             updateUI();
        } else {
        fetch(`https://${GetParentResourceName()}/changePage`, {
            method: 'POST',
            headers: {
            'Content-Type': 'application/json; charset=utf-8',
            },
            body: JSON.stringify({ direction: 'prev' }),
        });
      }
    }
    if (event.key === 'ArrowRight') {
      if(isFirstOpen){
          isFirstOpen = false;
             updateUI();
        } else {
        fetch(`https://${GetParentResourceName()}/changePage`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
            },
            body: JSON.stringify({ direction: 'next' }),
        });
      }
    }
  if (event.key === 'Escape') {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
      });
  }
});
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
let pdfDoc = null;
let currentPage = 1;
let totalPages = 0;
let bookOpened = false; // Přidána proměnná pro sledování stavu knihy

const leftPageCanvas = document.getElementById("left-page");
const rightPageCanvas = document.getElementById("right-page");
const leftPageContext = leftPageCanvas.getContext("2d");
const rightPageContext = rightPageCanvas.getContext("2d");

document.addEventListener("DOMContentLoaded", () => {
  window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "openBook") {
      document.body.style.display = "block";
      document.getElementById("book-container").style.display = "block";
      document.getElementById("new-book-form").style.display = "none";

      // Načteme PDF
      const loadingTask = pdfjsLib.getDocument(data.pdfUrl);
      loadingTask.promise.then(
        function (pdf) {
          pdfDoc = pdf;
          totalPages = pdf.numPages;
          currentPage = 1;
          bookOpened = false; // Kniha je zavřená
          updatePageNumberDisplay();
          renderPages();
        },
        function (reason) {
          console.error(reason);
        }
      );
    }

    if (data.action === "closeBook") {
      document.body.style.display = "none";
      document.getElementById("book-container").style.display = "none";
      pdfDoc = null;
    }

    if (data.action === "openNewBookForm") {
      document.body.style.display = "block";
      document.getElementById("new-book-form").style.display = "block";
      document.getElementById("book-container").style.display = "none";
    }
  });

  // Ovládání stránek
  document.getElementById("prev-page").addEventListener("click", () => {
    if (bookOpened) {
      if (currentPage > 2) {
        currentPage -= 2;
        renderPages();
      }
    } else {
      // Pokud je kniha zavřená, nemůžeme jít na předchozí stránku
    }
  });

  document.getElementById("next-page").addEventListener("click", () => {
    if (bookOpened) {
      if (currentPage + 1 < totalPages) {
        currentPage += 2;
        renderPages();
      }
    } else {
      // Otevřeme knihu
      bookOpened = true;
      // Nastavíme currentPage na 2, abychom pokračovali po obálce
      currentPage = 2;
      renderPages();
    }
  });

  // Upravit tlačítko "Další stránky" na "Otevřít knihu", pokud je zavřená
  function updateNextButtonLabel() {
    const nextButton = document.getElementById("next-page");
    if (bookOpened) {
      nextButton.textContent = "Další stránky";
    } else {
      nextButton.textContent = "Otevřít knihu";
    }
  }

  // Přidáme obsluhu tlačítka "Přejít"
  document.getElementById("go-to-page").addEventListener("click", () => {
    const pageNumberInput = document.getElementById("page-number-input");
    let pageNumber = parseInt(pageNumberInput.value);

    if (isNaN(pageNumber) || pageNumber < 1 || pageNumber > totalPages) {
      alert("Neplatné číslo stránky.");
      return;
    }

    if (!bookOpened && pageNumber > 1) {
      bookOpened = true;
    }

    // Ujistíme se, že zobrazujeme správné stránky
    if (bookOpened) {
      // Při otevřené knize zobrazujeme dvojstránky
      if (pageNumber % 2 === 0) {
        currentPage = pageNumber;
      } else {
        currentPage = pageNumber - 1;
      }
    } else {
      // Při zavřené knize můžeme zobrazit pouze první stránku
      currentPage = 1;
    }

    renderPages();
  });
  // Zavření knihy
  document.getElementById("close-book").addEventListener("click", () => {
    fetch(`https://${GetParentResourceName()}/closeBook`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    });
    document.body.style.display = "none";
    document.getElementById("book-container").style.display = "none";
    pdfDoc = null;
  });

  // Uložení nové knihy
  document.getElementById("save-book").addEventListener("click", () => {
    const title = document.getElementById("title").value.trim();
    const author = document.getElementById("author").value.trim();
    const pdfUrl = document.getElementById("pdf-url").value.trim();

    fetch(`https://${GetParentResourceName()}/saveNewBook`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ title, author, pdfUrl }),
    }).then(() => {
      closeBookForm();
      alert("Kniha byla úspěšně uložena.");
    });
  });

  // Zrušení vytvoření knihy
  document.getElementById("cancel-book").addEventListener("click", () => {
    closeBookForm();
  });

  function closeBookForm() {
    fetch(`https://${GetParentResourceName()}/closeBookForm`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    });
    document.body.style.display = "none";
    document.getElementById("new-book-form").style.display = "none";
    document.getElementById("title").value = "";
    document.getElementById("author").value = "";
    document.getElementById("pdf-url").value = "";
  }

  function renderPages() {
    if (!pdfDoc) return;

    const bookElement = document.getElementById("book");

    if (bookOpened) {
      // Přidáme třídu 'opened' pro odstranění pozadí
      bookElement.classList.add("opened");

      // Zobrazujeme dvojstránky
      leftPageCanvas.classList.remove("hidden");
      renderPage(currentPage, leftPageCanvas, leftPageContext);
      if (currentPage + 1 <= totalPages) {
        renderPage(currentPage + 1, rightPageCanvas, rightPageContext);
      } else {
        // Vyčistíme pravou stránku, pokud neexistuje další stránka
        rightPageContext.clearRect(
          0,
          0,
          rightPageCanvas.width,
          rightPageCanvas.height
        );
      }
    } else {
      // Odstraníme třídu 'opened' pro zobrazení pozadí
      bookElement.classList.remove("opened");

      // Zobrazíme pouze obálku na pravé stránce, levá je skrytá
      leftPageCanvas.classList.add("hidden");
      renderPage(currentPage, rightPageCanvas, rightPageContext);
    }

    // Aktualizujeme hodnotu inputu na aktuální stránku
    document.getElementById("page-number-input").value = currentPage;

    // Aktualizujeme zobrazení aktuální stránky a celkového počtu stránek
    updatePageNumberDisplay();

    // Aktualizujeme label tlačítka
    updateNextButtonLabel();
  }

  function renderPage(num, canvas, context) {
    // Získáme stránku z dokumentu
    pdfDoc.getPage(num).then(function (page) {
      const viewport = page.getViewport({ scale: 1.5 });

      // Přizpůsobíme velikost canvasu stránce
      canvas.height = viewport.height;
      canvas.width = viewport.width;

      // Vymažeme předchozí obsah
      context.clearRect(0, 0, canvas.width, canvas.height);

      // Nastavíme průhledné pozadí
      context.globalAlpha = 1.0;

      // Renderujeme stránku do canvasu s průhledným pozadím
      const renderContext = {
        canvasContext: context,
        viewport: viewport,
        background: "rgba(0,0,0,0)",
      };
      page.render(renderContext);
    });
  }

  // Funkce pro aktualizaci zobrazení čísla stránky
  function updatePageNumberDisplay() {
    const totalPagesElement = document.getElementById("total-pages");
    const currentPageElement = document.getElementById("current-page");
    totalPagesElement.textContent = totalPages;
    currentPageElement.textContent = currentPage;
  }
});

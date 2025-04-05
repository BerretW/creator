// script.js with debug logging
document.addEventListener("DOMContentLoaded", () => {
  console.log("[DEBUG] DOMContentLoaded - script is running.");

  // The poster:
  const posterContainer = document.getElementById("posterContainer");
  const posterCanvas = document.getElementById("posterCanvas");
  const posterCtx = posterCanvas.getContext("2d");
  const posterImg = document.getElementById("posterImg");
  const closePosterBtn = document.getElementById("closePoster");

  // The newspaper:
  const newspaperContainer = document.getElementById("newspaperContainer");
  const pagesWrapper = document.getElementById("pagesWrapper");
  const closeNewspaperBtn = document.getElementById("closeNewspaper");

  console.log("[DEBUG] Setting up window.message listener...");
  window.addEventListener("message", (event) => {
    const data = event.data;
    console.log("[DEBUG] Received NUI message:", data);

    if (data.action === "openPoster") {
      console.log("[DEBUG] → Action openPoster with URL:", data.url);
      showPoster(data.url);
    }
    if (data.action === "openNewspaper") {
      console.log("[DEBUG] → Action openNewspaper with PDF URL:", data.pdfUrl);
      showNewspaper(data.pdfUrl);
    }
  });

  function showPoster(url) {
    console.log("[DEBUG] showPoster, url =", url);
    document.body.style.display = "block";
    // Hide newspaper
    newspaperContainer.classList.add("hidden");
    // Show poster container
    posterContainer.classList.remove("hidden");
    posterImg.classList.add("hidden");
    posterCanvas.classList.add("hidden");

    // Check if it's PDF or not:
    if (/\.(pdf)$/i.test(url) || url.toLowerCase().includes("pdf")) {
      console.log(
        "[DEBUG] Poster is PDF -> using pdf.js to render first page."
      );
      // We load 1st page with pdf.js
      const loadingTask = pdfjsLib.getDocument({ url });
      loadingTask.promise
        .then((pdf) => {
          console.log(
            "[DEBUG] Poster PDF loaded. Number of pages =",
            pdf.numPages
          );

          pdf.getPage(1).then((page) => {
            console.log("[DEBUG] Poster PDF: got page 1, now rendering...");
            // Grab viewport at 1.0 scale just as example:
            const scale = 1.0;
            const viewport = page.getViewport({ scale });
            posterCanvas.width = viewport.width;
            posterCanvas.height = viewport.height;
            posterCanvas.classList.remove("hidden");

            const renderCtx = {
              canvasContext: posterCtx,
              viewport,
            };
            page.render(renderCtx).promise.then(() => {
              console.log("[DEBUG] Poster PDF page rendered successfully.");
            });
          });
        })
        .catch((err) => {
          console.error("[DEBUG] Error loading PDF poster:", err);
        });
    } else {
      console.log("[DEBUG] Poster is an image -> setting posterImg src");
      // Just treat as PNG/JPG
      posterImg.src = url;
      posterImg.onload = () => {
        posterImg.classList.remove("hidden");
        console.log("[DEBUG] Poster image loaded, now visible.");
      };
      posterImg.onerror = (err) => {
        console.error("[DEBUG] Poster image failed to load:", err);
      };
    }
  }

  function showNewspaper(pdfUrl) {
    console.log("[DEBUG] showNewspaper, pdfUrl =", pdfUrl);
    document.body.style.display = "block";
    // Hide poster
    posterContainer.classList.add("hidden");
    // Show newspaper container
    newspaperContainer.classList.remove("hidden");
    pagesWrapper.innerHTML = "";

    console.log("[DEBUG] Starting pdf.js loading for newspaper...");
    const loadingTask = pdfjsLib.getDocument({ url: pdfUrl });
    loadingTask.promise
      .then((pdf) => {
        console.log("[DEBUG] Newspaper PDF loaded. numPages =", pdf.numPages);
        const pageCount = pdf.numPages;

        // Let's just load all pages, stacked vertically:
        const loadAll = [];
        for (let i = 1; i <= pageCount; i++) {
          loadAll.push(pdf.getPage(i));
        }

        console.log(
          "[DEBUG] Fetching all pages in parallel (",
          pageCount,
          ")..."
        );
        Promise.all(loadAll)
          .then((pages) => {
            console.log(
              "[DEBUG] All pages fetched. Now rendering each page..."
            );
            pages.forEach((page, index) => {
              const viewport = page.getViewport({ scale: 1.0 });
              const cnv = document.createElement("canvas");
              cnv.className = "newsPageCanvas";
              const ctx = cnv.getContext("2d");
              cnv.width = viewport.width;
              cnv.height = viewport.height;
              pagesWrapper.appendChild(cnv);

              page
                .render({
                  canvasContext: ctx,
                  viewport,
                })
                .promise.then(() => {
                  console.log(`[DEBUG] Newspaper page ${index + 1} rendered.`);
                })
                .catch((err) => {
                  console.error(
                    `[DEBUG] Rendering error on page ${index + 1}:`,
                    err
                  );
                });
            });
          })
          .catch((err) => {
            console.error("[DEBUG] Error in loading all newspaper pages:", err);
          });
      })
      .catch((err) => {
        console.error("[DEBUG] Error loading newspaper PDF:", err);
      });
  }
  window.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      document.body.style.display = "none";
      // Podle toho, co je zobrazené, buď zavřít noviny, nebo plakát
      if (!posterContainer.classList.contains("hidden")) {
        // Zavřít plakát
        posterContainer.classList.add("hidden");
        fetch(`https://${GetParentResourceName()}/closePoster`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({}),
        });
      }
      if (!newspaperContainer.classList.contains("hidden")) {
        // Zavřít noviny
        newspaperContainer.classList.add("hidden");
        fetch(`https://${GetParentResourceName()}/closeNewspaper`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({}),
        });
      }
    }
  });
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      // Poster
      if (!posterContainer.classList.contains('hidden')) {
        posterContainer.classList.add('hidden');
        fetch(`https://${GetParentResourceName()}/closePoster`, {method: 'POST'});
      }
      // Newspaper
      if (!newspaperContainer.classList.contains('hidden')) {
        newspaperContainer.classList.add('hidden');
        fetch(`https://${GetParentResourceName()}/closeNewspaper`, {method: 'POST'});
      }
    }
  });
  // Close poster
  closePosterBtn.addEventListener("click", () => {
    console.log("[DEBUG] closePoster clicked -> hiding poster");
    posterContainer.classList.add("hidden");
    fetch(`https://${GetParentResourceName()}/closePoster`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({}),
    }).then(() => {
      console.log("[DEBUG] closed poster, setNuiFocus false on client side");
    });
  });

  // Close newspaper
  closeNewspaperBtn.addEventListener("click", () => {
    console.log("[DEBUG] closeNewspaper clicked -> hiding newspaper");
    newspaperContainer.classList.add("hidden");
    fetch(`https://${GetParentResourceName()}/closeNewspaper`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({}),
    }).then(() => {
      console.log("[DEBUG] closed newspaper, setNuiFocus false on client side");
    });
  });

  console.log("[DEBUG] script.js loaded successfully.");
});

let timeout;

document.addEventListener("DOMContentLoaded", () => {
  window.addEventListener("message", function (event) {
    const data = event.data;
    
    if (data.action === "open") {
      document.getElementById("prompt").innerText = data.prompt;
      const buttonsDiv = document.getElementById("buttons");
      buttonsDiv.innerHTML = "";

      // Nastav pozadí, pokud je uvedeno
      if (data.backgroundImage) {
        document.getElementById("nui-container").style.backgroundImage = `url('images/${data.backgroundImage}')`;
        document.getElementById("nui-container").style.backgroundColor = 'transparent';
      } else {
        document.getElementById("nui-container").style.backgroundImage = 'none';
        document.getElementById("nui-container").style.backgroundColor = '#f5deb3'; // Původní barva
      }

      data.options.forEach((option) => {
        const button = document.createElement("button");
        button.className = "button";
        button.innerText = option.label;
        button.onclick = () => selectOption(option.value);

        // Nastav obrázek tlačítka, pokud je uveden
        if (option.image) {
          button.style.backgroundImage = `url('images/${option.image}')`;
          button.classList.add('with-image');
        }

        buttonsDiv.appendChild(button);
      });

      document.body.style.display = "block";

      // Reset timeout
      if (timeout) clearTimeout(timeout);
    } else if (data.action === "close") {
      closeUI();
    }
  });

  const resourceName = 'aprts_inputButtons'; // Ujisti se, že toto je název tvého zdroje
  
  function selectOption(value) {
    fetch(`https://${resourceName}/selectOption`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ value }),
    });
    closeUI();
  }

  function closeUI() {
    document.body.style.display = "none";
    fetch(`https://${resourceName}/close`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    });
  }

  // Skryj NUI na začátku
  document.body.style.display = "none";
});

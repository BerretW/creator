# APRTS Button Inputs

APRTS Button Inputs je NUI skript pro RedM (platforma pro modifikace hry Red Dead Redemption 2), který umožňuje ostatním skriptům vytvářet jednoduchá uživatelská rozhraní (NUI) s tlačítky pro interakci s hráčem. Skript podporuje vlastní texty, obrázky tlačítek a pozadí, s možností přizpůsobení vzhledu podle potřeb.

## Obsah

- [Funkcionalita](#funkcionalita)
- [Instalace](#instalace)
- [Použití](#použití)
  - [Základní použití](#základní-použití)
  - [Použití s obrázky tlačítek a pozadí](#použití-s-obrázky-tlačítek-a-pozadí)
- [Konfigurace](#konfigurace)
- [Soubory](#soubory)
  - [`fxmanifest.lua`](#fxmanifestlua)
  - [`client/main.lua`](#clientmainlua)
  - [`nui/index.html`](#nuiindexhtml)
  - [`nui/script.js`](#nuiscriptjs)
  - [`nui/style.css`](#nuistylecss)
- [Poznámky](#poznámky)
- [Licence](#licence)

---

## Funkcionalita

- **Interaktivní NUI okno**: Zobrazuje otázku a sadu tlačítek pro výběr.
- **Volitelné obrázky**: Možnost použít vlastní obrázky pro tlačítka a pozadí.
- **Časový limit**: Nastavitelný timeout pro odpověď uživatele.
- **Flexibilita**: Pokud nejsou obrázky poskytnuty, zobrazí se pouze text s předdefinovaným vzhledem.
- **Jednoduchá integrace**: Exportovaná funkce `getAnswer` pro snadné použití v jiných skriptech.

## Instalace

1. **Stažení zdroje**: Stáhněte si tento skript a umístěte jej do složky `resources/aprts_buttonInputs` ve vašem serveru RedM.
2. **Přidání zdroje do server.cfg**:

ensure aprts_buttonInputs

markdown
Zkopírovat kód

3. **Restart serveru** nebo načtěte zdroj pomocí příkazu v konzoli:

restart aprts_buttonInputs

bash
Zkopírovat kód

## Použití

### Základní použití


Fonty: Skript používá vlastní font Chinese Rocks. Ujistěte se, že soubor crock.ttf je přítomen ve složce nui/ a zahrnut v fxmanifest.lua.
Poznámky
Název zdroje: Pokud změníte název složky zdroje, ujistěte se, že aktualizujete také resourceName v script.js a všechny odkazy v kódu.

Debugging: Pro testování můžete nastavit proměnnou Debug v main.lua na true a použít příkaz /testPrompt ve hře.

Časový limit: Pokud uživatel neodpoví v nastaveném časovém limitu, funkce vrátí nil.

Obrázky: Obrázky musí být ve formátu podporovaném prohlížečem (např. PNG, JPG) a umístěny ve složce nui/images/.

Stylování: Můžete upravit style.css pro přizpůsobení vzhledu NUI podle svých potřeb.

Licence
Tento skript je poskytován "tak, jak je", bez jakýchkoli záruk. Můžete jej upravovat a používat pro své projekty. Pokud skript sdílíte nebo redistribuujete, uveďte prosím původního autora.

V jiném klientském skriptu můžete použít exportovanou funkci `getAnswer`:

```lua
  local options = {{
            label = "Ano",
            value = 1,
            image = "check.png"
        }, {
            label = "Ne",
            value = 2,
            image = "cross.png"
        }, {
            label = "Možná",
            value = 3
        }}
        local timeout = 10000
        local backgroundImage = "black_paper.png"

        local answer = exports.aprts_inputButtons:getAnswer("Chceš pokračovat?", options, timeout, backgroundImage)

        print(answer)
```

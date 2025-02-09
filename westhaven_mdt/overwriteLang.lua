-------------------------------------------
-- NEMĚŇTE TENTO SOUBOR
-- PRO PŘEKLAD SKRIPTU POUŽIJTE SOUBOR overwriteLang.lua
-------------------------------------------

Lang = {}
---@param name string klíč řetězce
---@return string
function __(name) return Lang[name] or ("#"..name) end

-------------
-- VÝZVY
-------------
Lang.backToClipboard = "Zpět do schránky"
Lang.close = "Zavřít"
Lang.getMDT = "Získat MDT"
Lang.openFileLocker = "Otevřít trezor souborů"

-------------
-- PŘÍKAZY
-------------
Lang.commandOpenMDT = "Otevřít MDT"

-------------
-- ŘETĚZCE
-------------
Lang.fileLocker = "Trezor souborů"
Lang.mdt = "MDT"
Lang.mdtDescription  = "MDT ze stanice <b>%s</b>"
Lang.mdtGot = "MDT přidán do vašeho inventáře!"
Lang.reportItemDesc = "Zpráva č. %d<br>%s"

-------------
-- NUI
-------------
Lang.addJail = 'Přidat vězení'
Lang.age = 'Věk'
Lang.alias = 'Přezdívka'
Lang.back = 'Zpět'
Lang.cancel = 'Zrušit'
Lang.caseFile = 'Složka zprávy'
Lang.citizen = 'Občan'
Lang.citizenRegisteryNumber = 'Číslo občanského registru'
Lang.citizens = 'Občané'
Lang.clickToEdit = 'Klikněte pro úpravu'
Lang.confirmSaveCitizen = 'Chcete uložit tohoto občana?'
Lang.confirmSaveReport = 'Chcete uložit tuto zprávu?'
Lang.created = 'Vytvořeno'
Lang.date = 'Datum'
Lang.days = 'Dny'
Lang.delete = 'Smazat'
Lang.deleteInProgress = 'Mazání probíhá'
Lang.duration = 'Délka'
Lang.enterImageUrl = 'Zadejte URL obrázku'
Lang.enterNameToDelete = 'Zadejte <b>%s</b> k odstranění:'
Lang.eyecolor = 'Barva očí'
Lang.firstname = 'Křestní jméno'
Lang.formatDate = 'D MMM YYYY, HH:mm'
Lang.haircolor = 'Barva vlasů'
Lang.headerTitle = 'Oddělení šerifa'
Lang.hours = 'hodiny'
Lang.id = 'ID'
Lang.incidentReport = 'Zpráva o události'
Lang.inventory = "Inventář"
Lang.jailDuration = 'Délka vězení'
Lang.jails = 'Vězení'
Lang.jailsHistory = 'Historie vězení'
Lang.lastname = 'Příjmení'
Lang.marks = 'Značky'
Lang.maxInputLength = 'Maximální délka: 255 znaků.'
Lang.minutes = 'minuty'
Lang.name = 'Jméno'
Lang.new = 'Nový'
Lang.numberJail = 'Počet vězení'
Lang.numberReport = 'Počet zpráv'
Lang.refresh = 'Obnovit'
Lang.remove = 'Odstranit'
Lang.report = 'Spis'
Lang.reportDeleted = 'Spis smazáný'
Lang.reportNumber = 'Spis č.'
Lang.reports = 'Spisy'
Lang.reportsHistory = 'Historie spisů'
Lang.save = 'Uložit'
Lang.saveInProgress = 'Probíhá ukládání, nezavírejte MDT'
Lang.search = "Hledat"
Lang.selectJailDuration  = 'Vyberte délku vězení'
Lang.summary = 'Shrnutí'
Lang.title = 'Název'
Lang.unknown = 'Neznámý'
Lang.updated = 'Aktualizováno'
Lang.warningDelete = 'Varování, smažete zprávu.'
Lang.warningDeletePicture = 'Varování, smažete obrázek'
Lang.warningRefresh = 'Varování, všechna neuložená data budou ztracena.'
Lang.wrongInput ='Nesprávný vstup'
Lang.cases = 'Případy'
Lang.state = 'Stav'
Lang.created_sheriff = 'Vytvořeno sheriffem'
Lang.caseText = 'Popis případu'
Lang.sheriff = 'Sheriff'
Lang.caseNumber = 'Číslo případu'
Lang.confirmSaveCase = 'Chcete uložit případ ?'
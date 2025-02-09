-------------------------------------------
-- DON'T EDIT THIS FILE
-- TO TRANSLATE THE SCRIPT, USE overwriteLang.lua file instead
-------------------------------------------

Lang = {}
---@param name string key of the string
---@return string
function __(name) return Lang[name] or ("#"..name) end

-------------
-- PROMPT
-------------
Lang.backToClipboard = "Back to clipboard"
Lang.close = "Close"
Lang.getMDT = "Get a MDT"
Lang.openFileLocker = "Open file locker"

-------------
-- COMMANDS
-------------
Lang.commandOpenMDT = "Open the MDT"

-------------
-- STRINGS
-------------
Lang.fileLocker = "File locker"
Lang.mdt = "MDT"
Lang.mdtDescription  = "MDT from <b>%s</b> station"
Lang.mdtGot = "MDT added in your inventory !"
Lang.reportItemDesc = "Report n°%d<br>%s"

-------------
-- NUI
-------------
Lang.addJail = 'Add jail'
Lang.age = 'Age'
Lang.alias = 'Alias'
Lang.back = 'Back'
Lang.cancel = 'Cancel'
Lang.caseFile = 'Report file'
Lang.citizen = 'Citizen'
Lang.citizenRegisteryNumber = 'Citizen Registry No.'
Lang.citizens = 'Citizens'
Lang.clickToEdit = 'Click to edit'
Lang.confirmSaveCitizen = 'Do you want save this citizen ?'
Lang.confirmSaveReport = 'Do you want save this report ?'
Lang.created = 'Created'
Lang.date = 'Date'
Lang.days = 'Days'
Lang.delete = 'Delete'
Lang.deleteInProgress = 'Delete in progress'
Lang.duration = 'Duration'
Lang.enterImageUrl = 'Enter the image Url'
Lang.enterNameToDelete = 'Enter <b>%s</b> to delete:'
Lang.eyecolor = 'Eye color'
Lang.firstname = 'Firstname'
Lang.formatDate = 'D MMM YYYY, HH:mm'
Lang.haircolor = 'Hair color'
Lang.headerTitle = 'Sheriff Department'
Lang.hours = 'hours'
Lang.id = 'ID'
Lang.incidentReport = 'Incident report'
Lang.inventory = "Inventory"
Lang.jailDuration = 'Jail duration'
Lang.jails = 'Jails'
Lang.jailsHistory = 'Jails history'
Lang.lastname = 'Lastname'
Lang.marks = 'Marks'
Lang.maxInputLength = 'Max length: 255 characters.'
Lang.minutes = 'minutes'
Lang.name = 'Name'
Lang.new = 'New'
Lang.numberJail = 'Number of jail'
Lang.numberReport = 'Number of report'
Lang.refresh = 'Refresh'
Lang.remove = 'Remove'
Lang.report = 'Report'
Lang.reportDeleted = 'Report deleted'
Lang.reportNumber = 'Report No.'
Lang.reports = 'Reports'
Lang.reportsHistory = 'Reports history'
Lang.save = 'Save'
Lang.saveInProgress = 'Save in progress, don\'t close the MDT'
Lang.search = "Search"
Lang.selectJailDuration  = 'Select the jail duration'
Lang.summary = 'Summary'
Lang.title = 'Title'
Lang.unknown = 'Unknown'
Lang.updated = 'Updated'
Lang.warningDelete = 'Warning, you will delete a report.'
Lang.warningDeletePicture = 'Warning, you will delete a picture'
Lang.warningRefresh = 'Warning, all data unsaved will be lost.'
Lang.wrongInput ='Wrong input'
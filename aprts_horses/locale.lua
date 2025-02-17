local Locales = {
    ['en'] = {
        ['error_horse_not_stabled'] = 'ERROR: Horse not stabled!',
        ['horse_stabled'] = 'Horse stabled!',
        ['name_already_in_use'] = 'Name already in use!',
        ['stable_slot_limit_reached'] = 'Stable slot limit reached!',
        ['setting_default_horse_failed'] = 'Setting default horse failed!',
        ['default_horse_set'] = '%s set to default!',
        ['vehicle_registered'] = '%s %s Registered!'
    },
    ['cs'] = {
        ['error_horse_not_stabled'] = 'CHYBA: Kůň nebyl ustájen!',
        ['horse_stabled'] = 'Kůň ustájen!',
        ['name_already_in_use'] = 'Jméno již existuje!',
        ['stable_slot_limit_reached'] = 'Překročen limit stájí!',
        ['setting_default_horse_failed'] = 'Nastavení výchozího koně selhalo!',
        ['default_horse_set'] = '%s nastaven jako výchozí!',
        ['vehicle_registered'] = '%s %s zaregistrováno!'
    }
}

local currentLocale = 'en'

function _U(key, ...)
    if Locales[currentLocale] and Locales[currentLocale][key] then
        return string.format(Locales[currentLocale][key], ...)
    else
        return 'Translation [' .. key .. '] does not exist'
    end
end

function setLocale(locale)
    if Locales[locale] then
        currentLocale = locale
    end
end

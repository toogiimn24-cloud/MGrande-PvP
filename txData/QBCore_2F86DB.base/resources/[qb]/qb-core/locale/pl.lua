local Translations = {
    error = {
        not_online = 'Gracz nie jest online',
        wrong_format = 'NieprawidÅ‚owy format',
        missing_args = 'Nie kaÅ¼dy argument zostaÅ‚ wprowadzony (x, y, z)',
        missing_args2 = 'Wszystkie argumenty muszÄ… byÄ‡ wypeÅ‚nione!',
        no_access = 'Brak dostÄ™pu do tego polecenia',
        company_too_poor = 'TwÃ³j pracodawca jest spÅ‚ukany',
        item_not_exist = 'Przedmiot nie istnieje',
        too_heavy = 'Ekwipunek jest zbyt peÅ‚ny',
        duplicate_license = 'Znaleziono zduplikowanÄ… licencjÄ™ Rockstar',
        no_valid_license  = 'Nie znaleziono waÅ¼nej licencji Rockstar',
    },
    success = {},
    info = {
        received_paycheck = 'OtrzymaÅ‚eÅ› czek w wysokoÅ›ci $%{value}',
        job_info = 'Praca: %{value} | StopieÅ„: %{value2} | SÅ‚uÅ¼ba: %{value3}',
        gang_info = 'Gang: %{value} | StopieÅ„: %{value2}',
        on_duty = 'JesteÅ› teraz na sÅ‚uÅ¼bie!',
        off_duty = 'JesteÅ› teraz po sÅ‚uÅ¼bie!',
        checking_ban = 'Witaj %s. Sprawdzamy, czy jesteÅ› zbanowany.',
        join_server = 'Witaj %s na {Server Name}.',
    }
}

if GetConvar('qb_locale', 'en') == 'pl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

local Translations = {
    error = {
        not_online = 'MÃ¤ngija pole serveris!',
        wrong_format = 'Vale formaat.',
        missing_args = 'KÃµiki argumente pole sisestatud (x, y, z)',
        missing_args2 = 'KÃµik argumendid tuleb tÃ¤ita!',
        no_access = 'Sellele kÃ¤sule pole juurdepÃ¤Ã¤su!',
        company_too_poor = 'Teie tÃ¶Ã¶andja on pankrotis.',
        item_not_exist = 'Sellist asja ei eksisteeri',
        too_heavy = 'Inventuur on liiga tÃ¤is',
        duplicate_license = 'Leiti Rockstari litsentsi duplikaat',
        no_valid_license  = 'Kehtivat Rockstari litsentsi ei leitud',
    },
    success = {},
    info = {
        received_paycheck = 'Saite oma tÃ¶Ã¶tasu kÃ¤tte $%{value}',
        job_info = 'TÃ¶Ã¶koht: %{value} | Auaste: %{value2} | TÃ¶Ã¶l: %{value3}',
        gang_info = 'Gang: %{value} | Auaste: %{value2}',
        on_duty = 'Alustasite enda tÃ¶Ã¶pÃ¤eva!',
        off_duty = 'LÃµpetasite enda tÃ¶Ã¶pÃ¤eva!',
        checking_ban = 'Tere %s. Me kontrollime, kas olete keelustatud.',
        join_server = 'Tere tulemast %s serverisse {Server Name}.',
    }
}

if GetConvar('qb_locale', 'en') == 'ee' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

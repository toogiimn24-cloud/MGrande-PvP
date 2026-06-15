local Translations = {
    error = {
        not_online = 'Pelaaja ei ole paikalla',
        wrong_format = 'VÃ¤Ã¤rÃ¤ formaatti',
        missing_args = 'Kaikkia argumentteja ei ole syÃ¶tetty (x, y, z)',
        missing_args2 = 'Kaikki argumentit on tÃ¤ytettÃ¤vÃ¤!',
        no_access = 'Ei pÃ¤Ã¤syÃ¤ tÃ¤hÃ¤n komentoon',
        company_too_poor = 'TyÃ¶nantajasi on kÃ¶yhÃ¤',
        item_not_exist = 'Kohdetta ei ole olemassa',
        too_heavy = 'Taskusi ovat tÃ¤ynnÃ¤',
        location_not_exist = 'Sijaintia ei ole olemassa',
        duplicate_license = 'Rockstar-lisenssin kaksoiskappale lÃ¶ydetty',
        no_valid_license  = 'Voimassa olevaa Rockstar-lisenssiÃ¤ ei lÃ¶ytynyt',
        server_already_open = 'Serveri on jo auki',
        server_already_closed = 'Serveri on jo suljettu',
        no_permission = 'Sinulla ei ole oikeuksia tÃ¤mmÃ¶seen..',
        no_waypoint = 'Et ole asettanut waypointtia.',
        tp_error = 'Virhe teleportatessa.',
        connecting_database_error = 'Tietokantavirhe muodostettaessa yhteyttÃ¤ palvelimeen. (Onko SQL-palvelin pÃ¤Ã¤llÃ¤?)',
        connecting_database_timeout = 'Yhteys tietokantaan aikakatkaistiin. (Onko SQL-palvelin pÃ¤Ã¤llÃ¤?)',
    },
    success = {
        server_opened = 'Palvelin on avattu',
        server_closed = 'Palvelin on suljettu',
        teleported_waypoint = 'Teleporttaa Waypointille',
    },
    info = {
        received_paycheck = 'Olet saanut palkkasi $%{value}',
        job_info = 'TyÃ¶: %{value} | Arvo: %{value2} | Vuorossa: %{value3}',
        gang_info = 'Jengi: %{value} | Arvo: %{value2}',
        on_duty = 'Olet nyt vuorossa',
        off_duty = 'Olet nyt poisvuorosta!',
        checking_ban = 'Tervehdys %s. Tarkistetaan oletko saanut porttikieltoa.',
        join_server = 'Tervetuloa %s - {Server Name}.',
        exploit_banned = 'Sinut on bÃ¤nnatty cheattaamisesta. Katso lisÃ¤tietoja Discordistamme: %{discord}',
        exploit_dropped = 'Sinua on potkittu hyvÃ¤ksikÃ¤ytÃ¶n vuoksi',
    },
    command = {
        tp = {
            help = 'TP pelaajalle tai koordinaateille (Vain Admineille)',
            params = {
                x = { name = 'id/x', help = 'Pelaajan ID tai X-paikka'},
                y = { name = 'y', help = 'Y position'},
                z = { name = 'z', help = 'Z position'},
            },
        },
        tpm = { help = 'TP Markerille (Vain Admineille)' },
        togglepvp = { help = 'Vaihda PVP palvelimelle (Vain Admineille)' },
        addpermission = {
            help = 'Anna pelaajalle admin oikeudet (God Only)',
            params = {
                id = { name = 'id', help = 'Pelaajan ID' },
                permission = { name = 'permission', help = 'Permission level' },
            },
        },
        removepermission = {
            help = 'Poista pelaajatlta admin oikeudet (God Only)',
            params = {
                id = { name = 'id', help = 'Pelaajan ID' },
                permission = { name = 'permission', help = 'Permission level' },
            },
        },
        openserver = { help = 'Avaa palvelin kaikille (Vain Admineille)' },
        closeserver = {
            help = 'Sulje palvelin ihmisiltÃ¤, â€‹â€‹joilla ei ole oikeuksia (Vain Admineille)',
            params = {
                reason = { name = 'reason', help = 'Sulkemisen syy (valinnainen)' },
            },
        },
        car = {
            help = 'Spawnaa ajoneuvo (Vain Admineille)',
            params = {
                model = { name = 'model', help = 'Ajoneuvon nimi' },
            },
        },
        dv = { help = 'Poista ajoneuvo (Vain Admineille)' },
        givemoney = {
            help = 'Anna Pelaajalle rahaa (Vain Admineille)',
            params = {
                id = { name = 'id', help = 'Pelaajan ID' },
                moneytype = { name = 'moneytype', help = 'Rahan tyyppi (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Rahan mÃ¤Ã¤rÃ¤' },
            },
        },
        setmoney = {
            help = 'Aseta pelaajien rahasumma (Vain Admineille)',
            params = {
                id = { name = 'id', help = 'Pelaajan ID' },
                moneytype = { name = 'moneytype', help = 'Rahan tyyppi (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Rahan mÃ¤Ã¤rÃ¤' },
            },
        },
        job = { help = 'katso tyÃ¶si' },
        setjob = {
            help = 'Aseta pelaajalle tyÃ¶ (Vain Admineille)',
            params = {
                id = { name = 'id', help = 'Pelaajan ID' },
                job = { name = 'job', help = 'TyÃ¶n nimi' },
                grade = { name = 'grade', help = 'Arvo' },
            },
        },
        gang = { help = 'Katso jengisi' },
        setgang = {
            help = 'Aseta pelaajalle jengi (Vain Admineille)',
            params = {
                id = { name = 'id', help = 'Pelaajan ID' },
                gang = { name = 'gang', help = 'Jengin Nimi' },
                grade = { name = 'grade', help = 'Arvo' },
            },
        },
        ooc = { help = 'OOC Viesti lÃ¤hipelaajille' },
        me = {
            help = 'NÃ¤ytÃ¤ paikallinen viesti',
            params = {
                message = { name = 'message', help = 'MitÃ¤ haluat kertoa?' }
            },
        },
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

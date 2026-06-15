local Translations = {
    error = {
        not_online                  = 'Oyuncu Ã§evrimdÄ±ÅŸÄ±',
        wrong_format                = 'HatalÄ± format',
        missing_args                = 'TÃ¼m argÃ¼manlar girilmedi (x, y, z)',
        missing_args2               = 'TÃ¼m argÃ¼manlar doldurulmalÄ±dÄ±r!',
        no_access                   = 'Bu komut iÃ§in eriÅŸiminiz yok',
        company_too_poor            = 'Ä°ÅŸvereniniz iflas etti',
        item_not_exist              = 'EÅŸya mevcut deÄŸil',
        too_heavy                   = 'Envanter Ã§ok dolu',
        location_not_exist          = 'Konum mevcut deÄŸil',
        duplicate_license           = '[QBCORE] - AynÄ± Rockstar LisansÄ± Bulundu',
        no_valid_license            = '[QBCORE] - GeÃ§erli Rockstar LisansÄ± BulunamadÄ±',
        server_already_open         = 'Sunucu zaten aÃ§Ä±k',
        server_already_closed       = 'Sunucu zaten kapalÄ±',
        no_permission               = 'Bu iÅŸlem iÃ§in yetkiniz yok...',
        no_waypoint                 = 'Bir iÅŸaret noktasÄ± ayarlanmamÄ±ÅŸ.',
        tp_error                    = 'TaÅŸÄ±nÄ±rken hata oluÅŸtu.',
        ban_table_not_found         = '[QBCORE] - VeritabanÄ±nda yasaklÄ±lar tablosu bulunamadÄ±. LÃ¼tfen SQL dosyasÄ±nÄ±n doÄŸru ÅŸekilde yÃ¼klendiÄŸinden emin olun.',
        connecting_database_error   = '[QBCORE] - VeritabanÄ±na baÄŸlanÄ±rken hata oluÅŸtu. SQL sunucusunun Ã§alÄ±ÅŸtÄ±ÄŸÄ±ndan ve server.cfg dosyasÄ±ndaki bilgilerin doÄŸru olduÄŸundan emin olun.',
        connecting_database_timeout = '[QBCORE] - VeritabanÄ± baÄŸlantÄ±sÄ± zaman aÅŸÄ±mÄ±na uÄŸradÄ±. SQL sunucusunun Ã§alÄ±ÅŸtÄ±ÄŸÄ±ndan ve server.cfg dosyasÄ±ndaki bilgilerin doÄŸru olduÄŸundan emin olun.',
    },
    success = {
        server_opened = 'Sunucu aÃ§Ä±ldÄ±',
        server_closed = 'Sunucu kapandÄ±',
        teleported_waypoint = 'Ä°ÅŸaret noktasÄ±na taÅŸÄ±ndÄ±nÄ±z.',
    },
    info = {
        received_paycheck = 'MaaÅŸÄ±nÄ±zÄ± $%{value} aldÄ±nÄ±z',
        job_info = 'Ä°ÅŸ: %{value} | Seviye: %{value2} | GÃ¶revde: %{value3}',
        gang_info = 'Ã‡ete: %{value} | Seviye: %{value2}',
        on_duty = 'ArtÄ±k gÃ¶revdeyiniz!',
        off_duty = 'ArtÄ±k gÃ¶rev dÄ±ÅŸÄ±nda oldunuz!',
        checking_ban = 'Merhaba %s. YasaklÄ± olup olmadÄ±ÄŸÄ±nÄ±zÄ± kontrol ediyoruz.',
        join_server = 'HoÅŸgeldiniz %s, {Sunucu AdÄ±}\'na.',
        exploit_banned = 'Hile yaptÄ±ÄŸÄ±nÄ±z iÃ§in yasaklandÄ±nÄ±z. Daha fazla bilgi iÃ§in Discord\'umuza gÃ¶z atÄ±n: %{discord}',
        exploit_dropped = 'Hile yapmaktan dolayÄ± sunucudan atÄ±ldÄ±nÄ±z',
    },
    command = {
        tp = {
            help = 'Oyuncuya veya Koordinatlara TP (Sadece Admin)',
            params = {
                x = { name = 'id/x', help = 'Oyuncu ID\'si veya X konumu' },
                y = { name = 'y', help = 'Y konumu' },
                z = { name = 'z', help = 'Z konumu' },
            },
        },
        tpm = { help = 'Ä°ÅŸaret noktasÄ±na TP (Sadece Admin)' },
        togglepvp = { help = 'Sunucuda PVP modunu aÃ§/kapat (Sadece Admin)' },
        addpermission = {
            help = 'Oyuncuya Yetki Ver (TanrÄ± Yetkisi)',
            params = {
                id = { name = 'id', help = 'Oyuncu ID\'si' },
                permission = { name = 'permission', help = 'Yetki seviyesi' },
            },
        },
        removepermission = {
            help = 'Oyuncudan Yetki Al (TanrÄ± Yetkisi)',
            params = {
                id = { name = 'id', help = 'Oyuncu ID\'si' },
                permission = { name = 'permission', help = 'Yetki seviyesi' },
            },
        },
        openserver = { help = 'Sunucuyu herkes iÃ§in aÃ§ (Sadece Admin)' },
        closeserver = {
            help = 'Sunucuyu yetkisi olmayanlar iÃ§in kapat (Sadece Admin)',
            params = {
                reason = { name = 'reason', help = 'Kapanma nedeni (isteÄŸe baÄŸlÄ±)' },
            },
        },
        car = {
            help = 'AraÃ§ Spawn Et (Sadece Admin)',
            params = {
                model = { name = 'model', help = 'AraÃ§ model adÄ±' },
            },
        },
        dv = { help = 'AracÄ± Sil (Sadece Admin)' },
        dvall = { help = 'TÃ¼m AraÃ§larÄ± Sil (Sadece Admin)' },
        dvp = { help = 'TÃ¼m Pedleri Sil (Sadece Admin)' },
        dvo = { help = 'TÃ¼m Objeleri Sil (Sadece Admin)' },
        givemoney = {
            help = 'Bir Oyuncuya Para Ver (Sadece Admin)',
            params = {
                id = { name = 'id', help = 'Oyuncu ID\'si' },
                moneytype = { name = 'moneytype', help = 'Para tÃ¼rÃ¼ (nakit, banka, kripto)' },
                amount = { name = 'amount', help = 'Verilecek para miktarÄ±' },
            },
        },
        setmoney = {
            help = 'Oyuncunun Para MiktarÄ±nÄ± Ayarla (Sadece Admin)',
            params = {
                id = { name = 'id', help = 'Oyuncu ID\'si' },
                moneytype = { name = 'moneytype', help = 'Para tÃ¼rÃ¼ (nakit, banka, kripto)' },
                amount = { name = 'amount', help = 'Para miktarÄ±' },
            },
        },
        job = { help = 'Ä°ÅŸinizi Kontrol Edin' },
        setjob = {
            help = 'Bir Oyuncunun Ä°ÅŸini Ayarla (Sadece Admin)',
            params = {
                id = { name = 'id', help = 'Oyuncu ID\'si' },
                job = { name = 'job', help = 'Ä°ÅŸ adÄ±' },
                grade = { name = 'grade', help = 'Ä°ÅŸ seviyesi' },
            },
        },
        gang = { help = 'Ã‡etenizi Kontrol Edin' },
        setgang = {
            help = 'Bir Oyuncunun Ã‡etesini Ayarla (Sadece Admin)',
            params = {
                id = { name = 'id', help = 'Oyuncu ID\'si' },
                gang = { name = 'gang', help = 'Ã‡ete adÄ±' },
                grade = { name = 'grade', help = 'Ã‡ete seviyesi' },
            },
        },
        ooc = { help = 'OOC Sohbet MesajÄ±' },
        me = {
            help = 'Yerel mesaj gÃ¶nder',
            params = {
                message = { name = 'message', help = 'GÃ¶nderilecek mesaj' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'tr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

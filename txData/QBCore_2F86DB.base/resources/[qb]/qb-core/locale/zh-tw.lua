local Translations = {
    error = {
        not_online                  = 'çŽ©å®¶ä¸åœ¨ç·šä¸Š',
        wrong_format                = 'æ ¼å¼ä¸æ­£ç¢º',
        missing_args                = 'å°šæœªè¼¸å…¥æ‰€æœ‰åƒæ•¸ (x, y, z)',
        missing_args2               = 'å¿…é ˆå¡«å¯«æ‰€æœ‰åƒæ•¸!',
        no_access                   = 'ç„¡æ³•ä½¿ç”¨æ­¤æŒ‡ä»¤',
        company_too_poor            = 'æ‚¨çš„é›‡ä¸»å·²ç ´ç”¢',
        item_not_exist              = 'ç‰©å“ä¸å­˜åœ¨',
        too_heavy                   = 'èƒŒåŒ…å·²æ»¿',
        location_not_exist          = 'ä½ç½®ä¸å­˜åœ¨',
        duplicate_license           = '[QBCORE] - ç™¼ç¾é‡è¤‡çš„ Rockstar æŽˆæ¬Š',
        no_valid_license            = '[QBCORE] - æ‰¾ä¸åˆ°æœ‰æ•ˆçš„ Rockstar æŽˆæ¬Š',
        server_already_open         = 'ä¼ºæœå™¨å·²ç¶“é–‹å•Ÿ',
        server_already_closed       = 'ä¼ºæœå™¨å·²ç¶“é—œé–‰',
        no_permission               = 'æ‚¨æ²’æœ‰æ­¤æ¬Šé™..',
        no_waypoint                 = 'å°šæœªè¨­ç½®å°Žèˆªé»ž',
        tp_error                    = 'å‚³é€æ™‚ç™¼ç”ŸéŒ¯èª¤',
        ban_table_not_found         = '[QBCORE] - ç„¡æ³•åœ¨è³‡æ–™åº«ä¸­æ‰¾åˆ°å°ç¦æ¸…å–®ã€‚è«‹ç¢ºèªæ‚¨å·²æ­£ç¢ºåŒ¯å…¥ SQL æª”æ¡ˆã€‚',
        connecting_database_error   = '[QBCORE] - é€£æŽ¥è³‡æ–™åº«æ™‚ç™¼ç”ŸéŒ¯èª¤ã€‚è«‹ç¢ºä¿ SQL ä¼ºæœå™¨æ­£åœ¨é‹è¡Œ,ä¸” server.cfg æª”æ¡ˆä¸­çš„è¨­å®šæ­£ç¢ºã€‚',
        connecting_database_timeout = '[QBCORE] - è³‡æ–™åº«é€£æŽ¥è¶…æ™‚ã€‚è«‹ç¢ºä¿ SQL ä¼ºæœå™¨æ­£åœ¨é‹è¡Œ,ä¸” server.cfg æª”æ¡ˆä¸­çš„è¨­å®šæ­£ç¢ºã€‚',
    },
    success = {
        server_opened = 'ä¼ºæœå™¨å·²ç¶“é–‹å•Ÿ',
        server_closed = 'ä¼ºæœå™¨å·²ç¶“é—œé–‰',
        teleported_waypoint = 'å‚³é€è‡³å°Žèˆªé»žã€‚',
    },
    info = {
        received_paycheck = 'æ‚¨æ”¶åˆ°äº† $%{value} çš„è–ªæ°´',
        job_info = 'å·¥ä½œ: %{value} | ç­‰ç´š: %{value2} | ä¸Šç­ç‹€æ…‹: %{value3}',
        gang_info = 'å¹«æ´¾: %{value} | ç­‰ç´š: %{value2}',
        on_duty = 'æ‚¨ç¾åœ¨å·²ç¶“ä¸Šç­äº†!',
        off_duty = 'æ‚¨ç¾åœ¨å·²ç¶“ä¸‹ç­äº†!',
        checking_ban = 'ä½ å¥½ %s,æˆ‘å€‘æ­£åœ¨æª¢æŸ¥æ‚¨æ˜¯å¦è¢«å°ç¦',
        join_server = 'æ­¡è¿Ž %s åŠ å…¥ {Server Name}',
        exploit_banned = 'æ‚¨å› ä½œå¼Šè¡Œç‚ºè€Œè¢«å°ç¦ã€‚è«‹æŸ¥çœ‹æˆ‘å€‘çš„ Discord ä»¥ç²å–æ›´å¤šè³‡è¨Š: %{discord}',
        exploit_dropped = 'æ‚¨å› ä½¿ç”¨å¤–æŽ›ç¨‹å¼è€Œè¢«è¸¢å‡ºä¼ºæœå™¨',
    },
    command = {
        tp = {
            help = 'å‚³é€è‡³çŽ©å®¶æˆ–åº§æ¨™ (åƒ…é™ç®¡ç†å“¡)',
            params = {
                x = { name = 'id/x', help = 'çŽ©å®¶ ID æˆ– X åº§æ¨™' },
                y = { name = 'y', help = 'Y åº§æ¨™' },
                z = { name = 'z', help = 'Z åº§æ¨™' },
            },
        },
        tpm = { help = 'å‚³é€è‡³æ¨™è¨˜é»ž (åƒ…é™ç®¡ç†å“¡)' },
        togglepvp = { help = 'åˆ‡æ›ä¼ºæœå™¨ PVP ç‹€æ…‹ (åƒ…é™ç®¡ç†å“¡)' },
        addpermission = {
            help = 'çµ¦äºˆçŽ©å®¶æ¬Šé™ (åƒ…é™æœ€é«˜æ¬Šé™)',
            params = {
                id = { name = 'id', help = 'çŽ©å®¶ ID' },
                permission = { name = 'permission', help = 'æ¬Šé™ç­‰ç´š' },
            },
        },
        removepermission = {
            help = 'ç§»é™¤çŽ©å®¶æ¬Šé™ (åƒ…é™æœ€é«˜æ¬Šé™)',
            params = {
                id = { name = 'id', help = 'çŽ©å®¶ ID' },
                permission = { name = 'permission', help = 'æ¬Šé™ç­‰ç´š' },
            },
        },
        openserver = { help = 'é–‹æ”¾ä¼ºæœå™¨çµ¦æ‰€æœ‰äºº (åƒ…é™ç®¡ç†å“¡)' },
        closeserver = {
            help = 'é—œé–‰ä¼ºæœå™¨çµ¦ç„¡æ¬Šé™è€… (åƒ…é™ç®¡ç†å“¡)',
            params = {
                reason = { name = 'reason', help = 'é—œé–‰åŽŸå›  (é¸å¡«)' },
            },
        },
        car = {
            help = 'ç”Ÿæˆè¼‰å…· (åƒ…é™ç®¡ç†å“¡)',
            params = {
                model = { name = 'model', help = 'è¼‰å…·åž‹è™Ÿåç¨±' },
            },
        },
        dv = { help = 'åˆªé™¤è¼‰å…· (åƒ…é™ç®¡ç†å“¡)' },
        dvall = { help = 'åˆªé™¤æ‰€æœ‰è¼‰å…· (åƒ…é™ç®¡ç†å“¡)' },
        dvp = { help = 'åˆªé™¤æ‰€æœ‰ NPC (åƒ…é™ç®¡ç†å“¡)' },
        dvo = { help = 'åˆªé™¤æ‰€æœ‰ç‰©ä»¶ (åƒ…é™ç®¡ç†å“¡)' },
        givemoney = {
            help = 'çµ¦äºˆçŽ©å®¶é‡‘éŒ¢ (åƒ…é™ç®¡ç†å“¡)',
            params = {
                id = { name = 'id', help = 'çŽ©å®¶ ID' },
                moneytype = { name = 'moneytype', help = 'é‡‘éŒ¢é¡žåž‹ (ç¾é‡‘, éŠ€è¡Œ, åŠ å¯†è²¨å¹£)' },
                amount = { name = 'amount', help = 'é‡‘é¡' },
            },
        },
        setmoney = {
            help = 'è¨­å®šçŽ©å®¶é‡‘éŒ¢æ•¸é‡ (åƒ…é™ç®¡ç†å“¡)',
            params = {
                id = { name = 'id', help = 'çŽ©å®¶ ID' },
                moneytype = { name = 'moneytype', help = 'é‡‘éŒ¢é¡žåž‹ (ç¾é‡‘, éŠ€è¡Œ, åŠ å¯†è²¨å¹£)' },
                amount = { name = 'amount', help = 'é‡‘é¡' },
            },
        },
        job = { help = 'æŸ¥çœ‹ä½ çš„å·¥ä½œ' },
        setjob = {
            help = 'è¨­å®šçŽ©å®¶å·¥ä½œ (åƒ…é™ç®¡ç†å“¡)',
            params = {
                id = { name = 'id', help = 'çŽ©å®¶ ID' },
                job = { name = 'job', help = 'å·¥ä½œåç¨±' },
                grade = { name = 'grade', help = 'å·¥ä½œç­‰ç´š' },
            },
        },
        gang = { help = 'æŸ¥çœ‹ä½ æ‰€åœ¨çš„å¹«æ´¾' },
        setgang = {
            help = 'è¨­å®šçŽ©å®¶å¹«æ´¾ (åƒ…é™ç®¡ç†å“¡)',
            params = {
                id = { name = 'id', help = 'çŽ©å®¶ ID' },
                gang = { name = 'gang', help = 'å¹«æ´¾åç¨±' },
                grade = { name = 'grade', help = 'å¹«æ´¾ç­‰ç´š' },
            },
        },
        ooc = { help = 'OOC èŠå¤©è¨Šæ¯' },
        me = {
            help = 'é¡¯ç¤ºæœ¬åœ°è¨Šæ¯',
            params = {
                message = { name = 'message', help = 'è¦ç™¼é€çš„è¨Šæ¯' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'zh-tw' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

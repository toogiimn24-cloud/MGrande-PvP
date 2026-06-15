local Translations = {
    error = {
        not_online = 'Jogador nÃ£o estÃ¡ online',
        wrong_format = 'Formato incorreto',
        missing_args = 'Nem todos os argumentos foram inseridos (x, y, z)',
        missing_args2 = 'Todos os argumentos devem ser preenchidos!',
        no_access = 'Sem acesso a este comando',
        company_too_poor = 'Seu empresa estÃ¡ quebrada',
        item_not_exist = 'O item nÃ£o existe',
        too_heavy = 'IventÃ¡rio cheio',
        location_not_exist = 'O local nÃ£o existe',
        duplicate_license = 'LicenÃ§a da Rockstar duplicada encontrada',
        no_valid_license  = 'Nenhuma licenÃ§a da Rockstar vÃ¡lida encontrada',
        server_already_open = 'O servidor jÃ¡ estÃ¡ aberto',
        server_already_closed = 'O servidor jÃ¡ estÃ¡ fechado',
        no_permission = 'VocÃª nÃ£o tem permissÃµes para isso..',
        no_waypoint = 'Nenhum local definido.',
        tp_error = 'Erro ao teletransportar.',
        connecting_database_error = 'Ocorreu um erro de banco de dados ao conectar-se ao servidor. (O servidor SQL estÃ¡ ativado?)',
        connecting_database_timeout = 'A conexÃ£o com o banco de dados expirou. (O servidor SQL estÃ¡ ativado?)',
    },
    success = {
        server_opened = 'O servidor foi aberto',
        server_closed = 'O servidor foi fechado',
        teleported_waypoint = 'Teleportado para local marcado.',
    },
    info = {
        received_paycheck = 'VocÃª recebeu seu salÃ¡rio de $%{value}',
        job_info = 'Trabalho: %{value} | Grau: %{value2} | ServiÃ§o: %{value3}',
        gang_info = 'Gangue: %{value} | Grau: %{value}',
        on_duty = 'VocÃª agora estÃ¡ de plantÃ£o!',
        off_duty = 'VocÃª agora estÃ¡ de folga!',
        checking_ban = 'OlÃ¡ %s. Estamos verificando se vocÃª foi banido.',
        join_server = 'Bem-vindo %s a {Nome do servidor}.',
        exploit_banned = 'VocÃª foi banido por trapacear. Confira nosso Discord para mais informaÃ§Ãµes: %{discord}',
        exploit_dropped = 'VocÃª foi expulso por exploraÃ§Ã£o',
    },
    command = {
        tp = {
            help = 'TP Para Jogador ou Coordenadas (Somente administrador)',
            params = {
                x = { name = 'id/x', help = 'ID do jogador ou posiÃ§Ã£o X'},
                y = { name = 'y', help = 'posiÃ§Ã£o Y'},
                z = { name = 'z', help = 'posiÃ§Ã£o Z'},
            },
        },
        tpm = { help = 'TP Para Marcador (Somente administrador)' },
        togglepvp = { help = 'Alternar PVP no servidor (Somente administrador)' },
        addpermission = {
            help = 'DÃª permissÃµes ao jogador (SÃ³ Deus)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                permission = { name = 'permissÃ£o', help = 'NÃ­vel de permissÃ£o' },
            },
        },
        removepermission = {
            help = 'Remover permissÃµes do jogador (SÃ³ Deus)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                permission = { name = 'permissÃ£o', help = 'NÃ­vel de permissÃ£o' },
            },
        },
        openserver = { help = 'Abra o servidor para todos (somente administrador)' },
        closeserver = {
            help = 'Feche o servidor para pessoas sem permissÃµes (somente administrador)',
            params = {
                reason = { name = 'motivo', help = 'Motivo do fechamento (opcional)' },
            },
        },
        car = {
            help = 'Criar VeÃ­culo (somente administrador)',
            params = {
                model = { name = 'modelo', help = 'Modelo do veÃ­culo' },
            },
        },
        dv = { help = 'Excluir veÃ­culo (somente administrador)' },
        givemoney = {
            help = 'Dar dinheiro a um jogador (somente administrador)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                moneytype = { name = 'tipo_dinheiro', help = 'Tipo de dinheiro (cash, bank, crypto)' },
                amount = { name = 'quantia', help = 'Quantia de dinheiro' },
            },
        },
        setmoney = {
            help = 'Definir a quantidade de dinheiro do jogador (somente administrador)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                moneytype = { name = 'tipo_dinheiro', help = 'Tipo de dinheiro (cash, bank, crypto)' },
                amount = { name = 'quantia', help = 'Quantia de dinheiro' },
            },
        },
        job = { help = 'Verifique seu trabalho' },
        setjob = {
            help = 'Definir o trabalho do jogador (somente administrador)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                job = { name = 'trabalho', help = 'Nome do trabalho' },
                grade = { name = 'grau', help = 'Grau do trabalho' },
            },
        },
        gang = { help = 'Verifique sua gangue' },
        setgang = {
            help = 'Definir a gangue do jogador (somente administrador)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                gang = { name = 'gangue', help = 'Nome da gangue' },
                grade = { name = 'grau', help = 'Grau da gangue' },
            },
        },
        ooc = { help = 'Mensagem de bate-papo OOC' },
        me = {
            help = 'Mostrar mensagem local',
            params = {
                message = { name = 'mensagem', help = 'Mensagem para enviar' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

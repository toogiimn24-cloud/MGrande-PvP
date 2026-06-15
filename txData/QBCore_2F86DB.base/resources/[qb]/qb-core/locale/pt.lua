local Translations = {
    error = {
        not_online = 'O jogador nÃ£o estÃ¡ online',
        wrong_format = 'Formato invÃ¡lido',
        missing_args = 'NÃ£o introduziste todos os argumentos (x, y, z)',
        missing_args2 = 'Todos os argumentos tÃªm de ser preenchidos!',
        no_access = 'NÃ£o tens acesso a este comando',
        company_too_poor = 'A tua empresa estÃ¡ falida',
        item_not_exist = 'O item nÃ£o existe',
        too_heavy = 'InventÃ¡rio cheio',
        location_not_exist = 'LocalizaÃ§Ã£o nÃ£o existe',
        duplicate_license = 'LicenÃ§a Rockstar duplicada',
        no_valid_license  = 'LicenÃ§a Rockstar nÃ£o encontrada',
        server_already_open = 'O Servidor jÃ¡ se encontra aberto',
        server_already_closed = 'O Servidor jÃ¡ se encontra fechado',
        no_permission = 'NÃ£o tem permissÃµes para isto',
        no_waypoint = 'NÃ£o colocou nenhum waypoint',
        tp_error = 'Erro ao teleportar',
        connecting_database_error = 'Um erro na base de dados ocorreu enquanto se conecatava ao servidor. (SQL Server Ligado?)',
        connecting_database_timeout = 'Falhou a ligaÃ§Ã£o Ã  base de dados. (SQL server Ligado?)',
    },
    success = {
        server_opened = 'O Servidor abriu',
        server_closed = 'O Servidor fechou',
        teleported_waypoint = 'Foste teletransportado para o waypoint.',
    },
    info = {
        received_paycheck = 'Recebeste o pagamento de %{value}â‚¬',
        job_info = 'Emprego: %{value} | Grau: %{value2} | ServiÃ§o: %{value3}',
        gang_info = 'Gang: %{value} | Grau: %{value2}',
        on_duty = 'Agora estÃ¡s de serviÃ§o!',
        off_duty = 'Agora estÃ¡s fora de serviÃ§o!',
        checking_ban = 'OlÃ¡ %s. Estamos a verificar se estÃ¡s banido.',
        join_server = 'Bem vindo %s ao {Server Name}.',
        exploit_banned = 'Foste banido por cheats. Para mais informaÃ§Ãµes visita o nosso discord: %{discord}',
        exploit_dropped = 'Foste expulso por cheats!',
    },
    command = {
        tp = {
            help = 'TP para um jogador ou coordenadas (Apenas Admin)',
            params = {
                x = { name = 'id/x', help = 'ID do jogador ou posiÃ§Ã£o X'},
                y = { name = 'y', help = 'PosiÃ§Ã£o Y'},
                z = { name = 'z', help = 'PosiÃ§Ã£o Z'},
            },
        },
        tpm = { help = 'TP para Marcador (Apenas Admin)' },
        togglepvp = { help = 'Ligar /Desligar PVP no servidor (Apenas Admin)' },
        addpermission = {
            help = 'Dar PermissÃµes a jogador (Apenas God)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                permission = { name = 'permission', help = 'Nivel de permissÃ£o' },
            },
        },
        removepermission = {
            help = 'Remover permissÃ£o de jogador (Apenas God)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                permission = { name = 'permission', help = 'Nivel de permissÃ£o' },
            },
        },
        openserver = { help = 'Abrir o Servidor para todos (Apenas Admin)' },
        closeserver = {
            help = 'Fechar o servidor para todos exceto Admins (Apenas Admin)',
            params = {
                reason = { name = 'reason', help = 'RazÃ£o para fechar(opcional)' },
            },
        },
        car = {
            help = 'Spawnar VeÃ­culo (Apenas Admin)',
            params = {
                model = { name = 'model', help = 'Modelo do veÃ­culo' },
            },
        },
        dv = { help = 'Apagar VeÃ­culo (Apenas Admin)' },
        givemoney = {
            help = 'Dar dinheiro a jogador (Apenas Admin)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                moneytype = { name = 'moneytype', help = 'Tipo (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Quantidade de dinheiro' },
            },
        },
        setmoney = {
            help = 'Definir a quantia de dinheiro do jogador (Apenas Admin)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                moneytype = { name = 'moneytype', help = 'Tipo(cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Quantidade de dinheiro' },
            },
        },
        job = { help = 'Ver o teu trabalho' },
        setjob = {
            help = 'Definir o trabalho de 1 jogador (Apenas Admin)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                job = { name = 'job', help = 'Nome do trabalho' },
                grade = { name = 'grade', help = 'Nivel do trabalho' },
            },
        },
        gang = { help = 'Ver o teu Gang' },
        setgang = {
            help = 'Definir o Gang de um jogador (Apenas Admin)',
            params = {
                id = { name = 'id', help = 'ID do jogador' },
                gang = { name = 'gang', help = 'Nome do Gang' },
                grade = { name = 'grade', help = 'NÃ­vel/ PosiÃ§Ã£o no Gang' },
            },
        },
        ooc = { help = 'Mensagem Chat em OOC' },
        me = {
            help = 'Mostrar Mensagem local',
            params = {
                message = { name = 'message', help = 'Menssagem  a enviar' }
            },
        },
    },
}
if GetConvar('qb_locale', 'en') == 'pt' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

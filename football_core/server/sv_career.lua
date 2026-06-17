-- football_core/server/sv_career.lua

local ESX = exports['es_extended']:getSharedObject()

-- Valores de configuração do roleplay
local CLUB_CREATION_COST = 50000
local WEEK_IN_MS = 7 * 24 * 60 * 60 * 1000

Config = Config or {}
Config.Debug = Config.Debug or true 

---
--- Utils
---

local function debug_log(msg)
    if Config.Debug then
        print('[Football DEBUG] ' .. msg)
    end
end

local function error_log(msg)
    print('[Football ERROR] ' .. tostring(msg))
end

---
--- Carreira e Gestão de Clubes
---

-- Cria um clube novo no banco e debita a grana do criador. Bloqueia pra um cara não criar 300 times e floodar o servidor.
-- @param president_id (number) ID de sessão do jogador (source)
-- @param club_name (string) Nome do time
-- @return (number|nil) Retorna o ID do clube gerado no banco ou nil se der ruim
function create_club(president_id, club_name)
    -- 1. Entrada / Nil checks
    if not president_id or not club_name then 
        error_log("create_club: Faltou id do presidente ou nome do clube.")
        return nil 
    end

    local xPlayer = ESX.GetPlayerFromId(president_id)
    if not xPlayer then return nil end

    local citizen_id = xPlayer.identifier

    -- 2. Lógica principal
    -- Impede de criar mais de um time
    local existing_club = MySQL.scalar.await('SELECT id FROM football_clubs WHERE president_id = ?', {citizen_id})
    if existing_club then
        error_log("create_club: O jogador " .. citizen_id .. " já é dono de um clube.")
        return nil
    end

    -- Confere se o cara tem a grana
    if xPlayer.getMoney() < CLUB_CREATION_COST and xPlayer.getAccount('bank').money < CLUB_CREATION_COST then
        error_log("create_club: Sem dinheiro suficiente.")
        return nil
    end

    -- Cobra da carteira ou do banco
    if xPlayer.getMoney() >= CLUB_CREATION_COST then
        xPlayer.removeMoney(CLUB_CREATION_COST)
    else
        xPlayer.removeAccountMoney('bank', CLUB_CREATION_COST)
    end

    local insert_id = MySQL.insert.await('INSERT INTO football_clubs (president_id, name, balance) VALUES (?, ?, ?)', {
        citizen_id, club_name, 0
    })

    debug_log("Criou o clube " .. club_name .. " (ID: " .. tostring(insert_id) .. ")")

    -- 3. Retorno
    return insert_id
end

-- Puxa as infos do clube e já traz a lista de jogadores ativos junto pra não ter que fazer dois selects separados na UI.
-- @param club_id (number) ID do clube
-- @return (table|nil) Retorna a tabela do clube com o array do roster
function get_club(club_id)
    -- 1. Entrada / Nil checks
    if not club_id then return nil end

    -- 2. Lógica principal
    local club_data = MySQL.single.await('SELECT * FROM football_clubs WHERE id = ?', {club_id})
    if not club_data then return nil end

    -- Pega quem tá no time hoje
    local roster = MySQL.query.await('SELECT citizen_id, salary FROM football_contracts WHERE club_id = ? AND status = ?', {club_id, 'active'})
    club_data.roster = roster

    -- 3. Retorno
    return club_data
end

-- Vê em qual time o cara tá jogando pra liberar as opções de Vestiário/CT pra ele.
-- @param citizen_id (string) O identifier do jogador
-- @return (number|nil) Retorna o ID do clube ou nil se tiver sem time
function get_player_club(citizen_id)
    -- 1. Entrada / Nil checks
    if not citizen_id then return nil end

    -- 2. Lógica principal
    local club_id = MySQL.scalar.await('SELECT club_id FROM football_contracts WHERE citizen_id = ? AND status = ?', {citizen_id, 'active'})

    -- 3. Retorno
    return club_id
end

-- Registra a oferta no banco como pendente pra não forçar o cara a entrar no time sem querer.
-- @param club_id (number) ID do time que tá chamando
-- @param target_citizen_id (string) Identifier do alvo
-- @param salary (number) Salário por semana
-- @param duration_weeks (number) Quantas semanas dura
-- @return (boolean) Retorna true se enviou a proposta de boa
function offer_contract(club_id, target_citizen_id, salary, duration_weeks)
    -- 1. Entrada / Nil checks
    if not club_id or not target_citizen_id or not salary or not duration_weeks then return false end

    -- 2. Lógica principal
    local has_active = MySQL.scalar.await('SELECT id FROM football_contracts WHERE citizen_id = ? AND status = ?', {target_citizen_id, 'active'})
    if has_active then
        error_log("offer_contract: " .. target_citizen_id .. " já tá em outro time.")
        return false
    end

    local contract_id = MySQL.insert.await('INSERT INTO football_contracts (club_id, citizen_id, salary, duration_weeks, status) VALUES (?, ?, ?, ?, ?)', {
        club_id, target_citizen_id, salary, duration_weeks, 'offered'
    })

    -- Se o cara tiver online, já apita na tela dele
    local xTarget = ESX.GetPlayerFromIdentifier(target_citizen_id)
    if xTarget then
        TriggerClientEvent('football:contractOffered', xTarget.source, contract_id, club_id, salary)
    end

    debug_log("Mandou proposta (ID " .. contract_id .. ") pro " .. target_citizen_id)

    -- 3. Retorno
    return true
end

-- Oficializa o contrato e atualiza o time do cara lá na tabela users do ESX também.
-- @param citizen_id (string) O cara que aceitou
-- @param contract_id (number) ID da proposta
-- @return (boolean) 
function accept_contract(citizen_id, contract_id)
    -- 1. Entrada / Nil checks
    if not citizen_id or not contract_id then return false end

    -- 2. Lógica principal
    local rows_changed = MySQL.update.await('UPDATE football_contracts SET status = ? WHERE id = ? AND citizen_id = ? AND status = ?', {
        'active', contract_id, citizen_id, 'offered'
    })

    if rows_changed > 0 then
        -- Já que ele aceitou, vincula o club_id na tabela de usuários tbm
        local club_id = MySQL.scalar.await('SELECT club_id FROM football_contracts WHERE id = ?', {contract_id})
        MySQL.update.await('UPDATE users SET club_id = ? WHERE identifier = ?', {club_id, citizen_id})
        debug_log("Jogador " .. citizen_id .. " aceitou o contrato " .. contract_id)
        return true
    end

    -- 3. Retorno
    return false
end

-- Só ignora a proposta pra sumir da tela do jogador, sem deletar a linha do banco por via das dúvidas.
-- @param citizen_id (string) Identifier
-- @param contract_id (number) ID do contrato
-- @return (boolean)
function reject_contract(citizen_id, contract_id)
    -- 1. Entrada / Nil checks
    if not citizen_id or not contract_id then return false end

    -- 2. Lógica principal
    MySQL.update.await('UPDATE football_contracts SET status = ? WHERE id = ? AND citizen_id = ?', {
        'rejected', contract_id, citizen_id
    })

    -- 3. Retorno
    return true
end

-- Demite o jogador. Mantém o registro guardado como 'terminated' pra ter histórico de onde ele jogou.
-- @param citizen_id (string) Identifier do jogador demitido
-- @return (boolean)
function terminate_contract(citizen_id)
    -- 1. Entrada / Nil checks
    if not citizen_id then return false end

    -- 2. Lógica principal
    MySQL.update.await('UPDATE football_contracts SET status = ? WHERE citizen_id = ? AND status = ?', {
        'terminated', citizen_id, 'active'
    })
    
    -- Limpa o clube dele na base de users
    MySQL.update.await('UPDATE users SET club_id = NULL WHERE identifier = ?', {citizen_id})
    debug_log("Contrato finalizado do jogador: " .. citizen_id)

    -- 3. Retorno
    return true
end

-- Roda os salários de todo mundo. Desconta do saldo do clube e pinga na conta do jogador via ESX.
-- @param nenhum
-- @return (void)
function process_weekly_salaries()
    -- 1. Entrada / Nil checks
    debug_log("Iniciando folha de pagamento da semana...")

    -- 2. Lógica principal
    local active_contracts = MySQL.query.await('SELECT id, club_id, citizen_id, salary FROM football_contracts WHERE status = ?', {'active'})
    if not active_contracts then return end

    for _, contract in ipairs(active_contracts) do
        local club_balance = MySQL.scalar.await('SELECT balance FROM football_clubs WHERE id = ?', {contract.club_id})
        
        -- Só paga se o time tiver grana em caixa
        if club_balance and club_balance >= contract.salary then
            -- Tira do time
            MySQL.update.await('UPDATE football_clubs SET balance = balance - ? WHERE id = ?', {contract.salary, contract.club_id})
            
            -- Paga o jogador se ele estiver online
            local xPlayer = ESX.GetPlayerFromIdentifier(contract.citizen_id)
            if xPlayer then
                xPlayer.addAccountMoney('bank', contract.salary)
                TriggerClientEvent('esx:showNotification', xPlayer.source, "Caiu o salário do time: $" .. contract.salary)
            else
                -- Nota: Pra pagar o cara offline precisaria alterar direto na JSON/tabela account do ESX.
                error_log("process_weekly_salaries: Jogador " .. contract.citizen_id .. " offline. Precisa tratar o pagamento offline no DB depois.")
            end
        else
            error_log("process_weekly_salaries: Time " .. contract.club_id .. " não tem grana pro contrato " .. contract.id)
        end
    end

    -- 3. Retorno
end

-- Configura o loop infinito de pagamentos que não vai travar a thread principal do server com Wait().
-- @param nenhum
-- @return (void)
function schedule_salary_job()
    -- 1. Entrada / Nil checks 
    
    -- 2. Lógica principal
    SetTimeout(WEEK_IN_MS, function()
        process_weekly_salaries()
        schedule_salary_job() -- Chama ela de novo pra rodar na próxima semana
    end)
    
    debug_log("Timer de pagamento de salário agendado.")

    -- 3. Retorno
end

-- Salva tudo que rolou no jogo (gols, passes) e já gera o rating pra usar no painel.
-- @param match_id (number) ID da partida
-- @param stats_array (table) Lista de stats dos jogadores
-- @return (boolean)
function save_match_stats(match_id, stats_array)
    -- 1. Entrada / Nil checks
    if not match_id or type(stats_array) ~= 'table' then return false end

    -- 2. Lógica principal
    for _, stats in ipairs(stats_array) do
        -- Pesos pra tentar balancear nota de zagueiro com a de atacante
        local rating = (stats.goals * 10) + (stats.assists * 7) + (stats.passes * 0.5) + (stats.tackles * 3)

        MySQL.insert.await('INSERT INTO football_stats (match_id, citizen_id, goals, assists, passes, tackles, rating) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            match_id, stats.citizen_id, stats.goals, stats.assists, stats.passes, stats.tackles, rating
        })
    end
    debug_log("Stats salvos da partida " .. tostring(match_id))

    -- 3. Retorno
    return true
end

-- Pega o montante das estatísticas do cara pra montar o perfil dele no menu.
-- @param citizen_id (string) Identifier alvo
-- @return (table|nil)
function get_player_stats(citizen_id)
    -- 1. Entrada / Nil checks
    if not citizen_id then return nil end

    -- 2. Lógica principal
    local result = MySQL.single.await([[
        SELECT 
            SUM(goals) as total_goals, 
            SUM(assists) as total_assists, 
            SUM(passes) as total_passes, 
            SUM(tackles) as total_tackles,
            AVG(rating) as average_rating
        FROM football_stats 
        WHERE citizen_id = ?
    ]], {citizen_id})

    -- 3. Retorno
    return result
end

-- Lista os artilheiros do servidor pra montar o ranking.
-- @param limit (number) Limita a lista (ex: Top 10)
-- @return (table|nil) 
function get_top_scorers(limit)
    -- 1. Entrada / Nil checks
    limit = limit or 10

    -- 2. Lógica principal
    local result = MySQL.query.await([[
        SELECT citizen_id, SUM(goals) as total_goals 
        FROM football_stats 
        GROUP BY citizen_id 
        ORDER BY total_goals DESC 
        LIMIT ?
    ]], {limit})

    -- 3. Retorno
    return result
end

---
--- Eventos / Handlers
---

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    debug_log("Carregando o core de Carreira e Stats do Futebol...")
    schedule_salary_job()
end)

-- Comandos pra testar/administrar as carreiras
ESX.RegisterCommand('criarclube', 'admin', function(xPlayer, args, showError)
    if not args.nome then 
        showError("Manda assim: /criarclube [nome]")
        return 
    end
    create_club(xPlayer.source, args.nome)
end, true, {help = 'Cria um clube de futebol novo', validate = true, arguments = {
    {name = 'nome', help = 'Nome do time', type = 'string'}
}})

ESX.RegisterCommand('ofertarcontrato', 'admin', function(xPlayer, args, showError)
    local club_id = get_player_club(xPlayer.identifier)
    if not club_id then
        showError("Você não tá num clube pra poder fazer isso.")
        return
    end

    local tPlayer = ESX.GetPlayerFromId(args.id)
    if not tPlayer then
        showError("Não achei esse jogador online.")
        return
    end

    offer_contract(club_id, tPlayer.identifier, args.salario, args.semanas)
end, true, {help = 'Mandar proposta de contrato pra alguém', validate = true, arguments = {
    {name = 'id', help = 'ID de sessão (source)', type = 'number'},
    {name = 'salario', help = 'Salário por semana', type = 'number'},
    {name = 'semanas', help = 'Duração do contrato em semanas', type = 'number'}
}})

ESX.RegisterCommand('statsjo', 'admin', function(xPlayer, args, showError)
    local tPlayer = ESX.GetPlayerFromId(args.id)
    if not tPlayer then
        showError("Jogador não encontrado.")
        return
    end

    local stats = get_player_stats(tPlayer.identifier)
    if stats and stats.total_goals then
        xPlayer.showNotification("Gols: " .. stats.total_goals .. " | Assists: " .. stats.total_assists)
    else
        xPlayer.showNotification("Esse cara não tem nenhuma stat registrada.")
    end
end, true, {help = 'Ver stats rápidas de um jogador', validate = true, arguments = {
    {name = 'id', help = 'ID de sessão (source)', type = 'number'}
}})

-- Recebendo ações lá do client
RegisterNetEvent('football:acceptContract')
AddEventHandler('football:acceptContract', function(contract_id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local success = accept_contract(xPlayer.identifier, contract_id)
    if success then
        TriggerClientEvent('esx:showNotification', src, "Contrato assinado, parabéns!")
    else
        TriggerClientEvent('esx:showNotification', src, "Deu erro ao assinar o contrato.")
    end
end)

RegisterNetEvent('football:rejectContract')
AddEventHandler('football:rejectContract', function(contract_id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    reject_contract(xPlayer.identifier, contract_id)
    TriggerClientEvent('esx:showNotification', src, "Você recusou a proposta.")
end)

RegisterNetEvent('football:getMyStats')
AddEventHandler('football:getMyStats', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local stats = get_player_stats(xPlayer.identifier)
    TriggerClientEvent('football:receiveMyStats', src, stats)
end)

RegisterNetEvent('football:getTopScorers')
AddEventHandler('football:getTopScorers', function(limit)
    local src = source
    local limit_val = tonumber(limit) or 10

    local tops = get_top_scorers(limit_val)
    TriggerClientEvent('football:receiveTopScorers', src, tops)
end)
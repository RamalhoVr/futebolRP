function CreateTables()
    local queries = {
        {
            name = "football_clubs",
            query = [[
                CREATE TABLE IF NOT EXISTS football_clubs (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    owner_id VARCHAR(100),
                    stadium_name VARCHAR(100),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ]]
        },
        {
            name = "football_players",
            query = [[
                CREATE TABLE IF NOT EXISTS football_players (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    identifier VARCHAR(100) NOT NULL UNIQUE,
                    name VARCHAR(100) NOT NULL,
                    overall INT DEFAULT 50,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ]]
        },
        {
            name = "football_contracts",
            query = [[
                CREATE TABLE IF NOT EXISTS football_contracts (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    player_id INT NOT NULL,
                    club_id INT NOT NULL,
                    salary INT DEFAULT 0,
                    signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (player_id) REFERENCES football_players(id),
                    FOREIGN KEY (club_id) REFERENCES football_clubs(id)
                )
            ]]
        },
        {
            name = "football_matches",
            query = [[
                CREATE TABLE IF NOT EXISTS football_matches (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    home_club_id INT NOT NULL,
                    away_club_id INT NOT NULL,
                    home_score INT DEFAULT 0,
                    away_score INT DEFAULT 0,
                    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ]]
        },
        {
            name = "football_stats",
            query = [[
                CREATE TABLE IF NOT EXISTS football_stats (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    match_id INT NOT NULL,
                    player_id INT NOT NULL,
                    goals INT DEFAULT 0,
                    assists INT DEFAULT 0,
                    FOREIGN KEY (match_id) REFERENCES football_matches(id),
                    FOREIGN KEY (player_id) REFERENCES football_players(id)
                )
            ]]
        }
    }

    for _, tableData in ipairs(queries) do
        MySQL.query(tableData.query, {}, function(result)
            if result then
                print('[Football RP] Tabela ' .. tableData.name .. ' criada/verificada com sucesso.')
            else
                print('^1[ERRO] Falha ao criar tabela ' .. tableData.name .. '^0')
            end
        end)
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('[Football RP] Iniciando verificação do banco de dados...')
    CreateTables()
end)

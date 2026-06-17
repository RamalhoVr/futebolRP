# Convenções de Código — Football RP

## Nomenclatura Lua
- Variáveis e funções: snake_case → get_ball_state, active_matches
- Tabelas principais: PascalCase → Ball, Match, PlayerState  
- Constantes: UPPER_CASE → MAX_PLAYERS
- Prefixo de arquivo define escopo: sv_ = server, cl_ = client, sh_ = shared

## Eventos FiveM
- Formato: 'football:nomeEmCamelCase'
- Server → Client: TriggerClientEvent('football:evento', playerId, dados)
- Client → Server: TriggerServerEvent('football:evento', dados)

## Estrutura obrigatória de função
-- Descrição do que faz, em português
-- @param nome (tipo) descrição
-- @return (tipo) descrição
function nome_da_funcao(params)
  -- 1. validação de entrada (verificar nil sempre)
  if not params then return end
  -- 2. lógica principal
  -- 3. return
end

## Error handling
- Sempre checar nil: if not match then return end
- Erros: print('[Football ERROR] ' .. tostring(err))
- Debug (só se Config.Debug): print('[Football DEBUG] ' .. msg)

## Comentários
- Sempre em português
- Explicar o PORQUÊ da decisão, não o que a linha faz
- Exemplo ruim: -- incrementa contador
- Exemplo bom: -- usa índice separado pra evitar iterar todos os jogadores a cada tick
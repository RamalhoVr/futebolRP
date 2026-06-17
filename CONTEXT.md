# Football RP — FiveM — Contexto do Projeto

## Estrutura de arquivos
football_core/
  fxmanifest.lua          ← registro do recurso no FiveM
  shared/config.lua       ← configurações globais
  server/
    sv_main.lua           ← inicialização e eventos globais
    sv_database.lua       ← criação de tabelas e queries MySQL
    sv_ball_physics.lua   ← física da bola, loop 16ms server-side
    sv_player_state.lua   ← state machine por jogador
    sv_match_manager.lua  ← orquestrador de partidas
    sv_referee.lua        ← árbitro: gols, laterais, escanteios
    sv_career.lua         ← clubes, contratos, salários
  client/
    cl_main.lua                ← inicialização cliente
    cl_input_controller.lua    ← substitui input padrão do GTA
    cl_movement_controller.lua ← movimento esportivo com stamina
    cl_camera_controller.lua   ← câmera broadcast estilo FIFA
    cl_hud.lua                 ← controla HUD via NUI
  html/
    hud.html / hud.css / hud.js ← interface HUD em HTML

## Stack técnica
- Framework RP: ESX
- Database: oxmysql
- FiveM: versão recente (artifacts)
- Linguagem: Lua (server e client)

## Convenções de eventos
- Todos os eventos: prefixo 'football:'
- Exemplo: 'football:matchStart', 'football:ballUpdate'

## Funções implementadas
[vazio — preencher conforme criamos]

## Decisões tomadas
- Routing bucket base para partidas: Config.MatchRoutingBucketBase = 1000
- Bola é entidade matemática server-side, não prop do GTA
- Câmera é broadcast (lateral ao campo), não câmera do GTA
- Stamina afeta velocidade e precisão em faixas: 100-60%, 60-40%, 40-20%, <20%

## Estado atual
Fase 0 — estrutura de pastas criada. Nenhum arquivo tem conteúdo ainda.
Próximo: gerar fxmanifest.lua e config.lua
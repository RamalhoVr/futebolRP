# Copilot Instructions for Football RP

This document contains conventions and architecture guidelines for the Football RP FiveM resource. It incorporates rules from `CONVENTIONS.md` and `CONTEXT.md`.

## High-Level Architecture

This is a FiveM roleplay resource using **ESX** and **oxmysql**.
The codebase is divided into server, client, and shared environments:

- **Server-side (`server/sv_*.lua`)**: Handles the core logic, including a 16ms tick loop for mathematical ball physics (`sv_ball_physics.lua`), match orchestration via routing buckets (`sv_match_manager.lua`), and player state machines. The ball is a mathematical entity on the server, not a GTA prop.
- **Client-side (`client/cl_*.lua`)**: Responsible for overriding standard GTA inputs (`cl_input_controller.lua`), implementing sports movement with stamina tracking, and rendering a FIFA-style broadcast camera (`cl_camera_controller.lua`).
- **UI (`html/`)**: Uses HTML/CSS/JS for the player HUD (`cl_hud.lua` communicates via NUI).
- **Match Isolation**: Matches are isolated using routing buckets (starting at `Config.MatchRoutingBucketBase = 1000`).

## Key Conventions

### Naming & Style
- **Variables and Functions**: Use `snake_case` (e.g., `get_ball_state`, `active_matches`).
- **Main Tables/Classes**: Use `PascalCase` (e.g., `Ball`, `Match`, `PlayerState`).
- **Constants**: Use `UPPER_CASE` (e.g., `MAX_PLAYERS`).
- **File Prefixes**: `sv_` for server, `cl_` for client, `sh_` for shared.

### FiveM Events
- All events must be prefixed with `football:`.
- The event name itself should be in `camelCase` (e.g., `football:matchStart`, `football:ballUpdate`).
- **Client to Server**: `TriggerServerEvent('football:eventName', data)`
- **Server to Client**: `TriggerClientEvent('football:eventName', playerId, data)`

### Function Structure & Documentation
Always include standard Lua comments in Portuguese explaining the function and its parameters:

```lua
-- Descrição do que faz, em português (explaining the WHY, not the WHAT)
-- @param nome (tipo) descrição
-- @return (tipo) descrição
function nome_da_funcao(params)
    -- 1. Entrada / Nil checks
    if not params then return end
    
    -- 2. Lógica principal
    
    -- 3. Retorno
end
```

### Error Handling & Debugging
- **Strict Nil Checks**: Always validate data to prevent runtime errors (e.g., `if not match then return end`).
- **Error Logging**: Use `print('[Football ERROR] ' .. tostring(err))` for errors.
- **Debug Logging**: Wrap debug prints in a config check:
  ```lua
  if Config.Debug then
      print('[Football DEBUG] ' .. msg)
  end
  ```
- Write comments in **Portuguese** explaining the *why*, not the *what*.
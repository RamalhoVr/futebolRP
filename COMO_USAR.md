# Como usar o Copilot CLI neste projeto

## Todo prompt começa assim:
"Leia o copilot-instructions.md. Não pergunte nada, não confirme, apenas crie os arquivos."

## Se travar num bug:
"Não gere código novo ainda. Explique em português o que está causando o bug.
Depois que eu confirmar, aí você corrige."

## Ordem das fases:
Fase 0 ✓ → Fase 1.1 (sv_ball_physics) → 1.2 (cl_input_controller)
→ 1.3 (cl_movement_controller) → 1.4 (cl_camera_controller)
→ 1.5 (sv_match_manager) → TESTAR → Fase 2...

## Após cada módulo pronto, atualizar CONTEXT.md:
- Adicionar as funções criadas na seção "Funções implementadas"
- Atualizar "Estado atual" com o que foi feito e o próximo passo

## Prompt padrão para cada novo módulo:
"Leia copilot-instructions.md e CONTEXT.md.
Crie [nome do arquivo] com os seguintes requisitos:
[colar os requisitos do documento Football_RP_FiveM_Plano_Mestre.docx]
Não pergunte nada. Crie direto no disco."

## Se o CLI fechar, para reabrir:
cd E:\futebolRP
copilot

## Para trocar modelo se necessário:
/model → escolher Gemini 3.1 Pro
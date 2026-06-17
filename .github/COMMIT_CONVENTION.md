REGRAS DE COMMIT PROFISSIONAL:

1. Formato obrigatório:
<tipo>(<escopo>): <descrição curta em português, imperativo, sem ponto final>

<corpo opcional — explica o PORQUÊ, não o que foi feito>

<rodapé opcional — breaking changes, issues fechadas>

2. Tipos permitidos:
- feat: nova funcionalidade
- fix: correção de bug
- refactor: melhoria interna sem mudar comportamento externo
- perf: melhoria de performance
- chore: configuração, dependências, arquivos de projeto
- docs: documentação
- test: testes

3. Escopos do projeto:
- ball-physics, match-manager, referee, career, competition
- input, movement, camera, hud
- database, config, manifest

4. Exemplos CORRETOS (tom humano, decisão técnica clara):
feat(ball-physics): adiciona integração de Euler com drag e spin lateral
fix(camera): corrige lerp causando jitter quando bola sai do campo
refactor(match-manager): separa criação de bucket em função dedicada
perf(ball-physics): reduz alocações no tick loop usando tabela reutilizável
fix(referee): corrige detecção de gol quando bola atravessa poste em alta velocidade
feat(input): implementa detecção de sequência para pedalada e elástico
chore(config): aumenta StaminaSprintCost após testes de balanceamento

5. Exemplos ERRADOS (parecem IA ou amador):
❌ "Added ball physics system"
❌ "update files"  
❌ "feat: implementa o sistema completo de física da bola com todas as funcionalidades"
❌ "fix: corrige bug"
❌ "WIP"
❌ "feat: cria sv_ball_physics.lua"

6. Regras do corpo do commit (quando usar):
- Usar quando a decisão não é óbvia
- Explicar trade-offs feitos
- Máximo 72 caracteres por linha
- Exemplo:
  feat(ball-physics): usa Verlet no lugar de Euler para estabilidade

  Euler acumulava erro em colisões consecutivas em alta velocidade,
  causando tunneling na bola. Verlet mantém energia melhor sem custo
  de performance significativo no tick de 16ms.
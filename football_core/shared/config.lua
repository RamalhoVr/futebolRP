Config = {}

-- Ativa prints de debug para facilitar o desenvolvimento (desabilitar em produção)
Config.Debug = true

-- Duração da partida em segundos (ex: 600s = 10 minutos)
Config.MatchDuration = 600

-- Limita o número de jogadores por time para balanceamento e performance do loop
Config.MaxPlayersPerTeam = 6

-- Sistema de física da bola server-side
-- Define a resistência do ar/grama (valores mais próximos de 1.0 fazem a bola rolar mais)
Config.BallFriction = 0.985
-- Força da gravidade aplicada na bola a cada tick de 16ms
Config.BallGravity = -9.8
-- Quique da bola (1.0 = pula a mesma altura, menor = perde energia a cada impacto)
Config.BallRestitution = 0.6

-- Movimentação e sistema esportivo com stamina
-- Velocidade base máxima sem sprint
Config.PlayerMaxSpeed = 8.5
-- Multiplicador aplicado na velocidade ao usar sprint
Config.SprintSpeedMultiplier = 1.4
-- Teto máximo do medidor de stamina (100-60%, 60-40%, 40-20%, <20% determinam precisão)
Config.StaminaMax = 100
-- Custo deduzido por segundo quando o sprint está pressionado
Config.StaminaSprintCost = 8.0
-- Taxa de recuperação por segundo quando parado ou andando
Config.StaminaRecoveryRate = 5.0

-- Coordenada central do estádio base, usada para bounds e setup da partida
Config.StadiumCoords = vector3(-669.0, -1394.0, 5.0)

-- Bucket de roteamento base. Isolamento total das entidades (jogadores e bola) por partida.
-- matchId é somado a essa base
Config.MatchRoutingBucketBase = 1000

-- Configurações de força para as mecânicas de chute e passe
-- Força bruta base do chute comum
Config.ShootForceBase = 80.0
-- Chute colocado (menor velocidade e força, mas pensado para curvas)
Config.ShootFinesseForce = 65.0
-- Passe curto (pouca força, mantém a bola rente ao chão)
Config.PassShortForce = 40.0
-- Passe longo (maior força para cobrir distâncias e elevação)
Config.PassLongForce = 65.0
-- Passe em profundidade (força para buscar o espaço na frente)
Config.ThroughBallForce = 55.0
-- Chute de cavadinha/cobertura (foco na trajetória vertical)
Config.ChipShotForce = 35.0
-- Cruzamento rasteiro/forte (alta velocidade, pouca altura)
Config.DrivenCrossForce = 70.0
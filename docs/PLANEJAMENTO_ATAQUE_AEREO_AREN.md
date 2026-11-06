# M5-H — planejamento do ataque aéreo de Aren

**Situação:** planejamento, sem implementação ou autorização implícita de desenvolvimento. M5-H não aparece como marco anterior no roadmap consultado. O ataque aéreo é independente da recompensa de dash e não é pré-requisito para vencer o Abade.

## Objetivo e arquitetura atual

Permitir um golpe horizontal com J durante subida, ápice ou queda, preservando gravidade e controle horizontal. O controlador `scripts/player/knight_controller.gd` executa movimento e `SwordAttack.tick(delta, is_on_floor(), facing)`; `scripts/player/sword_attack.gd` só inicia quando `grounded`, fixa direção no início, executa WINDUP/ACTIVE/RECOVERY de 0,10/0,10/0,20 s e mantém uma lista de alvos atingidos por ciclo. A consulta da hitbox respeita direção e corredor contra paredes. `scripts/art/aren_attack_art.gd` fornece apresentação terrestre; `knight_visual.gd` a seleciona. Morte, teleporte e dash chamam `cancel()`; verificar que dano não letal atualmente não cancela automaticamente antes de propor essa mudança.

## Proposta

Estender a mesma máquina SwordAttack com contexto terrestre/aéreo fixado no início, sem arquitetura paralela. J no ar inicia um único golpe horizontal por acionamento válido; hitbox ativa apenas na fase ACTIVE e cada alvo recebe no máximo um acerto por ciclo. Preservar direção travada e consulta que impeça danos através de paredes e plataformas. Testar se o corredor horizontal existente é adequado em diferentes alturas antes de reutilizá-lo sem alterações. Não congelar velocidade vertical nem aplicar impulso. Valores de duração e alcance devem ser calibrados e aprovados, não inferidos do ataque terrestre.

| Situação | Comportamento proposto |
| --- | --- |
| Subida, ápice ou queda | J inicia ciclo aéreo; física vertical e horizontal prosseguem |
| Aterrissagem durante golpe | Concluir ou cancelar em janela explícita a validar; nunca repetir dano |
| Dano ou morte | Cancelar hitbox e animação, inclusive dano não letal após definir prioridade |
| Dash terrestre desbloqueado | Prioridade de cancelamento explícita; dash só no chão, sem invulnerabilidade nova |
| Parede, teto, plataforma | Colisão física e bloqueio de linha de golpe continuam válidos |
| Recuperação ou J mantido | Não iniciar automaticamente outro golpe |

**Proposta inicial para aprovação:** um golpe por salto, rearmado apenas ao aterrissar; verificar coyote time, rebotes e quedas. Preservar a recuperação e o comportamento já homologados no chão. Inicialmente, o dash não poderá cancelar o golpe; definir uma regra de bloqueio de entrada e testar a aterrissagem antes de implementá-la.

## Arte e dependências

Criar poses aéreas originais e rastro curto compatíveis com a pixel art existente, com mão, espada, hitbox e direção alinhados; fazer transição para queda/aterrissagem e manter feedback de acerto. Potenciais arquivos: controlador de Aren, SwordAttack, cena da hitbox, KnightVisual, ArenAttackArt, atlas próprio, testes de combate e documentação. Dependências: M5-G homologado, baseline consolidável, decisão de disponibilidade, desenho da animação e autorização específica.

## Disponibilidade: decisão do responsável

**Proposta inicial para aprovação — A:** mecânica básica desde o início, independente do dash e sem desbloqueio associado ao Abade. Isso melhora a fluidez e exige regressão e reavaliação dos encontros anteriores. **Alternativa B:** habilidade desbloqueável posteriormente e independente do dash; exige definir aquisição e persistência. A proposta inicial também prevê J na subida ou queda, um golpe por salto, gravidade e movimento horizontal preservados, animação e hitbox próprias e compatibilidade com inimigos e bosses. Nenhuma opção está implementada ou aprovada.

## Testes e aceite futuros

Ensaiar subida, ápice, queda, aterrissagem em cada fase, dano/morte, interrupção, repetição e hitbox sem permanência; física sem suspensão, teto, parede, plataformas e corredores; direções, alvos terrestres e em plataformas, inimigos altos, armadilhas e bosses anteriores. Testar golpe único e ausência de dano através de geometria, compatibilidade com dash/cooldown e regressão integral da espada terrestre, fases e checkpoints. Testar persistência apenas se B for aprovada. Comparar combate antes/depois para evitar trivialização. Aceite requer automação física, capturas/animação, ausência de softlocks e playtest explícito do responsável.

Sequência sugerida: decidir disponibilidade e limite por salto; projetar estados e arte; implementar em lote isolado; verificar física/colisões e regressões; ajustar mediante playtest; documentar e solicitar homologação. Nenhum desenvolvimento de M6 é autorizado por este planejamento.

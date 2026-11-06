# M5-H FIX01 — verificações realizadas

**PARTIAL; sem homologação.** O trabalho desta rodada foi interrompido pela nova prioridade M6-A. Resultados anteriores de M5-H continuam em `VALIDACAO_M5_H.md`; este documento não os transforma em novas execuções nem afirma que toda a matriz foi concluída.

## Ensaios na cópia com os arquivos locais atuais

Godot 4.7.2, cópia isolada e perfis sem dados pessoais. A cópia final `m6a-art-recovery-candidate` foi comparada por hash com os scripts locais de jogador e progresso antes destes dois ensaios:

- `m5_h_fix01_physics.gd`: 62/62. Alvo desobstruído e separado por parede, nos dois sentidos, subida e queda; contato físico com parede, teto baixo, ápice com movimento horizontal, queda de borda, aterrissagem em preparação/atividade/recuperação e últimos quadros, novo salto imediato, dano sem rearmar e Shift no ar sem cancelar golpe. A colisão usa a Godot; não prova todos os estados e geometrias possíveis.
- `m5_h_fix01_spawns.gd`: 42/42. Os seis novos inimigos do Cemitério e os dez da Abadia foram localizados nas cenas reais; contagens 12 e 20, suporte dos terrestres e consulta contra mundo com margem interna de 0,2 px para excluir contato normal com o chão. Sete checkpoints presentes. Não comprova individualmente justiça, comportamento prolongado ou todas as interações.
- Na mesma cópia, após a modificação exclusivamente visual da Floresta: `combat_test.gd` 36/36, `m5_h_aerial_test.gd` 16/16, `dash_vfx_test.gd` 47/47 e `recompensa_guardiao_test.gd` 33/33. A matriz de regressões completa do FIX01 não foi reexecutada nessa cópia.

No teste visual anterior foram observados quadros com espada deslocada em relação à mão durante a recuperação; o ajuste local de registro da lâmina está em `knight_visual.gd`, sem alteração de hitbox ou alcance. As capturas `tests/evidencias/m5h-fix01/` e as medições comparativas iniciais usaram uma candidata anterior, que não incluía todas as alterações locais atuais do controlador, sobrevivência, progresso e VFX de dash. São evidência histórica dessa candidata e **não** validam integralmente o estado atual. O estado atual requer nova sequência gráfica específica e benchmark comparativo se esses critérios forem exigidos.

A jornada histórica de atalhos falhou tanto na candidata antiga quanto no commit anterior. O primeiro erro ocorre porque o roteiro tenta abrir A1 ao chegar ao lado avançado sem antes completar o próprio setor; o jogo exige `forward_completed` desse setor. Isso explica a primeira divergência, mas não prova que todas as falhas posteriores sejam apenas do roteiro. Ensaios dirigidos de atalhos e opcionais foram executados na candidata anterior e permanecem resultados históricos, não uma nova comprovação na cópia atual.

Não foi identificado no controlador atual de Aren um sistema dedicado de knockback por dano para validar como funcionalidade existente. Permanecem as ressalvas M5-C3, ObjectDB e desempenho. É necessário playtest do responsável; nenhum staging, commit, push ou deploy foi executado nesta rodada.

# M5-H — implementação e validação

**Veredito: PARTIAL.** Implementações locais presentes; ainda não há aceite técnico integral nem homologação do responsável. A contagem e as jornadas principais foram verificadas, mas a justiça dos encontros, toda a matriz de interrupções e a apresentação ainda requerem os ensaios indicados abaixo.

## Base e preservação

Base `main` / `2ac02cf0344b5fa5fc447b301cfdd8bae397be43`; índice inicialmente vazio, 390 caminhos locais anteriores identificados, incluindo `project.godot`, imagens de referência, evidências/sidecars e o relatório de consolidação. Inventário e posições em [INVENTARIO_INIMIGOS_M5_H.md](INVENTARIO_INIMIGOS_M5_H.md). Ensaios em cópia do commit com alterações pertinentes sobrepostas e `APPDATA` isolado; não se usa o save pessoal. Godot 4.7.2 emite diagnóstico histórico de certificados; algumas suítes registram 3–4 objetos ObjectDB no encerramento, sem investigação nova.

## Implementação

- `SwordAttack` usa J no chão ou no ar, com direção fixada e consulta de colisão existente; um golpe por período aéreo, rearmado ao tocar o chão. Aterrissagem cancela ataque aéreo e sua hitbox. Morte, dano aceito e reset cancelam o ataque aéreo. A combinação salto+J usa o estado depois do movimento. O golpe aéreo não altera gravidade, velocidade nem desbloqueia dash; Shift não cancela golpe aéreo.
- A apresentação compõe as poses existentes de salto/queda com lâmina registrada em preparação, atividade e recuperação, e rastro discreto durante atividade. É uma composição de recursos existentes, ainda sujeita a avaliação visual; não é uma nova folha de sprites autorada quadro a quadro. A hitbox é a forma existente de 22 × 14 px, ativa apenas na fase ACTIVE, preservando o filtro por direção, único acerto por alvo e bloqueio por corredor sólido.
- Cemitério: 6→12 inimigos; Abadia: 10→20; chefes excluídos. Inimigos acrescentados usam cenas e sistema existentes. Setores 2 e 12 da Abadia mantiveram os totais anteriores; nenhum inimigo adicionado à arena ou às ramificações opcionais.

## Execuções registradas

Comando-base dos testes: `Godot_v4.7.2-stable_win64_console.exe --headless --path <cópia-isolada> --script res://tests/<arquivo>.gd`, com `APPDATA` em diretório exclusivo. As contagens e falhas abaixo correspondem às execuções desta alteração:

| Ensaio | Resultado e alcance |
| --- | --- |
| `m5_h_inventory_test.gd` | 12 e 20 instâncias; zero sobreposições amostradas com geometria do Cemitério e suporte geométrico das posições da Abadia; não certifica justiça. |
| `m5_h_aerial_test.gd` | 16/16: entrada física, subida, queda à esquerda, gravidade, limite por período, rearmar, dano, morte, J simultâneo ao salto, alvo de treino e ataque terrestre. |
| `m5_h_real_enemy_test.gd` | Golpe aéreo aplicado uma vez ao corvo real: HP 2→1. |
| `smoke_test.gd` | 14 verificações de movimento, sem falhas. |
| `combat_test.gd` | 36/36; a antiga expectativa de impedir J no ar foi alterada para o novo requisito. |
| `survival_test.gd` | 59/59. |
| `m5_c3_distribution_test.gd` | 202/202 após corrigir índice de apoio do novo acólito do setor 10; inclui entradas reversas e sete checkpoints. |
| `m5_h_cemetery_journey.gd` | 6/6, seis regiões, 12 ameaças ativas, sem dash; chegou à aproximação do Guardião com HP 4/5. Não incluiu a luta na mesma jornada. |
| `boss_test.gd` | 59/59 depois de atualizar a expectativa de seis para 12 inimigos; geometria continua exigida. |
| `boss_victory_test.gd` | 59/59, vitória do Guardião por golpes reais em ensaio dirigido. |
| `m5_g_full_journey_test.gd` | Atravessou S1–S12 com ameaças ativas e sem dash, entrou na arena com HP 2/5 e venceu o Abade com golpes reais, desbloqueando dash. |
| `m5_g_abbot_test.gd` | Vitória, duas fases, recompensa, retorno e revisita em ensaio dirigido; zero falhas. |
| `m5_g_fix01_dash_integration.gd` | Zero falhas com recompensa em perfil isolado preparado para a regressão; transição, checkpoint, borda e dano. |
| `m5_g_dash_shortcuts_test.gd` | Zero falhas para A1–A3 nos dois sentidos, com perfil isolado de recompensa. |
| `m5_g_dash_o1_test.gd` … `m5_g_dash_o6_test.gd` | Seis percursos testados individualmente com dash adquirido, entrada, retorno e ameaças ativas; zero falhas após atualizar exclusivamente contagens esperadas em O2–O5. Não substituem uma jornada contínua sem dash por todos os opcionais. |

Na primeira execução de `boss_test.gd`, uma expectativa histórica de seis inimigos falhou; após atualização do número esperado, 59/59. Nos testes O2–O5, a expectativa histórica de quantidade falhou inicialmente; após refletir os novos totais, as rotas passaram sem retirar verificações. Em uma tentativa inicial dos testes de dash, o perfil não continha a recompensa exigida e as verificações de dash falharam; com o perfil isolado correto, passaram.

**Jornada histórica de atalhos:** `m5_e_lote09_journey.gd` falhou 6 verificações na candidata, inclusive abertura/travessia de A1/A2 e interrupção em S8. No controle isolado do commit anterior, a mesma jornada também falhou em A1/A2 e terminou com 7 falhas em S8. Isso não demonstra uma regressão nova, mas não prova que a jornada integrada esteja correta: os ensaios dirigidos acima são evidência mais limitada.

## Imagem e desempenho

Capturas gráficas da cena real em movimento, fase ativa do golpe: [1280×720](evidencias/m5h/m5h_aerial_1280x720.png), [1920×1080](evidencias/m5h/m5h_aerial_1920x1080.png), [2560×1440](evidencias/m5h/m5h_aerial_2560x1440.png) e [janela 4K limitada a 3840×2119](evidencias/m5h/m5h_aerial_3840x2119.png). O processo foi solicitado em 3840×2160, mas a área útil da janela foi 3840×2119; não é evidência de 4K completo. As capturas amostram uma queda com golpe e inimigos, não toda a animação, os dois bosses ou todos os setores.

`m5_f_performance_sample.gd`, renderização OpenGL na RTX 2060 SUPER, quatro amostras de 5 s com janela solicitada 3840×2160: S1 60,00 FPS / p95 17,152 ms / máximo 19,660 ms; S4 60,05 / 17,252 / 25,348; S8 60,04 / 17,352 / 21,025; S10 60,01 / 17,215 / 18,413. São amostras breves, sem comparação controlada antes/depois, em janela limitada pela área útil; não provam ausência de picos ou desempenho completo em 4K. As ressalvas históricas de picos M5-D/M5-G permanecem.

## Pendências para aceite técnico e playtest

- Ampliar testes físicos do golpe no ápice, em ambas as direções, contra parede durante golpe aéreo, aterrissagem em cada fase, mudança horizontal durante golpe, dash em conflitos de entrada e novas combinações de dano/morte. O teste terrestre de parede passou, mas não é um teste específico da variante aérea.
- Verificar composição e sincronização de toda a animação em movimento e nas duas fases; as capturas não bastam para atestar qualidade visual. Verificar 4K real em tela cheia e medir densidade máxima de forma comparativa.
- Investigar a jornada contínua de atalhos, inclusive as falhas reproduzidas na base, e comprovar todos os opcionais sem dash com as novas ameaças, sem desativá-las. A distribuição geométrica não prova justiça, distâncias dinâmicas ou ausência de todos os bloqueios.
- Playtest do responsável: F5 no Capítulo 1, confirmar J na subida e queda, experimentar os novos encontros e alcançar Guardião sem dash; F6 na Abadia com perfil novo isolado, testar setores 1–12, checkpoints, segredos e atalhos, chegar ao Abade sem dash, vencer e conferir recompensa. Avaliar legibilidade, dificuldade, variedade e diversão. Não utilizar nem apagar o save pessoal para criar perfil novo; usar o mecanismo de perfil isolado de desenvolvimento documentado em M5-G FIX04.

As ressalvas históricas M5-C3, ObjectDB e desempenho permanecem. Não foi iniciado M6. Nenhum staging, commit, push ou deploy foi realizado.

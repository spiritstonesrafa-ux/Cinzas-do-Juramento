# Candidata Git M5-E/F/G — 06/11/2026

> Nota da consolidação: a seleção final preserva as capturas vinculadas neste relatório e os logs de benchmark vinculados. Outras capturas e logs mencionados como históricos permanecem locais, fora do commit; os resultados não são alterados.

> Auditoria pré-commit: as contagens de 441 arquivos e a lista anterior são históricas. A seleção final revisada, sem capturas redundantes, está em [MANIFESTO_M5_E_F_G.md](MANIFESTO_M5_E_F_G.md); a alteração da seleção restringiu-se a evidências e documentação.

**M5-G: homologado pelo responsável. Candidata: PASS técnico para a seleção e as proporções ensaiadas, com limitação de captura da janela inteira. Benchmark 4K: PARTIAL, não bloqueante. M5-H: planejado, não iniciado.** A futura seleção staged deve ser revisada e comparada novamente. Não houve consolidação Git.

## Comparação de proporções — validação pré-commit

Em duas cópias isoladas da candidata, uma usou o `project.godot` do HEAD e outra uma cópia do arquivo local protegido. Os 425 arquivos anteriormente selecionados eram idênticos nas duas cópias; não se alterou o arquivo protegido. No HEAD, `window/stretch/aspect="keep"` é explícito; no arquivo local, essa propriedade está ausente. Nesta execução da Godot 4.7.2, ambas as janelas reportaram `content_scale_aspect=1` (keep). A [documentação oficial de ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html#class-projectsettings-property-display-window-stretch-aspect) descreve `keep` como preservação de proporção com barras quando necessário; projetos recém-criados podem gravar outra opção, o que não altera o valor efetivamente observado nestas cópias.

A outra diferença é a serialização do evento da espada: o HEAD usa `Object(InputEventKey,"physical_keycode":74)`; o local registra explicitamente propriedades adicionais, incluindo `device=16`, e o mesmo código físico 74. Um evento físico J iniciou o golpe nas duas cópias; isso não garante equivalência de todos os dispositivos.

| Janela solicitada | Conteúdo capturado | Escala X/Y | Origem no quadro | Margens inferidas da transformação |
| --- | --- | --- | --- | --- |
| 1920×1080, 16:9 | 1920×1080 | 6×/6× | (0,0) | nenhuma |
| 1280×800, 16:10 | 1280×720 | 4×/4× | (0,40) | 40 px em cima e embaixo |
| 1024×768, 4:3 | 960×540 | 3×/3× | (32,114) | 32 px laterais e 114 px em cima/embaixo |
| 2560×1080, ultrawide | 1920×1080 | 6×/6× | (320,0) | 320 px laterais |

Em todas, as duas configurações reportaram janela solicitada, área lógica visível 320×180, escala uniforme inteira, a mesma origem da transformação e câmera da arena em (80160,90). Não há expansão da área lógica. Nas capturas da área interna, cenário, HUD de Aren, barra, sprite e poses de dash permaneceram enquadrados; as imagens estáticas da arena foram byte a byte iguais em três das quatro proporções, e igualdade de pixels não era requisito. A inspeção é amostral e os estados de dash foram preparados no fixture; a recompensa foi habilitada apenas em memória de teste e nenhum save pessoal foi alterado.

**Limitação:** `ViewportTexture.get_image()` captura a área interna renderizada, não as margens da janela. A tentativa de captura da tela/janela retornou imagens inteiramente pretas, e a janela isolada não ficou disponível para captura pela ferramenta de interface. Portanto, as margens e sua cor são o comportamento esperado a partir da transformação e da documentação, não uma fotografia verificada das bordas físicas. Não foi reproduzido corte ou distorção no conteúdo; a divergência de configuração de aspecto não é bloqueante na Godot 4.7.2 e nas proporções ensaiadas. Recomenda-se observar as bordas no computador do responsável como verificação adicional, sem declarar que ocorreu nesta execução.

Capturas da **área interna**, não imagens completas de janela: [16:9 HEAD](evidencias/m5-aspect/head_1920x1080_arena.png), [16:10 HEAD](evidencias/m5-aspect/head_1280x800_arena.png), [4:3 HEAD](evidencias/m5-aspect/head_1024x768_arena.png), [ultrawide HEAD](evidencias/m5-aspect/head_2560x1080_arena.png), [16:10 local](evidencias/m5-aspect/local_1280x800_arena.png), [dash de Aren](evidencias/m5-aspect/head_1280x800_dash_aren.png) e [dash do Abade](evidencias/m5-aspect/head_1280x800_dash_abade.png). A pasta contém as contrapartes locais e os logs. O roteiro é `tests/m5_aspect_compare.gd`.

## Seleção final proposta

A seleção aumenta de 425 para **441 caminhos** pela inclusão do teste visual, seu UID e 14 capturas/logs selecionados. O status final contém **652 caminhos** individuais: 441 propostos e 211 fora da seleção. As alterações de documentação existentes também foram atualizadas. Elas foram sincronizadas à candidata sem alterar o gameplay anteriormente testado. A [lista exata](PLANO_CONSOLIDACAO_GIT_M5.md) contém a seleção original e as adições; o manifesto isolado registra hashes. A checagem não encontrou protegidos, perfis, caches ou arquivos `.log`, `.tmp` ou `.bak` na seleção; o save pessoal permaneceu com o mesmo SHA-256. Recomenda-se um único commit seletivo futuro `feat(abbey): consolida exploracao, regressao e Abade`, após autorização e revisão do diff staged; nenhum staging foi feito nesta etapa.

## Seleção e ambiente — registro anterior

Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`, índice vazio. Foram observados **636 caminhos individuais** no status expandido, incluindo documentos, evidências e sidecars gerados nesta execução. Propõem-se **425 alterações** sobre o HEAD: 38 arquivos de gameplay compartilhado e específico, 2 de arte, 175 de testes/documentos, 9 documentos transversais e 201 evidências. As demais **211 alterações** não entram na proposta, incluindo o `project.godot` protegido, referências pessoais e sidecars de evidências. Os caminhos já rastreados e inalterados do HEAD entram na cópia-base, não nessa contagem.

A [lista completa e classificada](PLANO_CONSOLIDACAO_GIT_M5.md) apresenta as 416 alterações iniciais e as nove adições posteriores. O manifesto com SHA-256 está no diretório isolado de trabalho, em `manifesto-candidata-m5.json`. A cópia foi extraída de `git archive HEAD` e recebeu somente os arquivos da lista explícita, sem saves, logs ou caches da árvore original. A importação gerou os caches e sidecars próprios da candidata. Depois dos testes foram adicionadas apenas evidências, o roteiro do benchmark com seu UID e os documentos deste encerramento; não houve alteração posterior de gameplay na candidata. A futura seleção staged precisa ser novamente comparada e testada.

Após sincronizar os documentos finais, os 425 caminhos selecionados coincidiram por SHA-256 com a working tree. Outros 365 arquivos rastreados não selecionados coincidiram com os blobs do HEAD usando `git hash-object`, que aplica a normalização de fim de linha configurada no Windows. Uma primeira comparação de bytes crus acusou diferenças em arquivos de texto por CRLF; a comparação normalizada com os blobs não encontrou divergências. A importação pode produzir arquivos auxiliares ignorados ou não selecionados, que não fazem parte da proposta de commit.

Todos os 15 arquivos protegidos coincidiram com o baseline, inclusive o `project.godot` local; nenhum foi restaurado ou incluído como alteração candidata. O `project.godot` **da candidata é exatamente o blob do HEAD** `ee72ef1ebf52af8c53b1506e743a3a7dff69ce8f`. Ele aponta para `res://scenes/main.tscn`, configura 320×180, `canvas_items`, escala inteira, OpenGL Compatibility e J físico. O HEAD contém `window/stretch/aspect="keep"`, ausente do arquivo protegido local, e serialização distinta da tecla J. O teste físico de J iniciou o ataque; Shift é tratado diretamente em `knight_controller.gd`, sem ação adicional no InputMap. Não se verificou equivalência de apresentação fora das proporções testadas.

A inspeção de referências estáticas de scripts e cenas encontrou apenas `sector_%02d.tscn`, padrão dinâmico; os 12 arquivos correspondentes existem. Isso não prova todas as dependências carregadas dinamicamente. A importação Godot 4.7.2 terminou com código 0, sem erro crítico de recurso identificado; houve diagnóstico de leitura do repositório de certificados. A cena principal e `abbey_chapter.tscn` iniciaram por 120 quadros, código 0.

## Testes novos na candidata

- `smoke_test.gd`: física M0 sem falhas; `combat_test.gd`: 36/36; `survival_test.gd`: 59/59; `boss_test.gd`: 59/59.
- Tecla física J mapeada e ataque iniciado; perfil novo sem dash. Inicializador isolado do boss: vida 5/5, dash bloqueado e Abade 10/10.
- `m5_g_full_journey_test.gd`: travessia real S1–S12 por controles, entrada na arena, duas fases e vitória com golpes; dash desbloqueado e Aren terminou com 2 de vida.
- Em novo processo e com o save isolado dessa jornada: persistência, cooldown, colisão com parede e ausência de invulnerabilidade; revisita com Abade derrotado, preservação de HP/checkpoint e retorno sem reentrada automática: passaram.
- Matriz de ataques nos dois sentidos: 64/64; morte/CP7/reentrada: passou. Teste da barra durante golpes reais observou HP 10, 9, 5, 1 e 0 e restauração do HUD ao retornar.
- Testes dos três atalhos e O1–O6 com dash, morte/queda/F7 e persistência: sem falhas nos roteiros executados.
- `m5_g_visual_test.gd`: combate, transição, dash e recompensa capturados em 1280×720, 1920×1080, 2560×1440 e 3840×2160; código 0. Amostras selecionadas: [arena](evidencias/candidata-m5/arena_1280x720.png), [dash](evidencias/candidata-m5/dash_abade_1280x720.png) e [transição 4K](evidencias/candidata-m5/transicao_3840x2160.png). A inspeção amostral não equivale a um novo playtest humano.

Os testes usam perfis isolados; não acessam nem alteram o save pessoal. Os avisos históricos ObjectDB reapareceram em algumas saídas. Ensaios que preparam fixtures ou perfis não provam todos os estados possíveis.

## Investigação e benchmark gráfico 4K

Godot 4.7.2, Windows 10 build 19045, RTX 2060 SUPER, OpenGL Compatibility, VSync ligado, FPS sem limite explícito; executado graficamente em cópia separada com configuração local protegida copiada, sem mudar o arquivo original. Em tela cheia: tela física reportada 3840×2160, posição da janela (0,0), tamanho da janela e imagem lida 3840×2160. A área lógica visível e `content_scale_size` foram 320×180; modo de escala `canvas_items` e escala inteira. A textura reportou 46080×25920, exatamente 12 vezes cada dimensão da janela, enquanto sua imagem retornada mediu 3840×2160. O fator 12 é consistente com a escala inteira de 320×180 para 4K, mas **a razão interna da API para o valor da textura não foi comprovada**. Não se tratou automaticamente essa diferença como defeito. Tela cheia e captura 4K são verificadas; o tamanho físico interno de cada superfície da GPU não foi instrumentado independentemente.

Na execução longa, os intervalos de `process_frame` foram classificados por estado, com ameaças normais, vitória por controles e 50 dashes alternados de Aren. FPS mínimo é o inverso do maior intervalo individual; p95/p99 referem-se aos intervalos ordenados. Queda relevante: intervalo >33,333 ms.

| Cenário | Duração / quadros | FPS médio / mínimo | Média / p95 / p99 / máximo (ms) | >33,333 ms |
| --- | --- | --- | --- | --- |
| Introdução | 1,167 s / 70 | 59,98 / 56,75 | 16,674 / 17,039 / 17,231 / 17,515 | 0 |
| Fase 1 | 3,950 s / 237 | 60,01 / 52,13 | 16,665 / 17,054 / 17,365 / 19,183 | 0 |
| Fase 2 | 6,617 s / 390 | 58,94 / 8,73 | 16,966 / 17,057 / 17,632 / **114,494** | **2** |
| Dash de Aren | 51,663 s / 3100 | 60,00 / 48,06 | 16,665 / 17,019 / 17,161 / 20,806 | 0 |
| Vitória | 0,822 s / 49 | 59,64 / 46,81 | 16,766 / 16,920 / 17,020 / 21,365 | 0 |

Na repetição da fase 2 por 6,000 s, p95 17,006 ms, p99 17,170 ms, máximo 17,560 ms e zero intervalos >33,333 ms; na execução anterior em janela, a fase 2 também ficou abaixo de 33,333 ms. O pico de 114,494 ms não foi reproduzido nessas amostras. A causa e a relação com efeitos, HUD, GPU ou agendamento não foram identificadas; não há base para atribuí-lo ao M5-G nem para descartá-lo como histórico. A amostra longa cobre principalmente dash após vitória, não combate prolongado. O resultado é **PARTIAL**: há saída gráfica em 4K e evidência de estabilidade na amostra de dash, mas o pico da fase 2 e a duração curta do combate exigem observação posterior não bloqueante.

[Log da execução longa](evidencias/m5g-fechamento/resultado_4k_fullscreen.txt), [repetição](evidencias/m5g-fechamento/resultado_4k_repeticao.txt), [captura](evidencias/m5g-fechamento/benchmark_4k_fullscreen.png) e `tests/m5_g_4k_fullscreen_probe.gd` foram selecionados como evidência. As ressalvas históricas M5-C3, ObjectDB, pico de 183,878 ms e mínimo físico de 12.227,52 px permanecem.

## Plano e próximo marco

Recomenda-se um único commit futuro `feat(abbey): consolida exploracao, regressao e Abade`, pois capítulo, controlador, visual e documentação são compartilhados. Ele dependerá de revisão do conteúdo selecionado, escolha final das evidências, conferência do diff staged e nova execução na candidata que corresponda exatamente ao conteúdo autorizado. Risco aberto: diferença de configuração de aspecto entre HEAD e ambiente homologado; não se deve alterar o arquivo protegido sem autorização. Não houve staging, commit, push ou deploy.

[M5-H](../docs/PLANEJAMENTO_ATAQUE_AEREO_AREN.md) cobre subida/queda, J, arte própria, hitbox, gravidade, movimento, aterrissagem, dano/invulnerabilidade, dash, regressão terrestre, paredes e playtest. Recomenda-se disponibilização desbloqueável e independente, mas o responsável ainda deve decidir aquisição, número de golpes por salto e transições/cancelamentos. Nenhum ataque aéreo ou M6 foi implementado.

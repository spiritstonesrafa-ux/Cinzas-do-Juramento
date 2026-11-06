# M5-G — homologação e fechamento técnico

**HOMOLOGADO PELO RESPONSÁVEL em 05/11/2026.** Após o FIX05, o responsável informou: “AGORA SIM, FICOU BOM! APROVADO”. A aprovação cobre a identidade do Abade, combate de duas fases e dash ofensivo, recompensa permanente de Aren, apoio visual e derrota, retirada da linha artificial com avisos mantidos e barra no padrão do Guardião. O responsável considera a dificuldade aceitável, apesar de relativamente fácil; não autorizou novo rebalanceamento. Para chefes posteriores, planeja-se maior exigência de leitura e posicionamento, com justiça.

A Abadia está homologada no conteúdo testado; isso não significa que o repositório tenha sido consolidado ou publicado. M5-D e M5-E já estavam homologados; M5-F foi homologado com ressalvas. Preservam-se os relatórios M5-G e FIX01–FIX05: eles refletem seus estados históricos, não contradizem a homologação posterior.

## Histórico técnico

Antes desta execução, o FIX05 registrou 64/64 na matriz de ataques, 59/59 no primeiro chefe, barra observada em 10/9/5/1/0, vitória por ataques reais, morte/reentrada, persistência, revisita e capturas em quatro resoluções. Esses resultados históricos não são apresentados como novas execuções. Permanecem as limitações do M5-C3 (sete encontros e combinação avançada no Campanário), aviso ObjectDB sem causa conclusiva e pico histórico isolado M5-D de 183,878 ms. O mínimo físico global de 12.227,52 px continua não comprovado e não bloqueante por decisão aprovada; o grafo horizontal não é distância física real.

## Benchmark gráfico desta execução

Godot 4.7.2, Windows 10 build 19045, NVIDIA GeForce RTX 2060 SUPER, OpenGL Compatibility 3.3, driver reportado 621.01, janela, VSync modo 1, `Engine.max_fps=0`, base do projeto 320×180, `canvas_items` e escala inteira. Execuções gráficas com perfis separados e ameaças normais; não headless. O Windows recusou consulta CIM de GPU, portanto a identificação de GPU e driver vem da própria Godot. A cópia usou a configuração local protegida; o arquivo original não foi alterado.

A janela reportou 3840×2160 e a imagem capturada mede 3840×2160. Porém, `root.get_texture().get_size()` reportou 46080×25920; a discrepância entre dimensão lógica reportada e imagem capturada não foi esclarecida. Assim, há renderização gráfica e saída capturada em 4K, mas **a comprovação de toda a cadeia de renderização física 4K permanece inconclusiva**. A tentativa inicial, cuja janela ficou 960×540, foi descartada. A comparação em 1080p reportou janela e imagem 1920×1080, com discrepância semelhante no tamanho lógico da textura (11520×6480).

Método: intervalos de `process_frame` em microssegundos, classificados pelo estado real. FPS médio = quadros/tempo acumulado; FPS mínimo é 1000 dividido pelo maior intervalo individual, não média por segundo. p95/p99 são percentis das amostras ordenadas; quedas relevantes contam intervalos >33,333 ms. O roteiro venceu com controles, passou pelas duas fases e observou padrões ativos 1_0, 1_1, 2_2 e 2_0; foram iniciados quatro dashes de Aren nas direções [1,-1,1,-1] após recompensa. Perseguição, aviso, transição, movimentos, efeitos e morte ocorreram durante o roteiro, mas a amostragem por fase não isola cada efeito. O cenário A corresponde ao breve repouso de introdução, não a um ensaio prolongado.

| 4K saída — cenário | Amostras / segundos | FPS médio / mínimo instantâneo | Média / p95 / p99 / máximo ms | >33,333 ms |
| --- | --- | --- | --- | --- |
| A introdução | 70 / 1,167 | 60,00 / 57,22 | 16,668 / 16,880 / 17,080 / 17,476 | 0 |
| B fase 1 | 237 / 3,950 | 60,00 / 54,57 | 16,666 / 16,910 / 17,228 / 18,326 | 0 |
| C fase 2 | 360 / 6,000 | 60,00 / 55,64 | 16,667 / 16,847 / 16,911 / 17,972 | 0 |
| D dash de Aren | 248 / 4,133 | 60,01 / 59,02 | 16,663 / 16,839 / 16,923 / 16,942 | 0 |
| E vitória | 49 / 0,818 | 59,92 / 56,68 | 16,690 / 16,835 / 16,947 / 17,644 | 0 |

1080p, mesmos cenários: médias 59,99–60,01 FPS; p95 16,845–16,884 ms; p99 16,886–17,277 ms; máximo 18,461 ms; zero intervalos acima de 33,333 ms. Logs integrais e imagens: [4K](evidencias/m5g-fechamento/resultado_4k.txt), [captura 4K](evidencias/m5g-fechamento/benchmark_3840x2160.png), [1080p](evidencias/m5g-fechamento/resultado_1080p.txt). O limite próximo de 60 FPS é coerente com VSync; amostras de 0,8 a 6 s são curtas e não demonstram estabilidade prolongada ou ausência de picos. Não se pode atribuir o pico histórico M5-D a este encontro. **Benchmark 4K: parcial/inconclusivo** quanto à discrepância de viewport e à estabilidade prolongada.

## Novas regressões

Em cópia isolada com APPDATA de teste: física M0 sem falhas; espada M1 36/36; sobrevivência M2 59/59; integração de movimento, inimigos e checkpoints M3-E 101/101; primeiro chefe 59/59; matriz física do Abade 64/64; barra com golpes reais, fases, vitória e revisita sem falhas; morte e reentrada; persistência em processo separado, cooldown, parede e sem invulnerabilidade; morte/queda/F7; atalhos e seis percursos O1–O6 com dash, sem falhas nos roteiros executados. Diagnóstico de certificados e avisos ObjectDB reapareceram. Isso não prova todos os estados possíveis.

Arquivos executados: `smoke_test.gd`, `combat_test.gd`, `survival_test.gd`, `integration_test.gd`, `boss_test.gd`, `m5_g_fix01_direction_test.gd`, `m5_g_fix05_live_hud_test.gd`, `m5_g_respawn_test.gd`, `m5_g_persistence_probe.gd`, `m5_g_session_test.gd`, `m5_g_fix03_completed_test.gd`, `m5_g_dash_shortcuts_test.gd` e `m5_g_dash_o1_test.gd` a `m5_g_dash_o6_test.gd`. Perfis com vitória foram copiados de um perfil de benchmark de teste, não do perfil pessoal.

O `abbey_chapter_test.gd` também foi iniciado e interrompido após ficar claro que executava uma matriz extensa de travessias fora da regressão dirigida. Não recebeu PASS nem falha funcional; o encerramento ocorreu antes de completar a suíte. Os testes concluídos acima e as jornadas previamente documentadas têm escopo distinto.

A candidata exploratória criada de `git archive HEAD`, com scripts/cenas/recursos locais sobrepostos e `project.godot` do HEAD, importou e passou espada 36/36, barra/combate do Abade e respawn. Não representa um conjunto staged exato nem comprova equivalência visual com o projeto local protegido; o projeto do HEAD difere na configuração de aspecto e serialização de entrada. Consolidação futura exige seleção, revisão e teste de candidata exata.

Os testes foram executados pelo padrão abaixo, com `<teste>` substituído pelo nome indicado, e perfil diferente para ensaios que precisavam começar sem vitória:

```powershell
$env:APPDATA = '<cópia-isolada>\perfil-do-teste'
& 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path '<cópia-isolada>' --script 'res://tests/<teste>.gd'
```

Para repetir o benchmark gráfico, usar uma cópia isolada importada, perfil novo e executar sem `--headless`:

```powershell
$env:APPDATA = '<cópia-isolada>\perfil-benchmark-novo'
$env:M5G_BENCH_SIZE = '4k'
& 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path '<cópia-isolada>' --script 'res://tests/m5_g_4k_benchmark.gd'
```

## Estado e pendências

**Fechamento técnico: PARTIAL**, pela discrepância e duração do benchmark e pela reprodutibilidade Git ainda não demonstrada para conteúdo exato. Isso não altera a homologação do responsável. **Consolidação Git: preparada, não executada.** **Ataque aéreo: planejado em [M5-H](../docs/PLANEJAMENTO_ATAQUE_AEREO_AREN.md), não implementado.** Sem staging, commit, push ou deploy; sem M6. Inventário e proposta: [plano Git](PLANO_CONSOLIDACAO_GIT_M5.md).

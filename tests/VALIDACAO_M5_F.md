# M5-F — regressão e reprodutibilidade da Abadia

> **Homologação posterior M5-F:** o responsável informou “playtest ok” e homologou o M5-F com as ressalvas documentadas. O mínimo físico global de 12.227,52 px continua não comprovado e não bloqueante; o modelo horizontal não é distância física. M5-C3, ObjectDB e o pico histórico de 183,878 ms permanecem registrados. Esta informação não representa nova execução automatizada.

> **Atualização posterior:** o responsável aprovou a revisão do critério de distância e considerou atendido o critério funcional dos atalhos. O M5-F foi encerrado administrativamente com ressalvas; playtest e homologação final permanecem pendentes. O veredito e os resultados abaixo são históricos e não foram alterados. Ver [registro da decisão](PROPOSTA_ENCERRAMENTO_M5_F.md).

**Veredito: BLOCKED.** A regressão gráfica de percurso usada pelo benchmark falhou no setor 8 e não comprovou o restante da travessia; sua causa precisa ser distinguida entre controlador de ensaio e cenário. O menor caminho global pós-atalhos continua sem medição conclusiva, e a cobertura visual/de desempenho em movimento não abrange todas as condições exigidas. O responsável mantém a decisão da homologação final. A homologação M5-E continua válida no seu escopo.

## Preflight e candidata

Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`; índice vazio e 122 entradas locais iniciais, como no inventário. Os 15 protegidos coincidiram por SHA-256 com `m5c3-20261104-01/baseline.json`. Não se restaurou nem modificou o `project.godot` protegido.

A cópia isolada foi produzida por `git archive HEAD`, mais os 105 arquivos candidatos identificados no inventário anterior, sem os 15 protegidos e sem o ensaio exploratório excluído. Sua pasta é `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5f-candidata-5_39v6d8/`; o manifesto completo e os dois ensaios M5-F são identificados em [INVENTARIO_M5_F_CANDIDATA.md](INVENTARIO_M5_F_CANDIDATA.md). A cópia não é commit e seu conteúdo de documentos pode receber atualizações posteriores.

O `project.godot` local remove a linha explícita `window/stretch/aspect="keep"` e serializa os campos do evento J por extenso. O blob da candidata corresponde ao HEAD (`ee72ef1ebf52af8c53b1506e743a3a7dff69ce8f`); a comparação direta de bytes com a saída textual de `git show` é afetada por normalização de fins de linha, por isso foi verificado via `git hash-object`. A Godot 4.7.2 carregou em ambos `aspect=keep`, cena inicial `res://scenes/main.tscn`, nenhum autoload e as mesmas ações J/A/D/setas/Espaço/W/cima, com deadzone 0,2. A cena principal e recursos são os do HEAD mais os scripts M5-E listados; nenhum ajuste do arquivo protegido foi necessário nos testes executados. Isso evidencia equivalência dos parâmetros observados, não de todas as situações gráficas/inputs possíveis.

Importação `--headless --editor --path <candidata> --import` e inicialização `--headless --path <candidata> --quit-after 120`: código 0. A importação relatou erro de escrita em `editor_settings-4.7.tres` do perfil e erro de certificados; código 0 não apaga esses diagnósticos. A candidata importou e executou as suítes abaixo, mas não é declarada integralmente validada enquanto houver critérios bloqueados. `display_test.gd` gráfico passou **38/38** com a janela padrão do projeto. Uma tentativa anterior com `--resolution 1280x720` falhou somente na expectativa de janela inicial 960×540, porque essa opção havia sobrescrito a configuração testada; essa execução não foi omitida.

## Regressões automatizadas executadas na candidata

Todas as seguintes usam `Godot_v4.7.2-stable_win64_console.exe --headless --path <candidata> --script res://tests/<nome>.gd`, salvo as gráficas indicadas. Códigos 0 e contagens são os registrados nos logs desta execução; contagens por linha PASS são identificadas como tal, não uma soma de requisitos independentes. Logs estão em `.godot/m5f-*.log` no projeto local e são cache ignorado.

| Ensaio | Resultado observado |
|---|---|
| `smoke_test` | 14 linhas PASS, zero falhas; M0. |
| `combat_test` / `survival_test` | M1 36/36; M2 59/59. |
| `m5_c1_test` / `m5_c2_hazards_test` | 41/41 inimigos; 115/115 armadilhas, incluindo dois ciclos. |
| `m5_c1_final_test` / `m5_c2_audit_test` | 116/116 e 239/239 nas respectivas verificações complementares. |
| `integration_test` | M3-E 101/101 em modo headless; não constitui avaliação visual. |
| `m5_c3_journey_test` | Código 0: percurso contínuo por input 1→12→1, ameaças ativas; setor 8 atravessado em ambos os sentidos. |
| `m5_c3_lifecycle_test` / `m5_c3_distribution_test` | 104/104 ciclo de vida; 157/157 distribuição, checkpoints e combate amostral. |
| `m5_e_lote01_test` / `m5_e_lote02_test` | Código 0; 10 e 36 linhas PASS; a segunda usa aproximações preparadas. |
| `m5_e_lote06_o1_journey` e `m5_e_lote08_o2_test` a `o6_test` | Código 0 nos seis percursos, acessos, descoberta, retorno e continuidade ensaiados; ameaças e condições conforme cada script. |
| `m5_e_lote08_short_jump_test` | 15/15 aproximação, indicação e salto breve sem desvio. |
| `m5_e_lote09_shortcut_fixture` | Código 0, condições e pares, dano/respawn reais e queda induzida; prepara posições e estado de progressão. |
| `m5_f_f7_session_test` | Código 0: atalhos semeados em fixture desapareceram após F7 criar outra sessão. A tentativa anterior encerrou enquanto carregamentos assíncronos ainda operavam e produziu erros; a execução final aguardou e não reproduziu esses erros. |
| `m5_e_lote09_segment_journey` gráfico | Código 0 nos três trechos físicos com ameaças ativas; ida, volta, progressão, S10 e capturas reais em quatro resoluções nos corredores. Ensaios separados não são uma jornada integrada de uma única sessão. |

Essas suítes cobrem dano, invulnerabilidade e colisões conforme seus próprios cenários; não demonstram ausência universal de softlock. O estado do F5 foi conferido como cena principal no teste de continuidade; não houve prova manual de tecla F5 nem playtest humano nesta etapa. Capturas dos três corredores no ambiente isolado constam em `<candidata>/tests/evidencias/m5_e_lote09_*.png`; a foto é pausada no ponto de captura, após movimento real.

## Renderização e desempenho

`abbey_chapter_visual_test.gd` no backend gráfico Windows/OpenGL: **189/189**, 50 capturas, incluindo 12 setores em 1280×720, 1920×1080, 2560×1440 e 3840×2160, mais duas fixtures 4K. O teste posiciona Aren e isola ameaças: é evidência de composição e dimensões/FOV, não comprova movimento ou todos inimigos/perigos. Capturas em `<candidata>/m5f-visual/`. `abbey_continuity_test.gd` gráfico: **118/118**; a tentativa inicial em headless foi interrompida porque a suíte espera quadros renderizados e não conta como resultado.

O benchmark antigo `abbey_chapter_performance_test.gd`, sem fixed-fps, retornou **1, 15/24 verificações aprovadas, 9 falhas**. O primeiro erro é travessia automática de S8; os erros seguintes decorrem de o roteiro prosseguir sem sair daquele setor. Também houve acesso a `pilot` em sala nula durante ciclos posteriores. O ensaio gráfico independente `m5_e_lote09_segment_journey.gd` percorreu o trecho S7–S8 com ameaças ativas, completou S8 e voltou ao portão; isso mostra uma travessia bem-sucedida, mas não identifica a causa da falha no benchmark nem descarta todos os defeitos. Ele isolou ameaças no percurso e foi executado junto a outras suítes. Registrou, no segmento de travessia parcial, FPS 60,00, p95 17,044 ms e pico 27,647 ms; no ensaio inteiro, FPS 59,43, p95 17,047 ms, p99 18,491 ms e pico 616,312 ms. Esse pico inclui fases diversas; não foi atribuído a uma causa, nem tomado como frame estável de jogo. O resultado não é benchmark completo aprovado.

Ensaio adicional `m5_f_performance_sample.gd`, sem fixed-fps, janela solicitada em 3840×2160, com inimigos/mecanismos ativos e outras suítes concorrentes: criação/início 1352,748 ms; trocas preparadas S1/S4/S8/S10 de 44,574/116,101/116,054/116,117 ms. Por aproximadamente cinco segundos por setor: S1 60,01 FPS, média 16,664 ms, p95 16,930 ms, pico 21,195 ms; S4 60,04 FPS, 16,654 ms, 16,967 ms, pico 28,388 ms; S8 60,04 FPS, 16,656 ms, 16,951 ms, pico 21,566 ms; S10 60,01 FPS, 16,665 ms, 16,945 ms, pico 18,827 ms. Trocas são fixtures; não são uma jornada nem amostragem de todos opcionais e não é medição de TCL física. Não se investigou ou atribuiu causa ao histórico pico de 183,878 ms do M5-D.

## Medida de percurso

Ganhos observados no M5-E: 246,97, 185,74 e 573,50 px, ensaios independentes. Soma 1.006,21 px não representa ganho de uma jornada global. Espinha histórica: 17.360,42 px, não remedida nesta etapa. **Menor caminho após abertura: não determinado**. Não foi construída prova física e modelo de grafo completo suficiente para comparar com mínimo 12.227,52 px; não se inventa um valor nem se considera esse critério aprovado. Percurso inicial, ramos, travas e conexões estão documentados no lote 09, mas as medições isoladas não estabelecem o ótimo global.

## Ressalvas e preservação

M5-C3 permanece encerrado administrativamente com ressalvas dos sete encontros; S11 fica para revisão posterior. ObjectDB registra avisos históricos sem causa conclusiva. O pico de 183,878 ms permanece observação histórica não bloqueante em si. Falhas novas e concretas recebem seu próprio registro acima. Não se modificou gameplay, arte ou arquivo protegido; não se criou commit, staging, push, deploy nem M6.

## Encerramento e estado final

Jornada principal executada continuamente com input `m5_c3_journey_test.gd`: 1→12→1, ameaças ativas e código 0; checkpoint, vida e câmera foram observados nos trajetos do ensaio, e a suíte específica verificou os sete checkpoints. O teste de segmentos e a fixture verificaram os três pares; ainda não há jornada única que combine todas as ramificações, atalhos e retomadas após morte/queda. Não foi realizada prova manual em TCL física, nem inspeção em movimento de todos os tipos de ameaça e todos os setores nas quatro resoluções.

Os dois ensaios novos de instrumentação são `tests/m5_f_f7_session_test.gd` e `tests/m5_f_performance_sample.gd`; não há alteração de jogabilidade. O estado final da árvore conserva as 122 entradas iniciais e acrescenta os dois scripts e os documentos de validação e inventário M5-F: 126 entradas, índice vazio, branch `main` e HEAD inicial inalterado. Os 15 hashes foram rechecados sem divergência; `git diff --check` passou com aviso de normalização futura LF/CRLF de `project.godot`.

Pendências para sair de BLOCKED: diagnosticar o percurso automático que falhou no benchmark S8 e obter medição representativa sem falha; demonstrar ou submeter à decisão do responsável a medição global do menor caminho pós-atalhos; complementar captura em movimento e interação nas quatro resoluções em condições exigidas, com jornada integrada de exploração/persistência; preparar e revalidar a composição final a versionar e realizar playtest final. Não é necessário repetir auditorias de simultaneidade sem evidência nova.

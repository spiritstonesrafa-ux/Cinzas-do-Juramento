# M5-C1 — auditoria complementar

## Encerramento técnico — 4 de novembro de 2026

**AUDITORIA APROVADA COM RESSALVAS.** O responsável informou playtest **16/16 PASSOU, sem observações**, e **reteste visual do Vigia PASSOU, sem observações** após a correção da linha para 6 px. A linha, arte, balanceamento e comportamento homologados não foram alterados nesta rodada. Os resultados abaixo são automatizados e independentes do playtest humano.

### Inventário incremental e resultado

| Área | Pendências anteriores | Cobertas nesta execução e evidência anterior | Restantes | Estado |
|---|---|---|---|---|
| Esquivas do Penitente | Cruzamento, atrás, fora do alcance, recuperação e borda | `m5_c1_encerramento_test.gd`: movimento real cruza a trajetória, fica atrás ou fora do alcance, contra-ataca com espada na recuperação e respeita borda; invulnerabilidade. Salto, recuo e parede já tinham evidência nas suítes anteriores. | O salto precisa ser sincronizado: saltar no começo do aviso pode resultar em aterrissagem antes do golpe; observação preservada. | Cobertura crítica executada. |
| Hitbox do Vigia | Temporalidade e dano residual | Todos os frames amostrados do ataque mantiveram hitbox ativa; recuperação e derrota não causaram dano e houve somente um dano no ciclo. Bordas, direções, cruzamento e salto já eram cobertos antes. | Abaixo da área não é acessível na demonstração: Vigia está sobre piso sólido; não se extrapola para geometria futura. | Cobertura crítica da demonstração executada. |
| Descarregamento | Estados alcançados naturalmente | Para cada um dos três inimigos, aviso, ataque e recuperação foram alcançados pela simulação e descarregados; referências fracas de inimigo, fonte e receptor liberadas; projéteis liberados; uma sala e uma conexão na reentrada. Penitente atingido pela espada também foi liberado em HURT. | Não se reivindica prova para toda futura integração em setores. | Passou no escopo da demonstração. |
| Callbacks | Sinal durante vida e após liberação | Callback de teste foi observado uma vez em aviso/ataque; após descarga e cinco frames não ocorreu chamada tardia, e a referência ao emissor foi liberada. Recuperação foi preservada sem disparar dano artificial. | A janela observada é limitada. | Passou no escopo testado. |
| Sinais | Conexões após reentrada | Verificada uma conexão `hit_received` ao reinstanciar em cada ciclo; ausência de duplicação e referência ao antigo emissor. | Não há prova universal para sinais de funcionalidades futuras. | Passou. |
| Timers | Nós temporizados órfãos | Inspeção dos scripts e cena dos inimigos: não criam `Timer`, `SceneTreeTimer` ou `Tween`; usam contagem `remaining` no próprio nó. O nó e áreas são efetivamente liberados. | As esperas assíncronas da demonstração pertencem ao controlador de sala, não a timers dos inimigos. | Não aplicável aos inimigos; descarga validada. |
| ObjectDB | Comparar carregamento síncrono e assíncrono em condições equivalentes | Mesmo `cloister_pilot.tscn`, obtenção, instanciação, descarregamento e liberação de referência em ambos. Referências fracas da instância e `PackedScene` ficaram inválidas nos dois. Síncrono: sem aviso; assíncrono: sete `RefCounted` no encerramento. Ensaios anteriores de 12 e 48 trocas tiveram a mesma contagem final. | Origem específica dos sete objetos permanece inconclusiva; estabilidade limitada não prova ausência universal de vazamento. | Ressalva documentada, sem acúmulo persistente comprovado no escopo testado. |

### Ensaios e regressão

`tests/m5_c1_encerramento_test.gd`: **78/78 verificações passaram**, com física real para movimentação, colisão e frames de ataque. Nove combinações de três inimigos com aviso, ataque e recuperação foram alcançadas naturalmente. O teste instrumenta conexão e descarga; observar cinco frames não prova ausência de todo possível callback futuro. Os resultados anteriores de **41/41**, **46/46** e **116/116** foram reexecutados separadamente. Não somar rodadas como verificações independentes.

O primeiro teste de contra-ataque falhou porque Aren estava a aproximadamente 62 px, além do alcance da espada; a repetição aproximou Aren por movimento real e verificou a perda de HP do Penitente no frame em que ele ainda estava em recuperação. Os logs iniciais e finais foram preservados. Nenhuma correção de gameplay foi necessária nesta rodada.

Regressão representativa reexecutada: M0 **14**, M1 **36**, sobrevivência **59**, Guardião **59 + 152 + 59**, M5-A **357**, estrutura M5-B **105**, funcional M5-B **2299**, M5-C1 **41**, auditoria anterior **46**, direcionada anterior **116**, continuidade gráfica FIX01 **118** e alvenaria FIX02 **7**; sem falhas nas suítes indicadas. O teste direcionado novo passou 78/78 na última execução. As suítes headless usaram `Godot --headless --fixed-fps 60 --path . --script res://tests/<suite>_test.gd`; continuidade e alvenaria usaram `--disable-vsync` com renderização. Os comandos completos e códigos de saída estão em `regression-results.json` na pasta de evidências. Não se repetiram benchmark e capturas, pois não houve alteração de produção nesta rodada; os resultados históricos de 59,93 FPS e p95 17,117 ms continuam históricos, não medição nova.

### ObjectDB e escopo da ressalva

Comparação controlada com `--headless --verbose`, em processos separados, foi executada por `loader_compare.gd`: `load()` contra `ResourceLoader.load_threaded_request`/`load_threaded_get` da mesma cena, seguida de instanciação, remoção e 20 frames de liberação. Em ambos: `node_alive=false` e `resource_alive=false`. A saída síncrona não apresentou aviso; a assíncrona registrou sete `RefCounted` com contador 0 ao encerrar. Os cinco/seis avisos históricos da Abadia e a estabilidade observada após 12/48 trocas foram preservados; a origem exata dos objetos internos e a relação numérica entre os avisos continuam **inconclusivas**. A ressalva não é promovida a ausência absoluta de vazamentos. Não foi comprovado vazamento persistente associado aos inimigos, e as descargas e sinais críticos da demonstração passaram.

### Estado e evidências

Pasta `C:\PROJETOS\CINZAS DO JURAMENTO`, branch `main`, HEAD `5d4266a3e299d174e1ffabd10e65602d86854d5b`. Índice vazio. `project.godot` e os arquivos locais anteriores foram preservados; nenhuma alteração de gameplay nesta rodada. Criado `tests/m5_c1_encerramento_test.gd`; atualizados este relatório e `tests/VALIDACAO_M5_C1.md`. Evidências exclusivas, incluindo tentativa inicial, comparação ObjectDB, comandos, logs e resultado final: `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5c1-encerramento-20261104-01`. Sem staging, commit, push ou início de M5-C2/M5-C3.

---

## Rodada direcionada posterior — 4 de novembro de 2026

**Resultado: AUDITORIA BLOQUEADA.** O responsável mantém a homologação funcional e visual **16/16 PASSOU — nenhuma observação**. Houve progresso em esquivas, hitbox, descarga e investigação de ObjectDB, mas a matriz obrigatória ainda não foi completamente exercitada. Os resultados das seções seguintes são históricos e não devem ser confundidos com esta rodada.

### Matriz de encerramento

| Área | Exigidos | Executados e aprovados nesta rodada | Falhas remanescentes / estado |
|---|---|---|---|
| Esquivas do Penitente | 12 cenários | Aproximação, salto na antecipação e recuo durante preparação/investida com inputs e física reais; ataques e contra-ataque também cobertos nas suítes anteriores | Outros cenários da matriz não foram isolados; **parcial**. |
| Hitbox do Vigia | Matriz espacial e temporal nas duas direções | Bordas internas com dano, costas sem dano, aviso sem hitbox, início ativo, início da recuperação, morte; salto em subida/ápice/descida. Bordas externas e invulnerabilidade na suíte anterior | Todas as alturas e bordas internas/externas em ambas as orientações ainda não foram cruzadas sistematicamente; **parcial**. |
| Descarregamento | 3 inimigos × 6 estados implementados | 18 fixtures; em cada uma: estado confirmado, conexão única, liberação do inimigo e áreas, ausência de projétil órfão e uma sala residente: 90 verificações | Estados foram atribuídos por fixture; detecção natural, timers/callbacks e todos os casos de parede ainda não foram exercitados separadamente. **Parcial**. |
| Sinais e objetos | Ciclos e evolução de objetos | Uma conexão do receptor em cada fixture; 15 amostras após aquecimento ficaram em 1603 objetos; referências fracas das áreas e inimigos liberadas | A contagem não isola todos os recursos nem comprova ausência absoluta de vazamento. **Parcial**. |
| ObjectDB | Reproduzir, reduzir, comparar, investigar acúmulo | Suíte estrutural e carregamento isolado reproduzidos; controles síncrono e assíncrono, além de 12/48 trocas | Retenção associada ao carregamento assíncrono da cena piloto foi isolada; causa específica de cada objeto e descarte completo seguem **inconclusivos**. |
| F7 complementar | Projetil, investida, hitbox, reação, morte, descarga e reinícios repetidos | Cobertura anterior de projétil, investida, hitbox e morte; novos testes de reação e três reinícios consecutivos | Todas as combinações de referências, sinais e timers após F7 não foram inspecionadas. **Parcial**. |
| Regressão | M5-C1, auditoria, M5-A/B, FIX01/02, C1 e Guardião | Suítes descritas abaixo; todas as executadas terminaram sem falha | Algumas verificações de segurança funcional acima não foram executadas. **Parcial**. |

### Correção comprovada — aviso do Vigia

A hitbox aprovada tem centro horizontal 28 e largura 44, portanto começa em 6 px e termina em 50 px. A linha do aviso começava em 8 px. Aren na borda interna, com centro a 1 px e hurtbox de 12 px de largura, recebeu dano real enquanto sua borda alcançava 7 px, demonstrando diferença de 2 px entre sinalização e hitbox. Antes da correção, a verificação do início do marcador falhou (`pre-fix-console.log`). Alterou-se somente `scripts/abbey/m5c1_visual.gd`: a linha do Vigia começa em 6 px; os outros marcadores mantêm 8 px. A mesma verificação passou depois. A inspeção da expressão gráfica é uma verificação estrutural; não é comparação automatizada de pixels. Hitbox, dano, alcance, IA, animação e parâmetros não foram alterados. Como a linha mudou visualmente, recomenda-se confirmar o detalhe no próximo playtest.

### Física e ciclo de vida

`tests/m5_c1_final_test.gd`: **116/116** verificações passaram na execução final. A IA do Penitente foi deixada atingir o aviso naturalmente: aproximação foi observada, e recuo e salto acionados por inputs permitiram escapar. Um salto iniciado logo no começo do aviso resultou em dano quando Aren já havia descido; esta observação real permanece em `final-v1-console.log` e não foi apagada nem apresentada como falha corrigida. A repetição com salto na parte final do aviso evitou o golpe. O teste não significa que qualquer instante do aviso garanta esquiva.

O Vigia foi testado em subida, no ápice e na descida com salto real; na amostra da descida houve dano após sobreposição. As 18 combinações de três inimigos e estados PATROL/WARNING/ACTIVE/RECOVER/HURT/DEAD foram preparadas por fixture, descarregadas usando `switch_room` e verificadas após frames: referências fracas de inimigo, fonte e receptor foram liberadas, projéteis não ficaram órfãos e não houve duplicação de sala. O teste conta somente uma conexão do sinal de dano por instância; não prova que nenhum callback externo ou temporizador exista.

### ObjectDB — redução do caso

A reprodução prévia com a suíte estrutural gerou seis `RefCounted` ao encerrar. Nesta rodada, uma fixture reduzida carregou e descarregou a Abadia aguardando o carregamento assíncrono terminar: sem trocas e com 12 e 48 trocas, houve cinco `RefCounted` no encerramento; após 12 e 48 trocas a medição final foi de 1562 objetos e um nó da árvore em ambas. Outra fixture reduziu ainda mais: **somente `ResourceLoader.load_threaded_request` + `load_threaded_get` da cena `cloister_pilot.tscn`**, sem instanciar a Abadia nem M5-C1, gerou sete `RefCounted` com contador 0; carregar a mesma cena sincronamente não gerou aviso. Carregar uma textura por esse mesmo caminho assíncrono também não gerou aviso. Isso associa a reprodução ao carregamento assíncrono da cena piloto e suas dependências, mas não identifica a classe interna nem prova por que ocorrem as contagens 5, 6 e 7. **Origem detalhada inconclusiva; sem crescimento progressivo observado no ensaio limitado**, sem afirmar ausência absoluta de vazamento. Não se alterou o carregador homologado.

As primeiras variantes da fixture de ObjectDB foram preservadas, mas não são prova: a primeira não esperava a sala terminar de carregar; a segunda, nos casos 0/1, encerrou com carregamentos pendentes e registrou erros de preload. A variante v3 aguardou explicitamente as solicitações pendentes.

### Regressão, imagem e desempenho

Após a correção visual, `m5_c1_test.gd` passou 41/41 e `m5_c1_audit_test.gd` 46/46; a suíte direcionada passou 116/116. A regressão herdada desta rodada passou M0 14, M1 36, sobrevivência 59, cemitério 52, alcance 35, esqueleto 49, corvo 63, distribuição 115, mecanismos 77, integração 101, Guardião 59+152+59, piloto M5-A 357, estrutura M5-B 105 e funcional M5-B 2299. As suítes gráficas art/presentation/raster/ataque/cohesion/display passaram 18/10/8/46/14/38, e FIX02 passou 7/7. Essas suítes gerais iniciaram antes da alteração visual pontual; as duas suítes M5-C1 e a direcionada foram repetidas após ela. FIX01 gráfico foi executado posteriormente e passou 118/118, com aviso de cinco objetos ObjectDB. Foram geradas 12 capturas nativas dos três inimigos em quatro resoluções; são fixtures de aviso, não avaliação em movimento.

Ensaio de 60 s em janela 3840×2160, RTX 2060 SUPER: 3596 quadros, **59,93 FPS**, p95 **17,117 ms**, máximo **51,461 ms**, pico de 42 nós e um projétil, restando um nó da árvore de teste após a descarga. É instrumento sequencial com vida restaurada, não cobre todos os casos de derrota/F7 e não é medição na TCL. Outras suítes executaram em paralelo. Houve diagnóstico do ambiente de leitura do repositório de certificados.

### Preservação e evidências

HEAD e branch permaneceram `5d4266a3e299d174e1ffabd10e65602d86854d5b` e `main`, índice vazio. Inventário inicial de 39 arquivos locais anteriores: a única alteração entre eles antes da atualização deste relatório foi `scripts/abbey/m5c1_visual.gd`, pela correção descrita. Os 14 arquivos anteriores e `project.godot` foram preservados. Teste novo: `tests/m5_c1_final_test.gd`. Evidências exclusivas, incluindo comandos, erros intermediários e logs: `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5c1-final-direcionada-20261104-01`. Nenhum staging, commit, push ou M5-C2.

**Classificação: AUDITORIA BLOQUEADA por lacunas críticas de cobertura.** O responsável homologou funcional e visualmente os três inimigos: **16/16 passaram, nenhuma observação**. Essa homologação humana é independente dos testes automatizados abaixo; não foram alterados arte, parâmetros, IA ou jogo nesta auditoria.

## Base e preservação

Pasta `C:\PROJETOS\CINZAS DO JURAMENTO`, branch `main`, HEAD `5d4266a3e299d174e1ffabd10e65602d86854d5b`; índice vazio. `project.godot` já estava alterado (SHA-256 `63fddfb499d59cd3ae9b5b70d7d4a8816ccfd8586486c6cfcc3023733bcdcec9`), assim como 14 arquivos antigos não rastreados. Um inventário com hashes dos arquivos locais existentes foi gravado antes das mudanças da auditoria. M5-C1 continua local; não foram iniciados M5-C2/M5-C3, staging, commit ou push.

## Achados e testes

`tests/m5_c1_audit_test.gd` executou **46/46** verificações, sem erros de script. A física real e a hurtbox real foram usadas; estados foram forçados para criar fixtures e, portanto, não demonstram todas as sequências naturais de IA.

- **Acólito:** salto e recuo por entradas reais evitaram o projétil; parede à direita bloqueou detecção e removeu projétil, e projétil sem contato expirou. Primeiro ensaio de parede falhou porque um projétil anterior permaneceu na fixture e atingiu Aren antes da prova; após isolar a sala, o teste passou. Não foi atribuída essa falha inicial ao jogo. A suíte original executou detecção, dano real, recuperação e derrota.
- **Penitente:** patrulha não caiu na plataforma no teste original; a investida foi bloqueada por uma parede à direita e não causou dano através dela. Movimento, ataque, recuperação, dano e derrota foram executados na suíte original. Esquiva em salto e recuo contra sua investida ainda não foram automatizados.
- **Vigia:** forma `AttackSource/CollisionShape2D` retangular **44×12**, com centro horizontal em `facing × 28` e vertical `-14`; alcance frontal local de **6 a 50 px**, em escala unitária. A linha de aviso é desenhada entre 8 e 50 px. Como o receptor de Aren mede **12×24**, a sobreposição pode ocorrer quando seu centro está além de 50 px: isso não significa que a hitbox ultrapasse a linha. Os testes físicos passaram no centro, centro a 54 px (sobreposição), centro a 58 px (fora), atrás, acima, entrando andando e saindo andando antes da ativação; bordas externas e atrás também passaram com o Vigia voltado à esquerda. Invulnerabilidade e desativação depois do ataque passaram. A correspondência integral da borda interna, múltiplas alturas e geometria abaixo ainda não foi comprovada; o trecho de 6–8 px entre hitbox e início da linha exige avaliação adicional antes de declarar a matriz visual/física completa.
- **F7:** evento de teclado real via `Input.parse_input_event`, com cena corrente real, passou durante preparação e ataque dos três, com projétil ativo, após dano, após uma derrota, após as três derrotas e durante morte de Aren. Foram verificados liberação da cena/projétil, vida, sala inicial e ausência de sala duplicada. HUD, câmera, todos os timers e os efeitos em todas as combinações não foram formalmente medidos.
- **Descarga:** 12 trocas sucessivas liberaram a referência fraca ao inimigo anterior e mantiveram apenas uma sala. A prova não mede todos os objetos residentes nem demonstra ausência de crescimento de memória; projéteis, sinais e timers em cada estado ainda exigem matriz própria.

## ObjectDB

Com `--headless --verbose`, uma inicialização mínima da campanha sem M5-C1 e a suíte complementar isolada terminaram sem aviso ObjectDB. A suíte herdada `abbey_chapter_structure_test.gd` reproduziu **6 objetos `RefCounted`** no encerramento (cinco com contador 0 e um com contador 1); a saída não identificou seu tipo mais específico ou origem. A regressão também registrou 6 no capítulo e 5 no teste gráfico da alvenaria. Os 12 ciclos da demonstração não deixaram os inimigos anteriores vivos, mas não são perfil de heap. **Causa e eventual vazamento persistente permanecem inconclusivos**; não houve alteração especulativa nem ocultação de avisos.

## Reconciliação das contagens históricas

As métricas possuem escopos diferentes. Comandos originais e saídas estão em `m5b/results-functional.json`, `m5b/results-regression.json` e `m5c1-20261104-1758/results.json`; ambas as suítes funcionais usaram `--headless --fixed-fps 60 --script res://tests/abbey_chapter_test.gd`. Comparação dos logs reais:

| Grupo | M5-B | M5-C1 anterior | Diferença | Explicação |
|---|---:|---:|---:|---|
| 19 suítes Capítulo 1 | 1005 | 871 | -134 | Seis suítes gráficas: art 18, presentation 10, raster_art 8, horizontal_attack 46, cohesion 14 e display 38 não entraram na soma anterior M5-C1. |
| Piloto físico | 357 | 357 | 0 | Mesmo grupo. |
| Oito verificações nativas M4-C | 8 | 0 | -8 | A rodada nativa de 67 inclui 59 repetidas e oito adicionais, não executadas na soma M5-C1 anterior. |
| Funcional Abadia | 2439 | 2299 | -140 | FIX01 reorientou S4/S10. Cada salto amostrado gera teste de aterrissagem e de visibilidade: S4 caiu de 110 para 80 de cada tipo; S10 de 110 para 70 de cada tipo, total -140. São percursos alterados, não falhas. |
| Estrutura Abadia | 105 | 105 | 0 | Mesmo grupo. |
| Continuidade gráfica FIX01 | 0 | 118 | +118 | Incluída na soma M5-C1, fora do total principal M5-B. |
| **Total publicado** | **3914** | **3750** | **-164** | -134 -8 -140 +118; não equivale a 164 testes reprovados. |

As seis suítes gráficas foram reexecutadas nesta auditoria (134/134). Não foram reexecutadas as oito verificações adicionais da rodada nativa de vitória; não se atribui a elas resultado novo. Não se somam rodadas repetidas como verificações independentes.

## Timeout e regressão

O teste `abbey_continuity_test.gd` verifica explicitamente que não está em headless e aguarda `RenderingServer.frame_post_draw` para capturas e comparação de pixels. A tentativa headless anterior esperou 300 s e não passou; execução com renderização é a adequada para a parte gráfica. A execução gráfica desta auditoria passou **118/118**, incluindo FIX01 e F5; também terminou com aviso de cinco instâncias ObjectDB.

Nesta rodada as suítes funcionais herdadas passaram: M0 14, M1 36, sobrevivência 59, cemitério 52, alcançabilidade 35, esqueleto 49, corvo 63, distribuição 115, mecanismos 77, integração 101, chefe 59+152+59, piloto 357, estrutura 105 e Abadia 2299. A suíte original M5-C1 passou 41/41. Os testes gráficos herdados art/presentation/raster/ataque/cohesion/display passaram 18/10/8/46/14/38; o teste de alvenaria FIX02 passou 7/7, amostrando S4/S5/S9 durante salto real. DISPLAY01 confirmou dimensões nativas de 1280×720, 1920×1080, 2560×1440 e 3840×2160. Não foram reexecutadas todas as suítes gráficas de todos os setores ou a vitória nativa completa.

## Desempenho e evidências

Ensaio real em janela 3840×2160 por 60 s, GPU NVIDIA RTX 2060 SUPER: 3596 quadros, **59,93 FPS**, p95 **16,957 ms**, máximo **51,744 ms**, máximo 42 nós e um projétil; após descarregar restou um nó de teste. O instrumento alterna os três encontros e restaura a vida de Aren; não mede todos os cenários de F7 ou derrotas e não é validação física na TCL. Outras suítes estavam em execução durante a medição. O certificado raiz do ambiente não pôde ser lido; não houve erro de script nas suítes aprovadas.

Doze novas capturas nativas dos três inimigos em quatro resoluções foram salvas em `visual/`; mostram a preparação, não todas as animações. Logs, comandos, inventário inicial e capturas desta rodada estão em `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5c1-auditoria-20261104-01`. Resultados antigos não foram substituídos. Os 36 arquivos locais anteriores comparados por hash, exceto o relatório cuja atualização foi solicitada, permaneceram inalterados.

## Pendências

A matriz integral de esquivas, limites em ambas as direções, paredes à esquerda, detecção em diferentes níveis, descarregamento em todos os estados, estabilidade de objetos/sinais/timers, cenários completos de F7 e cobertura gráfica pedida permanecem incompletos. O aviso ObjectDB segue sem causa comprovada. Não houve correção em gameplay: não foi estabelecido defeito reproduzível cuja causa exigisse alteração. Não classificar a auditoria como integralmente aprovada até resolver as lacunas críticas.

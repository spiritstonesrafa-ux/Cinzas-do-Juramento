# M5-B — Abadia Silenciosa: expansão estrutural

**M5-A — HOMOLOGADO E COMMITADO LOCALMENTE.**

**M5-B — IMPLEMENTADO, PENDENTE DE PLAYTEST E HOMOLOGAÇÃO.**

Registro técnico de 04/11/2026. A aprovação humana 13/13 aplica-se ao M5-A; nenhum dos 30 critérios manuais M5-B foi aprovado por inferência. Sem push ou commit M5-B.

## 1. Etapa A — homologação e commit dos pilotos

Raiz confirmada: `C:\PROJETOS\CINZAS DO JURAMENTO`; branch `main`; baseline publicado `bfae340b2480dfc65dfbe1a6bde7deb7ebcae044`. Instruções locais consultadas; nenhum AGENTS.md aplicável encontrado. README, ROADMAP, GDD, arquitetura, relatórios e planejamento integral consultados. Autoria local já configurada, sem alteração global: Rafael <spiritstonesrafa@gmail.com>.

Homologação explicitamente informada pelo responsável: **M5-A — HOMOLOGADO FUNCIONAL, VISUAL E TECNICAMENTE PELO RESPONSÁVEL. Playtest manual: 13/13 PASSOU — Nenhuma observação.** Inclui qualidade de imagem e fluidez na TCL 4K. Critérios e fonte registrados em [VALIDACAO_M5_A.md](VALIDACAO_M5_A.md), seção 17. Checklist histórico de 30 itens preservado sem converter em 30/30. Resultados técnicos e diagnósticos anteriores mantidos; nenhuma nova execução da engine foi alegada na atualização documental da etapa A.

Commit único local `cf7f0b22eb37bfb83a4da5cf7224e463a7f58bca`: **feat(m5-a): homologa salas piloto da abadia silenciosa**. Autor Rafael <spiritstonesrafa@gmail.com>, branch main, pai igual ao baseline publicado. Inclui os 36 arquivos novos M5-A inventariados no relatório anterior e README/ROADMAP (38 arquivos; 1924 inserções, três remoções). Scripts, cenas, arte e testes dos pilotos foram preservados durante a homologação. O diff completo do índice foi auditado e arquivado externamente em `m5a/stage-a-full-staged.diff`; manifesto exato conferido, referências/UIDs e segredos verificados. Índice vazio e 38 arquivos confirmados após o commit, antes de iniciar M5-B. project.godot e 14 locais anteriores ficaram de fora e intactos. Sem push.

## 2. Como jogar — F6 na cena correta

1. Abra este projeto na Godot **4.7.2**.
2. No painel Arquivos, abra **`res://scenes/abbey/abbey_chapter.tscn`**.
3. Pressione **F6 — executar cena atual**. A cena começa no Átrio dos Votos.
4. A/D ou setas movem; Espaço/W/cima saltam; J usa a espada; **F7 reinicia toda a demonstração**.
5. Siga as setas das portas. Dormitório e Jardim avançam para a esquerda. Todas as ligações permitem retorno.

**F5 continua abrindo o Cemitério, Capítulo 1.** Não substituímos a cena inicial. `abbey_pilots.tscn` continua disponível com F6 como referência aprovada. Alternativa pela engine: `Godot_v4.7.2-stable_win64_console.exe --path "C:\PROJETOS\CINZAS DO JURAMENTO" res://scenes/abbey/abbey_chapter.tscn`.

Fim seguro: **“Fim da versão estrutural da Abadia — M5-B.”** Permite retornar ou usar F7. Não há chefe, falsa batalha, recompensa ou conclusão do capítulo. Progresso só na sessão; fechar/reabrir perde checkpoints/descoberta. Não há transição canônica ao Cemitério.

## 3. Ordem, envelopes de câmera e percurso efetivamente medido

Unidades em pixels lógicos, não pixels da tela. Envelopes são as caixas de câmera; a profundidade dos sólidos não equivale a exploração. Coordenadas são locais em cada setor. Os arquivos `sector_01.tscn` a `sector_12.tscn` estão em `scenes/abbey/sectors/` e possuem identidade exportada própria; geometria autorada centralizada em `chapter_layout.gd`.

| S | Nome e característica espacial | Envelope px | Entrada → saída local | Rota física px | Horizontal absoluto px | Vertical absoluto px | Saltos do navegador | Acumulado px |
|---|---|---|---|---:|---:|---:|---:|---:|
| 1 | Átrio dos Votos — Portal partido · terraços de recepção | 1024×240 | (48,00; 300,00) → (1008,00; 300,00) | 1045,14 | 959,93 | 163,42 | 2 | 1045,14 |
| 2 | Claustro Fraturado — Claustro das Sombras · Votos sem Nome | 1280×424 | (48,00; 300,00) → (1264,00; 228,00) | 1462,18 | 1214,72 | 418,09 | 6 | 2507,32 |
| 3 | Escadaria dos Contrapesos — Ascensão do poço de correntes | 1216×544 | (48,00; 588,00) → (1200,00; 252,00) | 1641,04 | 1150,94 | 807,44 | 14 | 4148,36 |
| 4 | Dormitório das Vigílias — Alcovas em galeria oeste descendente | 1216×400 | (1168,00; 252,00) → (16,00; 444,00) | 1235,75 | 1151,93 | 192,08 | 0 | 5384,11 |
| 5 | Cisternas Votivas — Reservatório baixo · canais minerais | 1344×424 | (48,00; 300,00) → (1328,00; 444,00) | 1478,45 | 1278,53 | 389,09 | 3 | 6862,57 |
| 6 | Galeria dos Turíbulos — Galeria dos Penitentes · Monge e Contrapeso | 1280×232 | (48,00; 300,00) → (1264,00; 300,00) | 1313,86 | 1215,35 | 163,41 | 2 | 8176,42 |
| 7 | Fundição dos Sinos — Duas oficinas · moldes e descanso central | 1472×280 | (48,00; 348,00) → (1456,00; 348,00) | 1636,70 | 1407,76 | 408,43 | 5 | 9813,13 |
| 8 | Ponte dos Penitentes — Travessas separadas · abrigos sobre o vazio | 1216×240 | (48,00; 300,00) → (1200,00; 300,00) | 1410,36 | 1150,52 | 490,10 | 6 | 11223,49 |
| 9 | Arquivo dos Juramentos — Estantes em galerias ascendentes | 1344×424 | (48,00; 444,00) → (1328,00; 228,00) | 1594,69 | 1279,40 | 519,10 | 9 | 12818,18 |
| 10 | Jardim Suspenso — Aqueduto oeste · terraços de vegetação | 1216×280 | (1168,00; 300,00) → (16,00; 276,00) | 1322,47 | 1150,39 | 302,76 | 4 | 14140,65 |
| 11 | Campanário Exterior — Contrafortes em ascensão ao sino | 1280×568 | (48,00; 612,00) → (1264,00; 252,00) | 1737,20 | 1215,92 | 865,11 | 15 | 15877,85 |
| 12 | Coro das Correntes — Bancadas do coro · últimos 240 px seguros | 1408×280 | (48,00; 300,00) → (1392,00; 300,00) | 1482,57 | 1345,43 | 245,09 | 3 | 17360,42 |

**Principal físico: 17360,42 px; fator real 5.6791×** sobre 3056,879979 px do Capítulo 1. Supera a meta 14400 e o mínimo 12227,519916. Soma das larguras não foi usada como prova: a projeção horizontal única conservadora entrada→saída é **14528,00 px**, também acima da meta, registrada separadamente como dado geométrico. O resultado físico inclui os arcos necessários; não se afirma ser o mínimo matemático, speedrun ou duração humana.

A espinha tem nova geometria em cada setor: recepção ampla; claustro escalonado aprovado; ascensão de 336 px na Escadaria; galeria oeste com alcovas e intrados; descida à cisterna e recuperação; galeria de ritmo aprovada; duas alas de fundição e respiro central; três vãos de ponte; arquivo ascendente com coberturas; aqueduto oeste; ascensão de 360 px no Campanário; coro com aproximação final segura. Intrados escuros dos setores 4/5/9 são tetos, sem a borda clara dos pisos; não são destinos de salto. Caixas indicativas e orçamentos por setor do plano foram adaptados à geometria executável, mantendo nomes, ordem e metas globais. Não se alega conteúdo final de encontros nesses espaços.

## 4. Método, transições e limitações da medição

Godot 4.7.2, física M0 original, 60 ticks/s; navegação por Input API e sondas reais de parede/borda. Somada a distância euclidiana entre posições sucessivas dos pés, com componentes horizontal/vertical absolutos publicados. Uma única ida contínua do spawn ao fim, sem resets entre ligações; a volta contínua é validada, mas não soma extensão. Sem dança de combate ou saltos gratuitos em piso livre. Nenhum ramo opcional entrou na rota principal.

Como na referência C1, ameaças foram isoladas apenas no teste de navegação: processamento do Monge/Prensa e fonte ofensiva desativados no fixture. Não é declaração de travessia humana sem dano. Testes antigos do duelo/perigo continuam completos; benchmark também exercita 15 s de encontro vivo integrado depois da rota.

As portas ligam setores adjacentes 1↔2↔3↔4↔5↔6↔7↔8↔9↔10↔11↔12. Cada link liga a saída da tabela à entrada do próximo; no retorno usa a entrada reversa apoiada no patamar final do anterior. Aproximação e saída dentro da sala entram na odometria; **deslocamento técnico do loader contado: 0 px em cada um dos 11 links**. O frame em que `busy` inicia ou o ID muda é descartado, sem extrapolação de comprimento. Origens X=id×4096 isolam as cenas na física, não representam geografia nem distância percorrida. Essa reposição técnica em portas, com espera segura pela colisão, é a conexão modular; não é atalho narrativo nem teleporte para substituir um salto impossível.

Traços completos, posições e deltas por tick: `functional-walking-complete/functional.json`, na pasta externa de evidências. São uma rota reproduzível e conservadora, não medição de média humana. Nenhuma meta de duração 14–22 min foi declarada cumprida. A rodada final contém69 saltos obrigatórios, sem saltar descidas adjacentes caminháveis.

## 5. Navegabilidade e câmera

Altura máxima novamente medida com Aren original: **40,91 px**. Referência homologada de alcance nivelado: aproximadamente 70 px correndo/66,67 px parado, não adotada como vão seguro. Passos principais novos ≤24 px; vãos da ponte 24 px, com desníveis ≤16 px, patamares ≥77 px. Patamares menores do Claustro são os já homologados, mantidos integralmente. As ledges da Galeria têm 24 px de elevação e exigem salto ao atravessar; o navegador usa sonda no corpo, não apenas no pé.

**1130 ensaios físicos locais**: quatro aproximações 8/12/16/20 px nos dois sentidos, mais decolagem parada a 8 px nos dois sentidos. Cada ligação verifica destino/corpo/8 px abaixo visíveis antes de partir e pouso integral apoiado. Descidas adjacentes são caminhadas; vãos são saltados. Fixtures locais usam reset para amostrar situações, mas são adicionais à ida/volta contínuas por inputs. Verificações de dados/espessura/limites são identificadas como geométricas e não substituem física ou playtest.

Câmera 320×180, sem zoom, liderança horizontal 24 px, acompanhamento 600 px/s e clamp por bounds locais. Y original 90…330 é mantido no envelope dos pilotos; extensão horizontal permite visualizar seus conectores. Transição reposiciona a câmera apenas quando o setor e sua física estão prontos; reset de smoothing/scroll evita arrastar câmera da sala anterior. Aren/HUD Nearest; fundos e materiais Linear. F5/Capítulo 1 e DISPLAY01 preservados.

## 6. Arquitetura, carregamento e estado

`chapter.gd`: uma instância de Aren e HUD persistentes; um setor residente. `chapter_sector.gd`: geometria, referência aos pilotos e pontos de integração locais. `chapter_layout.gd`: nomes, perfis, orientação, bounds, entradas/saídas e CPs. `chapter_art.gd`: fundos originais por tema, parallax limitado sem laço, atlas modular, intrados, materiais de água/bronze/vegetação e marcos arquitetônicos. Cenas modulares são carregadas pelo manifesto.

Na troca, Aren para de simular e cancela espada; sala anterior salva apenas HP/derrota do Monge na mesma vida, desarma fontes e é liberada; espera um frame, instancia o destino, instala colisões, espera duas etapas físicas e só então libera Aren. WeakRef, contagem de residentes, identidade do herói/HUD e sinal de respawn verificados. Texturas e cenas-piloto vizinhas são antecipadas via ResourceLoader threaded, retendo referências ao setor atual/vizinhos e ao destino durante o carregamento; a textura atual pertence à sala. Pilotos mantêm seus recursos compartilhados existentes. Não há 12 IAs ou cenários simulando simultaneamente.

Morte/queda limpa snapshots de encontros carregados/descarregados. Descoberta dos Votos sem Nome persiste na sessão; F7 zera a demonstração inteira, CP, descoberta e fim estrutural. Teste real de reload da cena confirma o comportamento. Nenhum sistema global de save foi criado. O fim estrutural é um aviso de sessão, não vitória de chefe.

## 7. Sete checkpoints funcionais e respawn

Nós RespawnCheckpoint originais vivem na raiz estável, com metadado sector_id e mapa de identidade; só o trigger do setor atual tem colisão habilitada. Marcador e trigger coincidem por adaptação local, sem mudar a classe base. O CP descarregado não é considerado seguro até seu setor ser reinstalado. Após morte, o loader carrega o dono antes de chamar o respawn M2 original. Sem cura em queda viva: retorna ao início preservando HP, CP e invulnerabilidade restante.

| CP | Setor | Trigger e marcador local px |
|---|---|---|
| AbbeyCP1 | 2 | (1120,00, 228,00) |
| AbbeyCP2 | 3 | (1178,00, 252,00) |
| AbbeyCP3 | 5 | (1302,00, 444,00) |
| AbbeyCP4 | 7 | (1426,00, 348,00) |
| AbbeyCP5 | 9 | (1296,00, 228,00) |
| AbbeyCP6 | 11 | (1242,50, 252,00) |
| AbbeyCP7 | 12 | (1168,00, 300,00) |

Todos os sete ativaram por contato físico, tiveram suporte e folga reais, sobreviveram ao descarregamento da sala, restauraram HP/HUD após morte distante e na mesma sala, e passaram cinco segundos parados sem depender de invulnerabilidade. Morte no trecho vertical, retorno, troca de CP, várias salas percorridas, morte após queda viva e evento fatal durante handoff assíncrono cobertos. CP7→fim são 224 px horizontais seguros, cerca de 2,24 s a velocidade constante; não há arena implementada. As posições de referência s do plano são orçamento, não coordenadas X; o ritmo final será avaliado com o conteúdo M5-C.

## 8. Pilotos e exploração opcional

Claustro das Sombras instanciado inalterado dentro do setor 2, **Claustro Fraturado**; Galeria dos Penitentes no setor 6, **Galeria dos Turíbulos**. Cada núcleo 960 px recebe um conector de 320 px. Scripts, cenas, arte, parâmetros e teste dos pilotos mantêm hash; nenhuma reimplementação do Monge, espada ou Prensa. O adaptador só atribui alvo, restaura snapshot e encaminha reset/desarme. A arte dos conectores é recortada em X≥960 para não cobrir o monumento original. A demonstração M5-A isolada continua passando.

Ramo existente dos Votos sem Nome: **279,11 px exclusivos físicos**, medidos separadamente desde a junção de decolagem (756,156) até a terceira ledge, por inputs/aterrissagens reais. Não inclui aproximação comum ou retorno; traço em `structure-prefetch-final/structure.json`. Uma descoberta de sessão existente, sem recompensa fictícia/inventário. Meta 3000 px, seis descobertas e três atalhos **não cumprida nem anunciada como cumprida**.

Seis envelopes/Marker2D OptionalReserve e três ShortcutReserve reservam topologia futura M5-E. São descritores com metadados de escopo, não portas ativas, segredos jogáveis ou atalhos que reduzam a espinha. EncounterReserve prepara chão e pontos para M5-C, sem entidades invisíveis ou novos arquétipos.

## 9. Arte, proveniência e evidências

Dez novos fundos originais temáticos, um para cada ambiente novo, gerados com image_gen integrado/skill imagegen e copiados sem edição para assets/art/m5b. Cada PNG 1774×887; prompts integrais, fontes, dimensões e SHA-256 em [PROVENANCE.md](../assets/art/m5b/PROVENANCE.md) e prompts.json. Nenhum asset de terceiro copiado. Atlas arquitetônico e dois fundos M5-A reutilizados sem alteração. Não se apresenta a arte estrutural como acabamento final M5-D.

Terreno modular segue sólidos reais; materiais/recortes variam por setor. Fundos possuem composições distintas de átrio, escadaria, dormitório, cisterna, fundição, ponte, arquivo, jardim, campanário e coro; não é um único fundo esticado por 12 setores. Aren, HUD e identidade dos pilotos preservados. Alguns motivos arquitetônicos compartilham o atlas, deliberadamente; variedade/ritmo e qualidade final aguardam humano.

**189/189 verificações gráficas M5-B, 50 PNGs nativos**: os 12 setores em 1280×720,1920×1080,2560×1440,3840×2160 (48), mais descoberta e fim em 4K (2). Capturas por fixture de composição; não simulam aprovação humana nem timing de combate. Dimensão real e FOV lógico verificados, sem upscale posterior. Imagens finais dos 12 setores em visual-complete; descoberta/fim corrigidos em visual-fixtures-final. visual-summary.json consolida 189 asserts distintos:187 da rodada completa + duas novas verificações de enquadramento (nove asserts executados no recorte final, sete repetidos). Rodadas anteriores visual-final/visual-vaults-final permanecem como histórico; não somadas como novas verificações.

Inspeção visual verificou escala, leitura dos pisos, separação do teto, atmosfera e HUD. Na revisão, a fixture do fim foi corrigida para aguardar a câmera após reposicionamento distante; uma verificação explícita de Aren/piso em quadro foi adicionada a cada fixture final. Isso não alterou câmera ou gameplay. A rodada final refinou intrados para se ligarem à massa arquitetônica superior em vez de parecerem blocos soltos; não mudou colisões ou física. O recorte do conector protege a descoberta aprovada. Qualidade percebida na TCL depende do responsável.

## 10. Regressão executada nesta etapa B

Baseline completo reexecutado, sem editar/enfraquecer testes anteriores. Total principal atual **3914 verificações aprovadas =1370 herdadas +2439 funcionais M5-B +105 estruturais M5-B**. Gráficas separadas: **257=68 M5-A+189 M5-B**. Benchmark possui 24 asserts de sequência/travessia, registrado separado; não infla o principal. Não somar rodadas nem as 59 verificações M4-C repetidas em renderização.

| Suíte reexecutada | PASS | Falhas | SCRIPT ERROR |
|---|---:|---:|---:|
| smoke | 14 | 0 | 0 |
| combat | 36 | 0 | 0 |
| survival | 59 | 0 | 0 |
| cemetery | 52 | 0 | 0 |
| reachability | 35 | 0 | 0 |
| skeleton | 49 | 0 | 0 |
| raven | 63 | 0 | 0 |
| distribution | 115 | 0 | 0 |
| mechanisms | 77 | 0 | 0 |
| art | 18 | 0 | 0 |
| presentation | 10 | 0 | 0 |
| raster_art | 8 | 0 | 0 |
| horizontal_attack | 46 | 0 | 0 |
| cohesion | 14 | 0 | 0 |
| display | 38 | 0 | 0 |
| integration | 101 | 0 | 0 |
| boss | 59 | 0 | 0 |
| boss_advanced | 152 | 0 | 0 |
| boss_victory | 59 | 0 | 0 |
| abbey_pilot | 357 | 0 | 0 |
| c1-victory-native | 67 | 0 | 0 |
| pilot-visual | 68 | 0 | 0 |
| import-final | 0 | 0 | 0 |
| c1-startup | 0 | 0 | 0 |
| pilot-startup | 0 | 0 | 0 |
| chapter-startup | 0 | 0 | 0 |
| M5-B física, estado, percurso | 2439 | 0 | 0 |
| M5-B estrutura/opcional/CP/handoff | 105 | 0 | 0 |
| M5-B gráficos finais | 189 | 0 | 0 |
| M5-B benchmark real | 24 | 0 | 0 |

As 19 suítes C1 somam 1005; M5-A física soma357; oito verificações de resolução M4-C vêm da rodada nativa67 (59 repetidas+8 novas) →1370 principais. M5-A gráficos68 são separados. Guardião: **17/17 PNGs idênticos por SHA-256** às referências M5-A previamente idênticas à auditoria publicada. Importação/editor e inicialização gráfica de campanha, pilotos e Abadia concluíram sem SCRIPT ERROR.

### Diagnósticos e rodadas preservadas

Primeira rodada funcional:1975 checks/29 falhas, enquanto os novos fundos ainda estavam sendo produzidos. O navegador não detectava a ledge baixa da Galeria com a sonda junto ao pé; rota parava no setor6 e invalidava as expectativas subsequentes. Uma fixture de câmera também não esperava o deslocamento após reset distante. Corrigidos somente o navegador do teste (sonda a−16) e a espera da câmera; nenhuma física/ledge homologada alterada. Ensaios físicos locais da geometria não indicaram salto impossível.

Segunda rodada:2427/0, com 1130 ensaios incluindo partida parada. Rodada funcional final anterior aos intrados:2427/0; após inclusão das coberturas:2427/0 novamente. Resultados repetidos não somam novos asserts. Estrutura final105/0 inclui evento fatal durante handoff. Diagnósticos históricos de M5-A ficam no relatório próprio, sem sobrescrever.

A primeira medição de desempenho registrou 258,942 ms no primeiro acesso ao piloto. O adaptador passou a antecipar também a PackedScene aprovada e seus recursos, sem editar o piloto, e a aguardar recursos pendentes sem bloquear frames. O teste acelerado precisou sincronizar com término real do loader:180 ticks simulados podiam terminar antes da leitura em thread. A rodada intermediária teve42 falhas subsequentes por essa espera curta; o sincronismo foi corrigido com conclusão do loader e limite real de10 s, mantendo os asserts. Regressão M5-B e benchmark foram repetidos após isso. As medições anteriores permanecem em performance-final e performance-prefetch-final. No fechamento, a auditoria também detectou que a sonda de chão adiante com12 px fazia o navegador saltar descidas caminháveis. A sonda passou a cobrir32 px, sem mudar o cenário;12 novos asserts exigem exatamente o número de saltos obrigatórios de cada perfil. A ida/volta, a extensão e o benchmark foram repetidos usando descidas caminhadas. Os valores anteriores de extensão não são os resultados finais.

Rodada final com descidas caminhadas:2439/0, incluindo12 asserts específicos para o orçamento de saltos de cada setor.

Ambiente: aviso conhecido de leitura do root certificate store; importação/editor pode informar impossibilidade de gravar editor_settings-4.7.tres no perfil restrito. Isso não foi tratado como sucesso de escrita. Não há SCRIPT ERROR ou falha de referência/recurso nos resultados finais. As mensagens iniciais de fundos ausentes pertencem à primeira rodada antes da cópia/importação, não ao fechamento. LF/CRLF é normalização informada pelo Git, sem diff de gameplay em project.godot.

## 11. Desempenho gráfico real 4K

Godot4.7.2 Compatibility/OpenGL, RTX2060SUPER, framebuffer (3840, 2160); sem --fixed-fps, sem headless. Amostra **171,94 s**, ida física contínua pelos 12 setores, dois ciclos de retorno via loader para verificar residência e 15 s do encontro vivo do Monge integrado. Navegação isola ameaças para medir; ciclos via loader não são comprimento jogável nem playtest manual. Captura e benchmark executados separadamente; não foi alegado teste físico na TCL pelo agente.

| Métrica | Resultado real |
|---|---:|
| FPS médio, incluindo bootstrap/ciclos/encontro | 59,80 |
| p95 / p99 | 17,14 / 17,95 ms |
| Máximo inclusivo | 416,38 ms |
| Travessia após bootstrap, com trocas: FPS / p95 / máximo | 59,98 / 17,12 / 52,38 |
| Entradas / descarregamentos | 37 / 36 |
| Nós monitorados mínimo / máximo | 41 / 88 |
| Primeiro carregamento (inclui espera física) | 308,55 ms |
| Carregamentos posteriores mínimo / máximo (incluem espera física) | 27,93 / 116,88 ms |
| Memória estática amostrada mínima / máxima | 41,81 / 48,54 MiB |
| Texturas amostradas mínimo / máximo | 129,30 / 141,29 MiB |
| Órfãos amostrados máximo | 0.0 |

A amostra intermediária após antecipação dos pilotos reduziu a primeira troca para o Claustro de252,246 para29,960 ms e o pico de travessia de258,942 para61,754 ms. A tabela acima registra a nova amostra final com descidas caminhadas. Picos residuais não têm atribuição conclusiva nesta instrumentação; não se alega ausência de travadas ou60 FPS travados. O máximo inclusivo contém bootstrap; os ciclos rápidos também incluem espera assíncrona maior sem representar o mesmo bloqueio do frame.

O tempo de switch inclui duas etapas físicas assíncronas; não equivale a bloqueio do frame com a mesma duração. A primeira entrada tem criação de recursos/shaders; máximo inclusivo é informado sem esconder bootstrap. A janela de travessia exclui só bootstrap, mantendo transições. Memória é monitor da engine amostrado a cada180 frames, não pico instantâneo ou total do driver; inclui arrays da instrumentação. Compartilhamento/cache de recursos e desenho por setor são limitados; uma amostra não prova ausência absoluta de vazamento ou 60 FPS travados. Séries, rotas e load_ms integrais em performance-walking-final/performance.json.

## 12. Pendências e limites de escopo

- **M5-C:** demais arquétipos, distribuição, novas famílias de perigo, justiça de encontros e ritmo final dos CPs. Só o Monge/Prensa homologados existem nesta região; não preencher densidade com inimigos falsos.
- **M5-D:** acabamento, variedade fina de materiais/motivos, composição por trecho, efeitos e revisão artística de toda a região. Os dez fundos atuais são arte original estrutural, sem alegação de homologação.
- **M5-E:** completar 3000 px opcionais, seis descobertas e três atalhos. Hoje há um ramo/descoberta herdado e reservas de topologia, sem atalhos ativos.
- **M5-F:** homologação da região completa, duração humana, sessões longas e produto final. Regressão desta entrega não conclui esse marco.
- **M6:** segundo chefe não iniciado. Nenhuma arena/falsa batalha criada. Sem conexão canônica, save global ou novas habilidades.
- Sensação de extensão, justiça, conforto de câmera, ausência de trechos vazios e TCL4K dependem do playtest humano. O conteúdo estrutural não representa capítulo com todos os encontros ou duração 14–22 min comprovada.

## 13. Checklist manual M5-B — aguarda responsável

Respostas permitidas: **PASSOU / FALHOU / NÃO TESTADO**. Todos permanecem NÃO TESTADO até declaração humana específica.

| # | Critério | Resultado |
|---|---|---|
| 1 | Acesso à Abadia com F6 | NÃO TESTADO |
| 2 | Entrada no primeiro setor | NÃO TESTADO |
| 3 | Identidade visual da Abadia | NÃO TESTADO |
| 4 | Qualidade dos ambientes | NÃO TESTADO |
| 5 | Diferença visual entre setores | NÃO TESTADO |
| 6 | Exploração horizontal | NÃO TESTADO |
| 7 | Exploração vertical | NÃO TESTADO |
| 8 | Funcionamento da câmera | NÃO TESTADO |
| 9 | Travessia entre setores | NÃO TESTADO |
| 10 | Ausência de travamentos | NÃO TESTADO |
| 11 | Retorno aos setores anteriores | NÃO TESTADO |
| 12 | Plataformas e colisões | NÃO TESTADO |
| 13 | Saltos obrigatórios | NÃO TESTADO |
| 14 | Trechos difíceis, mas justos | NÃO TESTADO |
| 15 | Preservação do Claustro | NÃO TESTADO |
| 16 | Preservação da Galeria | NÃO TESTADO |
| 17 | Monge Acorrentado | NÃO TESTADO |
| 18 | Prensa de Contrapeso | NÃO TESTADO |
| 19 | Checkpoints | NÃO TESTADO |
| 20 | Morte de Aren | NÃO TESTADO |
| 21 | Respawn | NÃO TESTADO |
| 22 | Respawn em setor anterior | NÃO TESTADO |
| 23 | HUD | NÃO TESTADO |
| 24 | Performance | NÃO TESTADO |
| 25 | Imagem na TCL 4K | NÃO TESTADO |
| 26 | Sensação de tamanho da região | NÃO TESTADO |
| 27 | Variedade de exploração | NÃO TESTADO |
| 28 | Ausência de corredores excessivamente vazios | NÃO TESTADO |
| 29 | Encerramento estrutural | NÃO TESTADO |
| 30 | Qualidade geral | NÃO TESTADO |

## 14. Integridade Git e inventário

M5-B não teve staging, commit ou push. main permanece no único commit M5-A. Índice vazio. Rastreados alterados pelo M5-B: somente README.md e ROADMAP.md. Relatório M5-A, pilotos e todo código/cena/arte/testes C1 permanecem byte a byte conforme inventário. project.godot já estava modificado antes desta tarefa e manteve SHA-256 `63fddfb499d59cd3ae9b5b70d7d4a8816ccfd8586486c6cfcc3023733bcdcec9`; não pertence ao M5-B. Os14 não rastreados anteriores permanecem intactos e excluídos, listados no relatório M5-A.

Novos arquivos M5-B:

```text
assets/art/m5b/PROVENANCE.md
assets/art/m5b/archive.png
assets/art/m5b/archive.png.import
assets/art/m5b/atrium.png
assets/art/m5b/atrium.png.import
assets/art/m5b/belfry.png
assets/art/m5b/belfry.png.import
assets/art/m5b/bridge.png
assets/art/m5b/bridge.png.import
assets/art/m5b/choir.png
assets/art/m5b/choir.png.import
assets/art/m5b/cistern.png
assets/art/m5b/cistern.png.import
assets/art/m5b/dormitory.png
assets/art/m5b/dormitory.png.import
assets/art/m5b/foundry.png
assets/art/m5b/foundry.png.import
assets/art/m5b/garden.png
assets/art/m5b/garden.png.import
assets/art/m5b/prompts.json
assets/art/m5b/stair.png
assets/art/m5b/stair.png.import
scenes/abbey/abbey_chapter.tscn
scenes/abbey/sectors/sector_01.tscn
scenes/abbey/sectors/sector_02.tscn
scenes/abbey/sectors/sector_03.tscn
scenes/abbey/sectors/sector_04.tscn
scenes/abbey/sectors/sector_05.tscn
scenes/abbey/sectors/sector_06.tscn
scenes/abbey/sectors/sector_07.tscn
scenes/abbey/sectors/sector_08.tscn
scenes/abbey/sectors/sector_09.tscn
scenes/abbey/sectors/sector_10.tscn
scenes/abbey/sectors/sector_11.tscn
scenes/abbey/sectors/sector_12.tscn
scripts/abbey/chapter.gd
scripts/abbey/chapter.gd.uid
scripts/abbey/chapter_art.gd
scripts/abbey/chapter_art.gd.uid
scripts/abbey/chapter_layout.gd
scripts/abbey/chapter_layout.gd.uid
scripts/abbey/chapter_sector.gd
scripts/abbey/chapter_sector.gd.uid
tests/VALIDACAO_M5_B.md
tests/abbey_chapter_performance_test.gd
tests/abbey_chapter_performance_test.gd.uid
tests/abbey_chapter_structure_test.gd
tests/abbey_chapter_structure_test.gd.uid
tests/abbey_chapter_test.gd
tests/abbey_chapter_test.gd.uid
tests/abbey_chapter_visual_test.gd
tests/abbey_chapter_visual_test.gd.uid
```

52 novos arquivos M5-B, com UIDs necessários e sidecars de importação das fontes PNG. Cache .godot, temporários, logs, exportações e credenciais não entram no versionamento; .gitignore preservado. Auditoria de referências, UIDs e assinaturas de segredo sem problemas. Os242 rastreados fora de README/ROADMAP e os14 locais anteriores mantêm SHA-256. Inventário/hashes externos em inventory.json/final-integrity.json.

Pasta de evidências externa: `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5b`. Logs/comandos e códigos de saída: results-regression.json, results-functional.json, results-structure.json, results-visual.json, results-performance.json. Traços, imagens, benchmark e comparação C1 disponíveis nas subpastas citadas. Históricos de resultados M0–M5-A preservados. Nenhum remoto configurado/alterado, branch trocada, reset/amend/tag/rebase ou operação destrutiva executada.

**Execução encerrada no M5-B. Aguardar playtest e homologação; não avançar para M5-C nem segundo chefe.**


## 15. Revisão M5-B-FIX01 — continuidade e orientação

O responsável aprovou o tamanho geral, mas identificou dois cortes internos de fundo emS2/S6 e confusão direcional. Correção e resultados atuais em [VALIDACAO_M5_B_FIX01.md](VALIDACAO_M5_B_FIX01.md). Os dados/checklist das seções anteriores são o histórico da entrega inicial, não a homologação da correção. S4/S10 agora avançam à direita; somente as junções internasX960 deS2/S6 receberam correção visual. Demais fundos preservados. Sem commit, push ou M5-C. Aguarda novo playtest.


## Homologação do responsável — M5-B

**M5-B — HOMOLOGADO PELO RESPONSÁVEL NO ESCOPO ESTRUTURAL, FUNCIONAL E VISUAL TESTADO.** Extensão principal histórica: **17.360,42 px — 5,6791×** o Capítulo 1; tamanho aprovado. FIX01 e FIX02 aprovados no playtest informado; nenhuma correção visual obrigatória adicional relatada. Não se infere aprovação de 30/30 itens.

Pendência técnica conhecida: investigar futuramente a origem das cinco instâncias ObjectDB registradas ao encerrar uma suíte visual; não há comprovação de vazamento persistente. Três diretórios externos de evidências FIX01 foram sobrescritos em regressão anterior; resultados históricos textuais preservados, sem reconstrução artificial.

M5-C não iniciado. O Capítulo 2 ainda depende de M5-C (inimigos e armadilhas), M5-D (acabamento), M5-E (exploração), M5-F (regressão final) e M6 (segundo chefe). Nenhuma nova execução de engine é alegada nesta homologação documental.

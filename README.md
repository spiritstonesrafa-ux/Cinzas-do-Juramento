> **Estado atual:** M5-D homologado visual e funcionalmente pelo responsável, que informou após o playtest que está tudo OK. M5-C3 permanece encerrado administrativamente com ressalvas, sem converter testes inconclusivos em PASS. O próximo marco previsto é M5-E, de exploração, segredos e atalhos. Consulte o [relatório M5-D](tests/VALIDACAO_M5_D.md) e o [encerramento M5-C3](tests/ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md).

# M5-B-FIX01 — Correção local para novo playtest

Tamanho geral aprovado pelo responsável. Corrigidos somente os cortes internos emX960 do **setor2 — Claustro Fraturado** e do **setor6 — Galeria dos Turíbulos**, preservando os demais fundos. Dormitório(S4) e Jardim(S10) reorientados: avançar sempre à direita, retornar à esquerda. A correção aguarda novo playtest, sem homologação automática.

[Correções, testes e checklist](tests/VALIDACAO_M5_B_FIX01.md). Abra scenes/abbey/abbey_chapter.tscn e use **F6**; **F7** reinicia a Abadia; **F5** mantém o Capítulo1. Sem commit, push ou M5-C. Os resultados M5-B abaixo são históricos; os resultados da revisão estão no relatório FIX01.

# M5-B — Abadia Silenciosa: 12 setores estruturais

**M5-A — HOMOLOGADO E COMMITADO LOCALMENTE.** Commit `cf7f0b22eb37bfb83a4da5cf7224e463a7f58bca`; aprovação manual 13/13, nenhuma observação. Sem push.

**M5-B — IMPLEMENTADO, PENDENTE DE PLAYTEST E HOMOLOGAÇÃO.** 17360,42 px principais medidos pela física (5.6791× o Capítulo 1), sem contar teletransportes/retorno/opcionais. 3914 verificações principais aprovadas; gráficos e desempenho separados no relatório.

Para jogar a Abadia, no painel Arquivos da Godot 4.7.2 abra **`scenes/abbey/abbey_chapter.tscn`** e pressione **F6 (executar cena atual)**. Começa no Átrio dos Votos e permite atravessar os 12 setores e voltar. **F5 continua abrindo o Capítulo 1**, pois a campanha oficial não foi substituída. Alternativa: `Godot_v4.7.2-stable_win64_console.exe --path "C:\PROJETOS\CINZAS DO JURAMENTO" res://scenes/abbey/abbey_chapter.tscn`.

A/D ou setas: andar; Espaço/W/cima: saltar; J: espada; **F7 reinicia toda a Abadia experimental** (progresso só na sessão, sem save em disco). Siga à direita para avançar em todos os12 setores; volte à esquerda para retornar. Sete checkpoints funcionais preservam a identidade quando a sala descarrega. Morte retorna ao checkpoint; queda viva retorna ao início sem curar, conforme as regras existentes. O fim seguro informa **“Fim da versão estrutural da Abadia — M5-B.”**; não conclui o capítulo e permite voltar.

Claustro das Sombras integrado ao setor 2, Claustro Fraturado; Galeria dos Penitentes ao setor 6, Galeria dos Turíbulos. A demonstração aprovada `scenes/abbey/abbey_pilots.tscn` continua independente e funcional. Não há ligação canônica ao Cemitério, segundo chefe ou novos arquétipos. Distribuição de ameaças M5-C, acabamento M5-D e exploração M5-E permanecem para etapas próprias.

[Relatório, métricas e checklist M5-B](tests/VALIDACAO_M5_B.md) · [Proveniência dos dez novos fundos](assets/art/m5b/PROVENANCE.md).

## Registro e acesso dos pilotos M5-A

# M5-A — Abadia Silenciosa: pilotos experimentais

**M5-A — HOMOLOGADO FUNCIONAL, VISUAL E TECNICAMENTE PELO RESPONSÁVEL.**

**Playtest manual: 13/13 PASSOU — Nenhuma observação.** Aprovação informada pelo responsável, incluindo imagem e fluidez na TCL 4K; distinta dos resultados automatizados históricos de 1370 verificações principais e 68 gráficas, sem nova execução nesta homologação. Campanha oficial continua no Cemitério homologado. Para experimentar, abra `scenes/abbey/abbey_pilots.tscn` na Godot4.7.2 e execute a cena atual com F6; ou use o executável da engine com `--path . res://scenes/abbey/abbey_pilots.tscn`. F5 continua iniciando a campanha oficial.

A/D ou setas: andar; Espaço/W/cima: saltar; J: espada; F7: reiniciar os pilotos. No Claustro, siga os patamares até a saída direita e procure a passagem superior dos Votos sem Nome. Na Galeria, enfrente o Monge e leia o aviso do Contrapeso; voltar pela esquerda retorna ao Claustro. O marco à direita encerra a demonstração e permite voltar. Checkpoints de teste não pertencem ao progresso canônico.

Apenas duas salas, um inimigo e um perigo novos. Meta14400 px/12 setores é planejamento, não região concluída. Sem segundo chefe ou transição definitiva. [Validação e checklist](tests/VALIDACAO_M5_A.md) · [Planejamento formalizado](docs/PLANEJAMENTO_CAPITULO_02.md) · [Proveniência](assets/art/m5a/PROVENANCE.md).

## Histórico homologado do Capítulo1 — preservado

# Cinzas do Juramento — M4-C: Conclusão do Guardião

**M4-C — HOMOLOGADO FUNCIONAL E VISUALMENTE PELO RESPONSÁVEL.**

Derrota de 2,6 s com quatro poses originais, dissipação da maldição, armadura
vazia persistente e conclusão de O Cemitério dos Esquecidos. Aren continua
livre e o selo esquerdo abre imediatamente; saída precoce e reentrada seguras.
Dificuldade introdutória, combate, controles, checkpoints e DISPLAY01 intactos.
Sem áudio apropriado no projeto; sem região, chefe, item ou habilidade novos.

**1013 verificações distintas aprovadas:** 946 herdadas + 59 físicas M4-C + oito
de resolução. Novos testes também passaram em renderização: 67/67. Importação
/startup aprovados; 17 capturas finais, sendo 14 nativas 4K e três nas outras
resoluções solicitadas. Amostra gráfica real de 45.0 s:
59.999 FPS médios, p95 17.048 ms, máximo 17.378 ms;
não equivale a homologação humana ou garantia de 60 FPS travados.

M4-B homologado funcionalmente de forma geral, sem bugs relatados ou checklist
29/29 inferido, e registrado no único commit local
`0cd1285f47987477f4ec620978ae9f6d6ec64ea2`.
M4-C registrado nesta entrega local de homologação. Nenhum push nesta tarefa.
Segunda fase do jogo e próximo chefe não iniciados.

[Relatório, regras, evidências e checklist de 30 itens](tests/VALIDACAO_M4_C.md) ·
[Arte de derrota, prompt e proveniência](assets/art/m4c/PROVENANCE.md).
F8/F5 reinicia; vença o Guardião e retorne pelo selo à esquerda.

## Homologação final informada pelo responsável — 04/11/2026

**M4-C — HOMOLOGADO FUNCIONAL E VISUALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 13/13 PASSOU — Nenhuma observação.**

**Validação automatizada anterior: 1013/1013 PASSOU.**

O responsável realizou o playtest humano e aprovou os itens abaixo. O agente
registra essa aprovação; não afirma ter realizado o playtest humano nem infere
aprovação individual dos 30 itens do checklist técnico histórico.

| Nº | Item informado pelo responsável | Resultado |
|---|---|---|
| 1 | Golpe final | PASSOU |
| 2 | Animação de derrota | PASSOU |
| 3 | Dissipação da maldição | PASSOU |
| 4 | Armadura persistente | PASSOU |
| 5 | Barra de vida | PASSOU |
| 6 | Texto narrativo | PASSOU |
| 7 | Controle de Aren | PASSOU |
| 8 | Saída e retorno | PASSOU |
| 9 | Reentrada após vencer | PASSOU |
| 10 | Morte após vencer | PASSOU |
| 11 | Morte antes de vencer | PASSOU |
| 12 | Imagem e fluidez | PASSOU |
| 13 | Sensação de conclusão | PASSOU |

**O primeiro chefe e a conclusão da primeira fase estão homologados.**
Guardião mantido como chefe introdutório: HP, dano, velocidades, quatro padrões,
tempos, cooldowns, recuperações e transformação aos 50% preservados. Nenhum
rebalanceamento, próxima região, segundo chefe ou novo marco foi iniciado.
A próxima região permanece pendente do roadmap; o jogo inteiro não está concluído.

Resultados anteriores preservados: 946 herdados + 59 funcionais + oito de
resolução; execução gráfica 67/67, importação/inicialização aprovadas,
17 capturas em quatro resoluções, sessão de 45,001 s, média 59,999 FPS,
p95 17,048 ms, máximo 17,378 ms e 182 nós estáveis. Suítes, importação,
startup e benchmark não foram repetidos nesta etapa. Houve apenas consulta
auxiliar de integridade da configuração e do PNG na Godot 4.7.2, sem carregar
a cena jogável, sem novos resultados de combate ou desempenho.

Autorizado exatamente um commit local M4-C. Sem push, tag, release ou
sincronização automática. Próximo marco depende de nova autorização.

## Histórico preservado — M4-B homologado

# Cinzas do Juramento — M4-B: Combate avançado

**M4-B — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

Guardião com duas fases aos 50% de vida: pesado original, investida de até 72 px,
varredura baixa e Onda do Juramento. Avisos distintos, direção comprometida,
recuperação e reset de perigos; Aren, arena, arte M3 e DISPLAY01 preservados.
Chama raster original image_gen; identidade e PNG homologado do chefe intactos.

**946/946 verificações funcionais aprovadas** (794 anteriores + 152 novas),
29 capturas finais nativas 4K, importação/inicialização aprovadas. Dois duelos
físicos de 28,15 s: vitória sem dano e com um erro, sem cura ou teleporte.
Medição gráfica real de 45.0 s: 60.00 FPS médios,
p95 17.05 ms; não significa 60 FPS travados ou homologação humana.

M4-A homologado 18/18 e publicado com M3-C/D/E em origin/main, commit
`ab003475e4a39bc5d0b40d33292b54fd5c745404`.
M4-B somente local, índice vazio, sem commit/push. M4-C não iniciado.

F8/F5 reinicia; ao terminar a fase, siga à direita até o Selo do Guardião.
A/D ou setas movem, Espaço/W/cima saltam, J ataca. Após vitória, selo esquerdo.
[Relatório, parâmetros, evidências e checklist manual](tests/VALIDACAO_M4_B.md) ·
[Arte original e prompt da onda](assets/art/m4b/PROVENANCE.md).

## Homologação funcional informada pelo responsável — 03/11/2026

**M4-B — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

Aprovação funcional geral recebida: ataques, transformação, segunda fase,
efeitos, morte de Aren, reinício e estabilidade funcionando normalmente;
nenhum bug relatado. O responsável confirmou: “Sim, tudo funcionando normal.”
Esta aprovação não representa preenchimento individual de 29/29 respostas;
o checklist técnico histórico permanece preservado abaixo.

**Decisão de balanceamento: Guardião do Juramento mantido como chefe introdutório.**

O responsável avaliou o boss como fácil e adequado à introdução/tutorial.
Isso não é defeito. HP, dano, velocidades, avisos, cooldowns, recuperações,
padrões e transformação aos 50% permanecem intactos. O próximo chefe deverá
exigir maior domínio por profundidade de padrões, com dificuldade justa;
não será implementado agora. Decisão registrada em ROADMAP.md.

Preservam-se os resultados técnicos anteriores: 946/946 verificações,
152 também em execução gráfica, 29 capturas 4K e dois duelos de 28,15 s,
sem dano e após um erro; medição real de 45,001 s, média 59,999 FPS,
p95 17,047 ms e máximo 24,717 ms. Não houve reexecução da engine nesta
etapa documental/Git. Avaliação humana e testes do agente são distintos.

Autorizado um único commit local M4-B, sem push. M4-C somente após validar
o commit; segunda fase do jogo e próximo chefe não iniciados.

## Histórico preservado — M4-A homologado

# Cinzas do Juramento — M4-A: Guardião do Juramento

**M4-A — HOMOLOGADO FUNCIONAL E VISUALMENTE PELO RESPONSÁVEL.**

O selo no final do Portão da Catedral abre um vestíbulo de combate com o
Guardião: introdução curta, arena travada, barra de vida, perseguição e um golpe
pesado telegrafado com janela de punição. Arte original com quatro poses; os
assets e sistemas homologados do M3 foram preservados.

**803 verificações distintas aprovadas:** 735 anteriores reexecutadas, 59 M4-A
físicas/funcionais e nove de gravação de capturas 4K. As 59 também passaram na
execução gráfica. Testes não substituem playtest nem medem fluidez prolongada.

Na Godot 4.7.2, F8/F5 reinicia o jogo. Ao concluir a fase, continue à direita
até o **Selo do Guardião**. Controles originais: A/D ou setas, Espaço/W/cima e J.
Após a vitória, volte pelo selo à esquerda. Morte usa o checkpoint já ativo;
queda viva conserva o início original e não cura. Sem novo checkpoint/recompensa.

[Planejamento, resultados, capturas e checklist M4-A](tests/VALIDACAO_M4_A.md) ·
[Sprite original e prompt image_gen](assets/art/m4a/PROVENANCE.md).
Homologação registrada; publicação autorizada conforme auditoria Git. M4-B ainda não iniciado.


## Homologação informada pelo responsável — 03/11/2026

**Playtest manual: 18/18 PASSOU — Nenhuma observação.**

O responsável aprovou selo, apresentação, aparência, escala, travamento da
arena, barra de vida, perseguição, golpe telegrafado, esquiva, dano do chefe,
ataque da espada, reação ao dano, recuperação, derrota, saída, morte durante
a luta, imagem 4K e estabilidade. A avaliação manual foi realizada e informada
pelo responsável, não pelo agente.

Preservam-se os resultados técnicos anteriores: **794/794 verificações
funcionais (735 herdadas + 59 M4-A)** e nove verificações de salvamento de
capturas 4K, total distinto 803. Importação e inicialização anteriores aprovadas.
Nenhuma execução da engine foi repetida na etapa de registro e versionamento.
Os diagnósticos e limitações históricos abaixo permanecem documentados.

Autorizado um único commit M4-A e push fast-forward do histórico homologado.
M4-B será iniciado somente após confirmar o push; M4-C não iniciado.

## Histórico preservado — M3-E homologado

# M3-E — Homologação funcional registrada

**M3-E — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 20/20 PASSOU — Nenhuma observação.**

**Testes automatizados anteriores: 735/735 PASSOU.** Resultados da execução
anterior, preservados sem reexecução nesta tarefa. Sessão gráfica anterior:
231,087 s em 4K, média observada 60,042 FPS, p95 17,342 ms e 160 nós estáveis.
A avaliação manual foi realizada e informada pelo responsável; a auditoria
atual do agente abrange documentação, arquivos e Git. Os 20 itens recebidos
estão registrados no relatório; o checklist histórico de 24 itens não foi
preenchido por inferência.

[Homologação, auditoria, metadados e resultados preservados](tests/VALIDACAO_M3_E.md).
Commit autorizado somente local. Sem push; M4 não iniciado.

## Histórico técnico M3-E preservado

# Cinzas do Juramento — M3-E: Regressão Final e Polimento

**M3-E — IMPLEMENTADO E VALIDADO TECNICAMENTE, PENDENTE DE PLAYTEST MANUAL E HOMOLOGAÇÃO.**

**735 verificações distintas passaram:** 634 anteriores reexecutadas e 101 de
integração nova, também repetidas em sessão gráfica fullscreen 4K de
231.1 segundos. Cobrem dez mortes nos checkpoints, queda sem cura e
percursos encadeados nos dois sentidos. Não houve mudança na arte, mecânicas,
câmera ou configuração DISPLAY01 homologadas. Medições e limitações são
separadas da avaliação manual na TCL.

M3-D completo homologado e registrado no único commit local
`369de2168d798b8e27a92ce406f4cbe666b8207d`. M3-E permanece local, sem staging/commit.
Nenhum push. M4 não iniciado.

[Relatório, métricas, inventário e checklist de 24 itens](tests/VALIDACAO_M3_E.md).

## Histórico preservado — homologação M3-D

## Homologação registrada — 03/11/2026

**M3-D — HOMOLOGADO FUNCIONAL E VISUALMENTE PELO RESPONSÁVEL.**
Abrange M3-D, FIX01, FIX02, FIX03 e DISPLAY01. Aprovação expressamente informada:

> Agora sim, a imagem está boa. E tudo funcionando normal. Essa é a resolução que o jogo deve ter.

Foram aprovados Aren, movimentação/salto/dano, ataque horizontal e integração
corpo/espada, arte dos seis setores, fundos, HUD, nitidez, funcionamento na TCL
4K e preservação da jogabilidade. É homologação geral recebida do responsável;
não significa preenchimento individual de todos os checklists históricos.
Os resultados automatizados anteriores (último total: 634/634), diagnósticos e
limitações abaixo são preservados como histórico, sem alegar nova execução.

Baseline PC mantido: referência lógica 320×180, janela 960×540, canvas_items,
aspecto keep/16:9, escala inteira, Linear em fundos/terreno e Nearest em atores
/HUD. Adapta-se à janela/tela; não está fixado exclusivamente em 4K.

Referências JPG do usuário e seus sidecars continuam locais, sem staging, pois
não são recursos runtime. Originais gerados e proveniência são versionados.
Seleção das capturas históricas do cache preservada em `tests/evidencias/m3d/`;
evidências detalhadas de DISPLAY01 permanecem no diretório persistente indicado
no seu relatório. Nenhum cache inteiro é incluído.

Este registro antecede o único commit local M3-D. M3-E será iniciado somente
após sua validação. Nenhum push autorizado; M4 permanece não iniciado.

## Histórico técnico da implementação (preservado)

# Cinzas do Juramento — M3-D-DISPLAY01

**M3-D-DISPLAY01 — IMPLEMENTADO, PENDENTE DE PLAYTEST E HOMOLOGAÇÃO MANUAL.**

Renderização 2D por `canvas_items`, referência lógica 320×180, janela inicial
960×540, proporção preservada e escala inteira. Fundos e revestimento do terreno
usam Linear; atores e HUD mantêm Nearest. Arte, física, câmera, combate,
colisões, inimigos, perigos e checkpoints preservados.

**634 verificações aprovadas:** 596 de regressão e 38 DISPLAY01. Testes
não substituem avaliação visual na TCL. A aprovação artística anterior de
M3-D/FIX01/FIX02/FIX03 foi informada pelo responsável na solicitação atual;
os registros abaixo permanecem como histórico das respectivas entregas.

[Configuração, evidências, resultados e checklist DISPLAY01](tests/VALIDACAO_M3_D_DISPLAY01.md).
Trabalho local sem commit/push. M3-E e M4 não iniciados.

## Histórico preservado — M3-D-FIX03

# Cinzas do Juramento — M3-D-FIX03: Ataque horizontal e coesão artística

**M3-D-FIX03 — IMPLEMENTADO, PENDENTE DE PLAYTEST MANUAL E HOMOLOGAÇÃO.**

Aren recebeu oito poses específicas de ataque, com preparação, extensão
horizontal e recuperação de tronco, braço, mão, espada e capa. O desenho antigo
da espada foi substituído; a lâmina do novo sprite foi registrada ao alcance
homologado. **Comando J, dano, hitbox 22×14 e ciclo 0,10/0,10/0,20 s intactos.**
Idle, corrida, salto, queda e dano do FIX02 foram preservados.

Portões, Lápides, Ponte e Catedral agora usam fundos originais da mesma família
de materiais do Jardim e das Catacumbas. Pisos e plataformas compartilham
texturas, e inimigos, espinhos, lâmina e checkpoints usam um atlas original.
Os seis setores têm arte raster integrada, com sobreposição nas transições;
geometria, câmera, IA, distribuição e regras de sobrevivência permanecem iguais.

**596 verificações passaram, zero falhas:** 536 anteriores e 60 novas.
Importação e inicialização concluídas com código 0. Há **103 capturas novas**,
incluindo 52 quadros consecutivos do ataque, acertos reais em ambos os inimigos
e dez vistas de transição. A cena conserva 160 nós. Qualidade, fluidez percebida
e desempenho prolongado aguardam seu playtest; não há homologação antecipada.

[Relatório e checklist de 28 itens](tests/VALIDACAO_M3_D_FIX03.md) ·
[Origem dos seis PNGs novos e prompts image_gen](assets/art/fix03/PROVENANCE.md).
A sequência local pode ser aberta em `.godot/fix03_attack_sequence.html`.
Histórico, assets e resultados dos marcos anteriores foram preservados.

Abra `project.godot` na **Godot 4.7.2**, encerre a execução antiga com F8 e use
F5. A/D ou setas movem; Espaço/W/cima saltam; J ataca. O M1 inicia ataque
somente no chão e mantém o golpe já iniciado se Aren saltar, como antes.
Resolução 320×180, nearest e escala inteira preservados.

**Somente alterações locais, sem staging, commit ou publicação. M3-E e M4
não iniciados. Aguardar playtest e homologação do responsável.**

---

## Registro da implementação anterior — M3-D-FIX02

# Cinzas do Juramento — M3-D-FIX02: Amostra de direção artística

**M3-D-FIX02 — IMPLEMENTADO, PENDENTE DE PLAYTEST MANUAL E HOMOLOGAÇÃO.**

O Jardim dos Mortos e as Catacumbas receberam uma amostra com **fundos raster
originais, materiais texturizados e sprites de Aren**, integrada à fase real.
O Jardim combina árvores retorcidas, folhas secas, monumento de luto,
mausoléus e uma necrópole distante; a cripta usa pedra irregular, relevos,
ossários, abóbadas e túneis recuados, com luz fria e focos âmbar.

As duas imagens fornecidas pelo responsável orientaram composição, materiais
e atmosfera. Seus pixels não são usados pelo jogo. Quatro PNGs novos foram
gerados com image_gen integrado e estão em `assets/art/fix02/`; os prompts e
a proveniência constam em [PROVENANCE.md](assets/art/fix02/PROVENANCE.md).

Aren usa oito poses originais, visor âmbar, armadura azul-prateada e capa
vinho. A espada continua separada e segue as fases homologadas. A HUD ganhou
retrato, moldura e cinco segmentos de vida; checkpoints receberam uma órbita
de runas. Corpos físicos, câmera, combate, vida, IA e geometria foram preservados.

**536 verificações aprovadas, zero falhas**: 528 anteriores e oito de integração
dos novos recursos. Importação e inicialização concluídas com código 0;
**41 capturas novas** do viewport real. O desempenho em sessão longa e a
qualidade artística aguardam sua avaliação. Os diagnósticos conhecidos do
ambiente Windows permanecem documentados.

O foco é validar este recorte; os outros setores mantêm a arte do FIX01,
com Aren/HUD atualizados. Não se declara equivalência artística às referências
nem homologação antecipada. [Relatório, evidências e checklist](tests/VALIDACAO_M3_D_FIX02.md).

Abra `project.godot` na Godot **4.7.2**, pare a execução antiga com F8 e use F5.
Controles: A/D ou setas, Espaço/W/cima e J. Resolução 320×180 e escala inteira.
**Somente alterações locais; sem staging, commit ou publicação. M3-E e M4 não
iniciados. Aguardar playtest e homologação manual.**

---

## Registro da implementação anterior — M3-D-FIX01

# Cinzas do Juramento — M3-D-FIX01: Refinamento Visual Avançado

**M3-D-FIX01 — IMPLEMENTADO, PENDENTE DE PLAYTEST MANUAL E HOMOLOGAÇÃO.**

O refinamento diferencia os seis setores: entrada coroada e ornamentada,
terraços funerários e terra irregular nas Lápides, Jardim com ciprestes,
capelas e flores fúnebres, Catacumbas com abóbadas e túneis em perspectiva,
Ponte entre penhascos e névoa inferior e Catedral com vitrais, estandartes,
contrafortes e luz sugerida. Novas camadas intermediárias reforçam a profundidade;
os pisos variam entre terra, pedra musgosa, alvenaria úmida e vãos revestidos.

Aren recebeu um elmo com crista partida, ombreira marcada e capa bordada.
Esqueleto, corvo, perigos e relíquias receberam acabamento adicional. O HUD
ficou mais compacto, o setor passou para o topo direito e as instruções
contextuais para uma faixa inferior. Vida, controles, checkpoints e indicação
de fim provisório continuam informados. Toda a arte permanece original,
desenhada por código Godot, sem recursos externos.

**528 verificações aprovadas, zero falhas**: 518 anteriores preservadas e dez
novas de interface. Importação e inicialização concluídas com código 0.
Produzidas e inspecionadas 37 novas capturas do viewport real, separadas das
evidências anteriores. Física, combate, vida, IA, posições, colisões, câmera,
geometria funcional e dificuldade não foram alterados.

A cena tem 160 nós, contra 159 no M3-D anterior. O fundo reutiliza comandos
enquanto a câmera está parada, com ambiente animado em passos de 7 Hz; textos
só são redesenhados quando mudam. As medições são amostras curtas e variáveis,
sem garantia de desempenho em sessão longa ou outra máquina. Os diagnósticos
conhecidos de certificados e escrita no perfil Windows permanecem documentados.

Abra `project.godot` na **Godot 4.7.2**, pare a execução antiga com F8 e use F5.
A/D ou setas movimentam, Espaço/W/cima saltam e J ataca. A arte ambiental é
composta em execução; o editor ainda pode exibir os polígonos provisórios.
Resolução 320×180 e escala inteira preservadas.

[Relatório do FIX01, resultados, limitações e checklist de 24 itens](tests/VALIDACAO_M3_D_FIX01.md).
**Somente alterações locais, sem staging, commit ou publicação. M3-E e M4 não
iniciados. Aguardando playtest e homologação manual do responsável.**

---

## Registro da implementação anterior — M3-D

# Cinzas do Juramento — M3-D: Arte e Ambientação

**M3-D — IMPLEMENTADO, PENDENTE DE PLAYTEST MANUAL E HOMOLOGAÇÃO.**

O Cemitério dos Esquecidos recebeu composição original em grade de pixels:
pedra e terra texturizadas, portões de ferro, lápides, estátua funerária,
mausoléus, catacumbas com arcos e ossários, ponte sobre aqueduto arruinado e
catedral com vitrais quebrados. Céu, lua, ruínas e árvores usam parallax sutil;
névoa, cinzas e velas completam a ambientação. A paleta combina azuis e cinzas
frios com vinho, marfim, turquesa e dourado pontuais.

Aren ganhou armadura, capa animada e poses de corrida, salto, queda, ataque,
dano, morte e reaparecimento. Esqueleto e corvo receberam silhuetas, animações
e sinais de ataque mais definidos. Armadilhas têm metal e estados distintos;
checkpoints são relíquias luminosas e a vida ganhou moldura e ícones temáticos.
Toda a arte desta etapa é desenhada por código Godot, sem assets externos.

Abra `project.godot` na Godot **4.7.2**, encerre a execução anterior com F8 e
inicie com F5. A arte ambiental é composta em execução; o editor pode ainda
mostrar os polígonos provisórios. A/D ou setas movimentam, Espaço/W/cima
saltam e J ataca. Resolução **320×180**, escala inteira e filtro nearest
preservados. Física, colisores, cenário funcional, câmera, combate, IA,
distribuição, dano e regras de checkpoints permanecem homologados e intactos.

**518 verificações passaram, zero falhas:** 500 de regressão e 18 novas
verificações de integridade visual. Importação e inicialização terminaram
com código 0. A nova suíte também foi executada com renderização gráfica real.
Foram produzidas 37 capturas após a arte e seis do baseline para comparação;
a inspeção pelo agente não substitui o playtest do responsável.

Na amostra gráfica de 120 quadros, a cena passou de 157 para 159 nós e de 24
para 197 chamadas de desenho. A medição curta e com cadência fixa não certifica
desempenho em outras máquinas. Permanecem os avisos de certificados e de
escrita das configurações da Godot no perfil Windows, sem erro de script
identificado nas execuções. Resultados, evidências, limitações e checklist
manual de 24 itens: [VALIDACAO_M3_D.md](tests/VALIDACAO_M3_D.md).

**Entrega somente local, sem staging, commit ou publicação. M3-E e M4 não
iniciados. Aguardando playtest e homologação manual do responsável.**

---

## Registro histórico homologado — M3-C

# Cinzas do Juramento — M3-C: Armadilhas e Checkpoints

**M3-C — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 22/22 PASSOU — Nenhuma observação.**
Homologação realizada e informada pelo responsável, distinta dos testes anteriores.

A versão homologada M3-B3 foi publicada na `main` do repositório
[Cinzas-do-Jugamento](https://github.com/spiritstonesrafa-ux/Cinzas-do-Jugamento),
no commit **3695eb2b350837cc7622e025e2d05c350b3e2ffc**. A união autorizada
preservou os históricos do projeto e da licença MIT, sem force push.
**M3-C autorizado para um único commit local; sem push ou publicação desta entrega.**

Abra `project.godot` na Godot 4.7.2, pare a execução antiga com F8 e inicie com F5.
A/D ou setas movimentam, Espaço/W/cima saltam e J usa a espada existente.

| Elemento | Posição | Como atravessar/usar |
|---|---|---|
| Espinhos fixos — entrada do Jardim | (824,140) | Saltar da parte plana para o desnível, nos dois sentidos. |
| Lâmina vertical — Catacumbas | origem (1384,176), Y=148–204 | Observar e caminhar quando a lâmina estiver alta; corrente não causa dano. |
| Espinhos temporizados — Catedral | (2016,156) | Observar SAFE → WARNING (!) → ACTIVE → RECOVER; esperar ou saltar. |
| CP1 — saída do Jardim/primeiro degrau das Catacumbas | (1176,180) | Bandeira I ativa automaticamente ao contato. |
| CP2 — piso firme após a Ponte | (1936,156) | Bandeira II substitui CP1 e permanece válida no retorno. |

Há **três armadilhas e dois checkpoints**. Portões e Lápides não receberam
armadilhas; os vãos e aterrissagens da Ponte também ficaram livres. Os seis
inimigos mantêm exatamente as posições, atributos, detecção e patrulhas homologadas.

A lâmina tem raio perigoso de 10 px, curso vertical de ±28 px e período de 2,8 s.
A grade temporizada usa 1,5 s segura, 0,6 s de aviso, 0,8 s ativa e 0,4 s de
recuperação. Somente ACTIVE possui área perigosa. Cada contato válido retira
1 HP pelo M2; a proteção continua 0,8 s. Permanecer sobre um perigo pode causar
novo dano após essa proteção expirar, conforme a regra original.

As bandeiras mudam de azul para âmbar ao ativar. Não é preciso apertar um botão.
Ao morrer, Aren retorna ao checkpoint válido mais avançado e recupera 5 HP.
Atravessar CP1 depois de CP2 não retrocede a progressão. **Cair vivo continua
retornando ao início (48,156), sem curar HP e sem apagar o checkpoint ativo.**
Morte e queda restauram os inimigos e as fases das armadilhas; CPs são locais à
sessão, sem save persistente. O antigo marcador CP1 em (1040,156) era inseguro
por estar no encontro do corvo; a posição efetiva usa o primeiro degrau seguro
após o Jardim. CP2 aproveita o piso largo já marcado após os vãos.

## Resultados da implementação anterior

**500 verificações passaram, zero falhas**: as 423 anteriores e **77 M3-C**.
Importação e inicialização concluíram com código 0. As regressões anteriores
usam uma fixture preservada do cenário B3, com todas as asserções mantidas;
a suíte nova carrega o cenário M3-C real e cobre armadilhas, checkpoints,
restauração, combate e travessia com os seis inimigos ativos.

No percurso contínuo M3-C: **ida 5→4 HP, volta 4→3 HP**, sem morte, cura,
teleporte ou reset durante o percurso. Ensaios locais passaram sem dano pelos
três perigos nos dois sentidos; o encontro final com a grade funcionando também
passou sem dano. Isso não certifica ausência de dano em qualquer abordagem.
Onze capturas renderizadas foram inspecionadas. Persistem os diagnósticos
conhecidos de certificados e escrita de configuração no perfil Windows.

Arquitetura, inventário completo, resultados, limites dos testes e checklist
manual histórico e homologação recebida: `tests/VALIDACAO_M3_C.md`.

```powershell
godot --headless --path . --import
godot --headless --path . --quit-after 60
godot --headless --path . --fixed-fps 60 --log-file .godot/c-mechanisms_test.log --script res://tests/mechanisms_test.gd
```

## Homologação manual informada pelo responsável — 03/11/2026

**M3-C — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 22/22 PASSOU — Nenhuma observação.**

O responsável realizou o playtest completo no Godot e aprovou:

1. Espinhos visíveis.
2. Dano dos espinhos.
3. Salto sobre espinhos.
4. Lâmina oscilante.
5. Esquiva da lâmina.
6. Armadilha temporizada.
7. Ciclo de ativação.
8. Invulnerabilidade.
9. Checkpoint 1.
10. Checkpoint 2.
11. Morte no CP1.
12. Morte no CP2.
13. Queda com vida.
14. Restauração dos inimigos.
15. Respawn seguro.
16. Percurso de ida.
17. Percurso de volta.
18. Ponte das Almas.
19. Encontro final.
20. Controles e câmera.
21. Dificuldade geral.
22. Estabilidade.

Decisão do responsável: M3-C homologado funcionalmente, sem correção obrigatória
identificada. A homologação foi realizada e informada pelo responsável; não é
uma auditoria independente nem um playtest executado pelo agente nesta tarefa.

Preservados os resultados automatizados anteriores: 500/500 verificações,
incluindo 423 dos marcos anteriores e 77 do M3-C, importação/inicialização,
11 capturas, ida 5→4 HP, volta 4→3 HP, travessias locais e combate final sem dano.
Diagnósticos Windows, falhas históricas de desenvolvimento e limitações técnicas
permanecem documentados. A homologação humana não amplia a cobertura dos testes.

Nesta etapa somente README e relatório receberam alterações documentais.
Engine e suítes não foram reexecutadas. Implementação, cenas, parâmetros,
coordenadas e regras homologadas foram preservados. M3-D não iniciado.

**M3-C NÃO PUBLICADO. M3-D NÃO INICIADO.**
Encerrar após o único commit local autorizado; aguardar nova autorização. Sem push ou deploy.

---

## Registro histórico homologado M3-B3

# Cinzas do Juramento — M3-B3: Distribuição dos inimigos

**M3-B3 — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 10/10 PASSOU — Nenhuma observação.**
Resultado realizado e informado pelo responsável, distinto das verificações do agente.
Baseline conferido: `main`, `56988ead853f65ad19a30036ce534ad5db32d030`,
árvore e índice inicialmente limpos. Os marcos anteriores permanecem homologados.

Abra `project.godot`, pare uma execução antiga com F8 e inicie com F5.
A/D ou setas movimentam; Espaço/W/cima saltam; J usa a espada.

| Setor | Encontro | Coordenadas iniciais |
|---|---|---|
| 1 — Portões | Nenhum; introdução segura | — |
| 2 — Lápides | Esqueleto original | (744,140) |
| 3 — Jardim | Corvo original | (1050,112) |
| 4 — Catacumbas | Um esqueleto no piso central | (1328,220) |
| 5 — Ponte | Um corvo no acesso firme, antes dos vãos | (1552,112) |
| 6 — Catedral | Esqueleto e corvo, separáveis por posição | (2120,156), (2188,112) |

São seis inimigos: três de cada espécie. Nas Catacumbas foi usado um esqueleto,
em vez dos dois propostos, para preservar recuo e aterrissagens no piso de 160 px.
Não há inimigos nas escadas. Na Ponte, o corvo tem detecção local de 38 px e
patrulha de ±8 px: o combate acontece no piso X=1504–1600. É possível esquivar
lateralmente, virar e contra-atacar no chão antes de iniciar os saltos.
Não salte antecipadamente apenas pelo aviso se isso prejudicar sua saída da borda.

No último setor, aproxime o esqueleto pela esquerda e resolva a ameaça terrestre
antes de avançar até o corvo. No retorno, é possível inverter a ordem. Os testes
físicos concluíram ambas as sequências com zero dano, duas vezes cada, sem
reposicionar Aren, curar ou reiniciar inimigos entre os dois combates.
Ao inverter uma caminhada para esquivar, considere a frenagem original de Aren.

Não foram alterados HP, dano, velocidades, temporizações ou código global dos
inimigos. Somente limites e alcances de instâncias novas foram ajustados.
Física de Aren, espada, sobrevivência, restauração, geometria, câmera e marcadores
provisórios permanecem intactos. Não há checkpoints novos, armadilhas ou chefe.

## Validação da implementação anterior do M3-B3

Godot **4.7.2.stable.official.ed1daf0bf**: importação e inicialização concluídas,
código 0. **423 verificações aprovadas, zero falhas**: 14 M0 + 36 M1 + 59 M2 +
52 M3-A + 35 FIX01 + 49 M3-B1 + 63 M3-B2 + **115 M3-B3**.
A suíte M3-B2 recebeu somente a atualização da quantidade planejada para seis;
suas 63 verificações foram mantidas. As outras suítes antigas não foram editadas.

O percurso contínuo com todos os inimigos ativos completou ida e volta, sem
teleporte, cura, morte ou retorno durante o percurso: **5→5 HP na ida e 5→4 na
volta**. Um retorno independente, iniciado com os seis inimigos vivos, passou
**5→5 HP**. Os ensaios locais de Catacumbas e Ponte passaram sem dano nos dois lados.
Isso demonstra estratégias controladas; não certifica ausência de dano em
qualquer abordagem nem substitui o balanceamento pelo responsável.

Oito capturas renderizadas dos setores/ponte foram inspecionadas. Persistem os
diagnósticos conhecidos de certificados e escrita de configuração no perfil,
sem erros observados de script/recurso. Evidências, parâmetros por instância,
limitações, roteiro histórico de 16 itens e homologação recebida: `tests/VALIDACAO_M3_B3.md`.

```powershell
godot --headless --path . --import
godot --headless --path . --quit-after 60
godot --headless --path . --fixed-fps 60 --log-file .godot/b3-distribution_test.log --script res://tests/distribution_test.gd
```

## Homologação manual informada pelo responsável — 03/11/2026

**M3-B3 — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 10/10 PASSOU — Nenhuma observação.**

Funcionalidades aprovadas no playtest completo realizado pelo responsável:

1. Setor inicial seguro.
2. Caminho das Lápides.
3. Jardim dos Mortos.
4. Catacumbas.
5. Ponte das Almas.
6. Portão da Catedral.
7. Percurso de ida e volta.
8. Morte e restauração.
9. Regressão e câmera.
10. Dificuldade geral.

A homologação foi realizada e informada pelo responsável. Não constitui uma
auditoria independente do agente nem uma nova execução dos testes automatizados.
Preservados os resultados anteriores: 423 verificações, incluindo 115 M3-B3,
ida 5→5 HP, volta 5→4 HP, retorno independente 5→5 HP e encontro final sem dano
nas duas ordens, duas vezes cada. Importação/inicialização, oito capturas,
diagnósticos Windows e limitações técnicas permanecem documentados.

Nesta etapa somente README e relatório foram atualizados. Engine e suítes não
foram reexecutadas. Código, cenas, coordenadas, limites de patrulha, atributos,
IA e balanceamento homologados foram preservados. M3-C permanece não iniciado.

Entrega autorizada para um único commit local. **Sem push, deploy ou publicação.**
**M3-C e marcos posteriores não iniciados; aguardar nova autorização.**

---

## Registro histórico homologado M3-B2

# Cinzas do Juramento — M3-B2: Corvo Amaldiçoado

**M3-B2 — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 14/14 PASSOU — Nenhuma observação.**
Resultado realizado e informado pelo responsável, distinto das verificações do agente.
Baseline: `main`, `3d3bf96e57f4c619684152e5a93da9c88ad3a039`, árvore inicialmente limpa.
Os marcos anteriores permanecem homologados historicamente. M3-B3 e marcos
posteriores não foram iniciados. Entrega autorizada para um único commit local,
sem push, deploy, exportação ou publicação.

## Jogar e contra-atacar

Pare uma execução antiga com F8 e inicie com F5. Há um único **CursedRaven** em
**(1050,112)**, sobre o piso seguro do Jardim dos Mortos (setor 3/6). Sua patrulha
horizontal vai de X=1030 a 1070. O esqueleto original continua nas Lápides.
O terreno, a câmera, os comandos e os parâmetros de Aren foram preservados.

O corvo voa sem causar dano por contato em IDLE/PATROL. Ao detectar Aren apoiado
no chão, visível e até 110 px de distância, mostra **!** e para por **0,45 s**.
A posição-alvo fica fixada nesse momento; a investida não acompanha a esquiva.
Afaste-se lateralmente durante o aviso. O corpo voa em linha reta a **85 px/s**,
por até 96 px, parando ao chegar ao ponto previsto ou encontrar um sólido.
Somente DIVE ativa a fonte de dano; um contato válido causa **1 HP**, respeitando
os **0,8 s** de proteção M2, sem repetir dano no mesmo ataque.

Depois da investida, há uma pausa baixa e inofensiva de **0,55 s** para o
contra-ataque. Vire-se para o corvo e use **J** com Aren no chão. Ele tem **2 HP**;
dois golpes M1 válidos o derrotam. Um acerto o deixa claro e interrompe o ataque.
A espada não ganhou alcance ou ataque vertical. O teste físico confirmou a
esquiva e os dois contra-ataques tanto pela esquerda quanto pela direita.

Após a pausa, o corvo retorna fisicamente à origem a 24 px/s. RECOVER inclui
essa viagem, portanto pode durar mais que 0,55 s. O intervalo mínimo entre
avisos é 1,8 s; não há nova investida antes de voltar à patrulha. Se sair da
tela durante o aviso, a investida é cancelada. Paredes também bloqueiam visão.
A aquisição exige apoio no chão e diferença vertical do alvo de até 48 px;
a esquiva continua livre durante o aviso/investida.

O corpo do corvo não bloqueia Aren. É possível evitar o encontro e prosseguir.
Derrotado, ele permanece inclinado e inativo até a restauração do cenário.
Ao morrer ou cair fora do mapa, Aren mantém as regras M2/B1 e os dois inimigos
restauram posição, HP, direção, temporizadores e colisores iniciais.

## Arquivos e validação M3-B2

- `scenes/enemies/cursed_raven.tscn`: corpo 14×10, SwordReceiver e fonte M2 separados.
- `scripts/enemies/cursed_raven.gd`: estados IDLE/PATROL/ALERT/DIVE/RECOVER/HURT/DEAD.
- `scripts/enemies/raven_attack_source.gd`: contrato DamageSource existente,
  janela ativa e consumo único do contato por investida.
- `scripts/enemies/raven_visual.gd`: corpo, bico, asas, olhos e poses originais.
- `tests/raven_test.gd`: testes físicos de rotina, espada, dano, colisões,
  visibilidade, esquiva, retorno e travessia nos dois sentidos.
- `tests/VALIDACAO_M3_B2.md`: auditoria, resultados, inventário e checklist manual.

Resultados da implementação anterior, preservados neste registro:
Godot **4.7.2.stable.official.ed1daf0bf**. As suítes executadas passaram em
**308 verificações**, sem falhas: 14 M0 + 36 M1 + 59 M2 + 52 M3-A + 35 de
navegabilidade + 49 M3-B1 + 63 M3-B2. Os testes anteriores não foram editados.
As duas suítes estruturais continuam isolando a IA; as suítes dos inimigos
verificam os encontros ativos. Importação e inicialização concluíram com código 0.
Persistiram os diagnósticos de certificados/perfil já documentados.
Sete capturas renderizadas foram inspecionadas, incluindo duas poses de asas;
essas capturas não constituem playtest humano ou homologação automática.
A engine e as suítes não foram reexecutadas nesta etapa de documentação e
versionamento; somente os registros documentais foram atualizados.

```powershell
godot --headless --path . --import
godot --headless --path . --quit-after 60
godot --headless --path . --fixed-fps 60 --log-file .godot/b2-raven_test.log --script res://tests/raven_test.gd
```

Os padrões configuráveis incluem HP 2, dano 1, patrulha 24 px/s, investida
85 px/s, detecção 110 px, aviso 0,45 s, intervalo 1,8 s e pausa de recuperação
0,55 s. Não foi alterado nenhum sistema de Aren ou combate do esqueleto.

## Homologação manual informada pelo responsável — 03/11/2026

**M3-B2 — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**Playtest manual: 14/14 PASSOU — Nenhuma observação.**

Funcionalidades aprovadas no playtest do responsável:

1. Aparência.
2. Patrulhamento aéreo.
3. Detecção.
4. Aviso do ataque.
5. Investida.
6. Esquiva.
7. Dano causado.
8. Invulnerabilidade.
9. Contra-ataque.
10. Morte do Corvo.
11. Recuperação.
12. Restauração.
13. Integração com sistemas anteriores.
14. Progressão pelo cenário.

A aprovação foi realizada e informada pelo responsável; não é uma auditoria
independente do agente. Preservados os resultados automatizados anteriores,
os testes físicos nos dois sentidos, as sete capturas, os diagnósticos e as
limitações técnicas. Código, IA, parâmetros, cenas e posicionamento não foram
alterados nesta etapa. M3-B3 permanece não iniciado.

**Encerrar após o único commit local do M3-B2; aguardar nova autorização.**

---

## Registro histórico homologado M3-B1

# Cinzas do Juramento — M3-B1: Esqueleto Patrulheiro

**M3-B1 — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**11/11 PASSOU — Nenhuma observação.** Resultado manual informado pelo responsável.
Baseline: `main`, `3e5a89781788a09f759e1bc21d6931c498cf2470`, árvore inicialmente limpa.
M0/M1/M2/M3-A/FIX01 permanecem homologados historicamente. A autorização atual
abrange somente o primeiro inimigo; Corvo, M3-B2/B3 e M3-C não iniciados.

## Jogar e verificar o inimigo

Pare uma execução antiga com F8 e inicie com F5. Use A/D ou setas,
Espaço/W/cima e J. Há **um** esqueleto em **(744,140)**, no piso plano
`GraveSlabC` do Caminho das Lápides (X=672–848). Patrulha X=704–784; o spawn
original fica distante, em (48,156). O mapa, os vãos e a câmera não mudaram.

O esqueleto começa parado e patrulha. Detecta Aren a 85 px, com diferença
vertical até 18 px e visão sem parede. Persegue a 35 px/s dentro dos mesmos
limites seguros, parando em bordas e paredes. Ao perder Aren por 0,6 s, volta
à patrulha. O corpo não bloqueia Aren: é possível passar ou saltar pelo encontro.

A 24 px inicia um golpe com **0,25 s de preparação**, **0,12 s de janela ativa**
e **0,35 s de recuperação**, com direção fixa e intervalo mínimo entre inícios
de **1,2 s**. A espada erguida sinaliza preparação, a lâmina horizontal clara
indica o golpe e a pose abaixada indica recuperação. Apenas a janela ativa
pode aplicar dano, respeitando paredes e a invulnerabilidade M2 de 0,8 s.
Contato com o corpo não causa dano. Um golpe válido tira 1 HP de Aren.

**J** utiliza a espada M1 original: cada golpe tira 1 dos **3 HP** do inimigo.
O esqueleto fica claro e atordoado por 0,18 s; receber o golpe cancela seu ataque.
Após três acertos válidos ele cai e fica inativo, sem colisões ou loot.
Ao morrer e reaparecer, ou cair vivo para fora do mapa, Aren retorna pelas
regras existentes e os inimigos da fase restauram posição, HP, direção,
temporizadores e colisões iniciais. Não há save de inimigos derrotados.

## Arquivos e integração M3-B1

- `scenes/enemies/skeleton_patrol.tscn`: inimigo reutilizável com corpo, visual,
  hurtbox de espada e fonte ofensiva separados.
- `scripts/enemies/skeleton_patrol.gd`: estados IDLE/PATROL/CHASE/ATTACK/HURT/DEAD,
  HP, limites, visão, bordas, ataque e restauração.
- `scripts/enemies/skeleton_visual.gd`: caveira, armadura, membros e arma geométricos.
- `scripts/enemies/skeleton_attack_source.gd`: janela ofensiva, acerto único por
  alvo por golpe e bloqueio por parede, usando entrega de contato M2.
- `scripts/combat/sword_receiver.gd`: contrato `receive_hit()` compartilhado pelo
  alvo original e hurtboxes de inimigos. Espada mantém fases/alcance/deduplicação.
- `tests/skeleton_test.gd`: encontro real e sondagens de bordas, paredes,
  múltiplos inimigos, ataques, morte e retorno.
- `tests/VALIDACAO_M3_B1.md`: auditoria, inventário, comandos e checklist completo.

Valores principais expostos no Inspector: HP 3, dano 1, patrulha 25 px/s,
perseguição 35 px/s, detecção 85 px, ataque 24 px, intervalo 1,2 s.
Aren continua com o mesmo controlador, parâmetros, HP e proteção; somente os
contratos de recepção de espada e de fonte de contato receberam adaptadores.

## Validação automatizada da implementação anterior

Godot **4.7.2.stable.official.ed1daf0bf**. Importação e inicialização headless
concluíram com código 0. Suítes finais: **14 M0 + 36 M1 + 59 M2 + 52 M3-A +
35 de navegabilidade + 49 M3-B1 = 245 verificações**, zero falhas.

M3-A tem agora 52 asserções porque o laço original também verifica o novo nó
`Enemies`. Seus testes estruturais e os de navegabilidade desativam a IA para
isolar o terreno; o teste M3-B1 verifica o encontro ativo e a passagem sem combate.
As três suítes M0/M1/M2 não foram editadas. Houve os diagnósticos de ambiente
já conhecidos sobre certificados e escrita de editor_settings, registrados no relatório.
Seis capturas gráficas de patrulha/perseguição/ataque/dano/morte foram inspecionadas;
essas capturas não são um playtest humano. A homologação funcional posterior
foi realizada pelo responsável e está registrada abaixo.

```powershell
godot --headless --path . --import
godot --headless --path . --quit-after 60
godot --headless --path . --fixed-fps 60 --log-file .godot/b1-skeleton_test.log --script res://tests/skeleton_test.gd
```

## Homologação manual informada pelo responsável — 03/11/2026

**M3-B1 — HOMOLOGADO FUNCIONALMENTE PELO RESPONSÁVEL.**

**11/11 PASSOU — Nenhuma observação.**

Funcionalidades aprovadas no playtest do responsável:

1. Aparência.
2. Patrulhamento.
3. Detecção.
4. Perseguição.
5. Ataque.
6. Dano causado.
7. Invulnerabilidade.
8. Dano recebido.
9. Morte do inimigo.
10. Restauração após morte ou queda de Aren.
11. Regressão dos sistemas anteriores.

A homologação acima foi realizada e informada pelo responsável. Ela é distinta
das 245 verificações automatizadas executadas anteriormente pelo agente,
incluindo 49 do inimigo, da importação/inicialização e das seis capturas
renderizadas já registradas. Resultados, diagnósticos de ambiente e limitações
foram preservados. A engine não foi reexecutada nesta tarefa de documentação
e versionamento. Nenhum código funcional, cena ou parâmetro foi alterado.

**M3-B2 e o Corvo Amaldiçoado permanecem não iniciados.** A homologação do B1
não autoriza nova implementação, M3-B3 ou M3-C. Não há push, deploy ou publicação.

Entrega autorizada para um único commit local, sem push, mudança de branch/remoto,
exportação ou publicação. **Encerrar no M3-B1 e aguardar nova autorização.**

---

## Registro histórico homologado M3-A e FIX01

# Cinzas do Juramento — M3-A: O Cemitério dos Esquecidos

**M3-A e M3-A-FIX01 homologados funcionalmente pelo responsável em
03/11/2026.** M0/M1/M2 continuam homologados historicamente. A aprovação
não inicia M3-B nem autoriza etapas posteriores.
Baseline conferido: branch `main`, HEAD M2
`c58690bbb3dfe122bb8e1ff8de05b966f17dd772`, Git inicialmente limpo.

## Jogar o M3-A

Abra `C:\PROJETOS\CINZAS DO JURAMENTO\project.godot` na Godot e pressione **F5**.
O projeto inicia a nova fase. **A/D ou setas** movimentam, **Espaço/W/seta para
cima** saltam, **J** usa a espada existente. Não há menu ou áudio.

Percorra os setores da esquerda para a direita:

1. Portões do Cemitério — início seguro e instruções.
2. Caminho das Lápides — três vãos simples de 32 px.
3. Jardim dos Mortos — blocos com subida de 24 px e marcação CP1 FUTURO.
4. Catacumbas — passagem por baixo do teto identificado, descida e escada de saída.
5. Ponte das Almas — vãos de 32/40/40 px e marcação CP2 FUTURO.
6. Portão da Catedral — piso seguro e faixa de FIM PROVISÓRIO.

As marcações de checkpoints **não ativam retorno nem curam**. Cair vivo de um
vão retorna ao início (48,156), sem cura, usando a regra existente de M0/M2.
A vida, espada e HUD são os componentes existentes, sem mudança de parâmetros.
Não foram adicionados inimigos, IA, armadilhas, chefe, arte final ou música.
Tela interna 320×180 e escala inteira preservadas.

O protótipo M0/M1/M2 permanece disponível: abra
`scenes/levels/prototype_stage.tscn` e pressione **F6** para testar o alvo,
espinhos e checkpoint antigos. Esses elementos não foram incluídos na nova fase.

## Validação e playtest do M3-A

- Especificação/layout: `docs/M3_A.md`.
- Resultados, inventário e roteiro histórico de playtest: `tests/VALIDACAO_M3_A.md`.
- Godot executada: **4.7.2.stable.official.ed1daf0bf**.
- Importação e inicialização headless concluídas. Regressões: **14 M0 + 36 M1
  + 59 M2**, zero falhas. Nova suíte: **51 verificações M3-A**, zero falhas.
- Percurso automatizado contínuo nos dois sentidos, sem teleporte ou reinício
  durante o percurso; seis quedas e integração de respawn verificadas à parte.
- Seis capturas renderizadas inspecionadas; sensação de controle e dificuldade
  não são certificados pelas capturas; a homologação funcional foi informada
  pelo responsável. Houve aviso de certificados do Windows
  na captura gráfica; detalhes no relatório.

### Correção M3-A-FIX01 — homologada funcionalmente

O bloco alto das Catacumbas é `CryptRoof`, um teto fora da rota, agora escurecido,
com borda inferior e indicação “TETO - PASSAGEM ABAIXO”. A ponte teve dois pisos
alargados e o segundo rebaixado em 8 px; a câmera antecipa os degraus inferiores
nas Catacumbas. Nenhum parâmetro, controle ou sistema homologado foi alterado.

Medição física: salto de aproximadamente **40,9 px**, deslocamento em piso
nivelado **70 px correndo / 66,7 px partindo parado**. Os degraus obrigatórios
sobem no máximo 24 px. A auditoria nova verifica 30 transições dirigidas nos seis
setores, com quatro aproximações por transição: **120 ensaios físicos** e 35
verificações. Na regressão final passaram **195 verificações**, sem falhas
(14 M0 + 36 M1 + 59 M2 + 51 M3-A + 35 de navegabilidade).

Coordenadas antes/depois, resultados pré-correção, limites do teste e checklist:
`tests/VALIDACAO_M3_A_FIX01.md`. O teste original contínuo passa nos dois sentidos;
os ensaios locais adicionais usam reposicionamento declarado entre tentativas.
O responsável informou a homologação funcional conjunta do M3-A e do FIX01.
Os resultados automatizados continuam separados dessa aprovação humana.

Após importar, execute também:

```powershell
godot --headless --path . --fixed-fps 60 --log-file .godot/m3a-test.log --script res://tests/cemetery_test.gd
godot --headless --path . --fixed-fps 60 --log-file .godot/fix01-reachability.log --script res://tests/reachability_test.gd
```

As três suítes antigas agora carregam `tests/fixtures/baseline_main.tscn`, cópia
da entrada M2. Só esse caminho foi alterado nos testes antigos; suas verificações
permanecem idênticas. A nova suíte carrega a entrada real de F5.

## Homologação funcional registrada — 03/11/2026

O responsável informou a **homologação funcional do M3-A e da correção
M3-A-FIX01** e autorizou registrar a implementação homologada em um único
commit local. Esta aprovação é atribuída ao responsável, não a um playtest
realizado pelo agente nesta etapa.

Foram preservados os resultados anteriores: 160 verificações na entrega
original e 195 na regressão final do FIX01, incluindo 35 verificações de
navegabilidade com 120 ensaios físicos agregados. Falhas de diagnóstico antes
da correção, limites dos testes e mensagens de ambiente continuam documentados.
Nenhum teste da engine foi repetido nesta etapa; foram feitas somente revisões
de documentação e versionamento. Não houve alteração de jogabilidade.

A homologação é funcional e restrita ao M3-A com FIX01. **M3-B não iniciado**;
qualquer etapa posterior exige autorização própria. Não há push ou publicação
no escopo deste registro.

O registro reúne a implementação M3-A e FIX01 em um único commit local,
sem push, alteração de remoto ou publicação. M3-B/C/D e M4 não iniciados.

---

## Registro histórico M0/M1/M2 — cenário de protótipo

As posições de alvo, espinhos, checkpoint, limite Y=224 e câmera de 960 px
descritas abaixo referem-se ao protótipo preservado, executado com F6, e não
ao novo greybox de F5. Relatórios históricos não foram reescritos.

### Entrega histórica M2

Fundação de plataforma 2D para Windows. Aren anda, salta e retorna ao ponto
inicial após cair. O combate M1 homologado foi preservado; M2 acrescenta vida,
dano recebido, invulnerabilidade, morte, checkpoint e respawn.

Baseline M2: `main`, commit M1 `c7a82dcd527ba7cf754878da6bad449f5f75e08d`.
**M2 homologado funcionalmente pelo responsável: playtest manual 11/11 PASSOU, sem observações.**

O responsável informou a **homologação manual do M0, sem observações**
(movimento, salto, aterrissagem, paredes, coyote time, buffer, câmera e retorno).
Baseline: `main`, commit `c9cd1f558dc02e83cb81438efa56c7a8fbbff622`.
Essa homologação foi fornecida pelo responsável; os testes desta etapa estão
registrados separadamente em `tests/VALIDACAO_M1.md`. O relatório M0 foi preservado.

## Ambiente e execução

- Requer Godot **4.3 ou superior**, edição padrão com GDScript; renderer Compatibility.
- Engine localizada nesta etapa: **4.7.2.stable.official.ed1daf0bf**, em
  `C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe`. Use o executável
  `_console.exe` dessa pasta para os testes. Nenhuma instalação foi realizada.
- Abra a Godot, escolha **Importar**, selecione `project.godot` e pressione **F6**
  para a cena aberta ou **F5** para iniciar o projeto pela cena principal.
- Alternativamente, no PowerShell, dentro desta pasta:

```powershell
& 'C:\caminho\Godot_v4.x-stable_win64.exe' --path . --editor
& 'C:\caminho\Godot_v4.x-stable_win64.exe' --path .
```

Tela interna 320 × 180; janela inicial 960 × 540. Escala inteira, aspecto
preservado, filtro nearest e renderização alinhada a pixels. Ao redimensionar,
podem aparecer barras para preservar pixels quadrados. Física a 60 Hz;
câmera sem suavização para evitar deslocamentos fracionários.

## Controles

| Ação | Teclas |
|---|---|
| Esquerda | A / seta esquerda |
| Direita | D / seta direita |
| Saltar | Espaço / W / seta para cima |
| Atacar | J |

Segurar salto ou ataque não repete a ação automaticamente. Não há menu.

## Combate M1

Aproxime-se do boneco de treino em **(112,156)**; por exemplo, pare em X≈88 e
olhe à direita. Aperte **J** no chão. O alvo não é sólido e pode ser atravessado.
O feedback é um breve clarão com marcas laterais; `hit_count` fica disponível
no Inspector remoto do alvo, sem criar HUD.

O nó `Knight/SwordAttack` expõe preparação **0,10 s**, janela ativa **0,10 s** e
recuperação **0,20 s**. A espada fica erguida na preparação, horizontal e clara
na execução, e abaixada na recuperação. Só a fase ativa produz acertos.
Outro pressionamento durante o ciclo é descartado, sem combo ou fila.
A direção visual e a área do golpe ficam fixas no lado escolhido ao começar,
mesmo se Aren caminhar para o outro lado. Movimento e salto permanecem livres.
Um golpe iniciado no chão termina normalmente se Aren saltar ou sair da borda;
não é possível iniciar um novo ataque no ar. Cair para fora da fase cancela o golpe.

A hitbox separada mede 22 × 14 px, entre 6 e 28 px à frente do centro de Aren,
centrada em Y=-14. Cada alvo recebe no máximo um acerto por golpe, inclusive
se já estava sobreposto na abertura da janela. Camadas: World=1, Player=2,
SwordAttack=3 (bit 4), TrainingTarget=4 (bit 8). Consultas de forma na física
leem a máscara do ataque; não dependem de sinais de entrada ou sobreposições
armazenadas do frame anterior. A forma fica desabilitada fora da janela ativa.

Uma consulta ao corredor da lâmina, com altura de 14 px entre Aren e o centro
do alvo, bloqueia acertos se encontrar qualquer sólido World. A regra é
conservadora: quinas que tocam esse corredor também impedem o golpe.
O alvo de treino continua sem HP, morte, IA ou ataque. Dano ao jogador e morte
são responsabilidade do sistema de sobrevivência M2, descrito a seguir.

## Sobrevivência M2

A HUD discreta mostra **VIDA 5/5**. `Knight/Survival` expõe vida máxima (5),
invulnerabilidade (0,80 s) e intervalo de morte (0,60 s). O método central
`Knight.receive_damage(amount)` delega a validação ao componente de vida,
que emite `health_changed`, `died` e `respawn_requested`. Valores de dano zero
ou negativos são ignorados. A armadilha aplica sempre exatamente um ponto.

A armadilha de espinhos em **(490,156)** é estática e não sólida. Ao tocá-la,
Aren perde 1 HP e pisca em vermelho durante a proteção. Continuar sobre os
espinhos permite novo contato válido depois dos 0,8 s; ficar parado ali esgota
a vida e permite testar a morte. Saltar sobre a armadilha evita o contato.
Não há knockback neste escopo.

Em zero HP, Aren entra em DEAD, assume uma pose caída e interrompe o golpe.
Ataque, movimento e salto ficam bloqueados até o respawn. Após 0,6 s, volta ao
último checkpoint, recuperando HP máximo, velocidade zero, controle e aparência
normal. Os temporizadores de dano/morte/invulnerabilidade e os comandos de
salto/ataque pendentes são limpos. Não há Game Over nem menu de continuação.

O ponto padrão seguro é **(48,156)**. A bandeira em **(690,156)** ativa o
checkpoint ao contato; sua cor muda de azul para âmbar. O Marker2D
`RespawnPoint` da cena reutilizável determina o retorno, inicialmente **(666,156)**.
Outra instância pode ser colocada pelo editor sem mudar scripts da fase.
Só o último checkpoint fica ativo, e contatos repetidos não repetem a ativação.
O estado é local à sessão, sem save permanente.

Antes da ativação e novamente no respawn, o marcador é verificado contra
sólidos e fontes de dano, com apoio de chão até 3 px abaixo. Um checkpoint
inválido não é ativado; se o ativo ficar inseguro depois, usa-se o início
padrão seguro. Se ambos forem inválidos, a morte é mantida e um aviso é emitido,
sem colocar Aren dentro de um obstáculo. Não há busca automática de posições.
A configuração atual tem ambos os pontos seguros; não precisa adicionar uma
nova invulnerabilidade ao reaparecer.

**Compatibilidade com a queda M0:** cair vivo além de Y=224 continua retornando
para o início original (48,156), com velocidade zero e ataque cancelado. Isso
não cura HP, não troca o checkpoint e não reinicia a proteção que já estivesse
em andamento. A única adaptação é ignorar esse retorno durante DEAD: uma morte
ocorrida junto ao vão deve completar seu intervalo e voltar ao checkpoint.
A câmera continua seguindo o retorno no mesmo passo de física.

Camadas adicionais: PlayerHurtbox=5/bit 16, DamageSource=6/bit 32,
Checkpoint=7/bit 64. A hurtbox consulta somente DamageSource; o ataque M1
continua consultando somente TrainingTarget. As formas são separadas.

## Arquivos e responsabilidades

- `project.godot`: configuração de vídeo, inputs, camadas físicas e cena inicial.
- `scenes/main.tscn`: instancia a fase.
- `scenes/player/knight.tscn`: CharacterBody2D e retângulo físico de 12 × 24 px.
- `scripts/player/knight_controller.gd`: movimento tipado, orientação e estados
  IDLE/RUN/JUMP/FALL. Ajustes no Inspector: velocidade 100 px/s, aceleração
  1200 px/s², desaceleração 1600 px/s², gravidade 680 px/s², salto -230 px/s,
  velocidade máxima de queda 360 px/s, coyote time e buffer de 0,10 s.
- `scripts/player/knight_visual.gd`: capacete, armadura, capa e bainha geométricos;
  apenas o visual é espelhado, mantendo o colisor inalterado.
- `scenes/levels/prototype_stage.tscn`: dois pisos, duas paredes, quatro
  plataformas sólidas, Marker2D inicial, jogador e Camera2D.
- `scripts/levels/prototype_stage.gd`: retorno após Y > 224 com velocidade e
  temporizadores zerados; câmera horizontal inteira com limites 0–960 × 0–180.
- `scripts/levels/stage_visual.gd`: fundo original sem colisão.
- `scripts/player/sword_attack.gd`: ciclo, hitbox, direção fixa e bloqueio por sólidos.
- `scenes/targets/training_target.tscn` e `scripts/targets/training_target.gd`:
  alvo reutilizável não sólido, contador e feedback, sem vida ou IA.
- `tests/smoke_test.gd`: regressão de física do M0, preservada.
- `tests/combat_test.gd`: testes de física e input do M1, preservados.
- `scripts/player/knight_survival.gd`: HP, sinais, proteção e intervalo de morte.
- `scripts/player/knight_hurtbox.gd`: consulta defensiva de contato.
- `scenes/props/damage_source.tscn` e `scripts/props/damage_source.gd`: espinhos.
- `scenes/props/respawn_checkpoint.tscn` e `scripts/props/respawn_checkpoint.gd`:
  checkpoint reutilizável e marcador de retorno.
- `scenes/ui/health_hud.tscn` e `scripts/ui/health_hud.gd`: HUD ligada aos sinais.
- `tests/survival_test.gd`: testes de sobrevivência e integração com M0/M1.
- `tests/VALIDACAO_M2.md`: inventário, resultados desta execução e checklist manual.

Fase de 960 px de largura, piso em Y=156 e vão entre X=560 e X=624. Plataformas
em Y=124, 94, 72 e 120. Início em (48,156), sobre chão seguro. O vão tem bordas
âmbar; cair nele testa o retorno. O salto padrão sobe aproximadamente 37 px
na integração discreta de 60 Hz; as plataformas formam uma escada alcançável.
Geometria é sólida por todos os lados; plataformas não são unidirecionais.

Os documentos originais `GDD.md`, `ARQUITETURA.md` e `ROADMAP.md` estavam na raiz
e foram preservados no local. Não foram criados diretórios vazios de assets,
autoloads, managers, inimigos ofensivos ou sistemas de marcos posteriores.

## Validação automatizada

Com o executável disponível, execute (substitua `godot` pelo caminho local):

```powershell
godot --version
godot --headless --path . --import
godot --headless --path . --quit-after 10
godot --headless --path . --log-file .godot/m0-test.log --script res://tests/smoke_test.gd
godot --headless --path . --log-file .godot/m1-test.log --script res://tests/combat_test.gd
godot --headless --path . --log-file .godot/m2-test.log --script res://tests/survival_test.gd
```

Na implementação original do M1 foram executados versão, importação, inicialização e smoke test M0
(14 verificações, zero falhas) e suíte M1 (36 verificações, zero falhas).
Os detalhes de execução estão em
`tests/VALIDACAO_M1.md`. Houve diagnósticos de ambiente relativos à loja de
certificados do Windows e ao acesso aos logs/configurações do perfil; não houve
erros de script nos testes. Os logs das suítes foram direcionados a `.godot/`.

Na execução M2, importação e inicialização concluíram com código 0. Passaram
novamente 14 verificações M0, 36 M1 e 59 M2, sem falhas. Permaneceram os
diagnósticos de ambiente já documentados. Resultados e comandos exatos estão
em `tests/VALIDACAO_M2.md`. A homologação manual do M2 foi informada pelo responsável; nesta etapa de documentação e versionamento, a engine não foi reexecutada.

## Homologação manual do M1 — APROVADA PELO RESPONSÁVEL

O responsável concluiu o playtest manual, informou **“tudo passou”** e
**homologou o M1, sem falhas relatadas**. Aprovações informadas pelo responsável:

- [x] Ataque e recuperação.
- [x] Acerto único por golpe e golpes consecutivos.
- [x] Direção, alcance e bloqueio por paredes.
- [x] Visual da espada e feedback do alvo.
- [x] Cancelamento após queda.
- [x] Regressão das funcionalidades homologadas do M0.

Esse resultado foi informado pelo responsável; o agente não realizou o playtest
manual. Os resultados automatizados anteriores (14 verificações M0 e 36 M1,
sem falhas) e os diagnósticos de ambiente foram preservados. Na etapa de
documentação e versionamento do M1, a engine não foi reexecutada. Os resultados
da execução do M2 estão em `tests/VALIDACAO_M2.md`.

Não há áudio.

## Homologação manual do M2 — APROVADA PELO RESPONSÁVEL

O responsável informou **11/11 PASSOU**, sem observações: vida inicial,
recebimento de dano, invulnerabilidade, feedback visual, novo dano, ativação do
checkpoint, morte, respawn, controles após respawn, queda do cenário e regressão.
Este registro atribui o resultado ao usuário; o agente não realizou o playtest
manual nem apresenta a homologação como auditoria própria. O detalhamento está
em `tests/VALIDACAO_M2.md`.

## Encerramento de escopo

M0, M1 e M2 estão homologados pelo responsável. Os relatórios históricos M0/M1
foram preservados, assim como os resultados automatizados anteriores do M2:
14 verificações M0, 36 M1 e 59 M2, sem falhas, com os diagnósticos de ambiente
registrados. A engine não foi reexecutada nesta etapa.

O responsável autorizou exclusivamente registrar a homologação funcional e
versionar o M2 em um único commit local na branch `main`, sem alterações
adicionais de jogabilidade. Caches, logs e arquivos temporários ficam fora do
commit. Não houve push, deploy, alteração de remoto ou publicação.
**M3 não iniciado.** Qualquer nova implementação exige autorização expressa.


## Homologação do responsável — M5-B

**M5-B — HOMOLOGADO PELO RESPONSÁVEL NO ESCOPO ESTRUTURAL, FUNCIONAL E VISUAL TESTADO.** Extensão principal histórica: **17.360,42 px — 5,6791×** o Capítulo 1; tamanho aprovado. FIX01 e FIX02 aprovados no playtest informado; nenhuma correção visual obrigatória adicional relatada. Não se infere aprovação de 30/30 itens.

Pendência técnica conhecida: investigar futuramente a origem das cinco instâncias ObjectDB registradas ao encerrar uma suíte visual; não há comprovação de vazamento persistente. Três diretórios externos de evidências FIX01 foram sobrescritos em regressão anterior; resultados históricos textuais preservados, sem reconstrução artificial.

M5-C não iniciado. O Capítulo 2 ainda depende de M5-C (inimigos e armadilhas), M5-D (acabamento), M5-E (exploração), M5-F (regressão final) e M6 (segundo chefe). Nenhuma nova execução de engine é alegada nesta homologação documental.

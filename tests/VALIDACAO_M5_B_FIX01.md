# M5-B-FIX01 — Continuidade dos dois trechos e orientação

**Correção local implementada; aguarda novo playtest. Sem staging, commit, push ou M5-C.**

O responsável aprovou o **tamanho geral** da Abadia após percorrer os12 setores. Isso não foi convertido em homologação completa de arte, direção ou de todos os itens do checklist M5-B. Resultados e relatórios anteriores foram preservados. Este documento registra a revisão de04/11/2026 e prevalece sobre a orientação oeste do relatório original.

## 1. Diagnóstico exato dos prints

Os dois cortes visuais ficam **dentro** dos setores2 e6, não em todas as11 portas entre setores:

| Trecho corrigido | Junção local | Causa |
|---|---|---|
| **2/12 — Claustro Fraturado**, núcleo Claustro das Sombras → extensão direita, próximo dos Votos sem Nome | **X=960**, pisoY228 | Fundo do piloto + segunda camada recortada emX≥960 com outro posicionamento/parallax |
| **6/12 — Galeria dos Turíbulos**, núcleo Galeria dos Penitentes → extensão direita, após a Prensa | **X=960**, pisoY300 | Mesma sobreposição com outro recorte, criando repetição/desalinhamento de arcos e iluminação |

As imagens enviadas pelo responsável foram consultadas; cópias externas reference_cloister.png/reference_gallery.png preservam o diagnóstico. O M5-A tinha960 px por piloto; o M5-B acrescentou320 px de conector. O renderizador original do piloto já desenha o fundo de toda a janela, inclusive além deX960. chapter_art.gd desenhava outro fundo só à direita do corte, calculado sobre bounds1280 e parallax diferente. O resultado parecia swap de imagem mesmo antes de sair do setor.

**Correção mínima:** os setores2 e6 passam a ter **um único dono do fundo**, pilot_art.gd original. chapter_art.gd continua desenhando o terreno do conector, mas não sobrepõe um segundo backdrop nesses dois casos. Assim, horizonte, recorte, profundidade, paleta, luz e parallax permanecem os mesmos nas duas metades. Nenhum PNG, material, shader, desenho de outro setor ou script do piloto foi refeito. A composição e a filtragem originais foram preservadas.

O ensaio inicial de vestíbulos gerais foi retirado após o complemento do responsável e a identificação dos prints. O loader chapter.gd voltou **exatamente ao hash inicial**; não há camada geral, fade, novos assets ou alteração visual nas outras dez salas nesta entrega.

## 2. Orientação — auditoria independente dos12 setores

Dormitório(S4) e Jardim(S10) tinham a espinha invertida. Aren saía de um setor pela direita, reaparecia próximo da direita do próximo, mas precisava seguir à esquerda. Manter a tecla direita aproximava-o da porta de retorno. Setas isoladas não resolviam a contradição espacial.

Os perfis desses dois setores foram refletidos horizontalmente, preservando a sequência de alturas, larguras, degraus, tetos e a extensão. Agora **todos os12 setores avançam para a direita**, entrando pela esquerda. A volta funciona à esquerda, entrando pela direita. Nenhuma exceção de orientação é necessária. Entradas, saídas, câmera e marcadores derivados do layout acompanham essa orientação. A regra explícita do pedido substitui os trechos oeste indicativos do planejamento.

| Ligação auditada | Situação direcional |
|---|---|
| 1 Átrio dos Votos ↔ 2 Claustro Fraturado | Preservada; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 2 Claustro Fraturado ↔ 3 Escadaria dos Contrapesos | Preservada; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 3 Escadaria dos Contrapesos ↔ 4 Dormitório das Vigílias | **Corrigida**; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 4 Dormitório das Vigílias ↔ 5 Cisternas Votivas | **Corrigida**; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 5 Cisternas Votivas ↔ 6 Galeria dos Turíbulos | Preservada; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 6 Galeria dos Turíbulos ↔ 7 Fundição dos Sinos | Preservada; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 7 Fundição dos Sinos ↔ 8 Ponte dos Penitentes | Preservada; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 8 Ponte dos Penitentes ↔ 9 Arquivo dos Juramentos | Preservada; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 9 Arquivo dos Juramentos ↔ 10 Jardim Suspenso | **Corrigida**; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 10 Jardim Suspenso ↔ 11 Campanário Exterior | **Corrigida**; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |
| 11 Campanário Exterior ↔ 12 Coro das Correntes | Preservada; ida direita→esquerda, continuação direita; retorno esquerdo→direito, continuação esquerda |

S4 eS10: entrada principal deX1168 para **X48**; saída principal deX16 para **X1200**, em envelope de largura1216. As alturas de entrada/saída permanecem252→444 no Dormitório e300→276 no Jardim. As demais entradas/saídas permanecem iguais. Os sete checkpoints estão em outros setores e **não mudaram** de posição, identidade ou regra. Não havia atalhos ativos no M5-B; reservas futuras continuam reservas, sem caminho removido. Votos sem Nome e suas três ledges opcionais permanecem intactos e alcançáveis.

## 3. Extensão preservada

| Evidência | Resultado atual |
|---|---:|
| Rota física principal, ida única | **17360,41 px** |
| Referência anterior |17360,419824 px |
| Variação numérica do traço |0.014648 px |
| Projeção horizontal única | **14528,00 px**, inalterada |
| Fator físico sobre3056,879979 |5.679126× |
| Saltos necessários do traço |69, inalterados |
| Caminho opcional existente |279,11 px, separado |

Não houve encurtamento de geometria. geometry-preservation.json compara todos os retângulos do manifesto anterior/atual: mesmosY/largura/altura; X refletido apenas emS4/S10. A diferença inferior a0,02 px no traço físico decorre da precisão numérica/colisão em coordenadas orientadas ao contrário, não de remover conteúdo. Teletransportes, volta e ramo opcional não entram na extensão principal. A meta14400 e o mínimo12227,52 continuam superados.

## 4. Verificações executadas

- **2299/2299 funcionais M5-B**: ida e volta contínuas, 1060 ensaios físicos locais, câmera/pousos, sete checkpoints, morte na sala atual e descarregada, queda viva sem cura, HUD, persistência, F7 e entrada F5.
- **105/105 estruturais**: perfis, colisões, suporte, salto M0, descoberta opcional, segurança dosCPs por cinco segundos e evento fatal durante carregamento.
- **118/118 de continuidade**:11 ligações reais nos dois sentidos, mantendo a mesma tecla por24 frames depois da entrada; lado/facing corretos e nenhuma volta acidental. Inclui cruzamento físico deX960 em ambos os trechos e verificações gráficas nas quatro resoluções.
- **1370 principais herdadas reexecutadas**:19 suítes C1=1005 +357 M5-A +8 de resolução M4-C (na rodada gráfica67, que repete59 funcionais). Gráficas M5-A68 separadas. Nenhuma suíte anterior foi editada ou enfraquecida.
- Importação e inicialização gráfica oficial, pilotos e Abadia concluídas; **17/17 PNGs do Guardião idênticos porSHA-256** às referências anteriores.

O total da suíte M5-B passou de2439 para2299 porque a orientação corrigida permite ao guard geométrico **já existente e não editado** reconhecer sete ligações planas contíguas emS4/S10 e dispensar70 fixtures de pouso desnecessárias (140 asserts). As plataformas, os69 saltos necessários, todas as transições e a ida/volta completas permanecem verificadas. Hash dos testes anteriores preservado. Não confundir redução de asserts auxiliares redundantes com redução de capítulo ou remoção de testes.

### Evidência visual específica

**16 capturas nativas**: setores2/6 emX920 eX1000, em1280×720,1920×1080,2560×1440 e3840×2160. Arquivos seam_S02_x920_*.png, seam_S02_x1000_*.png e correspondentesS06, em links-final. Inspeção visual confirmou que os arcos/colunas/luz atravessamX960 sem a linha vertical/reinício de imagem dos prints.

Além da inspeção, um oráculo compara os pixels de uma faixa de32×20 px lógicos cruzandoX960, acima de terreno/ator/HUD: o frame normal precisa ser **idêntico** ao fundo original do piloto com a pele do conector ocultada. Passou nos dois casos, em4K. Isso detectaria a sobreposição anterior. Não substitui a avaliação artística humana na TCL.

Os dez outros fundos mantêm os bytes originais e sua propriedade de desenho; não receberam nova composição, transição geral, recoloração ou parallax. S4/S10 apenas mudam a orientação da geometria de jogo.

### Desempenho real 4K

Sem headless ou --fixed-fps; RTX2060SUPER/Godot4.7.2 Compatibility. Amostra172,04 s com travessia dos12 setores, retornos pelo loader e encontro integrado:

| Métrica | Resultado |
|---|---:|
| FPS inclusivo / p95 / máximo |59,74 / 17,14 ms / 448,88 ms |
| Travessia, excluindo só bootstrap: FPS / p95 / máximo |59,97 / 17,12 ms / 85,86 ms |
| Entradas / descarregamentos |37 / 36 |
| Nós mínimo / máximo |41 / 88 |
| Órfãos amostrados máximo |0.0 |
| Texturas amostradas máximo |141,29 MiB |

Benchmark é amostra no computador de referência, não teste humano da TCL ou garantia de60 FPS travados. Espera de carregamento assíncrono inclui etapas físicas; não é o mesmo que bloqueio de frame. Séries e tempos em performance-walking-final/performance.json. A comparação com o histórico deve considerar picos e bootstrap, sem ocultar resultados anteriores.

Diagnósticos conhecidos preservados: leitura do root certificate store e impossibilidade de gravar editor_settings-4.7.tres no perfil restrito durante importação. Resultados finais sem SCRIPT ERROR ou falhas de teste.

## 5. Novo playtest objetivo

Abra `res://scenes/abbey/abbey_chapter.tscn` na Godot4.7.2 e use **F6**. F5 permanece no Capítulo1; F7 reinicia a Abadia inteira. A/D ou setas movem; Espaço/W/cima saltam; J ataca. Os setores são numerados no topo.

O tamanho geral já foi aprovado pelo responsável; os itens abaixo aguardam **novo** playtest, sem aprovação inferida:

| # | Verificação | Estado |
|---|---|---|
|1|F6 começa no Átrio; F5 continua no Cemitério|NÃO TESTADO|
|2|Seguir à direita nas11 portas sem precisar inverter a tecla, especialmente3→4→5 e9→10→11|NÃO TESTADO|
|3|Voltar à esquerda pelas11 ligações sem retorno involuntário ao avançar|NÃO TESTADO|
|4|S2: passar do monumento Votos sem Nome à extensão direita e voltar; fundo contínuo emX960|NÃO TESTADO|
|5|S6: passar da Prensa ao final da Galeria e voltar; arcos/luz sem corte emX960|NÃO TESTADO|
|6|Os demais dez fundos mantêm a qualidade aprovada|NÃO TESTADO|
|7|Caminho opcional dos Votos continua acessível e permite retorno|NÃO TESTADO|
|8|AtivarCP3 emS5, morrer no Monge/Prensa deS6 e confirmar retorno seguro aS5|NÃO TESTADO|
|9|F7 reinicia a Abadia sem prender Aren ou manter progresso antigo|NÃO TESTADO|
|10|TCL4K: imagem, HUD, câmera, combate e fluidez sem regressão percebida|NÃO TESTADO|

## 6. Arquivos e integridade

Alterados nesta correção:

- scripts/abbey/chapter_art.gd — propriedade única dos fundos deS2/S6.
- scripts/abbey/chapter_layout.gd — orientação deS4/S10 e descrição correspondente.
- README.md e ROADMAP.md — acesso/direção e estado da correção.
- tests/VALIDACAO_M5_B.md — ligação para esta revisão, preservando relatório histórico.

Novos: tests/abbey_continuity_test.gd e.uid; este relatório. chapter.gd, pilot_art.gd, todos osPNG/.import, cenas, demais scripts, testes anteriores e.uid permaneceram iguais ao início da tarefa. Não houve novo asset, inimigo, perigo, habilidade, áudio ou sistema M5-C.

Raiz e HEAD confirmados: main emcf7f0b22eb37bfb83a4da5cf7224e463a7f58bca. Índice vazio; nenhum staging/commit/push. project.godot modificado e14 locais antigos preservados. Todo o M5-B anterior continua local. Diff focado dos dois scripts, hashes, inventário e logs externos em `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5b-fix01`. O relatório original M5-B e evidências anteriores não foram sobrescritos.

**Aguardar novo playtest e homologação. Sem avanço para M5-C.**


## 7. Repetição instrumentada do desempenho

Uma segunda amostra de 171.985 s, com o mesmo percurso e sem alterar gameplay/testes existentes, usou performance_probe.gd externo. Resultado da travessia: **60.004 FPS**, p95 **17.114 ms**, máximo **22.147 ms**. Inclusivo: 59.802 FPS, p95 17.144 ms, máximo 427.342 ms. 37 entradas/36 descarregamentos; nós 41–88; órfãos amostrados zero.

O pico de85,859 ms da primeira amostra **não se repetiu**. A instrumentação registrou apenas dois frames acima de30 ms, ambos no bootstrap (427,342 e194,168 ms), antes da janela de travessia. Não houve pico acima de30 ms durante a travessia, inclusive nas duas junções corrigidas e nas portas. Isso não identifica conclusivamente a causa do pico isolado anterior nem garante60 FPS travados; as duas amostras são preservadas. O p95 permanece próximo dos17,122 ms do M5-B anterior, sem evidência de piora sustentada nesta medição. Avaliação física da TCL permanece manual.

Logs, comandos e dados em performance-profiled; classificação dos picos em spikes.json. O probe é diagnóstico externo, não arquivo novo do projeto ou sistema M5-C.


## Homologação do responsável — M5-B

**M5-B — HOMOLOGADO PELO RESPONSÁVEL NO ESCOPO ESTRUTURAL, FUNCIONAL E VISUAL TESTADO.** Extensão principal histórica: **17.360,42 px — 5,6791×** o Capítulo 1; tamanho aprovado. FIX01 e FIX02 aprovados no playtest informado; nenhuma correção visual obrigatória adicional relatada. Não se infere aprovação de 30/30 itens.

Pendência técnica conhecida: investigar futuramente a origem das cinco instâncias ObjectDB registradas ao encerrar uma suíte visual; não há comprovação de vazamento persistente. Três diretórios externos de evidências FIX01 foram sobrescritos em regressão anterior; resultados históricos textuais preservados, sem reconstrução artificial.

M5-C não iniciado. O Capítulo 2 ainda depende de M5-C (inimigos e armadilhas), M5-D (acabamento), M5-E (exploração), M5-F (regressão final) e M6 (segundo chefe). Nenhuma nova execução de engine é alegada nesta homologação documental.

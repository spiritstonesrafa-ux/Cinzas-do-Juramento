# M5-E — lote 03: percursos opcionais

**Resultado parcial.** O1 já dispõe de um caminho superior físico existente, agora testado desde a entrada do setor até o retorno e a continuação ao setor 3. A Capela O1 e as cinco ramificações O2–O6 do planejamento não foram implementadas: exigem estruturas de colisão ainda não autorizadas. As seis inscrições continuam presentes e a leitura das cinco placas da rota principal agora também funciona ao parar junto delas. M5-E e os atalhos permanecem pendentes.

## Baseline e alterações

`main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`; working tree já continha o piloto, as cinco inscrições, o planejamento e os 15 arquivos protegidos. Não foi feita alteração estrutural na geometria. Nesta etapa `chapter.gd` ganhou uma condição de observação: permanecer parado no chão, a menos de 18 px da marca, por 0,6 s. Passar correndo não revela o texto; o salto existente continua válido. `tests/m5_e_lote02_test.gd` verifica as duas situações; `tests/m5_e_lote03_o1_test.gd` prova a rota superior desde a entrada. As capturas e este relatório são novos. A aprovação visual das seis inscrições foi informada pelo responsável no pedido do lote 03; não é uma nova execução de teste.

## Matriz O1–O6

| ID | Estado e evidência | Saída e pendência |
|---|---|---|
| O1 S2 | **PARTIAL.** Da entrada `(48,300)` chega-se ao piso próximo de `(756,156)`, e depois aos três patamares existentes `Rect2(792,132,48,12)`, `Rect2(848,108,48,12)`, `Rect2(912,84,48,12)`. A inscrição `(867,108)` e Votos sem Nome `(936,84)` foram acionados em prova real. | Descer à esquerda, retornar ao piso e continuar pelo CP até S3 passou. O caminho existente não é a capela e circuito completo de 360 px propostos. |
| O2 S3 | **BLOCKED para a ramificação; PARTIAL para inscrição.** Inscrição em `(820,372)`; `main_surfaces` contém apenas a sequência principal de degraus e não há piso de galeria lateral. | Câmara do Contrapeso Partido e retorno alternativo requerem novas superfícies. Meta 480 px ainda não medida. |
| O3 S5 | **BLOCKED para a ramificação; PARTIAL para inscrição.** Inscrição `(550,420)`; a única geometria existente é piso principal e tetos. | Câmara baixa e escada de retorno requerem nova geometria; tetos limitam folga. Meta 560 px não medida. |
| O4 S7 | **BLOCKED para a ramificação; PARTIAL para inscrição.** Inscrição `(885,324)`; não há galeria lateral fora da espinha. | Molde acessível por percurso próprio depende de novas superfícies e de separação do Pêndulo e Monge. Meta 420 px não medida. |
| O5 S9 | **BLOCKED para a ramificação; PARTIAL para inscrição.** Inscrição `(1120,252)`; pisos e tetos existentes pertencem ao caminho principal. | Galeria e retorno requerem novas superfícies sem interferir com teto, Acólito e Jato. Meta 620 px não medida. |
| O6 S10 | **BLOCKED para a ramificação; PARTIAL para inscrição.** Inscrição `(700,300)`; só há superfícies da espinha. | Mirante com trajeto distinto requer apoio novo e preservação da separação entre travessia e combate. Meta 560 px não medida. |

Os 3.000 px planejados são soma de metas, não resultado. Nenhuma nova extensão exclusiva foi adicionada neste lote. A prova O1 registrou **276,71 px de deslocamento acumulado de ida**, do ponto de partida `(aprox. 756,156)` até o terceiro patamar `(aprox. 949,84)`, somando movimentos reais inclusive os arcos dos saltos; não é medida de comprimento único de plataforma, não deve ser somada ao orçamento de extensão exclusiva nem comprova a meta de 360 px. O retorno não foi incluído nessa medida. A primeira parte da prova anterior no S2 inclui o Monge real e usa controles normais.

## Alternativas geométricas para decisão posterior

Os esboços abaixo são **pontos de partida de projeto, não layouts comprovados ou seguros**. Cada `Rect2(x,y,largura,altura)` representa uma plataforma sólida candidata, em coordenadas locais, sem mudança aplicada. É necessário confirmar apoios, margem ao corpo, colisão com tetos, ameaças, câmera e manutenção da espinha antes de aprovar a implementação. Entradas/saídas são propostas a verificar no piso existente; nenhuma conexão ou comprimento exclusivo é alegado. A altura máxima física histórica de Aren é aproximadamente 41 px, com velocidade 100 px/s, gravidade 680 e impulso −230; distâncias aqui não substituem simulação física.

| Rota | Entrada / apoios candidatos / retorno | Impactos a resolver antes de autorizar |
|---|---|---|
| O1 S2 | entrada `(936,84)`; `Rect2(968,60,48,12)`, `(1028,84,48,12)`, `(1088,108,48,12)`; retorno pelos mesmos apoios | O trajeto proposto se sobrepõe horizontalmente à espinha e aproxima-se da faixa de saída/CP. Conferir leitura da câmera, saltos no retorno e se essa extensão realmente comporta a capela e o circuito, sem confundir Votos sem Nome. |
| O2 S3 | entrada `(820,372)`; `Rect2(830,336,48,12)`, `(890,312,48,12)`, `(950,288,48,12)`; retorno por estes apoios à entrada | A escadaria ascende sob a proposta; uma laje pode obstruir o corredor. Validar espaço do corpo e pêndulo em x340, câmera vertical e lugar para câmara narrativa. |
| O3 S5 | entrada `(550,420)`; `Rect2(540,380,48,12)`, `(600,404,48,12)`, `(660,428,48,12)`; retorno pelos mesmos apoios | Teto existente nos trechos 3–6 e Comporta x780. A posição proposta pode reduzir a folga; conferir sem bloquear o piso ou criar passagem por dentro de paredes. |
| O4 S7 | entrada `(885,324)`; `Rect2(860,284,48,12)`, `(920,260,48,12)`, `(980,236,48,12)`; retorno pelos mesmos apoios | Cuidado com Pêndulo x690 e Monge x1080, pisos ascendentes e colisões abaixo das plataformas; não interferir no checkpoint. |
| O5 S9 | entrada `(1120,252)`; `Rect2(1100,212,48,12)`, `(1160,188,48,12)`, `(1220,188,48,12)`; retorno pelos mesmos apoios | Teto no trecho 11, avanço até o checkpoint e proximidade da saída; não converter o acesso ao CP em percurso obrigatório. Validar câmera e saída para trás. |
| O6 S10 | entrada `(700,300)`; `Rect2(680,260,48,12)`, `(740,284,48,12)`, `(800,284,48,12)`; retorno pelos mesmos apoios | O Pêndulo está em x850; confirmar que a extensão não entre na varredura, mantenha a separação de combate/travessia e permita visualizar o mirante. |

Para a capela O1 completa, a rota existente termina perto de `(936,84)`: a alternativa acima precisa ser complementada por câmara e retorno, sem confundir a inscrição aprovada com Votos sem Nome e sem alterar a saída principal. Não há prova de espaço para ela. Os esboços para O2–O6 também não completam por si só as metas de 420–620 px; sua ampliação exige projeto espacial e medição posteriores. Nenhuma geometria desses esboços está autorizada por esta etapa.

## Testes e evidências

- `m5_e_lote03_o1_test.gd`, Godot 4.7.2 headless, terminou sem falhas: entrada S2 pelo controlador, deslocamento por inputs reais e Monge ativo, três saltos e pousos, descoberta, retorno físico, ativação do CP e transição real para S3. A colocação inicial na entrada é parte da troca normal de sala; não houve reposicionamento sintético durante a rota. Ensaio gráfico nas quatro resoluções repetiu os mesmos movimentos e criou imagens da aproximação, salto e chegada; os três primeiros ensaios gráficos antecederam a adição da verificação extra de continuação até S3, executada no teste final headless e na última execução gráfica.
- Grupo A e B: `m5_e_lote02_test.gd` passou **36 verificações locais**, incluindo observação parada, não ativação na passagem, salto, retorno e câmera. Estes são ensaios com colocação sintética em piso seguro perto das placas e não demonstram percurso desde entrada; como nenhum dos cinco ramos existe, não são provas de percurso opcional.
- Evidências O1 em `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote03/`, com arquivos `aproximacao-`, `salto-` e `caminhada-` nas quatro resoluções. Capturas anteriores das cinco inscrições estão em `.../m5e-lote02/setor-03.png`, `setor-05.png`, `setor-07.png`, `setor-09.png`, `setor-10.png`. Não há capturas de percursos inexistentes.
- Logs `.godot/m5e-lote03-o1-final.log`, `.godot/m5e-lote03-discovery.log` e `.godot/m5e-lote03-o1-{1280,1920,2560,3840}.log`. Certificados raiz indisponíveis e aviso ObjectDB no encerramento voltaram a ocorrer; não houve nova auditoria dessas ressalvas.

## Git e integridade

Os 15 arquivos protegidos foram novamente comparados aos hashes de referência. O índice permanece vazio; sem staging, commit, push ou deploy. Planejamento e demais alterações locais preexistentes preservados. Não foram alterados velocidade, gravidade, colisões, IA, checkpoints ou arte homologada; o traçado histórico principal de 17.360,42 px não foi medido de novo nesta etapa.

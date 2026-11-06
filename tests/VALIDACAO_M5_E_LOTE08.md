# M5-E — lote 08: acesso intencional e O2/O3

**Homologação informada pelo responsável:** os seis percursos O1–O6 foram aprovados em playtest quanto à experiência visual, movimentação, acessos e retornos. Isso registra a avaliação humana informada no lote 09 e não acrescenta uma execução automatizada.

**Resultado:** O2 e O3 receberam percursos físicos e passaram nas trajetórias ensaiadas. O4–O6 mantêm PASS técnico para acesso e retorno, com uma condição de intenção adicional. A adequação dessa condição, o conforto dos saltos e a direção visual foram aprovados no playtest informado pelo responsável no lote 09. O1 mantém PASS técnico anterior. Isso não conclui M5-E: os atalhos e a validação final permanecem pendentes.

## Acesso: antes e depois

Antes, a posição acima do limiar da saída e a velocidade à direita bastavam para abrir o anexo; os testes do lote 07 entravam com um toque de salto de um único quadro. Agora, a abertura em S3, S5, S7, S9 e S10 requer também manter o input existente de salto por **0,22 s enquanto Aren está no ar e se move à direita**. Uma indicação contextual perto da borda diz `Segure salto + direita: passagem opcional`; a prévia lateral de câmera foi mantida. Não se adicionou input novo nem se modificou a física de Aren.

O teste `m5_e_lote08_short_jump_test.gd` percorreu cada um dos cinco setores a partir da entrada, com ameaças e mecanismos ativos, conferiu a indicação contextual e pressionou salto por um quadro na aproximação: em todos Aren seguiu para o setor seguinte sem abrir anexo. Os cinco testes de rota seguraram o mesmo input e entraram, encontraram a inscrição, retornaram ao piso e seguiram ao próximo setor. Comparação com os testes do lote 07 evidencia a mudança da condição de entrada, não uma medição estatística de comportamento humano. Um jogador que mantenha salto ao avançar próximo da borda ainda pode escolher o anexo sem intenção; o playtest deve decidir se a distinção é suficientemente clara.

## Novas áreas O2 e O3

Geometria local ao setor, fora da largura da espinha; não foram colocadas lajes baixas sobre o corredor:

| Rota | Estruturas e descoberta | Resultado |
|---|---|---|
| O2 — S3 Escadaria | `Rect2(1216,252,80,32)`, `(1304,228,64,12)`, `(1376,204,72,12)`. Galeria do Contrapeso Partido, texto existente perto de `(1412,204)`; volta pelos apoios. | PASS técnico: entrada legítima, Pêndulo ativo, checkpoint, acesso com salto mantido, dois pousos, descoberta, retorno e saída S4. |
| O3 — S5 Cisternas | `Rect2(1344,444,200,32)`, `(1552,420,48,12)`. Terraço do Ossuário Votivo perto de `(1576,420)`, com retorno pelos apoios. | PASS técnico: entrada legítima, Acólito e Comporta ativos, checkpoint, acesso com salto mantido, pouso, descoberta, retorno e saída S6. |

Ambas reutilizam a indicação narrativa aprovada e a marca de sessão do respectivo setor. Os textos originais na espinha permanecem; as áreas não são itens ou descobertas adicionais de inventário. Colisões, ameaças e checkpoints existentes não foram modificados. A prévia de 32 px e a expansão de limite/câmera durante cada anexo seguem o mesmo modelo do lote 07; a câmera manteve Aren dentro dos limites internos amostrados nos dois percursos.

Na execução, a projeção horizontal da borda original até a posição alcançada ao descobrir foi aproximadamente `1410,31−1216 = 194,31 px` em O2 e `1573,78−1344 = 229,78 px` em O3. São projeções da trajetória ensaiada em espaço lateral, não comprimento de todos os apoios nem distância de ida e volta. Somadas à métrica equivalente de 545,45 px para O4–O6 do lote 07, resultam em aproximadamente **969,54 px**, excluindo O1 porque sua referência usa método distinto. Não se comprovou um total comparável à meta histórica proposta de 3.000 px. Deslocamentos bidimensionais, incluindo aproximação comum, arcos e retorno repetido: O2 **349,07 + 385,75 px**; O3 **355,89 + 326,72 px**. Não são extensão geométrica nova.

## Matriz atual

| Rota | Estado técnico | Limite |
|---|---|---|
| O1 S2 | PASS técnico anterior e regressão de jornada sem falha. | Playtest presencial da capela pendente. |
| O2 S3 | PASS técnico para a trajetória ensaiada. | Playtest de descoberta, leitura da bifurcação e margem dos saltos. |
| O3 S5 | PASS técnico para a trajetória ensaiada. | Playtest de descoberta, leitura da bifurcação e margem dos saltos. |
| O4 S7 | PASS técnico mantido após acesso intencional e retorno. | UX de segurar salto ainda depende de avaliação humana. |
| O5 S9 | PASS técnico mantido após acesso intencional e retorno. | UX de segurar salto ainda depende de avaliação humana. |
| O6 S10 | PASS técnico mantido após acesso intencional e retorno. | UX de segurar salto ainda depende de avaliação humana. |

PASS técnico cobre as trajetórias e verificações descritas, não todas as entradas, quedas ou estados possíveis; não constitui homologação visual, funcional ou de ausência universal de softlock.

## Testes e evidências

- Cinco execuções gráficas de `m5_e_lote08_o{2,3,4,5,6}_test.gd`, com inputs reais a partir da entrada de cada setor e perigos ativos: **zero falhas**. Foram verificadas descoberta, retorno, continuidade e câmera; O2–O5 também ativaram os checkpoints locais. As cinco entradas deliberadas mantêm o salto até o anexo.
- `m5_e_lote08_short_jump_test.gd`: **15/15** verificações, três por setor, para aproximação, indicação e toque breve sem desvio. O1 foi reexecutado sem falhas. Distribuição M5-C3: **157/157**; jornada principal pelos 12 setores em ambos os sentidos terminou com código 0. Não houve reabertura das auditorias de simultaneidade.
- Capturas de cada destino em 1280×720, 1920×1080, 2560×1440 e 3840×2160 no diretório `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote08/`, com prefixos `escadaria-`, `cisterna-`, `fundicao-`, `arquivo-` e `mirante-`. São quadros do destino, não capturas de toda a sequência em movimento.
- Logs `.godot/m5e-lote08-visual-o{2,3,4,5,6}.log`, `.godot/m5e-lote08-final-m5_e_lote08_short_jump_test.log`, `.godot/m5e-lote08-final-m5_e_lote06_o1_journey.log`, `.godot/m5e-lote08-final-m5_c3_distribution_test.log` e `.godot/m5e-lote08-final-m5_c3_journey_test.log`. O ambiente repetiu o diagnóstico de certificados e avisos ObjectDB no encerramento; não houve investigação nova de causa.

## Arquivos, integridade e playtest

Alterados nesta etapa: `scripts/abbey/chapter.gd`, `scripts/abbey/chapter_sector.gd`, novo `scripts/abbey/m5e_stair_cistern_annex.gd`, cinco testes `m5_e_lote08_o{2,3,4,5,6}_test.gd`, `m5_e_lote08_short_jump_test.gd`, planejamento e este relatório. Os arquivos e alterações locais anteriores foram preservados. A extensão histórica principal de 17.360,42 px não foi remedida. Os 15 arquivos protegidos foram conferidos por hash. Índice vazio; sem staging, commit, push ou deploy. Atalhos e M5-F não iniciados.

Para playtest: abrir `scenes/abbey/abbey_chapter.tscn` com F6; nos setores 3, 5, 7, 9 e 10, experimentar primeiro um toque breve de salto junto à saída e confirmar a progressão normal. Depois retornar, manter salto e direita para explorar, ler a inscrição, voltar à esquerda e seguir pelo piso. Avaliar se a indicação é clara, se o desvio ainda ocorre involuntariamente, se as superfícies são reconhecíveis e se câmera e ameaças permanecem confortáveis.

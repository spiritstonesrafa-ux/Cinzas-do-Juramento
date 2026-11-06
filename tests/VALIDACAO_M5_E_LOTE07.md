# M5-E — lote 07: áreas opcionais laterais

**Resultado:** O4, O5 e O6 receberam áreas físicas e têm PASS técnico nas trajetórias ensaiadas. O1 mantém seu PASS técnico anterior; O2 e O3 permanecem PARTIAL, sem percurso implementado. Nenhuma das novas áreas foi homologada pelo responsável. As provas não demonstram ausência de softlock em todas as ações possíveis nem substituem playtest.

## Como as áreas se conectam

As entradas estão ao lado das saídas direitas dos setores 7, 9 e 10. Pelo piso, a transição obrigatória segue funcionando. Um salto para a direita pouco antes do limiar abre o acesso ao anexo, mantém a sala atual e expande seu limite horizontal; para retornar, anda-se à esquerda até o corredor, e então se usa a saída pelo piso. **Consequência de design:** um salto suficientemente alto junto à saída pode levar ao anexo quando o jogador pretendia avançar. Isso altera a interpretação desse movimento na vizinhança da porta e deve ser avaliado no playtest; não é alegado que o comportamento de todas as possíveis entradas aéreas seja idêntico ao anterior. Ao morrer, cair ou trocar de sala, o estado local do anexo é limpo.

`chapter.gd` controla esses limites, o estado de cada área, o texto e uma prévia de 32 px da área lateral quando Aren se aproxima do fim das salas correspondentes. A câmera pode avançar mais apenas no respectivo anexo. A transição normal pelo piso foi verificada fisicamente após retornar de cada área e em uma jornada completa da Abadia nos dois sentidos. Essa jornada é uma amostra, não prova de todos os padrões de entrada.

## Geometria implementada

Coordenadas locais; retângulos de colisão ficam fora da largura original dos setores e não são lajes baixas sobre a espinha.

| Rota | Estrutura e descoberta | Teste |
|---|---|---|
| O4 S7 Fundição | `Rect2(1472,348,80,32)`, `(1560,324,64,12)`, `(1632,300,72,12)`; ateliê ascendente e texto existente do Sino Mudo perto de `(1668,300)`. | PASS técnico: da entrada legítima, ameaças ativas, CP, salto para o anexo, duas subidas, descoberta, dois retornos, corredor e saída para S8. |
| O5 S9 Arquivo | `Rect2(1344,228,72,32)`, `(1424,204,72,12)`, `(1504,180,72,12)`; galeria do registro sem assinatura perto de `(1540,180)`. | PASS técnico: da entrada legítima, ameaças ativas, CP, acesso, subidas, descoberta, retorno e saída para S10. |
| O6 S10 Jardim | `Rect2(1216,276,240,32)`; terraço do Mirante e texto existente perto de `(1400,276)`. | PASS técnico: da entrada legítima, Penitente e Pêndulo ativos, acesso, descoberta, retorno e saída para S11. |

As cinco inscrições preexistentes permanecem nos locais originais. As novas áreas reproduzem o conteúdo narrativo pertinente e atualizam a mesma marca de sessão por setor; não se trata de três itens de inventário ou de novas descobertas contadas adicionalmente. O1 e sua capela não foram alterados.

## Medições

Como medida homogênea e limitada, a projeção horizontal efetivamente percorrida **além da borda original do setor até o ponto de descoberta da execução** foi: O4 `1665,354−1472 = 193,35 px`; O5 `1538,824−1344 = 194,82 px`; O6 `1373,277−1216 = 157,28 px`. Soma dessas três projeções em áreas distintas: **545,45 px**. Essa medida não soma arcos, não é o comprimento integral da geometria nem prova ausência de trajetos repetidos. As larguras totais desenhadas dos anexos são 232, 232 e 240 px, incluindo vãos nos casos O4/O5; não são usadas como distância efetivamente percorrida.

O deslocamento bidimensional registrado desde os pontos de aproximação na espinha até a descoberta e depois até o retorno foi, respectivamente: O4 **345,62 + 385,14 px**, O5 **342,54 + 386,92 px**, O6 **245,64 + 198,04 px** na execução gráfica. Essas cifras incluem saltos, aproximação compartilhada e retorno repetido; não devem ser somadas como extensão nova. Aproximações horizontais antes da borda começam aproximadamente em x1424 no S7, x1296 no S9 e x1170 no S10. O1 possui a referência geométrica distinta do lote 06, que não foi somada a estas projeções. O total do M5-E comparável à meta histórica proposta de 3.000 px permanece não determinado.

## Validação e evidências

- `m5_e_lote07_o4_test.gd`, `m5_e_lote07_o5_test.gd`, `m5_e_lote07_o6_test.gd`: cada prova parte da entrada legítima do setor, sem reposicionamento durante a jornada, com ameaças instaladas e ativas; testa acesso, descoberta, retorno, câmera e saída. O4 e O5 também ativam o CP local. As três terminaram com zero falhas após o ajuste de câmera.
- Jornada principal `m5_c3_journey_test.gd` passou nos 12 setores em ambos os sentidos após as alterações, sem cair na ramificação ao usar a rota ensaiada. O1 foi reexecutado sem falhas; distribuição M5-C3 passou em 157/157 antes do último ajuste localizado de câmera. Nenhuma auditoria de simultaneidade foi reaberta.
- Capturas do destino de cada área em 1280×720, 1920×1080, 2560×1440 e 3840×2160: `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote07-definitivo/`, prefixos `fundicao-`, `arquivo-` e `mirante-`. São quadros de destino, não vídeos; a legibilidade da entrada e sua distinção da saída obrigatória precisam de avaliação humana em movimento.
- Logs em `.godot/m5e-lote07-final-m5_e_lote07_o4_test.log`, `...o5_test.log`, `...o6_test.log` e `.godot/m5e-lote07-main-final.log`. A Godot repetiu a falha conhecida de leitura de certificados e avisos ObjectDB ao sair, sem investigação de causa neste lote.

## Matriz e pendências

| Rota | Resultado |
|---|---|
| O1 S2 | PASS técnico anterior; playtest presencial pendente. |
| O2 S3 | PARTIAL: inscrição, sem ramo físico. O acesso lateral no fim da escadaria não foi implementado ou validado; os esboços sobre o corredor anteriormente apresentaram folga insuficiente. Não se afirma impossibilidade. |
| O3 S5 | PARTIAL: inscrição, sem ramo físico. A geometria lateral e a integração com os tetos/cisterna ainda precisam de projeto e prova; não se afirma impossibilidade. |
| O4 S7 | PASS técnico na trajetória ensaiada; playtest pendente. |
| O5 S9 | PASS técnico na trajetória ensaiada; playtest pendente. |
| O6 S10 | PASS técnico na trajetória ensaiada; playtest pendente. |

O2/O3 não foram tratados como concluídos por analogia com as outras áreas. Reaproveitar mecanicamente o mesmo acesso na saída de todos os setores poderia conflitar com a leitura de progressão e não foi validado nelas; seu projeto continua pendente. As metas históricas de extensão e os três atalhos também permanecem pendentes; M5-E não está concluído.

## Arquivos e Git

Alterações deste lote em `scripts/abbey/chapter.gd`, `scripts/abbey/chapter_sector.gd`, `scripts/abbey/m5e_garden_overlook.gd`, `scripts/abbey/m5e_silent_bell_gallery.gd`, `scripts/abbey/m5e_unsigned_record_gallery.gd`, três scripts de teste `tests/m5_e_lote07_o{4,5,6}_test.gd`, planejamento e este relatório. Geometria, mecanismos e checkpoints principais não foram editados; o valor histórico da espinha de 17.360,42 px não foi medido novamente. Os 15 arquivos protegidos foram comparados aos hashes de referência. Índice vazio, sem staging, commit, push ou deploy; alterações anteriores preservadas. M5-F e atalhos não iniciados.

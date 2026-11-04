# M5-B-FIX02 — Estabilidade da alvenaria superior

Correção local pendente de novo playtest; FIX01 foi informado como aprovado pelo responsável. Sem commit, push ou M5-C.

## Diagnóstico

A causa mais provável está em `scripts/abbey/chapter_art.gd`, na pintura dos intradorsos nos setores 4, 5 e 9. A malha começava em `view.position.y`, que acompanha a câmera: quando Aren pula, mudavam as origens dos blocos e dos recortes da textura. Além disso, recortes parciais eram preenchidos com a região inteira do atlas, ampliando o detalhe. A câmera é arredondada e não foi alterada; a deformação vinha da construção visual dependente dela. Não houve gravação prévia em movimento para provar isoladamente a causa percebida pelo responsável.

## Correção e testes

A malha agora é ancorada em coordenadas fixas do mundo. Os recortes nas bordas mantêm a proporção da região de origem; o desenho é limitado à área visível. Alteração compartilhada pelos três setores, sem mudanças em colisões, física, layout, câmera, fundos, combate ou checkpoints.

A suíte gráfica `abbey_ceiling_stability_test.gd` executou saltos com Aren e câmera reais nos setores 4, 5 e 9. Os sete checks passaram: câmera moveu e um ponto fixo da alvenaria manteve seus pixels com diferença máxima de 1/255 por canal. A primeira comparação de igualdade exata falhou por essa diferença de quantização; a tolerância explícita final é 2/255. O teste avalia pontos amostrados, não substitui a observação humana de toda a estrutura em movimento. O encerramento da suíte emitiu aviso de cinco instâncias ObjectDB; não foi diagnosticado como vazamento do jogo.

Regressão M5-B: 2299/2299 funcionais e 105/105 estruturais. FIX01: 118/118, incluindo direção em ambos os sentidos, fundos dos setores 2 e 6 e entrada F5. O teste funcional cobre F7, checkpoints e respawn. A inicialização do projeto ocorreu nos testes; o acesso manual F6 permanece para o playtest. Os avisos de certificados e de escrita no perfil são diagnósticos conhecidos do ambiente.

## Playtest pendente

1. Abra `scenes/abbey/abbey_chapter.tscn` e pressione F6.
2. No setor 9, pule repetidamente sob os tetos; observe também os setores 4 e 5.
3. Confirme a continuidade visual nos setores 2 e 6 e a ida/volta nas transições 3–4–5 e 9–10–11.
4. Verifique checkpoints, F7, F5 e imagem/fluidez na TCL 4K.

Ainda não foi recebida homologação manual desta correção. Branch main, índice vazio; alterações anteriores do M5-B e arquivos locais preservados.

## Desempenho 4K

Amostra gráfica real de 171.98 s, sem fixed-fps: travessia 60.003 FPS, p95 17.119 ms, máximo 30.828 ms; incluindo inicialização/ciclos/encontro: 59.791 FPS, p95 17.143 ms, máximo 448.598 ms. 37 entradas e 36 descargas; não é homologação na TCL. Dados em m5b-fix01/performance-walking-final.

## Rastreabilidade das evidências

As novas execuções reutilizaram inadvertidamente as pastas externas `links-final`, `structure-prefetch-final` e `performance-walking-final` do FIX01, sobrescrevendo seus arquivos de execução anteriores. Os resultados históricos textuais do relatório FIX01 permanecem, mas esses três conjuntos de logs/capturas já não são as evidências originais daquela rodada. As demais pastas anteriores não foram intencionalmente removidas.


## Homologação do responsável — M5-B

**M5-B — HOMOLOGADO PELO RESPONSÁVEL NO ESCOPO ESTRUTURAL, FUNCIONAL E VISUAL TESTADO.** Extensão principal histórica: **17.360,42 px — 5,6791×** o Capítulo 1; tamanho aprovado. FIX01 e FIX02 aprovados no playtest informado; nenhuma correção visual obrigatória adicional relatada. Não se infere aprovação de 30/30 itens.

Pendência técnica conhecida: investigar futuramente a origem das cinco instâncias ObjectDB registradas ao encerrar uma suíte visual; não há comprovação de vazamento persistente. Três diretórios externos de evidências FIX01 foram sobrescritos em regressão anterior; resultados históricos textuais preservados, sem reconstrução artificial.

M5-C não iniciado. O Capítulo 2 ainda depende de M5-C (inimigos e armadilhas), M5-D (acabamento), M5-E (exploração), M5-F (regressão final) e M6 (segundo chefe). Nenhuma nova execução de engine é alegada nesta homologação documental.

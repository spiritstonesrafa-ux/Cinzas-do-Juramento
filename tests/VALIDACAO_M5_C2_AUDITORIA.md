# M5-C2 — auditoria técnica complementar

**AUDITORIA APROVADA COM RESSALVAS.** O responsável informou **16/16 PASSOU, sem observações**, para a Prensa e as três famílias novas. A aprovação manual e os resultados automatizados são registros distintos. Nesta auditoria foi corrigido um defeito de ativação da comporta; posteriormente o responsável informou **reteste 2/2 PASSOU, sem observações**: aguardar fora do sensor e aproximar-se para observar aviso e fechamento. A ressalva histórica ObjectDB continua aberta, com origem inconclusiva.

## Base e inventário inicial

Pasta `C:\PROJETOS\CINZAS DO JURAMENTO`, branch `main`, HEAD inicial `149c02e06b7f9309e766209ed8e30abafdd67556`, índice vazio. `project.godot`, os 14 arquivos locais preexistentes e os arquivos locais M5-C2 foram inventariados por hash antes da auditoria. A matriz inicial separando evidências anteriores de lacunas está em `MATRIZ_INICIAL.md` no diretório de evidências desta rodada. M5-C3 não iniciado.

## Defeito comprovado e correção

**Comporta votiva:** com Aren a 200 px, fora do sensor de 85 px, ela iniciava WARNING depois do período seguro. O teste físico falhou antes da correção (`sensor-before-console.log`). A causa era o ramo genérico que avançava SAFE para WARNING assim que o contador expirava, antes de verificar proximidade. Em `scripts/abbey/m5c2_hazard.gd`, o caso SAFE da família comporta agora apenas reduz o contador até zero e aguarda um alvo válido dentro do sensor; o mesmo teste passou depois (`sensor-after-console.log`), assim como a entrada no sensor.

Não foram alterados sprite, animações, aviso de 0,8 s, dano, hitbox, recuperação ou velocidades. A condição corrigida é perceptível quando Aren está longe; o reteste direcionado estava pendente nesta auditoria e foi posteriormente informado como aprovado pelo responsável. Não há mudança na Prensa original ou nos inimigos M5-C1.

## Matriz final de cobertura

| Área | Cobertura anterior | Testes novos | Resultado | Pendência |
|---|---|---|---|---|
| Alturas de salto | Travessias no chão | Subida, ápice, descida e aterrissagem por inputs reais; salto durante ativação das três famílias | PASSOU; nesta amostra os três contatos causaram 1 dano real | Outros timings e geometria futura não são cobertos universalmente. |
| Hitbox do pêndulo | Dano e margem externa | Centro, margens internas/externas e limites verticais com hurtbox real; deslocamento durante a varredura | PASSOU | Tolerância de 2 px nas sondagens. |
| Hitbox da comporta | Dano e margem externa | Mesma matriz geométrica; sensor fora/dentro | PASSOU após correção | Reteste humano posteriormente informado: 2/2 PASSOU. |
| Hitbox do jato | Dano e margem externa | Mesma matriz geométrica | PASSOU | A área futura pode ter outro contexto. |
| Sincronização visual | 48 capturas nativas de quatro estados | Frames reais de aviso e ativo, colisão e recuperação; inspeção de que o pêndulo desenha e colide com `shape.position`; oito capturas direcionadas da comporta | PASSOU no escopo testado | Capturas não substituem observação de toda animação em movimento. |
| Janelas seguras | Travessia e recuo físicos nos dois sentidos | Travessia durante ativação e contato real | PASSOU | Não se garante segurança para todo timing escolhido. |
| Reset/respawn | Morte durante aviso, ativo e recuperação; reset | Morte em SAFE e retorno ao checkpoint para cada família | PASSOU | Nenhuma no escopo ensaiado. |
| F7 | Durante ativo e consecutivos | Durante aviso em cada família e durante morte | PASSOU | Nenhuma no escopo ensaiado. |
| Descarregamento | Ativo, hitbox e reinserções | SAFE, WARNING e RECOVER alcançados naturalmente; referência fraca de perigo e forma; reentrada segura | PASSOU | Não equivale a prova de toda futura integração nos setores. |
| Callbacks e sinais | Contagem estável em reinserções | Contador de sinal de vida, descarga com perigo ativo e 70 frames sem callback extra; conexão de respawn sem duplicação | PASSOU | A observação tem duração finita. |
| Timers e objetos | Reinserções estáveis | Inspeção: mecanismos usam contador `remaining` no próprio nó, sem criar `Timer`, `SceneTreeTimer` ou `Tween`; weakrefs liberadas | PASSOU / timers independentes N/A | Recursos gráficos compartilhados podem ficar em cache. |
| ObjectDB M5-C2 | 10 amostras estáveis e sem aviso na suíte nova | Execuções isoladas com `--verbose` da suíte M5-C1 e da auditoria M5-C2: sem aviso de instâncias em ambas | Sem evidência de aviso novo atribuível ao M5-C2 | Ressalva histórica assíncrona continua aberta; não se afirma ausência universal de vazamentos. |

As sondagens geométricas usam `PhysicsDirectSpaceState2D.intersect_shape`, a forma 12×24 da hurtbox de Aren, camadas reais e a transformação global da hitbox. A matriz de bordas é geométrica, enquanto os testes de travessia, salto, dano, tempo, morte e descarregamento usam frames e física reais. O aviso de 0,8 s foi verificado em 47–49 frames a 60 Hz; os frames ativos mantiveram a forma habilitada e o primeiro frame de recuperação a desabilitou. A linha e a massa do pêndulo utilizam a mesma posição da forma no desenho; isso foi verificado no código e pela posição física, não por comparação de pixels a cada frame.

## Resultados e regressão

Suíte nova `tests/m5_c2_audit_test.gd`: **239/239** verificações passaram na execução final, incluindo 3 sondas de callback após descarga. Muitas verificações acompanham frames consecutivos e não são casos independentes. A suíte anterior foi reexecutada após a correção: **115/115**. As execuções dirigidas usaram `Godot --headless --fixed-fps 60 --path . --script res://tests/m5_c2_audit_test.gd` com log exclusivo.

Regressão reexecutada: M0 14, M1 36, sobrevivência 59, Guardião 59+152+59, M5-A 357, estrutura M5-B 105, capítulo M5-B 2299, M5-C1 41/46/116/78, M5-C2 original 115 e auditoria intermediária 236; todas passaram. A auditoria final posterior passou 239/239. FIX01 gráfico 118 e FIX02 gráfico 7 também passaram; usam renderização em vez de headless. As suítes têm sobreposição e não são somadas como evidências independentes. Comandos e códigos de saída estão em `regression-results.json`.

Foi feita medição direcionada após a correção: janela 3840×2160, RTX 2060 SUPER, 60 s, um mecanismo por vez, vida restaurada pelo instrumento, outras suítes em paralelo: **59,90 FPS**, p95 **16,990 ms**, máximo **52,761 ms**, até 38 nós e 1588 objetos; após descarga, um nó e 1541 objetos. O instrumento não cobre todos os casos de morte/F7 ou carga combinada; não é teste físico na TCL. Capturas direcionadas da comporta em 1280×720 e 3840×2160 cobriram os quatro estados; as 48 capturas anteriores permanecem históricas.

Importação concluiu com os diagnósticos conhecidos de certificados e escrita das configurações do editor. As suítes herdadas da Abadia ainda registram avisos ObjectDB ao encerrar; eles não foram atribuídos aos novos mecanismos. O teste isolado M5-C2 final não registrou aviso ObjectDB, e 10 amostras anteriores de reinserção da demonstração ficaram estáveis em 1601 objetos. Não foi reaberta a investigação histórica de sete `RefCounted` no carregamento assíncrono; origem exata segue inconclusiva.

## Playtest direcionado da correção

Abrir `res://scenes/abbey/abbey_hazards_demo.tscn` com F6, avançar até **3/4 — Comporta votiva**. Permanecer longe por mais de dois segundos e confirmar que não há aviso ou fechamento; aproximar-se e confirmar aviso perceptível antes da ativação; afastar-se e retornar após o ciclo. Verificar também morte/respawn e F7 nessa estação. O restante da homologação manual 16/16 foi informado antes dessa correção e permanece registrado como histórico.

## Arquivos e evidências

Alterados nesta auditoria: `scripts/abbey/m5c2_hazard.gd` (condição do sensor) e `tests/VALIDACAO_M5_C2.md` (homologação). Novos: `tests/m5_c2_audit_test.gd`, seu UID e este relatório. A arte aprovada e os demais arquivos locais M5-C2 foram preservados. Logs e capturas exclusivos: `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5c2-auditoria-20261104-01`. Nenhum staging, commit ou push; M5-C3 não iniciado.

# M5-A — Abadia Silenciosa: duas salas-piloto

**M5-A — HOMOLOGADO FUNCIONAL, VISUAL E TECNICAMENTE PELO RESPONSÁVEL.**

**Playtest manual: 13/13 PASSOU — Nenhuma observação.** Registro de 04/11/2026, informado pelo responsável. Não é a Abadia completa. Sem segundo chefe ou ligação canônica entre capítulos. Homologação para um único commit local, sem push.

As seções 1–16 abaixo preservam o relatório técnico histórico da implementação, inclusive seu estado de entrega anterior à aprovação. Não representam novas execuções nesta atualização. O registro atual está na seção 17.

## 1. Baseline e planejamento

Raiz confirmada: `C:\PROJETOS\CINZAS DO JURAMENTO`, branch `main`, HEAD inicial/final `bfae340b2480dfc65dfbe1a6bde7deb7ebcae044`. Capítulo 1 homologado e publicado. Índice inicialmente vazio; `project.godot` já modificado por serialização e 14 arquivos locais conhecidos. Todos preservados por SHA-256. Nenhum AGENTS.md aplicável encontrado no projeto; instruções locais históricas foram consideradas junto da autorização atual.

Planejamento integral consultado em `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee 96-7412-bd 99-7c6152fadd40\planejamento-capitulo-02\PLANEJAMENTO_CAPITULO_02.md`, com GDD, arquitetura, README/ROADMAP, homologações M3/M4, controlador, espada, vida, checkpoints, câmera, cenas e testes. Cópia autossuficiente com formalização em [docs/PLANEJAMENTO_CAPITULO_02.md](../docs/PLANEJAMENTO_CAPITULO_02.md). A cópia histórica externa foi preservada em `m5a/planning-before.md`; o espaço indevido no hash impresso do estudo foi corrigido na documentação formalizada, sem mudar história Git.

O responsável aprovou **o conceito para prototipagem**, não o resultado manual destes pilotos. Permanecem metas futuras: 14400 px principais, mínimo 12227,52 px (aceite arredondado 12228), aproximadamente 4,71× o percurso de referência 3056,88 px;12 setores,3000 px opcionais, seis descobertas, três atalhos, sete checkpoints. A duração 14–22 min é projeção da região futura. Nenhuma dessas metas foi declarada cumprida por duas salas.

## 2. Organização consolidada dos marcos

M0–M4, seus commits e relatórios homologados permanecem identificados como antes. As linhas M5(slice), M6(expansão), M7(build) do ROADMAP v0.1 eram futuras, não marcos publicados. A autorização atual permite formalizá-las como:

- **M5-P:** planejamento e validação arquitetural.
- **M5-A:** dois pilotos experimentais, esta entrega, não homologada.
- **M5-B/C/D/E/F:** estrutura completa; inimigos/perigos/CP; arte; exploração; regressão/homologação da Abadia — não iniciados. Monge, arte e perigo dos pilotos pertencem ao M5-A e não concluem esses marcos futuros.
- **M6-A/B/C:** fundação, combate avançado e conclusão do segundo chefe — não iniciados.
- **M7:** expansão posterior e pendências de som/UX/polimento; não foram tratadas como concluídas.
- **M8:** build e publicação executável futuros; o push do código do Capítulo 1 não equivale a um executável lançado.

Isso substitui a recomendação provisória M6-C2 do estudo, preservada como histórico na seção 21 daquele documento e explicitamente atualizada pela seção 24. O GDD já indicava Abadia/Abade como conceitos provisórios; narrativa, layout e arte definitivos dependem da avaliação humana.

## 3. Acesso independente e controles

Na Godot 4.7.2, abrir `scenes/abbey/abbey_pilots.tscn` e usar **F6** para executar a cena atual. Alternativa pela engine:

```text
Godot_v4.7.2-stable_win64_console.exe --path "C:\PROJETOS\CINZAS DO JURAMENTO" res://scenes/abbey/abbey_pilots.tscn
```

A/D ou setas movem; Espaço/W/cima saltam; J ataca; **F7 reinicia somente a demonstração**. Entrada oficial `scenes/main.tscn` não foi alterada: F5 continua no Cemitério. Nenhuma referência aos pilotos foi adicionada à campanha ou ao Selo do Guardião.

Claustro sai pela direita, em piso baixo; caminho superior não dispara essa saída. Na Galeria, retornar pela esquerda recarrega o Claustro. A marca final à direita identifica o fim dos pilotos e permite voltar. Não abre outro setor, recompensa ou capítulo. Dano/HP são mantidos entre as duas salas do mesmo piloto; iniciar/reiniciar a demonstração cria a instância original com 5 HP, sem política definitiva entre capítulos.

## 4. Sala-piloto 1 — Claustro das Sombras

Envelope local **960×420 px**, origem global(0,0). Dez sólidos principais em degraus/patamares e três ledges opcionais. Pisos principais entreY300 e156: subida 144 px. Com o ramo opcional atéY84, amplitude de pisos 216 px. Não há buracos obrigatórios ou nova habilidade.

Entrada(48,300), percurso principal pelas superfícies abaixo, saída quando Aren alcançaX944 em piso abaixo deY204, rumo à direita. Reentrada pela direita em(904,228). Checkpoint de teste em(96,300), marcador de respawn original deslocado−24: **(72,300)**. Não confundir trigger com respawn.

| Superfície | Posição superior esquerda | Tamanho |
|---|---|---|
| Principal 0 | (0,300) | 224×120 |
| Principal 1 | (224,276) | 64×144 |
| Principal 2 | (288,252) | 64×168 |
| Principal 3 | (352,228) | 96×192 |
| Principal 4 | (448,204) | 64×216 |
| Principal 5 | (512,180) | 160×240 |
| Principal 6 | (672,156) | 96×264 |
| Principal 7 | (768,180) | 64×240 |
| Principal 8 | (832,204) | 64×216 |
| Principal 9 | (896,228) | 64×192 |
| Opcional 0 | (792,132) | 48×12 |
| Opcional 1 | (848,108) | 48×12 |
| Opcional 2 | (912,84) | 48×12 |

O ramo superior parte do patamar alto, cruza vãos 24/8/16 px e chega ao monumento **Votos sem Nome**, próximo de(936,84). Descoberta registra somente um booleano de sessão e feedback textual; não entrega item ou inventário. Pode retornar pelas mesmas plataformas ou cair com segurança ao percurso principal. A suíte cobre subida contínua desde o spawn e ligações locais reversas.

Arte original: claustro com arcos partidos, vitrais, colunas, vegetação discreta, pátio e campanário distante; terreno recebe cornijas/materiais do atlas arquitetônico. Fundo com parallax, canvas 480×240 e Linear; corpo/HUD continuam Nearest. Não há inimigo nesta sala, para validar descoberta e movimento por si mesmos.

## 5. Sala-piloto 2 — Galeria dos Penitentes

Envelope local **960×420 px**, origem global(1200,0). Piso contínuo(0,300,960,120), dois patamares em(80,276,96,12) e(648,276,80,12); amplitude 24 px. Entrada local(48,300), checkpoint trigger(96,300) e respawn(72,300), portanto global(1272,300). Marca de encerramento apósX912 local; voltar atéX16 carrega a sala anterior. O espaço global entre origens não é extensão caminhável.

Monge em(388,300) local, patrulha delimitada a±64; Contrapeso em(588,300). Distância 200 px permite ver ambos, mas há refúgio real entre o alcance máximo da corrente e o peso. A suíte atravessa a faixa durante janela segura e espera no refúgio sem dano. Não se fecha toda rota de esquiva.

Fundo original com estátuas erodidas, nichos, arcos altos, correntes e iluminação âmbar/índigo. Piso/ledge têm borda pousável consistente e revestimento arquitetônico; nenhuma cor aleatória ou bloco geométrico exposto é apresentado como arte final. Qualidade subjetiva e sensação de dificuldade ainda precisam da aprovação do responsável.

## 6. Monge Acorrentado

Cena reutilizável `scenes/enemies/chained_monk.tscn`, FSM própria: PATROL, CHASE, WARNING, ACTIVE, RECOVER, HURT, DEAD. **HP3/dano1**, os mesmos valores básicos do esqueleto. Corpo 14×28, receptor 18×30; sem colisão sólida contra Aren. Patrulha 23 px/s, perseguição 32; aquisição 104 px com limite vertical 20, linha de visão por cenário e presença no enquadramento antes de armar.

Ataque comprometido: aviso 0,55 s, ativo 0,14 s, recuperação 0,75 s. Corrente com caixa 44×12 deslocada 28 px para o lado escolhido, fonte compartilhada SkeletonAttackSource com consumo por alvo e bloqueio por parede. Aviso não causa dano e não acompanha Aren depois de comprometido. Golpe durante antecipação ainda reduz HP, mas não cancela gratuitamente a ação em curso; fora dela há reaçãoHURT0,18 s. HPzero desarma e torna corpo/receptor inertes.

Diferencial frente ao esqueleto é alcance, compromisso e momento de punição, não barra maior. A suíte demonstra três acertos físicos M1 em fixtures de recuperação e também **duelo contínuo por inputs originais**, vencido sem cura/manipulação de estado no loop e sem dano. Isso não equivale a homologar dificuldade humana.

Atlas original de oito poses: idle, dois passos, aviso, golpe, recuperação, dano e derrota. Poses acompanham estados/cadência; flash é somente visual. Cena reutiliza receptor e fonte existentes, sem editar combate/vida/controlador homologados.

## 7. Perigo-piloto — Prensa de Contrapeso

Variável vertical suspensa da família planejada de **prensas de moldes frios**, com identidade de contrapeso da abadia; não é apresentado como pêndulo já implementado. Cena `scenes/props/abbey_counterweight.tscn`, classe AbbeyCounterweight.

SAFE1,8 s → WARNING0,8 s → ACTIVE0,4 s → RECOVER1,2 s. Massa desce 70 px durante os primeiros 0,28 s ativos; retrai sem dano. Caixa 28×28 acompanha o peso; linha de corrente e ornamentos não dão dano. Somente ACTIVE habilita fonte M2, um ponto por ciclo/alvo, sem morte instantânea. Aviso usa faixa no piso, cantos direcionais e exclamação, não apenas cor. Há espera e travessia seguras com Aren original.

Morte desarma imediatamente; reset volta ao estado seguro e **reativa o processamento do ciclo**. Reentrada reconstrói o mecanismo em estado seguro, não persiste fase ativa. Isso é política dos pilotos, explicitamente distinta de salvar o relógio do perigo.

## 8. Arquitetura, transições e checkpoints

`abbey_pilots.tscn` possui um Aren original persistente entre salas, HealthHUD existente, câmera própria, contêinerRooms e dois checkpoints em raiz estável. Cada sala é PackedScene independente; o script da sala cria os sólidos do manifesto pequeno pilot_layout e suas entidades. Nenhum sistema do Capítulo 1 foi duplicado/refatorado.

Na transição, desabilitar processamento de Aren, cancelar espada, desarmar fontes, guardar HP do Monge, liberar sala anterior, instanciar destino e aguardar dois frames físicos para o suporte antes de reposicionar/retomar. Apenas **uma sala residente**. O HUD sinaliza travessia; não há entrada em colisão ausente. Recursos gráficos das duas salas são pré-carregados/compartilhados: trata-se de descarga de nós segura, **não** prova de streaming de texturas para 12 setores.

Checkpoints não são filhos da sala descartável. Ao morrer com checkpoint de outra sala, o adaptador carrega primeiro a geometria do destino e só então chama `KnightController.respawn_at_checkpoint()` original. Não reescreve vida ou segurança de respawn e não depende de concluir load antes do timer 0,6 s. Testa-se especificamente morte após descarregar o setor do checkpoint.

Na mesma vida, HP/derrota do Monge persistem ao descarregar/reentrar. Morte/queda limpa snapshots e restaura inimigo/perigo; descoberta opcional permanece nesta sessão. Queda viva carrega início e retorna sem curar, mantendo checkpoint e invulnerabilidade remanescente, como os contratos anteriores. Não há persistência em disco.

Câmera exclusiva do piloto: alvo localX limitado 160–800, Y90–330, avanço horizontal 24 e margem abaixo dos pés 48; movimento limitado 600 px/s, posições arredondadas e sem zoom. Isso permite subida/descida com destinos visíveis; a suíte verifica corpo e8 px abaixo do pouso antes de cada ligação, além de enquadramento após aterrissar. A câmera do Cemitério não mudou.

## 9. Arte e proveniência

Quatro PNGs originais produzidos pela ferramenta integrada **image_gen**, usando a skill imagegen, sem CLI, API key ou recorte de assets de terceiros. Copiados sem edição do resultado; recortes/âncoras são do runtime. Dois fundos 1774×887, Monge 1774×887 com alpha, arquitetura 1536×1024 com alpha. Sidecars .import e UIDs dos scripts presentes. [Prompts integrais, fontes e hashes](../assets/art/m5a/PROVENANCE.md).

O atlas arquitetônico fornece cornija, alvenaria, peso e monumento. Cornijas modulares≤96 px evitam esticar uma peça por 960; variações de recorte da alvenaria evitam repetição idêntica. Fundo usa 480×240 para densidade próxima do padrãoM3, parallax e Linear. Atores/HUD continuam Nearest. Nenhuma textura ou sprite homologado foi sobrescrito.

## 10. Verificações funcionais e regressão

**357/357 verificações novas funcionais aprovadas.** Incluem 96 ensaios físicos locais, quatro aproximações(8/12/16/20 px) em ambos os sentidos por ligação:52 saltos e44 descidas caminhando. Caminhar vãos pequenos descendentes é ação legítima para não ultrapassar patamar estreito; não foi alterada física para aprovar. Ensaios locais usam resets, mas há também rota principal contínua, retorno e descoberta superior contínua por inputs.

Cobertura: inicialização, suporte, parâmetrosAren/M1/M2, câmera antes/depois de pousar, descoberta, saída/reentrada, liberação por WeakRef, CP de sala descarregada, morte/queda/estado/HUD, Monge avisando/atacando/recebendo dano/morrendo, direção comprometida, salto sem dano, duelo vivo, Contrapeso seguro/aviso/dano/recuperação/refúgio/travessia, ciclo após reset e seis ciclos de descarregamento.

**1013 verificações principais herdadas aprovadas novamente:**19 suítes somam 1005; as oito de resolução M4-C vêm da execução gráfica 67/67 (59 funcionais repetidas+8). Não contar essas 59 duas vezes. Total principal desta entrega: **1370 =1013+357**. As **68 verificações gráficas M5-A** são registradas à parte; total de asserts distintos por escopo de teste 1438, sem somar repetições de correção/benchmark. Não alegar novo playtest humano por esse número.

Regressões existentes não foram enfraquecidas ou editadas. M0, M1, M2, M3-A/FIX01, esqueletos, corvos, distribuição, mecanismos, arte/presentation/raster/ataque/cohesion/DISPLAY01, M3-E e M4-A/B/C passaram. Importação e inicialização oficial e dos pilotos passaram, sem SCRIPT ERROR. Capítulo 1 manteve **17/17 capturas idênticas** à auditoria anterior.

### Diagnósticos durante o desenvolvimento — preservados

Primeira suíte:252 checks/16 falhas. Identificou dois saltos reversos afetados pela ledge opcional, descidas que ultrapassavam patamares ao saltar, e expectativas incorretas de fixture sobre deslocamento do marcadorCP, início visível do aviso, sincronização do perigo e invulnerabilidade. Segunda rodada:252/2 falhas. Geometria corrigida movendo a primeira ledge paraX792, Y132; descidas curtas são percorridas caminhando. Testes usam marcador real do CP, aguardam aviso visível/fase efetiva e verificam invulnerabilidade em vez de cancelá-la.

Terceira rodada:254/0; cobertura de câmera/rota ampliada:351/0; revisão encontrou ciclo do perigo suspenso após morte na mesma sala, corrigido somente em código novo e coberto:352/0; duelo contínuo e travessia acrescentados:357/0 final. Logs intermediários não foram apagados; não somar rodadas como verificações novas. Houve revisão visual posterior de escala/material; capturas e benchmark M5 foram repetidos no estado final. Nenhum parâmetro homologado de Aren foi alterado para obter PASS.

## 11. Resultados gráficos e limites

Suíte gráfica final: **68/68**, backend Windows/OpenGL Compatibility,17 PNGs nativos: oito das duas salas em 1280×720,1920×1080,2560×1440 e3840×2160; uma descoberta 4K; quatro poses do Monge e quatro estados do Contrapeso 4K. São 11 imagens 4K e seis nas demais resoluções. Estados posados são **fixtures visuais**; timing/dano são comprovados separadamente na suíte física, não por screenshots.

Inspeção das imagens finais confirmou recursos visíveis, escala deAren/HUD, bordas, contraste do aviso e distinção de atmosfera. Avaliação artística final é do responsável. Não houve teste físico manual na TCL nesta execução e não se apresenta headless como renderização.

Evidências externas: `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee 96-7412-bd 99-7c6152fadd40\m5a`. Capturas atuais em **pilot-visual-final**, screenshotsC1 em c1-victory-native; versões anteriores permanecem em pilot-visual para rastreabilidade. Comandos/logs em results.json/final-results.json, funcional em functional/functional.json e functional-complete-console.txt.

## 12. Limitações e pendências

- Arte, fluidez percebida, conforto de câmera e dificuldade aguardam playtest humano; não preencher aprovação automaticamente.
- Somente duas salas, um Monge e um perigo. Não há 12 setores, segundo chefe, save, recompensas definitivas ou transição canônica; meta 4× não cumprida nem anunciada como cumprida.
- Um minuto de benchmark e24 transições não garantem ausência de vazamentos/fluidez na região completa. Recursos de ambas as salas permanecem compartilhados; futuras salas exigem manifesto/bounds/orçamento próprios.
- Geometria é autorada em dados explícitos; export room_id limita aos dois pilotos. Não é editor genérico de 12 setores pronto.
- Fontes sem áudio novo; todos os avisos são visuais. Polimento de som/UX permanece backlog, não foi declarado concluído.
- Diagnósticos ambientais conhecidos de certstore e gravação do perfil da Godot continuam nos logs. Importação concluiu exit 0, mas não se diz que todos os logs são isentos de ERROR ambiental.

## 13. Checklist manual do responsável

Checklist histórico proposto na implementação. Opções: **PASSOU / FALHOU / NÃO TESTADO**. Naquela entrega ainda não havia aprovação. A homologação recebida depois abrange os 13 critérios da seção 17; não se infere aprovação individual destes 30 itens.

| Nº | Item | Resultado |
|---|---|---|
| 1 | Acesso às salas-piloto | NÃO TESTADO |
| 2 | Qualidade artística do Claustro | NÃO TESTADO |
| 3 | Qualidade artística da Galeria | NÃO TESTADO |
| 4 | Movimentação de Aren | NÃO TESTADO |
| 5 | Saltos | NÃO TESTADO |
| 6 | Exploração vertical | NÃO TESTADO |
| 7 | Câmera | NÃO TESTADO |
| 8 | Plataformas | NÃO TESTADO |
| 9 | Passagem opcional | NÃO TESTADO |
| 10 | Descoberta | NÃO TESTADO |
| 11 | Transição entre salas | NÃO TESTADO |
| 12 | Entrada e saída | NÃO TESTADO |
| 13 | Aparência do Monge Acorrentado | NÃO TESTADO |
| 14 | Movimento do inimigo | NÃO TESTADO |
| 15 | Ataques do inimigo | NÃO TESTADO |
| 16 | Telegrafia | NÃO TESTADO |
| 17 | Combate | NÃO TESTADO |
| 18 | Perigo ambiental | NÃO TESTADO |
| 19 | Legibilidade do perigo | NÃO TESTADO |
| 20 | Dano | NÃO TESTADO |
| 21 | Morte | NÃO TESTADO |
| 22 | Respawn | NÃO TESTADO |
| 23 | Reset | NÃO TESTADO |
| 24 | HUD | NÃO TESTADO |
| 25 | Imagem 4K | NÃO TESTADO |
| 26 | Fluidez | NÃO TESTADO |
| 27 | Sensação de dificuldade | NÃO TESTADO |
| 28 | Variedade visual | NÃO TESTADO |
| 29 | Potencial de expansão | NÃO TESTADO |
| 30 | Qualidade geral | NÃO TESTADO |

Esperar explicitamente pelo menos um ciclo do perigo após morrer; morrer na Galeria antes de ativar seu CP para confirmar retorno ao Claustro; depois ativarCP2, morrer e conferir respawn local. Fazer queda viva mantendoHP4/CP2, aguardar invulnerabilidade e então morrer para confirmar recarga do checkpoint de outra sala. Repetir idas/voltas após derrotar Monge e descobrir monumento. F7 reinicia só os pilotos; F5 confirma campanha oficial preservada.

## 14. Encerramento

M5-A entregue para avaliação, **não homologado**. Nenhum próximo marco iniciou; não construir demais setores ou segundo chefe. Nenhum staging, commit, push, branch, tag, release ou exclusão. As seções seguintes registram desempenho e inventário efetivamente conferidos no fechamento.


## 15. Desempenho gráfico final medido

Amostra real de **60.001 s**, nativa 3840×2160, sem fixed-fps, com 24 entradas/trocas e23 descarregamentos. Média **59.999 FPS**, p95 **17.078 ms**, p99 **18.046 ms**, máximo **22.760 ms**. Nós entre 44 e55, compatíveis com as duas composições; zero órfãos nas amostras.

Carga inicial instrumentada **388.333 ms**; trocas seguintes entre **33.030 e33.583 ms**, incluindo a espera assíncrona de dois ticks físicos. Esse número não é tempo de frame bloqueado: o máximo de frame da amostra é o registrado acima. Pré-carga inicial ocorre antes do intervalo principal de medição.

Texturas cresceram do primeiro aquecimento de 123.30 para 125.96 MiB, estabilizando nas últimas amostras. Memória estática passou de 41.49 a43.75 MiB; inclui aquecimento e arrays de instrumentação que crescem com a sessão. Não se afirma ausência absoluta de vazamentos pela amostra de um minuto. Não houve nova medição física de Windows/TCL; hardware/renderizador identificados no console da execução. Dados brutos em pilot-performance-final/performance.json.

## 16. Registro de execuções e inventário

| Execução | Modo | PASS | Falhas | Exit |
|---|---|---:|---:|---:|
| import-final | headless | 0 | 0 | 0 |
| pilot-visual | gráfico | 68 | 0 | 0 |
| pilot-performance | gráfico | 0 | 0 | 0 |
| smoke | headless | 14 | 0 | 0 |
| combat | headless | 36 | 0 | 0 |
| survival | headless | 59 | 0 | 0 |
| cemetery | headless | 52 | 0 | 0 |
| reachability | headless | 35 | 0 | 0 |
| skeleton | headless | 49 | 0 | 0 |
| raven | headless | 63 | 0 | 0 |
| distribution | headless | 115 | 0 | 0 |
| mechanisms | headless | 77 | 0 | 0 |
| art | gráfico | 18 | 0 | 0 |
| presentation | gráfico | 10 | 0 | 0 |
| raster_art | gráfico | 8 | 0 | 0 |
| horizontal_attack | gráfico | 46 | 0 | 0 |
| cohesion | gráfico | 14 | 0 | 0 |
| display | gráfico | 38 | 0 | 0 |
| integration | headless | 101 | 0 | 0 |
| boss | headless | 59 | 0 | 0 |
| boss_advanced | headless | 152 | 0 | 0 |
| boss_victory | headless | 59 | 0 | 0 |
| c1-victory-native | gráfico | 67 | 0 | 0 |
| c1-startup | gráfico | 0 | 0 | 0 |
| pilot-startup | gráfico | 0 | 0 | 0 |
| pilot-visual-final | gráfico | 68 | 0 | 0 |
| pilot-performance-final | gráfico | 0 | 0 | 0 |
| functional-complete (estado final) | headless/física real | 357 | 0 | 0 |

pilot-visual/pilot-performance são a avaliação anterior ao refinamento de escala; os diretórios com sufixo **-final** são as evidências atuais. Repetição foi motivada por mudança visual e não soma ao total distinto. Depois do último ajuste funcional, a suíte 357/357 foi executada; mudanças posteriores de relatório não exigiram repetir a engine. Não foi executado novo benchmark M4-B/M4-C de 45 s nesta entrega; a regressão gráfica de vitória foi executada.

**Rastreados alterados nesta tarefa:** README.md e ROADMAP.md, somente documentação. **project.godot modificado é preexistente e seu hash permaneceu intacto.** Nenhum código/cena/arte de Capítulo 1 foi modificado.

**Novos arquivos da entrega (36):**

```text
assets/art/m5a/PROVENANCE.md
assets/art/m5a/architecture.png
assets/art/m5a/architecture.png.import
assets/art/m5a/cloister.png
assets/art/m5a/cloister.png.import
assets/art/m5a/gallery.png
assets/art/m5a/gallery.png.import
assets/art/m5a/monk.png
assets/art/m5a/monk.png.import
docs/PLANEJAMENTO_CAPITULO_02.md
scenes/abbey/abbey_pilots.tscn
scenes/abbey/cloister_pilot.tscn
scenes/abbey/gallery_pilot.tscn
scenes/enemies/chained_monk.tscn
scenes/props/abbey_counterweight.tscn
scripts/abbey/counterweight.gd
scripts/abbey/counterweight.gd.uid
scripts/abbey/monk.gd
scripts/abbey/monk.gd.uid
scripts/abbey/monk_visual.gd
scripts/abbey/monk_visual.gd.uid
scripts/abbey/pilot_art.gd
scripts/abbey/pilot_art.gd.uid
scripts/abbey/pilot_demo.gd
scripts/abbey/pilot_demo.gd.uid
scripts/abbey/pilot_layout.gd
scripts/abbey/pilot_layout.gd.uid
scripts/abbey/pilot_room.gd
scripts/abbey/pilot_room.gd.uid
tests/VALIDACAO_M5_A.md
tests/abbey_pilot_performance_test.gd
tests/abbey_pilot_performance_test.gd.uid
tests/abbey_pilot_test.gd
tests/abbey_pilot_test.gd.uid
tests/abbey_pilot_visual_test.gd
tests/abbey_pilot_visual_test.gd.uid
```

### Arquivos locais anteriores — preservados e fora do escopo M5-A

```text
The Art of the Pixel.jpg
The Art of the Pixel.jpg.import
The Siege and the Sandfox _ Le metroidvania en 2D de Cardboard Sword et PLAION sortira le 20 mai sur PC.jpg
The Siege and the Sandfox _ Le metroidvania en 2D de Cardboard Sword et PLAION sortira le 20 mai sur PC.jpg.import
tests/evidencias/m3d/fix03-after-sector 1.png.import
tests/evidencias/m3d/fix03-after-sector 2.png.import
tests/evidencias/m3d/fix03-after-sector 3.png.import
tests/evidencias/m3d/fix03-after-sector 4.png.import
tests/evidencias/m3d/fix03-after-sector 5.png.import
tests/evidencias/m3d/fix03-after-sector 6.png.import
tests/evidencias/m3d/fix03-attack--1-8.png.import
tests/evidencias/m3d/fix03-attack-1-8.png.import
tests/evidencias/m3d/fix03-detail-cp 1-active.png.import
tests/evidencias/m3d/fix03-detail-cp 2-active.png.import
```

220 dos 222 arquivos do inventário anterior mantêm SHA-256; as duas exceções são README/ROADMAP autorizados. Isso inclui project.godot e todos os 14 locais anteriores intactos. Verificação de referências não encontrou recurso ausente; todos os scripts novos têmUID; nenhum UID novo duplicado ou assinatura de segredo encontrada. git diff --check passou. Índice permanece vazio; HEAD/main iguais ao baseline; nenhum staging/commit/push. Inventário detalhado em m5a/inventory.json e final-inventory.json.


## 17. Homologação oficial informada pelo responsável — 04/11/2026

**M5-A — HOMOLOGADO FUNCIONAL, VISUAL E TECNICAMENTE PELO RESPONSÁVEL.**

**Playtest manual: 13/13 PASSOU — Nenhuma observação.**

| # | Critério informado | Resultado |
|---|---|---|
| 1 | Qualidade artística do Claustro | PASSOU |
| 2 | Câmera vertical | PASSOU |
| 3 | Plataformas e caminhos opcionais | PASSOU |
| 4 | Descoberta dos Votos sem Nome | PASSOU |
| 5 | Aparência e animações do Monge Acorrentado | PASSOU |
| 6 | Legibilidade e dificuldade dos ataques | PASSOU |
| 7 | Aviso e funcionamento da Prensa de Contrapeso | PASSOU |
| 8 | Combinação entre inimigo e armadilha | PASSOU |
| 9 | Transição entre salas | PASSOU |
| 10 | Morte e respawn na sala correta | PASSOU |
| 11 | Reinício dos pilotos com F7 | PASSOU |
| 12 | Campanha original iniciando normalmente com F5 | PASSOU |
| 13 | Qualidade de imagem e fluidez na TCL 4K | PASSOU |

Fonte: declaração explícita do responsável na solicitação de homologação. Não é playtest executado pelo agente. Os 30 itens históricos não foram convertidos em 30/30.

Resultados automatizados históricos preservados: 1370 principais (1013 herdadas + 357 novas), 68 gráficas, 17 capturas dos pilotos, 17 capturas do Guardião idênticas às referências. Benchmark 4K de 60 s: 59,999 FPS, p95 17,078 ms, máximo 22,760 ms, 24 entradas/trocas. Nenhum teste da engine foi repetido nesta etapa documental. Diagnósticos de ambiente e limitações anteriores permanecem acima.

Auditoria documental/versionamento desta etapa: raiz e baseline confirmados, branch main, autoria local Rafael <spiritstonesrafa@gmail.com>, 36 arquivos novos esperados e duas documentações rastreadas; referências/UIDs sem ausência ou duplicação e nenhuma assinatura de segredo. Os 220 arquivos anteriores fora das duas documentações mantêm SHA-256, incluindo project.godot e os 14 locais excluídos do commit. Scripts, cenas, arte e parâmetros homologados não foram alterados nesta homologação. Conferência do índice e commit registrada também no relatório final da tarefa.

M5-B autorizado após a verificação do commit M5-A; ainda não iniciado no fechamento da etapa A. M5-C e M6 não iniciados. Pilotos independentes preservados como referência aprovada. Sem push.

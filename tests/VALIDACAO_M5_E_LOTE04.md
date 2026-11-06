# M5-E — lote 04: expansão geométrica controlada

**Resultado: parcial.** Uma extensão física de O1 foi implementada e testada; O2–O6 permanecem sem ramificações implementadas. Nenhum percurso recebe PASS integral neste relatório: O1 ainda não comprova a capela/circuito e extensão do planejamento e os demais não têm caminho distinto. As seis inscrições seguem presentes; não foram criados atalhos nem iniciado M5-F.

## Diagnóstico e validação prévia

Baseline `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`, com alterações locais dos lotes M5-E preservadas. Os 15 arquivos protegidos foram comparados com o baseline de hashes. A movimentação existente usa 100 px/s, gravidade 680 e impulso −230; a medida histórica física do salto é cerca de 41 px.

Em `m5_e_lote04_o1_fixture.gd` foram instaladas as três lajes candidatas **apenas numa fixture sintética** e executados seis saltos individuais com Aren real, nos dois sentidos. A primeira tentativa com movimento contínuo passou três e ultrapassou três destinos; após soltar a direção antes do centro do destino, os seis pousos passaram. Isso prova as amostras individuais, não garante conforto para todo jogador. As lajes ficam acima da espinha do S2, cuja superfície nessa região está em y228; seus fundos estão em y72, 96 e 120. Câmera e continuidade precisaram de prova integrada posterior.

A triagem geométrica `m5_e_lote04_geometry_audit.gd` examinou os esboços do lote 03, **sem física**: no S3 há fundos de laje com 0 a 24 px de folga sobre o piso principal, e no S5 uma sobreposição deixa 4 px; isso não preserva uma passagem de corpo de 24 px com margem. Nos esboços S7, S9 e S10 a folga inferior registrada foi 28 px ou mais, mas isso não prova que a passagem e os saltos da rota obrigatória, os tetos, os perigos ou a câmera estejam preservados. `m5_e_lote04_other_fixtures.gd` conseguiu alcançar os primeiros apoios dos cinco esboços em ensaios sintéticos isolados; esses resultados não provam cadeias completas, retorno, ausência de bloqueio ou experiência adequada. Não se conclui que esses setores sejam inerentemente impossíveis: faltam um desenho diferente e a prova integrada exigida para instalar novos sólidos com segurança.

## Geometria e conteúdo implementados

Somente S2/O1: três retângulos sólidos novos, locais ao setor, `Rect2(968,60,48,12)`, `Rect2(1028,84,48,12)` e `Rect2(1088,108,48,12)`. O percurso parte dos três patamares existentes do piloto, adiciona estes três e retorna pelos mesmos apoios. A inscrição de capela próxima de `(1112,108)` é independente de Votos sem Nome e da inscrição aprovada do piloto. Não se construiu uma câmara fechada ou um circuito com saída distinta. O desenho reutiliza o atlas da Abadia e suportes decorativos sem colisão; a integração artística permanece para playtest.

Arquivos desta etapa: `scripts/abbey/m5e_o1_chapel.gd`, integração em `scripts/abbey/chapter_sector.gd` e mensagem/estado em `scripts/abbey/chapter.gd`; os quatro scripts de testes `tests/m5_e_lote04_o1_fixture.gd`, `tests/m5_e_lote04_other_fixtures.gd`, `tests/m5_e_lote04_geometry_audit.gd` e `tests/m5_e_lote04_o1_journey.gd`; planejamento e este relatório. Os demais arquivos M5-E e alterações preexistentes não foram descartados.

## Resultado por percurso e métricas

| Percurso | Classificação | Extensão geométrica distinta comprovada | Pendência |
|---|---|---|---|
| O1 S2 | PARTIAL | 144 px de largura somada dos **três novos topos**; 288 px somando também os três topos opcionais anteriores de 48 px. | São somas de apoios, não comprimento do percurso ou da câmara; validar projeto, conforto e circuito/capela completos. Meta proposta: 360 px. |
| O2 S3 | PARTIAL | 0 px novo | Inscrição apenas; os esboços cortam a passagem principal. Meta proposta: 480 px. |
| O3 S5 | PARTIAL | 0 px novo | Inscrição apenas; uma laje candidata deixa 4 px sobre o piso. Meta proposta: 560 px. |
| O4 S7 | PARTIAL | 0 px novo | Inscrição apenas; primeiros ensaios não provam sequência completa nem preservação da passagem. Meta proposta: 420 px. |
| O5 S9 | PARTIAL | 0 px novo | Inscrição apenas; teto, checkpoint e sequência inteira exigem prova. Meta proposta: 620 px. |
| O6 S10 | PARTIAL | 0 px novo | Inscrição apenas; Pêndulo, percurso completo e preservação da separação entre travessia e combate exigem prova. Meta proposta: 560 px. |

As cinco distâncias zero significam que nenhum apoio opcional foi adicionado nelas, não que seu desenho futuro esteja resolvido. **Total comprovado por esta métrica limitada: 288 px de topos opcionais em O1, dos quais 144 px são novos.** Não se dispõe de medida válida de extensão geométrica de cada percurso completo nem do total das ramificações, e não se somam arcos de salto ou ida e volta para atingir os 3.000 px históricos propostos. A prova histórica anterior registrou 276,71 px de deslocamento de Aren até o terceiro patamar anterior; a extensão completa da nova galeria, ida e volta em px e tempo não foram medidos. O valor principal histórico 17.360,42 px não foi novamente medido; as definições da espinha e dos checkpoints não foram alteradas.

## Ensaios integrados

- `m5_e_lote04_o1_journey.gd`: Godot 4.7.2, Monge real ativo, entrada normal S2, trajeto por inputs reais aos três apoios anteriores e três novos, mensagens de Votos sem Nome e capela, três saltos de retorno, descida à rota, ativação de checkpoint e avanço a S3: zero falhas. A entrada foi estabelecida pela troca de setor do controlador; não houve reposicionamento durante a travessia. A câmera chegou ao alvo no retorno e foi observada em capturas; não se demonstrou exaustivamente ausência de softlocks em todas as situações.
- A execução gráfica gerou capturas no destino nas resoluções 1280×720, 1920×1080, 2560×1440 e 3840×2160, com o mesmo percurso físico. São quadros parados após o pouso, não uma avaliação completa em movimento das quatro resoluções. Evidências em `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote04-final/capela-{largura}x{altura}.png`.
- Regressão das inscrições dos cinco setores: 36 verificações locais sem falha. Distribuição e checkpoints M5-C3: 157/157; não representa repetição das auditorias de simultaneidade. Histórico de diagnóstico de certificados raiz e avisos ObjectDB voltou a aparecer no encerramento; sem investigação de causa nesta etapa.
- Logs: `.godot/m5e-lote04-o1-fixture.log`, `.godot/m5e-lote04-outras-fixtures.log`, `.godot/m5e-lote04-geometria.log`, `.godot/m5e-lote04-o1-final-visual.log`, `.godot/m5e-lote04-m5_e_lote02_test.log` e `.godot/m5e-lote04-m5_c3_distribution_test.log`.

## Estado e próximos passos

Fazer playtest de O1, observando a necessidade de frear nos pousos, a leitura do destino, os suportes visuais, a câmera e o retorno. Para O2–O6, projetar apoios variados com folga real para Aren e executar testes de sequência, perigos ativos e corredor principal antes de instalar geometria; ensaios isolados não bastam. O índice está vazio e os arquivos permanecem locais, sem staging, commit, push ou deploy.

# M5-C1 — demonstração dos inimigos da Abadia

**M5-C1 — HOMOLOGADO FUNCIONAL E VISUALMENTE PELO RESPONSÁVEL; AUDITORIA TÉCNICA APROVADA COM RESSALVAS.** Playtest manual informado: **16/16 PASSOU — nenhuma observação**. A ressalva ObjectDB e o escopo dos testes constam em [VALIDACAO_M5_C1_AUDITORIA.md](VALIDACAO_M5_C1_AUDITORIA.md). M5-A e M5-B permanecem homologados. M5-C2 e a distribuição definitiva M5-C3 não foram iniciados.

O responsável aprovou aparência, animações, aviso, esquiva e derrota dos três inimigos; sinalização e limites do Vigia; recuperação; acesso aos encontros; morte e respawn; F7; qualidade visual e fluidez em 4K. Este registro relata o playtest humano informado e é distinto dos testes automatizados abaixo.

O responsável também informou o **reteste visual do Vigia: PASSOU, nenhuma observação**, após a correção do início da linha para 6 px. Alcance, dano, temporização e balanceamento permaneceram iguais.

### Homologação manual informada pelo responsável — 16/16

1. Acólito: aparência e animações — PASSOU.
2. Acólito: aviso do disparo e tempo de reação — PASSOU.
3. Acólito: esquiva do projétil por movimento ou salto — PASSOU.
4. Acólito: derrota com a espada — PASSOU.
5. Penitente: aparência e animações — PASSOU.
6. Penitente: movimentação na plataforma — PASSOU.
7. Penitente: investida legível e evitável — PASSOU.
8. Penitente: combate divertido e diferente do Monge — PASSOU.
9. Vigia: aparência e animações — PASSOU.
10. Vigia: área do ataque sinalizada — PASSOU.
11. Vigia: ausência de dano fora da área indicada — PASSOU.
12. Vigia: recuperação permite contra-ataque — PASSOU.
13. Integração: três inimigos acessíveis e enfrentáveis — PASSOU.
14. Integração: morte e respawn — PASSOU.
15. Integração: F7 reinicia a demonstração — PASSOU.
16. Integração: qualidade visual e fluidez em 4K — PASSOU.

Observações informadas: nenhuma. O reteste da linha visual do Vigia também passou sem observações. **ObjectDB permanece com ressalva técnica aberta:** sete `RefCounted` observados em carregamento assíncrono isolado, sem causa exata determinada; não há comprovação de vazamento persistente. M5-C2 permanece não iniciado.

## Base e escopo

Branch `main`, HEAD inicial `5d4266a3e299d174e1ffabd10e65602d86854d5b`. O `project.godot` já estava modificado e 14 arquivos já eram não rastreados; foram preservados. Foram examinados o planejamento do capítulo, documentação M5-A/M5-B, controlador de Aren, monge, dano, carregamento e testes existentes. A campanha e os sistemas homologados não foram editados. Esta demonstração é uma cena independente e carrega um encontro por vez.

## Encontros

- **Acólito:** 2 PV, preparo de 0,75 s, emissão de projétil visível a 65 px/s por até 1,6 s, bloqueado pelo mundo, 1 dano, recuperação de 0,90 s. Procura distância; projétil é removido ao contato, morte ou descarregamento.
- **Penitente:** 2 PV, patrulha curta sobre uma plataforma, sensores de borda e aproximação; preparo de 0,65 s, investida de 72 px/s por 0,30 s, 1 dano e recuperação de 0,90 s. Movimenta-se com colisão, sem teleporte entre plataformas.
- **Vigia:** 3 PV, vigilância estática, aviso de 0,75 s com linha de alcance frontal, área ativa de 0,18 s, 1 dano e recuperação de 0,90 s.

Os três reutilizam o receptor de espada, a fonte de dano e a máquina de estados do monge sem alterar o monge: patrulha/posicionamento, aviso, ataque, recuperação, reação e derrota. Poses distintas de repouso, passos, preparação, ataque, recuperação, reação e derrota são escolhidas conforme o estado. Consulte `assets/art/m5c/PROVENANCE.md` para a origem dos três atlas. O cenário da demonstração reaproveita a arte aprovada da galeria. Detecção exige proximidade, visibilidade na câmera e linha de visão.

## Como executar

No editor Godot, abra `res://scenes/abbey/abbey_enemies_demo.tscn` e pressione **F6** para executar a cena atual. Caminhe para a direita para passar ao encontro seguinte e para a esquerda para voltar; pule para a plataforma do Penitente. **F7** reinicia a demonstração. A/D movimenta, espaço salta, J ataca. F5 permanece ligado à cena principal existente. Os checkpoints são locais à demonstração.

## Resultados observados

- Godot 4.7.2: importação e inicialização da demonstração concluídas. O ambiente informou falhas de leitura do repositório de certificados e de escrita das configurações/logs no perfil; logs direcionados para a pasta de evidências foram gravados.
- `tests/m5_c1_test.gd`: **41 verificações passaram**, sem falhas: carregamento, detecção, aviso, ataque, dano físico, recuperação, espada derrotando cada arquétipo, limpeza, reinício, patrulha sobre plataforma, morte/respawn e passagem nos dois sentidos entre as duas primeiras salas. Os combates são automatizados e não substituem playtest.
- Regressão herdada: **3.750 verificações passaram**: 3.632 nas 16 suítes registradas em `results.json`, incluindo M0, M1, sobrevivência, cemitério, inimigos, mecanismos, integração, chefe, piloto, estrutura e capítulo da Abadia, e 118 na continuidade gráfica. A tentativa headless anterior da continuidade ultrapassou 300 s; a repetição com renderização gráfica passou 118/118.
- Capturas reais com GPU: 12 arquivos, três arquétipos em 1280×720, 1920×1080, 2560×1440 e 3840×2160. Os arquivos capturam a pose de aviso; não comprovam todas as poses em movimento nem uma TV TCL física. As capturas de 1280×720 do Acólito, Penitente e Vigia foram inspecionadas no contexto da cena; aceitação artística permanece manual.
- Ensaio de 60 s em janela 3840×2160, RTX 2060 SUPER, um encontro por vez, vida de Aren restaurada pelo instrumento: 3.596 quadros, média 59,93 FPS, p95 16,865 ms, máximo 51,736 ms, máximo 42 nós e 1 projétil; após descarregar restou 1 nó da árvore de teste. Houve outras verificações em execução no computador; não é benchmark isolado nem medição na TV. Uma primeira tentativa do instrumento falhou por acesso a sala descarregada; foi preservada e corrigida no instrumento, sem atribuí-la ao jogo.
- ObjectDB: as suítes herdadas `abbey_chapter` e `abbey_chapter_structure` registraram **6 instâncias** no encerramento; a continuidade gráfica registrou 5. A suíte nova e o ensaio de descarregamento não registraram aviso equivalente; isso não comprova ausência de vazamento persistente nem identifica a origem histórica.

Evidências desta rodada, sem sobrescrever as anteriores: `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5c1-20261104-1758` (resultados, logs e `final-platform/` com capturas).

## Limitações ainda abertas

Na rodada original não foram cobertos automaticamente todos os casos solicitados de esquiva em movimento, limites da área do Vigia, bloqueio por paredes, projétil em todas as transições, reinício por tecla F7, todas as poses e toda a regressão gráfica histórica. O Penitente patrulha uma plataforma e usa investida no mesmo nível; não realiza salto autônomo entre plataformas. O responsável posteriormente aprovou funcional e visualmente o conjunto; a auditoria automatizada é separada dessa aprovação.

## Checklist do responsável

Marcar cada item **PASSOU / FALHOU / NÃO TESTADO**:

- Acólito: aparência; movimento; animações; aviso; ataque; projétil; dano; derrota.
- Penitente: aparência; movimento; plataforma e bordas; aviso; ataque; recuperação; dano; derrota.
- Vigia: aparência; animações; aviso; limites da área; legibilidade; dano; recuperação; derrota.
- Integração: controles de Aren; espada; morte e respawn; F7; visual em 4K; fluidez; ausência de problemas graves; qualidade artística geral; diferença entre inimigos; dificuldade justa.

## Inventário e Git

Novos: atlas e proveniência em `assets/art/m5c/`, cena `scenes/enemies/abbey_experimental_enemy.tscn`, cena `scenes/abbey/abbey_enemies_demo.tscn`, scripts `scripts/abbey/m5c1_*`, seus UIDs e `tests/m5_c1_test.gd`. Não foi feito staging, commit ou push. O índice permanece vazio; os arquivos preexistentes continuam locais.

# M5-E — lote integrado das cinco inscrições

**Estado: implementação local parcial; avaliação humana e validação integrada pendentes.** Cinco inscrições contextuais foram adicionadas aos setores 3, 5, 7, 9 e 10. O teste físico local passou nos cinco pontos, mas usa uma fixture apoiada próxima a cada marca; ele não prova uma jornada completa a partir da entrada de cada setor nem comprova percursos opcionais novos. Os ramos históricos O2–O6, com seus comprimentos e acessos próprios, não foram construídos. Os atalhos não foram iniciados.

## Conteúdo e localização

As posições são locais a cada setor, sobre superfícies existentes. A inscrição aparece na faixa contextual ao saltar junto à marca; ela reaparece em visitas posteriores e um estado simples de sessão registra a descoberta. Não há recompensa de inventário ou mudança de geometria. A marca usa a placa aprovada no lote 01, com matizes de acordo com a paleta de cada ambiente.

| Setor | Ponto local | Conteúdo |
|---|---|---|
| 3 Escadaria dos Contrapesos | `(820,372)` | Contrapeso partido e corrente rompida. |
| 5 Cisternas Votivas | `(550,420)` | Ossuário votivo e nomes guardados pela água. |
| 7 Fundição dos Sinos | `(885,324)` | Molde de um sino que não soou. |
| 9 Arquivo dos Juramentos | `(1120,252)` | Registro sem assinatura. |
| 10 Jardim Suspenso | `(700,300)` | Memória dos ausentes associada ao mirante. |

Estas inscrições ficam na rota existente, e sua leitura requer um salto próximo; não constituem, por si só, câmaras, desvios de exploração nem os 480/560/420/620/560 px historicamente propostos. A descoberta por salto pode ser acidental ou pouco intuitiva; deve ser avaliada em playtest antes de homologar o lote. Não se afirma que os elementos ambientais específicos originalmente imaginados, como a corrente partida e o molde físico, foram acrescentados.

## Arquivos e preservação

`scripts/abbey/m5e_discoveries.gd` contém dados, posições e marcas; `scripts/abbey/chapter_sector.gd` instancia as marcas e `scripts/abbey/chapter.gd` usa a faixa contextual e registra estado de sessão. `tests/m5_e_lote02_test.gd` executa as provas. `tests/VALIDACAO_M5_E_LOTE01.md` registra a homologação informada pelo responsável para o piloto. Os arquivos e mudanças locais anteriores foram preservados. Os 15 arquivos protegidos foram conferidos por hash; os resultados e ressalvas M5-C3 e ObjectDB permanecem históricos.

## Verificações

- Godot 4.7.2, teste headless: **26 verificações, zero falhas**. Para cada setor, verifica apoio seguro de uma posição de teste cerca de 50 px antes da marca, movimentação e salto reais, mensagem e estado, inimigos e perigos instalados e ativos, retorno à posição anterior e aproximação da câmera. A fixture é reposicionada no começo de cada setor; não houve teletransporte durante o trecho testado.
- Godot com renderização 1920×1080: as mesmas verificações e cinco capturas passaram. Os ensaios mostram a leitura no salto; não substituem playtest, nem demonstram uma passagem completa entre salas com perigos.
- Regressão M5-E lote 01: zero falhas; Monge ativo e checkpoint do setor 2 ativado fisicamente. Distribuição M5-C3: **157/157**, incluindo respawn dos sete checkpoints e combate em setores selecionados. Não é nova validação dos encontros combinados inconclusivos.
- A Godot registrou novamente falha de leitura dos certificados raiz do ambiente e avisos ObjectDB ao encerrar os testes; sem investigação nova nem afirmação de causa.

Capturas reais: `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote02/setor-03.png`, `setor-05.png`, `setor-07.png`, `setor-09.png` e `setor-10.png`. Logs em `.godot/m5e-lote02.log`, `.godot/m5e-lote02-visual.log`, `.godot/m5e-lote02-m5_e_lote01_test.log` e `.godot/m5e-lote02-m5_c3_distribution_test.log`.

## Checklist para o responsável

1. Abra `scenes/abbey/abbey_chapter.tscn` e pressione F6; percorra os setores 3, 5, 7, 9 e 10 normalmente.
2. Observe se cada placa combina com o cenário e sugere corretamente que é possível examiná-la. Salte próximo e avalie clareza, duração e significado do texto.
3. Confirme que é possível afastar-se e retornar, que as ameaças continuam legíveis e que checkpoints e progressão seguem naturais.
4. Avalie se as inscrições sobre a rota principal são suficientes para a experiência pretendida; os percursos opcionais maiores continuam pendentes.

Sem staging, commit, push ou deploy. O lote não recebeu homologação visual ou funcional do responsável.

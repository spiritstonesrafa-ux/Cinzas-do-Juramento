# M5-C3 — encerramento administrativo com ressalvas

O responsável aprovou a opção B da RCA01 e determinou o **encerramento administrativo do M5-C3 com ressalvas**, autorizando o planejamento do próximo marco. Esta decisão não é homologação funcional, visual ou técnica dos testes inconclusivos e não converte seus resultados em PASS.

## Decisão de design

Os critérios passam a respeitar a função documentada e o comportamento de cada encontro. Nos setores 5, 6, 7, 8 e 9, a presença de ameaças na mesma sala não impõe, por si só, uma prova universal de pressão simultânea. No setor 10, Jardim Suspenso, o responsável aprovou a separação original entre travessia e combate. No setor 11, Campanário Exterior, permanece a exigência de combinações avançadas ensinadas. Identificar e comprovar a combinação pretendida é uma **pendência técnica para revisão posterior que não bloqueia o avanço do roadmap**, conforme determinação do responsável.

As evidências de jornada, danos identificados, checkpoints e ciclo de vida permanecem nos relatórios anteriores. A decisão não afirma impossibilidade de pressão simultânea nem altera as classificações históricas das provas. Avaliações de justiça e legibilidade observadas em playtest continuam relevantes para o desenvolvimento.

## Pendências conhecidas por setor

| Setor | Registro para revisão posterior |
|---|---|
| 5 — Cisternas Votivas | Classificação e comportamento do agrupamento Comporta/Acólito conforme sua função real. A prova de pressão conjunta permaneceu inconclusiva. |
| 6 — Galeria dos Turíbulos | Relação funcional entre Monge, Prensa e Jato. A evidência de pressão conjunta permaneceu inconclusiva. |
| 7 — Fundição dos Sinos | Função das ameaças nas duas alas e descanso entre encontros. A simultaneidade dos agrupamentos permaneceu inconclusiva. |
| 8 — Ponte dos Penitentes | Função do Penitente e da Comporta no trecho com vãos. A simultaneidade permaneceu inconclusiva; as travessias dos dois sentidos constam dos testes anteriores. |
| 9 — Arquivo dos Juramentos | Relação entre Acólito, projétil e Jato. A pressão conjunta permaneceu inconclusiva. |
| 10 — Jardim Suspenso | Separação entre travessia e combate aprovada pelo responsável. A impossibilidade de sobreposição em todos os estados não foi comprovada. |
| 11 — Campanário Exterior | Identificar e comprovar a combinação avançada pretendida. Pendência técnica futura expressamente não bloqueante para o roadmap. |

A ressalva histórica **ObjectDB** permanece aberta. Foram observados objetos `RefCounted` em carregamento assíncrono e avisos em testes posteriores, sem origem conclusiva. Não se afirma resolução nem vazamento persistente. Qualquer problema real de dano inevitável, softlock, legibilidade ou descarregamento que apareça no desenvolvimento ou no playtest deve ser registrado e priorizado conforme seu impacto, sem presumir defeito a partir destas pendências.

## Evidências e próximos passos

Os resultados históricos constam em [FIX02](VALIDACAO_M5_C3_FIX02.md), [FIX03](VALIDACAO_M5_C3_FIX03.md), [FIX04](VALIDACAO_M5_C3_FIX04.md), [FIX05](VALIDACAO_M5_C3_FIX05.md) e [RCA01](VALIDACAO_M5_C3_RCA01.md). Eles distinguem as provas aprovadas das lacunas. Não houve nova execução da engine para este registro documental.

O próximo marco formal é **M5-D — arte e acabamento da região completa**, antes de M5-E e M5-F. Seu planejamento está em [PLANEJAMENTO_M5_D.md](../docs/PLANEJAMENTO_M5_D.md). O planejamento não constitui implementação ou homologação. O desenvolvimento de M5-D segue a autorização específica do responsável para sua execução, conforme a regra geral do roadmap.

Estado de referência desta etapa: branch `main`, HEAD `cda7e40b689e4e7197d2eccfb53e9fbd357032d0`, índice inicialmente vazio. As alterações locais M5-C3 permanecem sem commit. Os 15 arquivos protegidos incluem o `project.godot` previamente modificado e 14 arquivos não rastreados anteriores, conferidos pelo inventário de hashes histórico. A geometria de referência de 17.360,42 px e os sete checkpoints não receberam alteração nesta etapa. Sem staging, commit, push ou deploy.

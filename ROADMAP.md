> **Estado atual (07/11/2026):** M5 homologado; **M6-B2 (Setores 1 a 6 da Floresta dos Ossos) homologado oficialmente pelo responsável**. Os seis setores possuem travessia bidirecional nivelada, arte petrificada do Codex e acessibilidade validada (subidas <= 20 px). Próximo lote: M6-B3 (setores subsequentes da Floresta dos Ossos; novos inimigos, armadilhas e Cervo Espectral permanecem pendentes e não iniciados).

> **Homologação posterior M5-F:** o responsável informou “playtest ok” e homologou o M5-F com as ressalvas documentadas. O mínimo físico global de 12.227,52 px continua não comprovado e não bloqueante; o modelo horizontal não é distância física. M5-C3, ObjectDB e o pico histórico de 183,878 ms permanecem registrados. Esta informação não representa nova execução automatizada.

## Histórico — homologação M5-D e continuidade

Esta seção registra a situação à época; o estado atual consta no topo.

O responsável informou que concluiu o playtest e que está tudo OK, aprovando oficialmente o M5-D no escopo visual e funcional. O ensaio automatizado 4K registrou pico isolado de 183,878 ms como **observação de desempenho não bloqueante**; sua causa não foi determinada e o resultado médio e p95 permanecem documentados. A ressalva histórica ObjectDB e as pendências conhecidas do M5-C3, inclusive a combinação avançada do Campanário para revisão posterior sem bloquear o roadmap, continuam registradas. Nenhum novo teste da engine é alegado neste encerramento documental.

O próximo marco previsto é **M5-E — exploração, segredos e atalhos completos**, dependente da base M5-D homologada e de autorização específica de implementação conforme a regra geral do roadmap. O [planejamento M5-E](docs/PLANEJAMENTO_M5_E.md) propõe seis descobertas sinalizadas, percursos opcionais e três atalhos abertos pelo lado avançado, com retorno funcional, preservação dos sete checkpoints e sem exigir novos sistemas de inventário. Os números e distâncias são propostas a validar no escopo próprio, incluindo a manutenção do mínimo de rota principal após atalhos. M5-F permanece destinado à regressão e homologação da região; M6 depende de M5-F. M5-E não foi implementado nesta etapa.

# Cinzas do Juramento — Roadmap por marcos

**Versão:** 0.1  
**Regra geral:** cada marco exige relatório técnico, verificação automatizada compatível com o ambiente e avaliação jogável humana. O próximo marco só começa após aprovação explícita do responsável. Não fazer commit/push automaticamente.

| Marco | Entrega demonstrável | Critério de aceite principal | Dependência |
|---|---|---|---|
| **M0 — Fundação jogável** | Cavaleiro provisório se move, salta, colide, acompanha câmera e retorna após queda em cenário de teste | Abrir no Godot, jogar sem bloqueios e documentar validação | Nenhuma |
| **M1 — Combate com espada** | Ataque básico, hitbox temporal, inimigo estático/móvel simples, feedback de acerto | Golpe só causa dano em janela correta; sem acerto por trás ou fora de alcance | M0 homologado |
| **M2 — Sobrevivência** | HP, receber dano, invulnerabilidade, knockback, checkpoints, reinício | Dano não repete indevidamente; restauração previsível | M1 homologado |
| **M3 — Primeira fase** | Cenário gótico, inimigos variados, desafios, armadilhas, início/fim de fase | Percurso completo, sem softlock, ritmo de dificuldade validado | M2 homologado |
| **M4 — Chefe** | Chefe de fase, arena, padrões legíveis, vitória | Pode ser derrotado de forma justa, sem estado impossível | M3 homologado |
| **M5 — Abadia Silenciosa** | Planejamento e desenvolvimento incremental da região; M5-A somente dois pilotos experimentais | Aprovação artística, funcional e técnica por marco; extensão final mínima 4× | M4 homologado |
| **M5-G — Chefe da Abadia** | Arena, Abade e dash pós-vitória homologados pelo responsável | Homologação funcional e visual concedida; fechamento técnico e Git separados | M5-F homologado |
| **M5-H — Combate aéreo e recompensas** | Ataque aéreo; ampliação de inimigos; +1 de vida máxima pelo Guardião; cinemática do Abade e dash Passo das Sombras; persistência segura | M5-H homologado pelo responsável; SAVE-SAFETY-01 validado tecnicamente, com limitações documentadas | M5-G homologado |
| **M6-B2 — Floresta dos Ossos (Setores 1 a 6)** | Seis setores conectados, passagens niveladas, abismos de 48 e 45 px, Grande Ossuário | **Homologado oficialmente pelo responsável em 07/11/2026**; 46/46 verificações aprovadas | M6-B1 homologado |
| **M6-B3 — Expansão subsequente** | Próximos setores da Floresta dos Ossos; novos inimigos, armadilhas e Cervo Espectral | Não iniciado; aguarda planejamento e autorização | M6-B2 homologado |
| **M7 — Expansão posterior e polimento** | Demais regiões; backlog de som original, UX e polimento do slice preservado | Escopos futuros aprovados separadamente | M6 homologado e autorização |
| **M8 — Publicação executável** | Build Windows, configuração, testes finais e distribuição | Empacotamento, licenças e documentação revisados | Escopo de produto homologado e autorização |

## M0 — Backlog estrito

- **M0-01** Detectar estado da pasta/versão da Godot e registrar baseline.
- **M0-02** Criar `project.godot` e cena inicial, sem sobrescrever material pré-existente.
- **M0-03** Configurar resolução lógica 320×180 e escala visual pixel-perfect.
- **M0-04** Criar personagem `CharacterBody2D` com silhueta geométrica do cavaleiro (espada embainhada decorativa).
- **M0-05** Implementar movimento horizontal, gravidade, pulo, *coyote time* e *jump buffer*.
- **M0-06** Criar cenário de testes com piso, três plataformas de alturas diferentes, paredes e zona de queda.
- **M0-07** Configurar câmera horizontal limitada às bordas do cenário.
- **M0-08** Implementar retorno ao ponto de início quando o jogador cai.
- **M0-09** Escrever `README.md` com requisitos, execução, controles e decisões técnicas.
- **M0-10** Rodar validações disponíveis e entregar relatório honesto com testes manuais pendentes.

## Decisão oficial — chefes por fase

O responsável definiu um chefe obrigatório para cada uma das cinco fases, além de um chefe final adicional e um chefe secreto adicional: **sete confrontos de chefe previstos**. A fase 1 possui o Guardião do Juramento e a Abadia possui o Abade das Correntes, homologado em M5-G. A antiga atribuição do Abade a M6 é histórica e não cria um segundo Abade. Os chefes posteriores devem exigir progressivamente mais posicionamento e leitura, sem ataques inevitáveis ou dificuldade artificial. Detalhes futuros de M6 e dos chefes final e secreto dependem de definição.

## Não entra no M0

Ataques, dano, inimigos, chefes, armadilhas com dano, efeitos de sangue, vida, menu, save, checkpoints, gamepad, fases finais, diálogos, cutscenes, trilha, asset packs, exportação release, publicação.

## Gatilho para avançar

Somente iniciar M1 depois que: (1) o projeto abrir e executar no computador do responsável; (2) o movimento e a câmera forem aprovados em jogo; (3) o relatório de M0 mostrar alterações e verificações; (4) houver autorização expressa para M1.

## Disciplina de entregas

- Um objetivo principal por marco.
- Cenas e scripts revisáveis e autocontidos.
- Mudanças pequenas, reversíveis e rastreáveis.
- Nunca declarar PASS se o comando não foi executado.
- Toda aprovação é do responsável, não do agente.
- Git: somente ações de leitura até instrução explícita para versionar.

## Decisão homologada M4-B — progressão dos chefes (03/11/2026)

O Guardião do Juramento é o primeiro chefe de O Cemitério dos Esquecidos,
concluindo o percurso na Catedral. Sua dificuldade é intencionalmente
introdutória: ensina leitura de antecipações, esquiva/posicionamento,
contra-ataques, recuperação e adaptação à segunda fase. Ser relativamente
fácil não é defeito. M4-B homologado funcionalmente pelo responsável.

Preservar HP 10, dano 1, velocidades, telegrafias, cooldowns, recuperações,
padrões e transição aos 50% homologados. Não elevar dificuldade no M4-C.

O segundo chefe deverá aumentar perceptivelmente a dificuldade por maior
profundidade dos padrões e domínio do jogador, com justiça; não apenas HP
ou dano maiores. Próximo chefe e segunda fase do jogo não iniciados.

O plano macro do GDD v0.1 contém nomes provisórios anteriores; o cânone
implementado da primeira fase é O Cemitério dos Esquecidos e seu chefe é o
Guardião do Juramento. M4-C foi autorizado como conclusão deste encontro;
continuidade deve limitar-se a gancho narrativo, sem acesso funcional a região
inexistente, habilidade, item ou recompensa nova. Homologação do M4-C pendente.

## M4-C — conclusão homologada (04/11/2026)

Derrota de 2,6 s, armadura vazia, ruptura de um elo da maldição e conclusão de
O Cemitério dos Esquecidos integradas ao selo/retorno existentes. Combate
introdutório M4-B preservado. Estado de vitória só na sessão, sem save global.
Nenhuma nova região, próximo chefe, equipamento ou habilidade foi iniciado.
Sem anúncio de acesso funcional a uma fase inexistente. Relatório e checklist
em tests/VALIDACAO_M4_C.md. Homologado funcional e visualmente pelo responsável:
13/13 PASSOU, nenhuma observação. Primeiro chefe e conclusão da primeira fase
homologados; próxima região e novo marco aguardam autorização.


## Formalização dos marcos futuros — M5 (04/11/2026)

Histórico da autorização de prototipagem: conceito da Abadia aprovado para duas salas independentes. M0–M4 publicados não mudam. As antigas linhas futuras M5(slice),M6(expansão),M7(publicação executável) são substituídas pela sequência acima: seu backlog de som/UX/polimento não foi dado como concluído e permanece no M7 futuro. Push do Capítulo1 é publicação do código, não build/release executável.

- M5-P: estudo/validação arquitetural, formalizado em docs/PLANEJAMENTO_CAPITULO_02.md.
- M5-A: Claustro das Sombras e Galeria dos Penitentes; **HOMOLOGADO FUNCIONAL, VISUAL E TECNICAMENTE PELO RESPONSÁVEL**. Playtest manual: **13/13 PASSOU — Nenhuma observação**, incluindo TCL 4K. Testes técnicos anteriores preservados, sem nova execução nesta etapa documental.
- M5-B: expansão estrutural dos12 setores implementada, 17360,42 px principais medidos; **pendente de playtest e homologação**. Sete posições funcionais de checkpoint pertencem à estrutura; distribuição completa de ameaças segue no M5-C.
- M5-C: demais inimigos, desafios e checkpoints, não iniciado; o Monge/Contrapeso do piloto não concluem esse marco.
- M5-D: arte e acabamento da região completa, não iniciado; assets dos pilotos pertencem ao M5-A.
- M5-E: exploração, segredos e atalhos completos, não iniciado à época deste registro histórico.
- M5-F: regressão e homologação da região, não iniciado à época deste registro histórico.
- M6-A/B/C: fundação, combate avançado e conclusão do segundo chefe, **não iniciados**.

Meta futura:14400 px principais; mínimo12227,52 px, aceite arredondado12228; expansão4,71× sobre3056,88 px. Pilotos não cumprem nem alegam cumprir a extensão final. Manter3000 px opcionais, seis descobertas, três atalhos e seteCP como metas. Narrativa/arte/layout definitivos dependem do responsável. Campanha inicial, Cemitério e Guardião preservados. Sem transição canônica, save global ou nova habilidade.

Homologação M5-A registrada em 04/11/2026 para commit local único, sem push. A expansão M5-B está autorizada somente após conferir esse commit; no fechamento desta etapa A permanece não iniciada. Pilotos preservados como referência aprovada.

## M5-B — expansão estrutural autorizada após o commit M5-A

M5-A registrado localmente em `cf7f0b22eb37bfb83a4da5cf7224e463a7f58bca`, conferido antes da implementação. Doze cenas modulares conectadas, pilotos instanciados sem alteração, um Aren/HUD persistentes e sete checkpoints estáveis. Acesso F6 em scenes/abbey/abbey_chapter.tscn; F5 preservado. Métricas reais e checklist em tests/VALIDACAO_M5_B.md. Sem homologação automática, staging/commit M5-B ou push. M5-C, M5-D, M5-E e M6 não iniciados como marcos completos; reservas de integração e arte estrutural não os concluem.


## M5-B-FIX01 — continuidade focada, aguarda novo playtest

Tamanho geral aprovado pelo responsável; M5-B ainda não homologado integralmente. Dois cortes internos de fundo corrigidos somente emS2/S6, X960. Direção auditada nos12 setores; S4/S10 reorientados, sem encurtar perfis, para manter direita na ida e esquerda na volta. Relatório tests/VALIDACAO_M5_B_FIX01.md. Sem staging, commit, push ou início do M5-C.


## Homologação do responsável — M5-B

**M5-B — HOMOLOGADO PELO RESPONSÁVEL NO ESCOPO ESTRUTURAL, FUNCIONAL E VISUAL TESTADO.** Extensão principal histórica: **17.360,42 px — 5,6791×** o Capítulo 1; tamanho aprovado. FIX01 e FIX02 aprovados no playtest informado; nenhuma correção visual obrigatória adicional relatada. Não se infere aprovação de 30/30 itens.

Pendência técnica conhecida: investigar futuramente a origem das cinco instâncias ObjectDB registradas ao encerrar uma suíte visual; não há comprovação de vazamento persistente. Três diretórios externos de evidências FIX01 foram sobrescritos em regressão anterior; resultados históricos textuais preservados, sem reconstrução artificial.

M5-C não iniciado. O Capítulo 2 ainda depende de M5-C (inimigos e armadilhas), M5-D (acabamento), M5-E (exploração), M5-F (regressão final) e M6 (segundo chefe). Nenhuma nova execução de engine é alegada nesta homologação documental.

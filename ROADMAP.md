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
| **M6 — Segundo chefe** | Fundação, combate avançado e conclusão do Abade, ainda não iniciado | Padrões justos e dificuldade superior por aprendizado | M5-F homologado e autorização |
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
- M5-B: expansão estrutural dos12 setores, **não iniciada**.
- M5-C: demais inimigos, desafios e checkpoints, não iniciado; o Monge/Contrapeso do piloto não concluem esse marco.
- M5-D: arte e acabamento da região completa, não iniciado; assets dos pilotos pertencem ao M5-A.
- M5-E: exploração, segredos e atalhos completos, não iniciado.
- M5-F: regressão e homologação da região, não iniciado.
- M6-A/B/C: fundação, combate avançado e conclusão do segundo chefe, **não iniciados**.

Meta futura:14400 px principais; mínimo12227,52 px, aceite arredondado12228; expansão4,71× sobre3056,88 px. Pilotos não cumprem nem alegam cumprir a extensão final. Manter3000 px opcionais, seis descobertas, três atalhos e seteCP como metas. Narrativa/arte/layout definitivos dependem do responsável. Campanha inicial, Cemitério e Guardião preservados. Sem transição canônica, save global ou nova habilidade.

Homologação M5-A registrada em 04/11/2026 para commit local único, sem push. A expansão M5-B está autorizada somente após conferir esse commit; no fechamento desta etapa A permanece não iniciada. Pilotos preservados como referência aprovada.

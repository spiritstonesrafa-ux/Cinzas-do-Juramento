# Cinzas do Juramento — Game Design Document (GDD)

**Versão:** 0.1 — Pré-produção  
**Status:** conceito inicial; valores sujeitos a playtest  
**Plataforma-alvo inicial:** Windows PC  
**Tecnologia:** Godot 4.x (versão estável instalada e documentada), GDScript tipado  
**Modelo de produção:** marcos pequenos, implementados com Codex e homologados pelo responsável.

## 1. Visão geral

**Elevator pitch:** um cavaleiro condenado a vagar entre a vida e a morte atravessa fortalezas, criptas e templos arruinados, enfrentando criaturas sobrenaturais com sua espada para descobrir o preço de um juramento quebrado.

**Gênero:** ação e plataforma 2D linear, com progressão por fases e chefes.  
**Inspiração mecânica:** jogos de ação e plataforma de 16 bits, especialmente a cadência e a dificuldade dos clássicos do Super Nintendo.  
**Identidade própria:** mundo, enredo, protagonista, personagens, cenários, monstros, música e arte originais. Não reproduzir assets, nomes, layouts ou músicas de Castlevania.

### Pilares de design

1. **Controles justos e responsivos:** a dificuldade nasce do desafio, nunca de comandos imprevisíveis.
2. **Combate legível:** os golpes de espada têm início, janela de acerto e recuperação compreensíveis.
3. **Níveis lineares expressivos:** obstáculos, inimigos e ambiente contam parte da história.
4. **Atmosfera gótica própria:** decadência medieval, pedra, aço, cinzas, vitrais e luz fria.
5. **Chefes como testes de domínio:** vencer exige reconhecer sinais, esquivar e escolher o momento de atacar.

## 2. Mundo e narrativa

**Título de trabalho:** *Cinzas do Juramento*. **Protagonista:** Aren, cavaleiro amaldiçoado. **Premissa:** Aren quebrou um juramento sagrado tentando salvar seu reino. Ressurge em um território transformado por um mal ancestral, com a armadura marcada por brasas frias e a memória fragmentada. Precisa avançar por domínios arruinados e confrontar os guardiões que o mantêm preso à maldição.

**Tom:** melancólico, sombrio e heroico. História transmitida por introduções curtas, ambientação e encontros marcantes. Evitar longos diálogos que interrompam o ritmo.

**Objetivo narrativo inicial:** descobrir a causa da maldição e alcançar a fortaleza central. Reviravoltas e desfecho ficam para uma versão posterior do GDD.

## 3. Núcleo de jogabilidade

### Loop principal

Entrar na fase → superar plataformas e perigos → enfrentar inimigos → alcançar checkpoint → enfrentar desafio final/chefe → concluir fase → liberar a próxima.

### Personagem

- Deslocamento horizontal de direção livre, salto e queda.
- Espada como arma principal: um golpe básico de alcance curto/médio, com direção determinada pelo lado para o qual o personagem olha.
- Estado de vida e feedback de dano em marcos futuros.
- Sem árvore de habilidades, XP, loot aleatório, crafting ou exploração metroidvania na primeira versão.

### Movimentação desejada

- Resposta rápida às mudanças de direção, sem deslizar excessivamente.
- Salto previsível; protótipo poderá incluir *coyote time* e *jump buffering* para reduzir frustrações.
- Gravidade, velocidade, aceleração e altura do salto configuráveis por parâmetros.
- Animações/poses legíveis em idle, run, jump e fall.

### Combate planejado — não implementar em M0

- Golpe simples de espada (M1), com hitbox ativa apenas durante a janela de acerto.
- Inimigos sinalizam ataques antes de causarem dano.
- Vida, invulnerabilidade breve após dano e checkpoints (M2).
- **Decisão oficial de recompensas de chefes:** Todo chefe concede uma recompensa permanente própria e significativa.
  - **Chefe 1 (Guardião do Juramento):** concede permanentemente **+1 ponto de Vida Máxima** a Aren na primeira vitória legítima (HP máximo 5 → 6), refletido no HUD discreto e persistido em arquivo seguro, sem concessão duplicada em refights. Homologado pelo responsável em 06/11/2026.
  - **Chefe 2 (Abade das Correntes):** concede permanentemente a habilidade **Passo das Sombras (dash terrestre)**, com sequência cinematográfica gótica de encerramento (queda, rompimento das correntes, assimilação de energia sombria por Aren e apresentação da nova técnica). Efeito visual com sigilo gótico em cruz floriada, arco etéreo, faíscas radiais no piso, cascalho, rastro de raspagem, névoa escura e frenagem. Persistência segura em arquivo de progresso. Homologado pelo responsável em 06/11/2026.
- **M5-H (Ataque Aéreo e Expansão):** Aren pode golpear no ar com J durante salto ou queda (um golpe por ciclo no ar, preservando gravidade e movimento horizontal). Inimigos comuns expandidos para 12 na Fase 1 (Cemitério) e 20 na Fase 2 (Abadia). Homologado oficialmente pelo responsável em 06/11/2026.

## 4. Design das fases

### Decisão oficial sobre chefes

O responsável definiu que cada uma das cinco fases terá obrigatoriamente um chefe, além de um chefe final adicional e um chefe secreto adicional: **sete confrontos previstos**. O chefe da fase 1 é o **Guardião do Juramento**; o segundo é o **Abade das Correntes**, homologado no M5-G. Sua dificuldade atual foi aceita; os chefes posteriores devem exigir mais posicionamento, leitura de padrões e domínio das habilidades disponíveis, sem ataques inevitáveis ou números definidos prematuramente. Os chefes final e secreto são adicionais aos cinco chefes de fase; seus nomes e acessos ainda serão definidos.

### Plano macro (ideias anteriores, sujeito a revisão)

| Fase | Cenário | Principal desafio | Ideia de chefe |
|---|---|---|---|
| 1 — O Cemitério dos Esquecidos | Cemitério e Catedral | Aprender salto e espada | Guardião do Juramento (implementado e homologado) |
| 2 — Abadia Silenciosa | Claustros e sinos | Ritmo de armadilhas | Abade das Correntes (implementado e homologado) |
| 3 — Floresta dos Ossos | Floresta petrificada | Plataformas e inimigos móveis | Cervo Espectral |
| 4 — Fornalha do Juramento | Minas e fornalhas | Perigos do ambiente | Guardião das Brasas |
| 5 — Trono Esquecido | Fortaleza central | Domínio de todas as mecânicas | Regente do Vazio |

Os nomes e conceitos das fases e chefes futuros são provisórios; o Guardião do Juramento e O Cemitério dos Esquecidos são os nomes implementados. Fases de 8–12 minutos são uma meta de design, não uma promessa de duração.

### Vertical slice

Criar uma fase polida de **3–5 minutos**, com entrada, desafios de plataforma, inimigos, checkpoint, chefe, conclusão e identidade audiovisual. **Não faz parte de M0**.

## 5. Direção de arte e som

- **Arte:** pixel art original inspirada na clareza e no contraste de jogos 16-bit, sem replicar sprites existentes.
- **Tela:** resolução lógica 320×180 (16:9), pixels nítidos e upscale inteiro.
- **Referência de escala:** tiles de 16×16 px; cavaleiro com cerca de 24–32 px de altura aparente (a validar).
- **Paleta:** carvão, cinza de pedra, ferro azulado, vinho escuro e detalhes âmbar.
- **Silhueta:** armadura marcada, capa desgastada e espada reconhecível.
- **Som:** trilha original com timbres sombrios, camadas ambientais, impactos metálicos e passos. Nada de música ou SFX de franquias existentes.
- **M0:** apenas arte provisória geométrica desenhada no próprio projeto, sem necessidade de baixar assets.

## 6. Interface e acessibilidade

- Inicialmente teclado; gamepad é meta futura.
- Controles remapeáveis são desejáveis antes da primeira versão pública.
- Manter contraste visual entre cenário, jogador, plataformas e perigos.
- Evitar depender exclusivamente de cores para comunicar dano e estados.
- Tela de vida, menu, pausa, HUD e saves serão implementados em marcos posteriores, não na fundação.

## 7. Escopo da primeira fundação (M0)

**Inclui:** projeto Godot inicial executável, cena de bootstrap, cenário de teste com chão, plataformas e limite de queda, cavaleiro provisório com silhueta de armadura e espada embainhada, movimento para os dois lados, salto, gravidade, colisões, câmera horizontal com limites, mecanismo simples de reposição após queda, mapa de controles, README e validação de carregamento.

**Exclui:** golpes de espada, hitboxes ofensivas, inimigos, IA, combate, vida, dano, morte, checkpoints permanentes, chefe, menus, saves, efeitos especiais, trilha sonora, assets finais, DLC, mobile, multiplayer, integração em nuvem e sistemas de RPG.

## 8. Definição de pronto do M0

- Projeto abre no editor Godot 4.x sem recursos ausentes e inicia na cena principal.
- O jogador anda, muda de direção, salta e aterrissa sem atravessar superfícies.
- Cenário contém pelo menos três plataformas ou alturas diferentes e uma zona de queda testável.
- Câmera acompanha horizontalmente o jogador e não mostra espaço além dos limites do nível.
- Se cair para fora da área jogável, jogador volta ao início do cenário sem travar.
- Teclas documentadas e arquivo README explica como abrir/rodar no Windows.
- Código organizado, sem warnings graves ou erros no carregamento; testes executados e evidenciados quando a engine estiver disponível.
- Nenhum commit ou push foi criado; próximos marcos permanecem intocados.

## 9. Riscos e mitigação

- **Sensação de controle ruim:** priorizar playtests antes de arte definitiva.
- **IA expandindo escopo:** marcos aprovados separadamente, com listas de exclusão explícitas.
- **Arte inconsistente:** adotar guia visual e pipeline único antes da produção artística.
- **Cenas difíceis de manter:** composição por cenas pequenas e scripts tipados.
- **Validação enganosa:** separar testes automatizados de avaliação manual da jogabilidade.

## 10. Questões abertas para próximas revisões

Dificuldade e curva de aprendizado; número de vidas/checkpoints; suporte a gamepad; duração-alvo do jogo completo; características definitivas da espada; identidade visual final; nome e direção narrativa definitivos.

# M5-G — Abade das Correntes, chefe da Abadia Silenciosa

> **Atualização de implementação:** a arena, o Abade e o dash pós-vitória foram implementados em caráter experimental e estão em validação, sem homologação do responsável. Os trechos abaixo descrevem o planejamento histórico e não substituem o [relatório de validação](../tests/VALIDACAO_M5_G_ABADE.md).

**Implementação M5-G autorizada e em validação; sem homologação do responsável.** O responsável determinou um chefe por fase, mais um chefe final adicional e um secreto adicional: sete confrontos previstos para cinco fases. O Guardião do Juramento é o chefe implementado da primeira fase; **Abade das Correntes** é o nome provisório do chefe da Abadia, ainda inexistente no jogo. M5-G é uma proposta de realocação do trabalho anteriormente chamado M6-A/B/C, não um chefe extra; o destino de M6 dependerá de decisão futura. A Abadia não será considerada concluída sem integrar e homologar seu chefe.

Fontes: [GDD](../GDD.md), [roadmap](../ROADMAP.md), [planejamento original, seção 17](PLANEJAMENTO_CAPITULO_02.md), `scripts/abbey/chapter_layout.gd`, `scripts/abbey/chapter.gd` e resultados M5-F. Todos os detalhes de arena e combate abaixo são propostas para avaliação, não gameplay implementado nem aprovação de arte.

## Localização e entrada

Propor arena própria depois do **setor 12 — Coro das Correntes**, acessível pela continuação à direita após o percurso principal. O código atual só sinaliza o fim estrutural em S12; não existe arena ou vitória da Abadia. Os últimos patamares e o checkpoint CP7 do S12 já existem: a conexão e qualquer área nova precisam ser projetadas no marco do chefe, preservando os 12 setores, checkpoints e a geometria homologada. O acesso deve ser intencional, com carregamento seguro, sem disparar enquanto Aren retorna pela sala e sem alterar a ligação do Capítulo 1. Definir com o responsável a forma de entrada/retorno e a política de saída durante o combate.

Ponto de partida para protótipo: piso contínuo e bordas seguras, com origem do golpe, alvo e resposta visíveis; o estudo anterior sugeriu 640×240 lógicos, até duas telas, com possibilidade de reduzir a área ativa caso a câmera oculte informações. São dimensões de estudo, não geometria aprovada. O checkpoint próximo deve permitir uma nova tentativa segura; a referência anterior de até 10 s de CP7 até recuperar controle na arena deve ser medida, não presumida.

## Identidade e narrativa

Figura alta e curvada com vestes escuras, aro votivo e correntes com pesos de bronze: antigo guardião dos registros e votos da Abadia. Inscrições e correntes podem sugerir sua relação com os juramentos sem exposição longa. Sua culpa, ligação com Aren, detalhes visuais e desfecho permanecem abertos à aprovação; manter identidade distinta da armadura e espada do Guardião. Silhueta, antecipação e recuperação devem sobressair à arquitetura e aos efeitos.

## Combate proposto

Aren usa os controles, salto, espada terrestre, vida e invulnerabilidade existentes. O protótipo anterior sugere começar com HP 10 e dano 1 do chefe, sujeitos a testes e decisão, não como valores aprovados. Dificuldade maior deve vir de leitura e posicionamento, sem exigir nova habilidade, salto alterado, imunidade longa ou maior dano como única resposta.

| Família proposta | Sinal e resposta prevista | Janela/limite de justiça |
|---|---|---|
| Peso de penitência | Braço erguido e marca de chão; sair da marca. | Alvo fixado antes da queda; peso preso permite aproximação. |
| Varredura baixa | Corrente tensionada em direção legível; saltar ou recuar. | Alcance limitado e recuperação atingível pela espada. |
| Gancho comprometido | Linha e postura indicam eixo e direção; sair do eixo. | Retorno inicialmente não ofensivo; sem puxar Aren como mecânica nova. |
| Passo do carrilhão | Dois passos e peso erguido indicam o lado ameaçado. | Direção comprometida; não rastrear continuamente. |
| Dois votos | Dois sinais distintos para ações já ensinadas. | No máximo duas ações por sequência no protótipo; intervalo permite reposicionar. |
| Ressonância | Aro e pulsos de chão anunciam faixas alternadas. | Faixa segura visível; sem dano em toda a tela ou fonte invisível. |

Proposta de duas fases: primeira ensina as famílias básicas; segunda tem transição reconhecível sem dano, limpa ataques ativos e introduz sequências curtas e ressonância. Os tempos do estudo anterior (avisos cerca de 0,75–1,00 s e recuperações de 0,55–0,85 s) são apenas sementes: medir deslocamento e janela real da espada antes de decidir. Todas as famílias e pares permitidos precisam ter resposta possível sem dano com Aren original; não ocultar a origem do ataque fora da câmera.

## Ciclo de encontro e integração

- **Vitória proposta:** HP do Abade chega a zero, ataques e hitboxes são desarmados, animação/feedback de derrota e estado de vitória são aplicados uma vez; conclusão da Abadia ocorre apenas depois do resultado válido, sem anunciar transição de fase inexistente.
- **Derrota:** morte de Aren cancela ataques e fontes ofensivas, descarrega/retorna de forma segura ao checkpoint existente e restaura vida segundo o sistema atual. Reentrada reinicia o encontro com estado coerente antes da vitória; após a vitória válida, o desbloqueio permanente deve sobreviver a morte, queda, F7 e ao fechamento/reabertura do jogo. A arquitetura atual é apenas de sessão e ainda não fornece essa persistência: sua implementação e integração são dependências futuras do marco.
- **Casos de borda a definir e testar:** dano simultâneo, morte durante aviso/ataque/transição de fase, saída e retorno, carregamento de sala, morte após vitória e repetição da entrada. O comportamento exato de vitória simultânea requer decisão de design antes da implementação.
- **Integração com fim da fase:** substituir o aviso de fim estrutural somente em M5-G, após decisão sobre fluxo e apresentação; o fluxo de F5 e a vitória do Guardião devem continuar intactos. Setores, atalhos e 17.360,42 px históricos não são alterados por este plano.

## Decisão aprovada — dash após vitória e melhoria posterior

O responsável definiu que Aren desbloqueará **permanentemente o dash/deslizamento ao vencer o Abade das Correntes**, com comunicação visual clara e integração à progressão. O dash não estará disponível antes da vitória válida; o encontro do Abade e o percurso anterior devem permanecer vencíveis com os controles atuais. A recompensa não é uma habilidade disponível no começo da luta. Esta decisão é de design: nenhum dash, tela ou sistema de persistência foi implementado agora.

A permanência deve atravessar morte, queda, F7, troca de cena e reinício do aplicativo. O armazenamento e a restauração precisam ser concebidos para vitória e desbloqueio coerentes, gravação e leitura verificáveis, reentrada e repetição idempotentes, sem concessão antecipada ou perda silenciosa. A tecnologia de save, tratamento de falhas e integração com o estado legado permanecem escolhas de implementação; não se declara que o projeto atual salva em disco. Duração, velocidade, cooldown, tecla e eventual invulnerabilidade do dash ainda não foram definidos.

Critérios específicos: verificar que não há dash antes da vitória, concedê-lo somente após vitória válida e comunicá-lo visualmente; confirmar disponibilidade após morte, retorno, F7 e reinício, inclusive após reentrada no chefe; validar falhas de gravação, integridade do progresso e regressões de Aren. Definir como comunicar e recuperar eventual falha de gravação antes de homologar. A vitória simultânea e o instante exato de concessão exigem regra explícita antes da implementação.

O **ataque aéreo é melhoria independente**, planejada para depois do desenvolvimento do chefe. Não integra o dash, não é pré-requisito para vencer o Abade e não deve ser implementado ou desbloqueado automaticamente junto à recompensa. Seu escopo, momento de desbloqueio e parâmetros serão definidos em etapa própria.

## Dependências e etapas propostas

1. Revisão do critério M5-F aprovada; o responsável informou “playtest ok” e homologou o M5-F com ressalvas. A implementação M5-G foi autorizada.
2. Aprovar conceito visual/narrativo, topologia e câmera da arena, entrada, saída, política de vitória simultânea e requisitos de repetição.
3. **M5-G-A proposto:** arena piloto e uma família de ataque; validar câmera, distância, morte e respawn com física real antes de arte definitiva.
4. **M5-G-B proposto:** expandir as famílias e fase progressiva aprovadas; validar cada resposta e os pares permitidos, sem mudar Aren.
5. **M5-G-C proposto:** integrar derrota, recompensa de dash permanente, persistência, narrativa e conclusão; regressão completa, desempenho, playtest e homologação. Nenhuma das subetapas começa sem autorização específica.

Dependências técnicas: cena e controlador próprios para arena/chefe, integração com carregamento e snapshots da Abadia, hitbox/hurtbox da espada e de dano existentes, sinais de vida, checkpoint, câmera, HUD/feedback, recursos originais e UIDs pertinentes. Examinar se o padrão do Guardião é reutilizável sem acoplamento ou regressão; não criar framework genérico. A persistência permanente da recompensa é agora requisito explícito, mas o mecanismo de armazenamento ainda deve ser projetado; o sistema atual somente em sessão não a satisfaz.

## Critérios de aceite e playtest

- Entrada e reentrada legítimas, CP seguro, câmera e sinalização compreensíveis; resposta física sem dano por família e combinação autorizada, em ambos os lados quando aplicável, com janela de ataque terrestre verificável.
- Sem ataque invisível ou inevitável, hitboxes residuais, dano após morte/derrota, softlock, transição sem controle ou alteração dos contratos M0–M5 homologados. Verificar derrota, morte, simultaneidade e retorno.
- Testes da concessão, bloqueio anterior à vitória e persistência permanente do dash conforme seção acima; o ataque aéreo independente permanece fora do escopo do chefe.
- Testes de integração e regressão de controles, combate, checkpoints, setores, atalhos e Capítulo 1; inspeção gráfica nas quatro resoluções e desempenho em condições representativas.
- Playtest do responsável: reconhecer cada aviso, entender onde falhou, encontrar oportunidade de punir, comparar aprendizagem e conforto com o Guardião e avaliar arena, efeitos e narrativa. A dificuldade deve ser justa; vencer sem mortes é possível. Registrar observações e solicitar homologação expressa.

Sem implementação, alterações de cena ou gameplay, staging, commit, push, deploy ou início de M6 nesta preparação.

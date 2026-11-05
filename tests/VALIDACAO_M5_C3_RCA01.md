# RCA01 — critérios dos encontros M5-C3

**Conclusão C — decisão de design necessária**, com revisão B recomendada para o Jardim. A documentação exige combinações seguras no capítulo, mas não identifica os sete agrupamentos como sete encontros obrigatoriamente simultâneos. As instruções posteriores exigem interação simultânea nos encontros combinados relevantes. Elas continuam válidas até o responsável definir quais agrupamentos se enquadram ou aprovar revisão. O M5-C3 permanece BLOCKED.

## Causa-raiz e rastreabilidade

O planejamento [seções 10–13](../docs/PLANEJAMENTO_CAPITULO_02.md) descreve S5 como posicionamento, S6 como ritmo entre ciclos, S7 como duas alas com descanso, S8 como mobilidade, S9 como espaço e cobertura, S10 como travessia e combate separados e S11 como combinações ensinadas. A regra de no máximo duas fontes ofensivas simultâneas no campo de visão é um teto, não um mínimo para cada setor. O requisito de resposta por par na seção do chefe diz respeito ao chefe.

O pedido original M5-C3, §§8–11 e 20, em `C:/Users/ovohe/.codex/attachments/f0d5a701-1291-43e3-945e-b5d56304293e/Texto colado.txt`, exige combinações moderadas e avançadas, espaço, resposta legítima e ausência de dano inevitável ou bloqueio de todas as saídas simultaneamente. Os exemplos de pares são explicitamente exemplos. O pedido exige testar combinações relevantes, mas não designa cada uma das sete coexistências como encontro simultâneo.

O FIX02, §9, exige examinar cada combinação presente e pressão simultânea de outras ameaças em encontros com projéteis. O FIX03, §4, exige interação simultânea das ameaças relevantes para encontros combinados. O FIX04 explicitou prova de duas ameaças impondo decisões relevantes, ou comprovação de impossibilidade, para cada combinação relevante. Assim, há autorização posterior explícita para esse critério. A lacuna é identificar quais pares são encontros relevantes. A matriz FIX02 agrupou instâncias por sala, sem demonstrar que cada agrupamento constitui uma combinação simultânea. O bloqueio foi perpetuado ao aplicar essa hipótese aos sete agrupamentos, enquanto as amostras negativas não demonstravam impossibilidade.

A [distribuição](../scripts/abbey/m5c3_distribution.gd) define posições e arquétipos por sala, sem identificadores ou gatilhos compartilhados de encontro. A [matriz M5-C3](VALIDACAO_M5_C3.md) chama S5 de padrões consecutivos e combinação a validar. Isso não comprova intenção simultânea. Não se pode retirar unilateralmente a exigência posterior.

## Modelo estrutural

O [layout](../scripts/abbey/chapter_layout.gd) preserva 12 salas, pisos em degraus, vãos de 24 px na Ponte, direção principal à direita e sete checkpoints. O [piloto](../scripts/abbey/pilot_room.gd) coloca o Monge em (388,300) e a Prensa em (588,300); o Jato novo fica em (850,300). Coexistência é demonstrada pelo código. Dois relógios de mecanismos independentes podem coincidir em atividade, o que não demonstra áreas sobrepostas nem duas decisões simultâneas para Aren.

O [Monge](../scripts/abbey/monk.gd) e os [outros arquétipos](../scripts/abbey/m5c1_enemy.gd) dependem de visão até 104 px em x e 20 em y, câmera e linha livre, com posição limitada a ±64 px da origem. Acólito anuncia 0,75 s e lança [projétil](../scripts/abbey/m5c1_projectile.gd) de raio 5 a 65 px/s, com duração superior a 1,6 s e bloqueio pelo cenário. Penitente anuncia 0,65 s e investe durante 0,30 s. Vigia usa aviso de 0,75 s e ataque de 0,18 s. O projétil pode sobreviver à fase ativa.

Os [mecanismos](../scripts/abbey/m5c2_hazard.gd) usam seguro/aviso/ativo/recuperação. Pêndulo usa 1,8/0,8/1,2/1,4 s e forma móvel 24×24. Comporta usa 1,6/0,8/0,5/1,5 s, forma 20×48, e só inicia aviso com Aren a menos de 85 px em x e 28 em y. Jato usa 1,8/0,8/0,7/1,4 s e forma 40×16 em x+18 a x+58. A [Prensa](../scripts/abbey/counterweight.gd) usa aviso de 0,8 s e ataque de 0,4 s, com forma 28×28 em movimento vertical. As áreas efetivas dependem de posições, altura, direção, ciclo e colisão com terreno. Ausência de candidatos no filtro do FIX04 não prova impossibilidade. FIX05 acompanhou projéteis, mas não validou toda a identificação de causas de remoção nem uma janela de pressão conjunta.

## Matriz de critérios

R2 indica requisito confirmado com evidência insuficiente. R3 indica incompatibilidade com o design documentado. R4 indica intenção ambígua. As classificações não substituem as classificações de alcançabilidade do FIX05.

| Encontro | Requisito original e implementação | Evidência existente | Classificação | Próxima ação |
|---|---|---|---|---|
| S5 Cisternas, ida e volta | Posicionamento e descida. Comporta (780,492) e Acólito (950,516); 170 px entre origens e degraus. O planejamento não designa este par como simultâneo | FIX02 travessias; FIX03 duas esquivas do disparo sem dano após janela da Comporta. Ela estava segura no disparo observado | R4 | Solicitar decisão se o par é um encontro combinado ou desafios consecutivos |
| S6 Galeria, ida e volta | Ritmo, ciclos e abrigos. Monge (388,300), Prensa (588,300), Jato (850,300) | FIX03 esperou a Prensa sem dano. Prensa ativa e Jato em aviso foram observados, sem segunda decisão comprovada | R4 | Solicitar decisão sobre pares relevantes e aplicar critério correspondente |
| S7 Fundição, ida e volta | Duas alas, descanso entre pares e Vigia isolado primeiro. Vigia (410,300), Pêndulo (690,348), Monge (1080,276) | FIX02 passou nos dois sentidos. As origens dos inimigos distam 670 px | R4 | Solicitar decisão sobre quais agrupamentos são encontros combinados |
| S8 Ponte, ida e volta | Mobilidade, vãos e apresentação do Penitente. Penitente (550,300), Comporta (850,300) | FIX02 ida e volta sem dano. Amostras FIX04 não provam impossibilidade de pressão conjunta | R4 | Solicitar decisão se o par é combinado e manter prova direcionada caso seja |
| S9 Arquivo, ida e volta | Exploração, espaço e cobertura. Acólito (510,372), Jato (800,300) | FIX03 duas esquivas sem dano. Jato seguro no disparo observado. Projétil pode continuar após fase ativa | R4 | Solicitar decisão se se espera pressão conjunta e, se exigida, observar trajetória e fase do Jato |
| S10 Jardim, ida e volta | O planejamento diz travessia e combate separados. Penitente (450,252), Pêndulo (850,324) | FIX02 ida e volta sem dano. A separação entre origens é 400 px, sem prova de impossibilidade em todos os estados | R3 quanto à leitura de simultaneidade como requisito original; R4 quanto à instrução posterior | Solicitar aprovação para avaliar travessia e combate separados, mantendo justiça e retorno |
| S11 Campanário, ida e volta | O planejamento exige combinações ensinadas na progressão avançada. Vigia (420,516), Comporta (850,372) | FIX02 passou nos dois sentidos. Não demonstra que este par seja a combinação exigida | R2 para a combinação avançada geral; R4 para atribuí-la a este par | Solicitar designação da combinação avançada e manter prova direcionada pendente |

Para cada setor, simultaneidade do par específico não está explicitada na descrição original. Uma sequência pode satisfazer o ritmo de uma sala, sobretudo S10, mas isso depende de decisão quanto às instruções posteriores. A justiça foi demonstrada apenas nas trajetórias amostradas. Não há defeito R5 comprovado. A ausência de simultaneidade não foi comprovada como escolha implementada nem impossibilidade. As metas preliminares de quantidade do planejamento não são prova isolada de defeito, pois o pedido M5-C3 recomenda distribuir pela geometria sem cotas arbitrárias.

## Critério definitivo proposto para aprovação

1. Designar cada encontro relevante como sequencial ou combinado. Várias entidades numa sala não constituem, automaticamente, um encontro simultâneo.
2. Para sequenciais, avaliar avisos, espaço e tempo de reação, resposta legítima, ida e volta com ameaças ativas, proteção de entradas e checkpoints. Não exigir simultaneidade artificial.
3. Para combinados designados, demonstrar resposta legítima às pressões alcançáveis, mantendo hitboxes e IA ativas. Alegação de impossibilidade exige invariantes suficientes, não apenas amostras negativas.
4. Preservar a obrigação original de combinações seguras e progressivas no capítulo e de que hitboxes não fechem todas as opções. S11 ou outra localização indicada precisa sustentar a combinação avançada ensinada.
5. Reutilizar FIX02 para jornada 1→12→1, sete checkpoints, 104 verificações de ciclo de vida e regressões, e FIX03 para os três danos explicados e evitados em duas provas por caso. FIX04 amostrou posições com filtro incompleto. FIX05 observou projéteis, mas não validou completamente causas de remoção ou pressão conjunta. Essas evidências não provam impossibilidade nem substituem playtest.

Esta proposta depende de aprovação expressa. Não é uma alteração unilateral do requisito posterior. Mesmo aprovada, não autoriza M5-C3 PASS sem comprovar os requisitos aplicáveis e a avaliação humana.

## Decisão do responsável e prova mínima condicional

**Alternativa A — Manter simultaneidade.** Designar quais dos sete pares são encontros combinados, especialmente S9 e S11. Preserva a exigência posterior, com custo de provar janelas alcançáveis ou impossibilidade fundamentada.

**Alternativa B — Critério por função.** Aprovar S10 como sequencial e classificar os demais por encontro. Aceitar as evidências existentes quando compatíveis, mantendo combinações reais e seguras no capítulo. Reduz provas sem correspondência de design, mas exige designar pelo menos onde a progressão combinada avançada será demonstrada.

Para cada par que for designado combinado: usar a sala real, todas as ameaças e hitboxes ativas, e começar na entrada prevista. Repetir da outra entrada em execução separada. Aproximar, esperar, saltar ou recuar usando controles normais até que duas ameaças efetivamente imponham decisões na mesma janela. Registrar, em quadros comuns, comandos, posição e velocidade de Aren, HP e invulnerabilidade normal, estados, formas e projéteis em voo. Sucesso é registrar a janela relevante e uma resposta legítima reproduzível em duas execuções, com progressão e retorno. Se não ocorrer janela, demonstrar restrições suficientes para excluir estados alcançáveis ou manter inconclusivo. Interromper ao observar softlock, dano inevitável reproduzível ou referência inválida, ou após conjunto finito definido de variações sem resultado. Essas provas não foram executadas nesta auditoria.

## Riscos e integridade

O plano é histórico e inclui propostas de quantidade, geometria e tipos sujeitas a implementação e aprovação. FIX02–FIX05 são amostras automatizadas. A ressalva histórica ObjectDB, inclusive os sete RefCounted observados no carregamento assíncrono, permanece sem causa conclusiva. Não houve novos testes de engine nesta RCA.

Início e fim em C:/PROJETOS/CINZAS DO JURAMENTO, branch main, HEAD `cda7e40b689e4e7197d2eccfb53e9fbd357032d0`, índice vazio. Havia alterações locais M5-C3, project.godot modificado e 14 arquivos anteriores não rastreados. Os 15 hashes protegidos foram conferidos antes e depois. Único novo arquivo da RCA: este relatório. Nenhuma alteração funcional, staging, commit, push ou deploy.

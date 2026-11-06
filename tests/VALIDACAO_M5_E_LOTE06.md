# M5-E — lote 06: O1 e alternativas de exploração

**Resultado:** O1 recebe **PASS técnico para o circuito implementado**, sujeito a playtest presencial. O2–O6 permanecem **PARTIAL**: inscrições existentes, mas sem percursos opcionais físicos completos. Nenhuma geometria nova foi acrescentada neste lote. A aprovação artística da capela por captura foi informada pelo responsável no pedido do lote; não equivale a playtest presencial ou a nova execução automática.

## O1: percurso e medidas

A entrada do S2 é `(48,300)`. A prova percorre a espinha com o Monge ativo, entra no ramo em aproximadamente `(756,156)`, sobe os três patamares do piloto, passa por Votos sem Nome, percorre os três apoios adicionais e chega à Capela dos Nomes. A saída é pela borda direita `(1208,108)`, descendo ao piso perto de `(1219,228)`; Aren volta para ativar o CP e prossegue para S3. As mensagens e estados de Votos sem Nome, da placa de nomes e da capela são separados. O circuito possui uma entrada e reconexão distintas, embora a descida e a arquitetura não provem que todo cenário de queda seja seguro.

Para uma **referência geométrica explícita**, usa-se a polilinha local `(756,156) → (816,132) → (872,108) → (936,84) → (992,60) → (1052,84) → (1148,108) → (1208,108)`. Cada ponto intermediário é um centro de patamar ou ponto da capela; os segmentos retos são referências entre pontos, inclusive sobre vãos. Seu comprimento é **478,40 px**; a conexão de descida até `(1219,228)` acrescenta uma corda de **120,50 px**, totalizando **598,91 px**. A linha representa a rota alternativa em outra altura e é distinta da linha da espinha, com bifurcação e reconexão nas extremidades. Não é a soma da largura dos patamares, não é um caminho continuamente apoiado nem mede nova largura horizontal do mapa. A projeção horizontal da parte superior é 452 px e sobrepõe em x a rota principal. A meta histórica O1 de 360 px e a agregada de 3.000 px são propostas; métodos não equivalentes não demonstram seu cumprimento.

Na travessia automática a medição física acumulada do ponto de lançamento até a aterrissagem foi **844,39 px**, incluindo arcos e correções; a soma dos deslocamentos horizontais absolutos foi **461,66 px**, incluindo eventuais repetições. Não somar essas cifras à polilinha. O retorno pela descida é distinto da ida superior; o trecho posterior no piso até o CP volta a ser compartilhado com a espinha. A distância exata repetida ao caminhar do pouso até o CP não foi instrumentada. Referência calculada por `m5_e_lote06_o1_metric.gd`; não se confunde com deslocamento real de Aren.

## Provas e limites de O1

- `m5_e_lote06_o1_journey.gd`: Godot 4.7.2, travessia desde a entrada legítima do setor com ameaças em estado canônico, seis pousos, os dois marcos narrativos, descida, CP e transição S3, sem reposicionamento intermediário: zero falhas. Durante o ramo, o maior afastamento medido entre Aren e o centro da câmera foi `(99,26; 48,45)` px, dentro da janela lógica de 320×180; nenhuma amostra ultrapassou os limites internos usados no teste. É uma trajetória, não prova universal para todas as velocidades e erros de salto.
- `m5_e_lote06_o1_clearance.gd` testou fisicamente saltos partindo de três posições sintéticas apoiadas no corredor sob as novas lajes (`x=992`, `1052` e `1148`, y228). Em todas, o salto alcançou **40,908 px** e Aren voltou ao chão. As amostras demonstram espaço nos três pontos, não ausência absoluta de aprisionamento em todas as posições.
- As capturas finais do lote 05 mostram o destino em 1280×720, 1920×1080, 2560×1440 e 3840×2160: `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote05-definitivo/capela-{largura}x{altura}.png`. São imagens paradas; não foram produzidas novas capturas para este lote sem mudanças visuais. O responsável aprovou a direção por imagem, e a avaliação do conforto de pouso e de possíveis quedas no jogo segue pendente.
- Logs: `.godot/m5e-lote06-o1.log`, `.godot/m5e-lote06-clearance.log` e `.godot/m5e-lote06-metric.log`. O aviso conhecido de certificados e o aviso ObjectDB no encerramento voltaram a aparecer; não houve auditoria de causa.

## O2–O6: matriz e estratégia

| Rota | Estado inicial e final | Avaliação e proposta a desenvolver |
|---|---|---|
| O2 S3 | PARTIAL → PARTIAL; inscrição existente, sem ramo | Escadaria ascendente usa toda a largura da passagem; candidatos anteriores deixaram 0–24 px sob lajes. Uma galeria em espaço deslocado da espinha exigirá mapear entrada e reconexão sem cruzar degraus nem varredura do Pêndulo. |
| O3 S5 | PARTIAL → PARTIAL; inscrição existente, sem ramo | Os tetos e a laje de 4 px de folga inviabilizam o esboço anterior. Um nicho do ossuário deve ficar fora da coluna de movimento e respeitar os tetos, Comporta e câmera; nenhuma posição foi comprovada. |
| O4 S7 | PARTIAL → PARTIAL; inscrição existente, sem ramo | O esboço de laje baixa reduziu um salto da espinha a 4 px. Investigar uma oficina ou nicho lateral do molde, sem colocar teto baixo sobre o corredor ou interferir no Monge/Pêndulo. |
| O5 S9 | PARTIAL → PARTIAL; inscrição existente, sem ramo | O mesmo esboço baixo bloqueou salto; uma alcova do registro precisa respeitar os tetos e o CP, com acesso fora da envoltória normal da espinha. |
| O6 S10 | PARTIAL → PARTIAL; inscrição existente, sem ramo | O esboço baixo bloqueou salto; um mirante fora da varredura do Pêndulo deve conservar separação entre travessia e combate. |

As alternativas são direções de design, **não coordenadas fisicamente validadas**. `chapter.gd` limita a posição horizontal de Aren às bordas do setor, e a câmera usa limites calculados pelas superfícies existentes. Um anexo além dessas bordas exigiria uma solução local para acesso, enquadramento e retorno; não se pode simplesmente desenhar uma sala fora da área jogável e chamá-la de percurso. Uma eventual solução deve evitar modificar a espinha ou arquivos protegidos, e deve ser demonstrada com física e ameaças antes de receber PASS. A avaliação feita neste lote não comprova que todas as alternativas arquitetônicas sejam impossíveis; O2–O6 permanecem trabalho não concluído.

## Integridade e Git

Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`. Nenhum sistema ou cena foi alterado neste lote: apenas três scripts de verificação, este relatório e atualização do planejamento. Os 15 arquivos protegidos foram conferidos contra seus hashes; alterações locais anteriores preservadas. A extensão principal histórica de 17.360,42 px não foi medida novamente. Sem staging, commit, push ou deploy; atalhos e M5-F não iniciados.

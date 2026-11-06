# M5-F — planejamento de regressão e homologação final da Abadia

**Estado:** planejamento preparado; execução completa e homologação M5-F não iniciadas. M5-E foi homologado visual e funcionalmente pelo responsável; a aprovação não converte resultados históricos inconclusivos em PASS. Fontes: [roadmap](../ROADMAP.md), [planejamento original do Capítulo 2, seções 21, 22 e 24](PLANEJAMENTO_CAPITULO_02.md), [encerramento M5-E](../tests/ENCERRAMENTO_M5_E.md), relatórios M5-A–E e [encerramento administrativo M5-C3](../tests/ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md).

## Escopo e dependências

O marco M5-F consolida a regressão e a homologação da região da Abadia, não implementa o Abade nem novas funcionalidades. A base compreende 12 setores, sete checkpoints, movimento e combate existentes, inimigos e mecanismos, acabamento M5-D e exploração M5-E. A confirmação da instalação candidata e das dependências é necessária antes da homologação: `project.godot` está protegido, com conteúdo local diferente do HEAD; a versão de teste usou essa configuração local. Qualquer proposta futura de commit deve verificar seu efeito numa cópia adequada, sem alterar o arquivo protegido ou descartar suas diferenças.

O plano original estabelece percurso principal mínimo de 12.227,52 px (aceite arredondado 12.228), incluindo após atalhos, 12 setores, sete checkpoints, seis descobertas, ida e volta física, justiça de ameaças e regressões dos sistemas existentes. A extensão original de 17.360,42 px é referência histórica da espinha, não prova do menor caminho após atalhos. As metas de 3.000 px opcionais, economia até 960 px e duração de 14–22 min são planejamento histórico: medições com métodos diferentes não devem ser somadas ou transformadas em PASS. Se não forem comprovadas ou forem contrariadas, apresentar evidências e pedir decisão explícita de escopo, sem modificar artificialmente o jogo. Exigências do Abade pertencem ao M6 e não ao M5-F.

## Matriz de validação

| Área | Procedimento recomendado | Aceite e evidência |
|---|---|---|
| 12 setores e transições | Jornada real contínua da entrada ao final e volta; repetir limites e entradas relevantes, acompanhando posição, câmera, estados e carregamento. | Ida/volta funcionais, sem bloqueio crítico ou saída involuntária reproduzível; log e amostra visual. |
| Aren e combate | Andar, saltar, aterrissar, atacar e recuperar em terreno plano, vãos e encontros reais; regressões M0/M1/M2 adequadas. | Controles e respostas homologados preservados; relatar qualquer falha reproduzível. |
| Checkpoints | Ativar os sete, morrer com cada um como referência e reaparecer no setor carregado; verificar persistência de identidade e apoio seguro. | Sete funcionam e permitem continuar; queda viva não cura, conforme regra existente. |
| Inimigos e mecanismos | Exercitar tipos distribuídos, detectar, evitar, atacar, sofrer dano e voltar após troca de sala/morte. Separar ensaios individuais de encontros reais. | Ameaças visíveis, evitáveis e puníveis conforme função; sem dano inevitável ou estados travados. |
| Projéteis e colisão | Ensaiar disparos frente a paredes, troca de setor e morte da fonte; distinguir bloqueio de colisão de mera posição. | Sem tiro através de parede, fonte invisível ou projétil ofensivo residual após fronteira nos casos testados. |
| Inscrições | Visitar as seis, ler texto contextual por aproximação legítima e sair. | Textos e pistas corretos e legíveis, sem exigir inventário novo. |
| O1–O6 | Partir da entrada, acessar, ler, retornar e continuar; verificar ameaças e câmera próprias. | Seis acessos e retornos reais, sem softlock observado; evidência e resultado por rota. |
| A1–A3 | Verificar bloqueio anterior, conclusão obrigatória, abertura pelo lado avançado, ambas as travessias e persistência em morte/queda; A3 somente após primeira visita S10. | Nenhum bypass da primeira passagem nos cenários testados; retornos funcionais, sessão preservada. |
| Distância | Definir grafo e método de distância para as rotas com atalhos abertos; medir conexões fisicamente e identificar transições. Não somar ganhos de ensaios independentes. | Comparar menor caminho sustentado com mínimo original; diferenciar medição, inferência e qualquer trecho ainda não comprovado. |
| Renderização/câmera | Capturas e observação com Aren em movimento, HUD e ameaças nas resoluções 1280×720, 1920×1080, 2560×1440 e 3840×2160; usar saída real em cada tamanho. | Pousos e perigos legíveis, câmera acompanha e interface não impede jogo; avaliação humana final. |
| Desempenho | Sessões gráficas sem fixed-fps em situações representativas, incluindo travessia, ameaças, atalhos e retorno; registrar plataforma, resolução, duração, média, p95, picos e, quando disponível, memória. | Fluidez aceitável na experiência real, sem regressão crítica reproduzível. Comparar pico de 183,878 ms sem presumir causa ou impor limiar inventado. |
| Integração/Capítulo 1 | Verificar F6/F7 da Abadia e F5 do Capítulo 1; executar suítes M0/M1/M2, capítulos e sistemas afetados, importação e inicialização na configuração candidata. | Resultados reais, falhas identificadas; não extrapolar headless para imagem ou áudio. |

## Evidência reaproveitável e lacunas

Os relatórios M5-E dos lotes 01–09 documentam trajetórias e homologações; o lote 09 registrou jornada principal em ambos os sentidos, 157/157 na distribuição, sete checkpoints, ensaios O1–O6 e capturas em quatro resoluções. O teste de queda de atalhos foi induzido por posição, não uma queda manual; atalhos foram testados em trechos independentes. As capturas em `tests/evidencias/m5_e_lote09_*.png` e as externas citadas nos lotes são evidências de seus momentos; logs sob `.godot/` são cache local, não garantia de disponibilidade futura. As evidências históricas M0–M4 e M5-D podem contextualizar a regressão, mas não provam o resultado de uma versão posterior modificada.

Novas evidências previstas: jornada integrada com os três atalhos e sessão mantida, morte e queda no contexto real, menor caminho após abertura com método explícito, encontros e projéteis nas fronteiras, inspeção em movimento nas quatro resoluções e benchmark real da versão candidata. A jornada não substitui ensaios específicos dos sete checkpoints e seis ramos. Não reabrir a auditoria histórica de simultaneidade nem a investigação ObjectDB sem novo sintoma relevante.

## Estratégia, critérios e sequência

1. Identificar versão, estado Git e configuração candidata; registrar diferenças locais e checar os 15 hashes sem alterá-los. Decidir como validar a diferença protegida de configuração antes de propor uma versão reproduzível.
2. Mapear suites existentes e executar regressões relevantes em ordem: importação/inicialização, M0/M1/M2 e Capítulo 1, estrutura e sistemas da Abadia, exploração e atalhos. Registrar comando, versão, resultado, saída e limites; não reduzir asserts para manter contagens.
3. Executar jornada contínua de ida/volta com checkpoints, inimigos, perigos, inscrições, opcionais e atalhos; usar fixtures apenas identificadas como tal. Conferir a primeira visita S10 e persistência após morte/queda. Tratar problemas reais reproduzidos, sem mudança de escopo implícita.
4. Medir o grafo e o menor caminho pós-atalhos; relatar se o mínimo original é comprovado. Observar câmera e legibilidade com movimento real nas quatro resoluções e executar benchmark comparável, sem fixed-fps.
5. Consolidar matriz, logs, capturas e limitações; solicitar playtest de integração do responsável. **Homologação M5-F exige decisão expressa do responsável**, depois de revisar a evidência e eventuais pendências.

**Bloqueiam aceite técnico** regressões críticas reproduzidas que impeçam progressão, gerem softlock, dano inevitável, checkpoint inseguro, bypass obrigatório antes da visita, perda indevida de estado, ou quebra relevante de controles/câmera. Uma medição obrigatória inconclusiva fica pendente, sem PASS; divergências de metas históricas requerem decisão fundamentada, não correção artificial. M5-C3 mantém sete encontros registrados com ressalvas e S11 para revisão posterior; ObjectDB é diagnóstico histórico sem causa confirmada; o pico isolado de 183,878 ms de M5-D é observação não bloqueante por si só. Problema novo reproduzido pode ser tratado por seu impacto real.

Nenhuma suíte ou benchmark é declarada executada por este documento. Não iniciar M6, publicação ou deploy nesta preparação.

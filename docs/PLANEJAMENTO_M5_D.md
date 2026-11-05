# M5-D — planejamento técnico de arte e acabamento da Abadia Silenciosa

**Estado: M5-D homologado visual e funcionalmente pelo responsável.** Após a aprovação preliminar das amostras e a continuidade do acabamento, o responsável informou que realizou o playtest, confirmou que está tudo OK e aprovou oficialmente o marco. Os resultados técnicos históricos e a observação de desempenho não bloqueante constam em [VALIDACAO_M5_D.md](../tests/VALIDACAO_M5_D.md).

## Resultado pretendido

Finalizar visualmente os 12 setores da Abadia com identidade arquitetônica coerente, variação por ambiente e leitura clara de chão, teto, entradas, inimigos, armadilhas e avisos. O acabamento deve funcionar com Aren e a HUD reais e com as ameaças integradas. A aprovação visual e funcional pertence ao responsável em playtest. A passagem ao marco seguinte depende dos critérios e da aprovação aplicáveis quando M5-D for executado.

O encerramento administrativo do M5-C3 foi autorizado com ressalvas. Ele permite preparar e avançar o roadmap sem transformar testes inconclusivos em PASS. As pendências dos sete setores e de ObjectDB estão em [ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md](../tests/ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md). No Campanário, identificar e comprovar a combinação avançada continua pendente de revisão posterior e não bloqueia o avanço do roadmap, por decisão do responsável.

## Base existente e dependências

- M5-A e M5-B foram homologados no escopo informado. Seus pilotos e a expansão de 12 setores são a base, com referência de **17.360,42 px** e sete checkpoints. A medição física anterior de 17.360,4052 px pertence ao FIX01 do M5-C3 e foi executada com ameaças isoladas para medir geometria.
- M5-C1 e M5-C2 estão homologados e registrados localmente. M5-C3 está distribuído localmente e encerrado administrativamente com ressalvas, ainda sem commit. A base de trabalho deve ser inventariada e preservada no início da implementação.
- O plano canônico descreve arquitetura gótica, arcos, contrafortes, cisternas, arquivos, sinos e planos de profundidade. A documentação M5-B define M5-D como acabamento, variedade de materiais e motivos, composição por trecho, efeitos e revisão artística. As propostas históricas de quantidade e cronograma não são exigências automaticamente executadas.
- `scripts/abbey/chapter_art.gd` desenha fundos, atlas arquitetônico e decorações por setor. Os setores 2 e 6 usam o fundo do piloto como proprietário único. O código mantém terreno e intrados derivados do layout. A arte dos inimigos e mecanismos existentes reside em seus próprios módulos e recursos de M5-A, M5-C1 e M5-C2.
- O M5-B-FIX01 corrigiu a troca de fundo nos setores 2 e 6, próximo de x=960. O FIX02 estabilizou a alvenaria superior nos setores 4, 5 e 9. Ambos pertencem à base aprovada e devem orientar qualquer alteração visual.
- F6 executa `scenes/abbey/abbey_chapter.tscn`, F7 reinicia a Abadia e F5 mantém o Capítulo 1. O desenho lógico de referência é 320×180, com apresentação 16:9 e filtros adequados às camadas.

## Escopo proposto

1. Inventariar fundos, atlas, elementos, animações e sua proveniência, além de registrar o estado visual atual por setor. Conferir a cena real com Aren, HUD, inimigos e mecanismos visíveis. Marcar o que já foi aprovado e o que depende de revisão humana.
2. Definir uma direção visual coerente para a Abadia, preservando as características de cada ambiente. Organizar uma matriz dos 12 setores com intenção, paleta, profundidade, marcos de orientação, leitura do percurso e pontos de atenção. Priorizar problemas reais visíveis no jogo e evitar refazer trechos aprovados sem justificativa.
3. Propor duas amostras de acabamento, uma exterior e uma interior, com protagonista, HUD e perigo em contexto. Validar enquadramento, contraste, avisos, piso e teto em movimento antes de ampliar o tratamento aos demais setores. A preferência e aprovação artística do responsável devem orientar o restante do acabamento.
4. Aplicar acabamento proporcional à necessidade observada nos 12 setores, incluindo materiais, motivos, composição, profundidade e efeitos que não prejudiquem a leitura. Manter referências e procedência de qualquer recurso criado, além de dimensões, transparência, importação e `.uid` quando cabíveis.
5. Revisar continuidade e limites de câmera em movimento, incluindo os núcleos dos setores 2 e 6 e os tetos dos setores 4, 5 e 9. A arte de fundo e efeitos não devem ocultar telegraphs, hitboxes relevantes, destinos de salto, entradas, saídas ou checkpoints.
6. Preparar relatório por setor, evidências e checklist objetivo para playtest. Avaliar os sete encontros pendentes segundo a função decidida pelo responsável, registrando observações reais. A identificação e comprovação da combinação avançada do setor 11 permanece pendência posterior que não bloqueia o roadmap.

## Limites e preservação

O M5-D é um marco visual. Preservar física e controles de Aren, espada, vida, IA, dano, tempos, colisões, sete checkpoints, geometria, extensão, orientação dos setores, câmera e arquitetura de uma sala residente. Preservar o Capítulo 1 e os recursos homologados dos pilotos, inimigos e armadilhas. Uma falha funcional observada deve ser reproduzida e relatada com impacto e evidência antes de qualquer mudança em sistema homologado.

M5-E mantém exploração, segredos e atalhos completos. M5-F mantém regressão e homologação da região. M6 mantém o segundo chefe. Recursos narrativos, atalhos funcionais, inimigos, armadilhas ou mecânicas novas precisam de escopo e autorização próprios. Não transformar reservas de layout em funcionalidade concluída.

## Sequência técnica de implementação

| Etapa | Entrega verificável | Dependência e condição de avanço |
|---|---|---|
| 1. Baseline e inventário | Branch, HEAD, alterações locais, hashes protegidos, recursos e capturas de referência | Preservar o estado local M5-C3 e os arquivos anteriores |
| 2. Diagnóstico visual | Matriz dos 12 setores e lista de problemas observados, com prioridade e justificativa | Cenas reais, FIX01/FIX02 e ameaças existentes |
| 3. Amostras interior/exterior | Duas propostas integradas em jogo com Aren, HUD e perigos | Avaliação visual do responsável antes de generalizar |
| 4. Acabamento por lotes | Materiais, composição e efeitos aplicados aos setores necessários, com proveniência | Direção visual das amostras aprovada; registrar o que mudou por setor |
| 5. Integração e qualidade | Verificações gráficas, funcionais, regressões e desempenho proporcionais às alterações | Nenhuma regressão crítica comprovada; evidências acessíveis |
| 6. Entrega para playtest | Relatório, checklist por setor e estado do Git | Aprovação humana separada dos resultados automatizados |

As amostras são um ponto de avaliação durante a futura implementação, não uma autorização para modificar arte nesta etapa de planejamento.

## Critérios de aceite propostos

- Os 12 setores apresentam acabamento coerente e identidade própria. Mudanças são rastreáveis e não apagam decisões ou material previamente aprovados sem justificativa.
- Aren, HUD, inimigos, avisos, perigos, plataformas e destinos de salto permanecem reconhecíveis durante movimento e combate. A apresentação não mascara colisões nem sugere um teto como piso.
- As transições dos setores 2 e 6 continuam sem o corte de fundo corrigido, e a alvenaria dos setores 4, 5 e 9 permanece estável durante deslocamento e salto.
- A geometria, entradas e saídas, sete checkpoints, movimentação e navegação bidirecional permanecem funcionais. Medir a extensão pelo método histórico se arquivos capazes de afetar a geometria forem alterados ou surgir divergência; documentar o isolamento de ameaças usado na medição.
- Apresentação inspecionada em 1280×720, 1920×1080, 2560×1440 e 3840×2160, com capturas nativas e avaliação em movimento. O responsável avalia separadamente a experiência na TCL 4K quando disponível.
- Em benchmark comparável na máquina disponível, registrar FPS médio, p95, pior quadro, memória quando disponível, carga e picos de troca. O plano histórico sugere proximidade de 60 FPS em 4K e p95 inicial de até 20 ms, como referências a verificar, não promessa de desempenho. Investigar picos relevantes e relatar qualquer limitação.
- Recursos novos têm origem e licença ou autoria registradas, arquivos necessários de importação e identificadores preservados e nenhuma dependência ausente. Testes inconclusivos e avisos permanecem identificados.
- Relatório técnico, evidências e checklist manual estão completos. Homologação só ocorre após avaliação expressa do responsável.

## Testes planejados

| Área | Verificação proposta | Limite da prova |
|---|---|---|
| Imagem e movimento | Capturas nativas nas quatro resoluções, varredura dos 12 setores e inspeção em movimento com protagonista, HUD e ameaças | Capturas estáticas e automação não substituem playtest humano |
| Continuidade | Reexecutar `tests/abbey_continuity_test.gd` e observar em movimento os fundos dos setores 2 e 6 | Oráculo de pixels cobre faixas específicas, não toda a direção artística |
| Tetos | Reexecutar `tests/abbey_ceiling_stability_test.gd` e observar saltos nos setores 4, 5 e 9 | Complementar com inspeção humana da leitura visual |
| Navegação e integração | Executar suítes de estrutura e capítulo, usando fixture de medição que isole ameaças quando o objetivo for geometria. Executar jornada com ameaças ativas separadamente | Medição estrutural isolada não demonstra justiça dos encontros |
| Combate e perigos | Reexecutar testes M0/M1/M2 e M5-C1/C2 e a distribuição M5-C3 afetados pelas mudanças. Conferir avisos visíveis, dano e retorno em cenas reais | Preservar os relatórios e distinguir resultados históricos de novas execuções |
| Checkpoints e atalhos | Validar sete checkpoints, morte e respawn, F6/F7 e F5 no contexto correto | M5-E continua responsável por atalhos funcionais futuros |
| Desempenho e recursos | Medir 4K com cenas e cargas documentadas, incluindo troca de setor e ameaças visíveis. Comparar com ensaios históricos somente quando comparáveis | Benchmark local não equivale à TCL física nem garante desempenho em outras máquinas |
| Importação e estado | Importar e iniciar no Godot 4.7.2, revisar logs, referências, proveniência e arquivos de versão | Distinguir diagnósticos de ambiente e ressalva ObjectDB de novas falhas |

As suítes exatas e a amplitude final da regressão devem acompanhar os arquivos modificados e quaisquer falhas observadas. Nenhum teste acima foi executado para preparar este plano.

## Entregáveis futuros e pendências

Na implementação, entregar arte e código visual revisáveis, inventário de recursos e proveniência, relatório técnico de M5-D, evidências por setor e resolução, resultados reproduzíveis e checklist manual com PASSOU / FALHOU / NÃO TESTADO. Registrar observações do responsável sem converter testes inconclusivos do M5-C3 em aprovação.

Pendências conhecidas para acompanhamento: os sete agrupamentos listados no encerramento M5-C3, a combinação avançada do Campanário para revisão posterior e a origem inconclusiva dos avisos ObjectDB. A decisão atual permite avançar o roadmap com essas ressalvas. Problemas concretos percebidos pelo jogador devem ser priorizados de acordo com impacto e evidência.

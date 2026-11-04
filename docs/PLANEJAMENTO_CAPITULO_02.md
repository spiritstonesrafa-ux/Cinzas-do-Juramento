> Registro completo do estudo e formalização. A seção24 atualiza a proposta histórica da seção21; M5-A ainda não homologado.

# PLANEJAMENTO DO CAPÍTULO 2 — CINZAS DO JURAMENTO

**04/11/2026 — estudo M5-P, exclusivamente planejamento.** Projeto: `C:\PROJETOS\CINZAS DO JURAMENTO`. Base: branch main, HEAD `bfae340b2480dfc65dfbe1a6bde7deb7ebcae044`, Capítulo 1 homologado e publicado. Toda identidade adicional, quantidade, mecânica nova e estimativa do Capítulo 2 é **proposta, não implementada e não canônica até aprovação**. Os dados observados do Capítulo 1 são separados das metas.

## 1. Resumo executivo

Recomenda-se desenvolver a direção provisória existente no GDD: **Abadia Silenciosa**, região de claustros, campanários e reservatórios votivos; chefe **Abade das Correntes**. Ampliar a região por espaços inéditos em várias cotas, sem transformar o jogo em metroidvania ou pressupor habilidades novas.

A rota de referência medida do Capítulo 1 tem **3.056,88 px**. O mínimo 4× é **12.227,52 px**; adotar **12.228 px** como piso de aceite. Proposta: **14.400 px principais, 12 setores, 3.000 px opcionais, 30 zonas de encontro, 40 inimigos não chefes, quatro arquétipos novos, 12 dispositivos ambientais e sete checkpoints ativáveis além do início seguro**. Primeira exploração humana: alvo modelado **14–22 minutos**, ainda não medido.

O segundo chefe deve começar o protótipo com HP 10 e dano 1, assim como o Guardião. Maior dificuldade virá de seis famílias de ataques, combinações em duas fases e punição estratégica, sem alterar Aren ou rebalancear o primeiro chefe. Há conflito entre a numeração sugerida no pedido e os marcos macro M5/M6 existentes; uma organização compatível é proposta na seção 21, sem editar o ROADMAP.

## 2. Análise do Capítulo 1

Dados reais: seis setores em cena contínua, 16 superfícies de percurso, um teto e duas paredes = **19 sólidos**. Aren: velocidade 100 px/s, aceleração 1200 px/s², gravidade 680 px/s², impulso−230 px/s, corpo 12 × 24. Espada horizontal terrestre; não pressupor ataque aéreo, dash, escalada, agarrar borda ou salto duplo.

Portões → Lápides → Jardim → Catacumbas → Ponte → Catedral → arena. Existem seis inimigos em cinco zonas de proximidade, três perigos e dois checkpoints. Inimigos de percurso podem ser evitados; só a derrota do Guardião condiciona a conclusão. Não chamar seis instâncias de seis mortes obrigatórias.

Não foram identificadas salas opcionais autorais, atalhos ou recompensas secretas implementadas. Retornar pela mesma rota após vencer não acrescenta extensão exclusiva. Arena carregada sob demanda é conectada por teleporte: o espaço entre cenas não é deslocamento jogável.

As causas da brevidade são percurso pequeno, poucos encontros e ausência de ramificações. A expansão precisa de conteúdo novo, não corredores vazios nem repetição. O Guardião é introdutório por decisão homologada e permanece intacto.

## 3. Medidas reais, fontes e limitações

Unidade: pixel lógico do mundo, não pixel físico de uma tela 4K. Extração da cena versionada, controlador e suíte de alcançabilidade; dados completos em `metrics.json`.

| Medida geométrica | Dado real |
|---|---|
| Paredes | X=0–2368; centro físico aproximadamente 6–2362 |
| Spawn / selo | (48,156) / centro do selo(2344,138), piso 156 |
| Projeção horizontal spawn→selo | 2296 px |
| Pisos de percurso | Y=116–220: amplitude 104 px |
| Variação acumulada de altura entre superfícies | 256 px, sem arcos de salto |
| Vãos | 32/32/32/32/40/40 px: seis, total 208 px |
| Transições adjacentes de altura | nove; subida necessária máxima 24 px |
| Teto da cripta | X1248–1408, Y64–120; não é destino de percurso |

Não confundir a altura de 244 da câmera ou profundidade dos sólidos com exploração vertical. Os seis setores têm faixas X0–384,384–768,768–1152,1152–1536,1536–1984,1984–2368.

| Superfície | Faixa X | Piso Y |
|---|---|---:|
| GateFloor | 0–448 | 156 |
| GraveSlabA | 480–544 | 144 |
| GraveSlabB | 576–640 | 156 |
| GraveSlabC | 672–848 | 140 |
| GardenRise | 848–912 | 116 |
| GardenDescent | 912–976 | 140 |
| GardenRest | 976–1152 | 156 |
| CryptEntryUpper | 1152–1200 | 180 |
| CryptEntryLower | 1200–1248 | 204 |
| CryptFloor | 1248–1408 | 220 |
| CryptExitLower | 1408–1456 | 196 |
| CryptExitUpper | 1456–1504 | 172 |
| BridgeApproach | 1504–1600 | 156 |
| BridgeSpanA | 1632–1712 | 148 |
| BridgeSpanB | 1752–1848 | 144 |
| CathedralFloor | 1888–2368 | 156 |

### Medição física nova da rota

Executada apenas na cópia isolada do HEAD criada pela auditoria anterior. Godot 4.7.2 oficial, headless, física original, `--fixed-fps 60`, navegação por Input API e sondas de borda. Inimigos/mecanismos tiveram processamento desativado e a consulta de contato da hurtbox foi desligada **somente na cópia**, para isolar comprimento; não é teste de combate ou playtest humano. Script auxiliar em `.godot` isolada, sem editar cenas/scripts do jogo. Evidências: `measure_route.gd`, `route.json`, `measurement-console.txt` e `measurement-final.log` nesta pasta.

Somou-se distância euclidiana entre posições sucessivas dos pés até antes do teleporte, excluindo esse frame. Completou-se o pequeno trecho até o centro do selo; acrescentou-se aproximação geométrica de engajamento na arena X48→206, sem dança de combate.

| Parcela | Valor |
|---|---:|
| Trajetória física spawn→última posição pré-portal | 2882,787450 px |
| Última posição | (2327,907;155,9253) |
| Complemento horizontal até centro do selo | 16,092529 px |
| Aproximação geométrica na arena | 158 px |
| **Rota de referência total** | **3056,879979 px** |
| Navegação até ativar portal | 1405 ticks =23,4167 s de simulação |

É uma rota reproduzível pela topologia real, com cripta e ponte; **não** prova do caminho matematicamente mais curto, média humana ou duração do capítulo. O navegador pode saltar em descidas caminháveis. A aproximação de 158 px não foi simulada como duelo; complemento final é explicitamente extrapolado. Não repetir saltos gratuitos no Capítulo 2 para inflar a métrica. A primeira sondagem desligava processamento, o que não garante remover colisões de perigos estáticos. Por isso uma segunda execução desligou também a consulta de contato; terminou com 5 HP, sem retorno/teleporte intermediário, e reproduziu exatamente a mesma extensão e os mesmos 1405 ticks. Os dois resultados foram preservados. Nenhum benchmark gráfico ou regressão completa foi repetido nesta etapa. A sondagem concluiu exit 0 e preserva o diagnóstico conhecido de certstore.

### Checkpoints e ameaças

CP1 atual **(1176,180)**, não o marcador histórico(1040,156); CP2 **(1936,156)**. Distâncias horizontais: spawn→CP1=1128 px; CP1→CP2=760 px; CP2→selo=408 px. Não são comprimentos com saltos.

Esqueletos em(744,140),(1328,220),(2120,156); corvos em(1050,112),(1552,112),(2188,112). Pelo critério declarado de agrupar as duas instâncias finais próximas, separadas 68 px em X, há **cinco zonas potenciais**. Sem essa agregação, são seis posições de ameaça, não seis combates obrigatórios.

GardenSpikes(824,140), CryptBlade(1384,176), CathedralTimed(2016,156): três dispositivos de três comportamentos. Seis vãos e nove transições de altura são categorias diferentes; não somar como salas distintas.

Salto anteriormente observado em física:40,83–40,91 px; alcance nivelado 70 px correndo ou 66,67 px parado. Fontes: docs/M3_A.md e VALIDACAO_M3_A_FIX01.md. Não reexecutado nesta etapa; 70 px não é orçamento seguro de vão elevado.

## 4. Cálculo 4× e contagem futura

`L2 mínimo = 4× 3056,879979 = 12227,519916 px`. Arredondar para cima: **12228 px**. Meta 14400 px = **4,7107 ×**, reserva 2172,48 px. Doze setores não provam extensão; a soma das rotas deverá prová-la.

Criar futuramente grafo com entradas, saídas, alturas, sentidos e comprimento de cada aresta; publicar traço físico e planta. Rota contínua de primeira progressão, sem somar volta pela mesma aresta, teleporte, mortes, dança de combate, idas buscar nada ou saltos desnecessários. A linha central geométrica relevante também deve atingir o mínimo, para não depender da odometria de saltos. O traço do Capítulo 1 é referência conservadora, não certificação de menor caminho.

Os comprimentos da proposta são **orçamentos**, ainda não construídos. Se a rota física ou sua linha central ficarem abaixo de 12228, o marco falha. Opcionais, área retangular e número de arquivos não compensam.

Três atalhos podem poupar no máximo 960 px combinados:14400−960=**13440 px**, ainda 4,3966 ×. Recalcular o menor caminho no grafo depois de todos abertos; não somar economias isoladas sem verificar combinações. Os 3000 px opcionais são arestas exclusivas e não financiam o requisito 4×.

## 5. Continuidade da história e cânone

Lidos README, ROADMAP, GDD v0.1, ARQUITETURA v0.1, docs/M3_A.md e homologações M3/M4 (inventário em sources.json). Não foi encontrado documento separado de biografia ou segundo chefe detalhado em docs; não pressupor material inexistente.

**Estabelecido:** Aren é cavaleiro amaldiçoado; quebrou um juramento sagrado tentando salvar o reino, tem memória fragmentada e busca a causa da maldição e a fortaleza central. O GDD menciona mal ancestral, mas identidade e origem completas permanecem abertas. Juramentos sustentam a condenação narrativa; sua metafísica não está totalmente explicada. A Catedral encerra o Cemitério e abriga o encontro com o Guardião. A vitória rompe **um elo**, deixa armadura vazia e anuncia que a jornada continua. Não concede item, poder ou acesso funcional a uma nova região.

**Direção provisória existente:** Abadia Silenciosa / Abade das Correntes no GDD. O ROADMAP não os fixa como cânone definitivo. Portanto desenvolver essa direção é coerente, mas os detalhes abaixo precisam de aprovação. Os antigos nomes da fase 1 no GDD foram superados pelo Cemitério/Guardião implementados, não devem voltar.

**Proposta:** marcas na Catedral apontam para a abadia onde eram registrados os votos. Aren segue passagens de manutenção e aquedutos procurando testemunho de seu próprio juramento. Correntes ainda tensionam sinos que ninguém ousa tocar. O Abade conserva os votos em vez de apenas guardar tesouro; sua culpa e relação com Aren são hipóteses narrativas para aprovação.

Manter em aberto: autor do mal, texto completo do voto, verdade sobre o salvamento do reino, identidade do regente e desfecho. O capítulo pode revelar ligação entre registro e aprisionamento, sem resolver tudo. Final proposto: ruptura de segundo vínculo e indício de continuidade, sem implementar Capítulo 3, habilidade ou inventário.

## 6. Região recomendada

**Abadia Silenciosa:** claustros, campanários, arquivos e cisternas votivas. Respeita o GDD, dá continuidade à Catedral e contrasta com túmulos/árvores. Não apresentar três alternativas concorrentes quando já existe essa direção editorial provisória.

Tema: promessas preservadas além da morte. Três movimentos ambientais: periferia com peregrinos petrificados; oficinas/arquivo votivo; campanário onde convergem as correntes. História por objetos e inscrições breves, sem longos diálogos obrigatórios.

Subterrâneos são apenas uma parte. Alternar pátios abertos, galerias em altura, passarelas externas e salões de maquinaria. A descoberta vem de mudar a leitura de um marco espacial, não de repetir Catacumbas por quatro vezes. Não produzir arte nesta etapa.

## 7. Identidade visual

Paleta: ardósia azul-acinzentada e índigo, calcário frio, bronze oxidado/verde mineral, vinho dessaturado e âmbar em sinais. Perigo nunca comunicado apenas por cor: usar pose, silhueta, direção e pulsação.

Arquitetura: arcobotantes assimétricos, arcadas, contrafortes fendidos, arquivo vertical, contrapesos, tubulações de incenso e sinos rachados. Marco orientador: torre com três campanas vista de diferentes cotas. Fundos em planos próximos/médios/distantes, separados da colisão. Não desenhar um teto como plataforma pousável.

Iluminação por massas pintadas e poucos efeitos localizados, sem pressupor inúmeras luzes dinâmicas. Água decorativa/rasa, sem física de natação. Animações ambientais: panos, gotejos, fumaça contida, correntes e sombras de sinos. Não cobrir avisos de ataque com VFX.

Transições revelam o próximo espaço antes de mover a câmera. Preservar escala de Aren/HUD e DISPLAY01:320 × 180 lógico, canvas_items, keep/integer, fundos Linear e atores/HUD Nearest, proporção 16:9. Renderização nativa 4K nas validações, não ampliação posterior. Áudio pode entrar em marco próprio; toda ação deve ser legível sem som.

## 8. Mapa conceitual textual

```text
Catedral concluída [conexão futura a aprovar]
 → S1 Átrio → S2 Claustro
                ↑ S3 Escadaria
                ← S4 Dormitório [nova galeria, não retorno pelo mesmo piso]
                ↓ S5 Cisternas → S6 Turíbulos
                                  ↓ S7 Fundição → S8 Ponte
                                                   ↑ S9 Arquivo
                                                   ← S10 Jardim Suspenso
                                                     ↑ S11 Campanário
                                                     → S12 Coro → Abade

Opcionais: O1/S2, O2/S3, O3/S5, O4/S7, O5/S9, O6/S10.
Atalhos: S4↔S3, S8↔S7, S11↔S9; abertos pelo lado avançado.
Economia conjunta máxima de percurso:960 px.
```

Setas representam conectividade editorial, não coordenadas finais. Trechos em direção oeste ocupam galerias novas em outra cota. A espinha não depende de chave, inventário, elevador, dash ou habilidade futura. Ligações desbloqueadas precisam funcionar nos dois sentidos, sem portão fechando sobre Aren.

## 9. Setores propostos

Comprimentos são metas de rota, não larguras retangulares. Caixas locais são envelopes indicativos para autoria, não prova de dimensão ou quedas permitidas. Alturas de 540 px exigem vários patamares com Aren original. Geometria/coordenadas absolutas serão desenhadas no marco autorizado, não estão prontas.

| S / nome | Rota / acumulado px | Caixa indicativa | Entrada→saída | Função e ritmo | Plataformas / desafios / ameaças | Visual, segredos e checkpoint |
|---|---|---|---|---|---|---|
| 1 Átrio dos Votos | 900 /900 | 800 × 180 | Catedral→claustro L→R | descoberta; recepção dos votos | piso amplo, degraus 16; 0 encontros/0 inimigos | portal partido, primeiro sino; início seguro |
| 2 Claustro Fraturado | 1100 /2000 | 800 × 360 | átrio→base da escadaria | pressão nova moderada | vãos 24–32; 2 encontros/2 inimigos; Monge sozinho primeiro | pátio e arcadas; O1; CP1 ao final |
| 3 Escadaria dos Contrapesos | 1250 /3250 | 960 × 540 | base baixa→galeria alta | verticalidade | degraus 20–24; 3 encontros/4 inimigos; contrapeso isolado | correntes marcadas; O2; CP2 ao final |
| 4 Dormitório das Vigílias | 1150 /4400 | 960 × 360 | leste alto→oeste inferior novo | pausa narrativa e alcance | alcovas/cobertura; 2 encontros/3 inimigos; Acólito | celas abertas e mantos; atalho ao S3 |
| 5 Cisternas Votivas | 1350 /5750 | 1120 × 540 | galeria→reservatório→canal | descida e posicionamento | água rasa decorativa, recuperação sob quedas; 4 encontros/5 inimigos | reflexos pintados e selos minerais; O3; CP3 |
| 6 Galeria dos Turíbulos | 1200 /6950 | 800 × 540 | canal baixo→oficinas | ritmo e contemplação entre ciclos | válvulas com abrigos; 3 encontros/4 inimigos | turíbulos e fumaça baixa; sem novo ramo |
| 7 Fundição dos Sinos | 1400 /8350 | 1120 × 360 | oficina→travessa | clímax intermediário | duas alas, descanso entre pares; 4 encontros/6 inimigos; Vigia isolado primeiro | moldes/bronze/campanas; O4; CP4 |
| 8 Ponte dos Penitentes | 1150 /9500 | 960 × 540 | travessa→galeria oposta | mobilidade | vãos≤36 e patamares largos; 3 encontros/4 inimigos; Penitente | pontes em cotas distintas; atalho ao S7 |
| 9 Arquivo dos Juramentos | 1300 /10800 | 1120 × 360 | galeria→arquivo alto | exploração e espaço | cobertura alternada; 3 encontros/4 inimigos | selos e roseta; O5; CP5 |
| 10 Jardim Suspenso | 1100 /11900 | 960 × 360 | arquivo→contraforte oeste | alívio visual | travessia e combate separados; 3 encontros/4 inimigos | vegetação desbotada/aqueduto; O6/mirante |
| 11 Campanário Exterior | 1200 /13100 | 960 × 540 | contraforte→ante-coro | tensão final com regras conhecidas | combinações ensinadas; 2 encontros/3 inimigos | cabos grossos/sombra do sino; CP6; atalho ao arquivo |
| 12 Coro das Correntes | 1300 /14400 | 960 × 360 | ante-coro→arena | preparação e confronto | 1 encontro/1 inimigo no início; últimos 200 px seguros | correntes convergentes; CP7 em s=14200 |

Total: **14400 px, 30 zonas, 40 inimigos de percurso**. Arena/aproximação incluídas no orçamento de S12; combate não acrescenta extensão. Ajustar distribuição por leitura, não por quota rígida. Amplitude global preliminar de pisos **720 px**, em salas/cotas distintas, sem câmera mostrando toda essa altura simultaneamente. Checkpoints de referência para os setores sem ponto próprio: S1 usa início/CP1; S4 fica entre CP2 e CP3; S6 entre CP3 e CP4; S8 entre CP4 e CP5; S10 entre CP5 e CP6. Os demais têm seu ponto indicado na tabela; S12 tem CP6 na entrada e CP7 antes do chefe.

## 10. Percurso principal e navegabilidade

Sem retorno obrigatório ou chaves: setores verticais usam patamares alternados e galerias inéditas. Margens propostas: degraus 16–24 px, vãos iniciais 24–32 e posteriores 36–40 somente com teste físico confortável. Não combinar automaticamente vão máximo e subida máxima. Os 70 px medidos no mesmo nível não são folga de design.

Destinos visíveis antes de saltar, incluindo corpo e pelo menos 8 px abaixo da borda. Teto/ornamento tem linguagem distinta de piso. Sem zoom para esconder erro geométrico. Considerar corpo, arco do salto e arte na folga superior.

Cada ligação necessária: quatro aproximações 8/12/16/20 px, nos dois sentidos, Input API com corpo original e apoio integral no pouso. Incluir partida parada e aceleração real. Esses ensaios locais não substituem travessia contínua sem resets. Patamar de combate inicial indicativo≥96 px, validado com espada e saída segura; nenhuma ameaça inevitável no aterrissar.

Priorizar pisos de recuperação **visíveis** sob travessias arriscadas, com escadas curtas de retorno. Sem teleporte ou dano de queda novo. A queda viva atual retorna ao início sem curar mesmo com checkpoint: não alterar esse contrato silenciosamente. Abismos na espinha longa devem ser evitados para não forçar repetir minutos. O limiteY288 do Cemitério não serve para a região em várias cotas; definir bounds próprios na região mantendo a semântica de retorno. Nunca alterar gravidade, velocidade ou salto de Aren para corrigir cenário.

## 11. Percursos opcionais e atalhos

| Ramo | Origem | Extensão exclusiva alvo | Conteúdo/recompensa compatível | Retorno |
|---|---|---:|---|---|
| O1 Capela dos Nomes Riscados | S2 | 360 px | relevo e vista do pátio | loop ao claustro |
| O2 Câmara do Contrapeso Partido | S3 | 480 px | ritmo e sinal de sabotagem antiga | serviço até patamar conhecido |
| O3 Ossuário Submerso | S5 | 560 px | corredor raso, inscrição de votos | subida legível |
| O4 Molde do Sino Mudo | S7 | 420 px | encontro opcional e monumento | saída distinta |
| O5 Registro sem Assinatura | S9 | 620 px | sala de selos e pista parcial | galeria sobre o arquivo |
| O6 Mirante da Abadia | S10 | 560 px | vista do caminho e travessia sem pressão | reconexão à espinha |

Total **3000 px novos**, uma vez por aresta exclusiva. Em ramo só de ida/volta, não dobrar a extensão. Não somar trechos comuns. Nenhum ramo é necessário para terminar.

Atalhos propostos abrem por trava de serviço vista pelo lado avançado, sem inventário de chaves. Servem às tentativas e retorno, não a eliminar setores inéditos antes de apresentados. Novo mecanismo de trava é escopo futuro explícito, não sistema já existente. Economia combinada≤960 px, conferida pelo menor caminho após desbloqueio.

## 12. Inimigos propostos

Quatro novos arquétipos; nenhum criado agora. Reusar SwordReceiver/DamageSource e contratos M1/M2 em adaptadores próprios, sem mudar golpe/dano de Aren. HP/dano e tempos são sementes de protótipo, não balanceamento homologado.

| Inimigo | Aparência/papel | Movimento, ataque e aviso | Vulnerabilidade/plataformas | Distribuição/dificuldade |
|---|---|---|---|---|
| Monge Acorrentado | hábito vinho, braços presos; pressão terrestre | patrulha limitada, golpe frontal; ombro recua/corrente tensiona por~0,55 s; direção comprometida | recuar/saltar e punir no chão; HP3/dano 1; frear em bordas e respeitar patrulha | apresentar sozinho S2; S3–S11 contextual; baixo→médio |
| Acólito do Turíbulo | máscara de bronze/incensário; alcance | passos curtos, um projétil baixo de arco curto; aviso~0,75 s; depois aproxima e recupera | cobertura bloqueia tiro; HP2/dano 1; sempre alcançável por espada terrestre; não atirar fora de tela | apresentar S4; S6/S9/S11; médio |
| Penitente das Arcadas | figura magra, joelheiras/corrente leve; mobilidade | salto curto comprometido; agacha~0,65 s e marca pouso | pousa/recupera≥0,65 s no chão; HP2/dano 1; validar destino antes de saltar, sem perseguir por abismo | apresentar S8 em piso amplo; S9/S10; médio→alto |
| Vigia do Sino | armadura bronze/sino fissurado; resistência e espaço | lento, guarda frontal desenhada, golpe baixo circular, giro limitado | recuperação/flanco acessíveis; HP3–4/dano 1; nunca bloquear corredor sem recuo; sem exigir ataque aéreo | apresentar S7 isolado; S9/S11 e início S12; médio→alto |

Reusar esqueleto como ameaça simples S2/S4/S10 e corvo nos exteriores S3/S8/S10, preservando mergulho visível e recuperação terrestre. Reuso de código não cria um tipo novo; novos tipos exigem comportamento e identidade próprios.

Distribuição quantitativa inicial:12 Monges,8 Acólitos,6 Penitentes,6 Vigias,5 esqueletos,3 corvos =**40 instâncias**. São seis tipos não chefes, quatro novos, em 30 zonas. Maioria solos/duplas; no máximo duas fontes ofensivas comprometidas simultaneamente no campo de visão. Começar com layout/cooldown locais, sem framework de horda desnecessário.

Não combinar tiro+mergulho+armadilha no salto obrigatório. Projétil colide com cenário e expira; guarda não exige atravessar dano. Morte/queda restaura IA e fontes. Verificar perda de alvo, fronteira de sala e descarga durante investida. Alongar luta por mais HP não é solução para duração; exigir posicionamento e recuperação legíveis.

## 13. Armadilhas e obstáculos

**12 dispositivos: dois de cada família**, quatro novas e duas reutilizadas. Distribuição proposta: S3 dois contrapesos; S5 duas comportas; S6 dois jatos; S7 uma lâmina/uma prensa; S8 uma lâmina; S9 uma prensa; S11 dois temporizados. S12 sem novo perigo entre checkpoint e chefe.

| Família | Sinal e resposta | Limite de justiça |
|---|---|---|
| Contrapeso pendular — novo | sombra/corrente antecipa massa; cruzar depois ou recuar | nicho permanente; não ocupar pouso obrigatório |
| Comporta votiva — nova | trava recua e faixa de fechamento aparece | bolsões nos dois lados; dano M2, não morte instantânea; saída possível |
| Jato de incenso abrasivo — novo | válvula âmbar/fumaça preliminar, pulso contido | abrigo entre válvulas; fumaça não oculta aviso |
| Prensa de moldes frios — nova | sobe, trava visível e só então desce | trilho curto, recuperação longa; nunca no respawn |
| Lâmina oscilante — existente | linguagem já conhecida em contexto novo | reusar classe sem modificar parâmetros globais |
| Perigo temporizado — existente | seguro/aviso/ativo explícitos | não depender apenas de cor |

Semente: aviso≥0,6 s e janela segura para atravessar largura real a100 px/s com folga do corpo. Calcular por dispositivo; não impor período igual a todas as salas. Ensinar isolado, combinar depois com ameaça conhecida e patamar amplo. Restaurar ciclos seguros em morte/queda conforme M3-C.

Além de dispositivos,24–32 sequências de navegação autorais planejadas: escadas, ligações inferiores, travessas e retornos curtos. Não equivalem a copiar 32 vãos. Elevadores/plataformas móveis obrigatórios ficam excluídos: seriam sistemas adicionais sujeitos a aprovação. Nenhuma nova habilidade é premissa.

## 14. Checkpoints e ritmo

Oito pontos seguros contando início; sete ativáveis. **s é extensão acumulada, não coordenada X.**

| Ponto | s | Intervalo anterior | Local |
|---|---:|---:|---|
| Início | 0 | — | Átrio |
| CP1 | 2000 | 2000 | final S2 |
| CP2 | 3250 | 1250 | final S3 |
| CP3 | 5750 | 2500 | saída S5 |
| CP4 | 8350 | 2600 | final S7 |
| CP5 | 10800 | 2450 | saída S9 |
| CP6 | 13100 | 2300 | chegada ao ante-coro |
| CP7 | 14200 | 1100 | preparação do Abade; faltam 200 px |

Intervalos 1250–2600 px entre início/ativáveis. Ajustar por dificuldade e tempo observado de tentativa, visando aproximadamente 75–150 s de repetição útil nos trechos desafiadores; trecho curto não precisa ser artificialmente alongado. CP7→controle da arena≤10 s sem combater, incluindo carregamento no equipamento de referência.

Respawn em piso largo sustentado, sem inimigo em alcance, projétil em voo ou ciclo já atingindo Aren. Testar esperar cinco segundos e sair nas duas direções. Preservar vida 5, invulnerabilidade 0,8 s e morte 0,6 s; não usar invulnerabilidade como substituto de área segura.

Morte usa checkpoint; queda viva retorna ao início sem cura. Reduzir punição por pisos recuperáveis/atalhos, não por mudança silenciosa do contrato. Sem save global: fechar aplicativo perde estado da sessão. Essa limitação fica explícita para um capítulo maior; persistência em disco é marco separado, não requisito oculto.

## 15. Segredos e recompensas

O1–O6 têm pistas perceptíveis: corrente cortada, fluxo de ar, marca de bronze, alvenaria interrompida ou luz atrás de arco. Sem parede aleatória invisível ou salto no vazio para procurar segredo.

Recompensas compatíveis: vista inédita, inscrição breve no cenário, informação parcial e atalho. Objetos narrativos não pressupõem tela de coleta. Nada aumenta HP, dano ou salto. Colecionável, diário persistente, equipamento ou habilidade são **ideias opcionais**, dependentes de sistema e aprovação específicos, fora do plano básico. Descobrir tudo não condiciona a vitória ou compreensão da instrução essencial.

## 16. Progressão, comparação quantitativa e duração

S1 orienta; S2 ensina pressão; S3 testa verticalidade; S4 respira e introduz alcance; S5 exige posicionamento; S6 alterna ritmo; S7 é clímax intermediário; S8 apresenta mobilidade; S9 concentra descoberta; S10 oferece alívio; S11 combina regras; S12 prepara o chefe.

Densidade de zonas:5/3056,88 × 1000=**1,64 por 1000 px** no Capítulo 1;30/14400 × 1000=**2,08** no planejado, cerca de 27% a mais. Aumento moderado somado a variedade/extensão; não multiplicar simultaneamente dano, inimigos e perigos por quatro. Médias não obrigam cada sala a ser igualmente densa.

| Métrica | Capítulo 1 — real/classificado | Capítulo 2 — meta, não construído |
|---|---|---|
| Extensão principal de referência | 3056,88 px, método seção 3 | 14400 px; mínimo 12228 |
| Após atalhos | sem atalhos autorais | ≥13440 px sob orçamento proposto |
| Rotas opcionais exclusivas | 0 ramos/salas autorais identificados | 3000 px /6 ramos |
| Setores | 6 | 12 |
| Amplitude dos pisos | 104 px | cerca 720 px em múltiplas cotas |
| Tipos não chefes | 2 | 6, quatro novos |
| Instâncias não chefes | 6 | 40 |
| Zonas potenciais de encontro | 5 pelo critério declarado | 30 |
| Mortes obrigatórias | chefe para concluir | chefe; sem quotas de mortes nos portões comuns |
| Dispositivos | 3 de 3 famílias | 12 de 6 famílias, quatro novas |
| Navegação | 6 vãos /9 transições adjacentes | 24–32 sequências distintas a projetar |
| Checkpoints ativáveis | 2 (+início) | 7 (+início) |
| Segredos autorais/recompensas | 0 identificados | 6 descobertas sem inventário |
| Chefe | 2 fases/4 padrões/HP 10/dano 1 | 2 fases/6 famílias e combinações; começar HP 10/dano 1 |
| Dificuldade | introdutória homologada | progressiva, ainda não validada |
| Duração humana | não cronometrada; modelo 2–5 min | alvo 14–22 min, a comprovar |

### Dados de tempo versus hipóteses

**Observado:** navegação automática 23,42 s de simulação até o selo, ameaças desativadas; não inclui tempo da aproximação geométrica na arena. **Histórico:** duelo automático do Guardião 28,15 s em M4-B/C. Não são duração humana da fase.

Modelo do Capítulo 1, **estimativa sem mortes repetidas**: deslocamento 23–40 s + cinco zonas 5–12 s cada(25–60 s) + leitura dos perigos 12–24 s líquidos + orientação/contemplação25–70 s + chefe 35–90 s =**120–284 s**, aproximadamente**2–5 min**. Tempos por combate/perigo são hipóteses, não logs; o jogador não é obrigado a matar todos.

Modelo do Capítulo 2: deslocamento 110–180 s;30 zonas× 10–18 s=300–540 s; dispositivos 50–90 s líquidos; orientação principal 80–140 s; chefe 75–140 s =**615–1090 s**, cerca**10–18 min** na espinha. Ramos selecionados acrescentam 120–240 s líquidos, produzindo faixa ampla 12–22 min. **Alvo editorial 14–22 min na primeira exploração**, não promessa para veterano/speedrunner e não duração obtida esperando ciclos longos.

A referência de odometria inclui componente vertical (~130,5 px/s ao longo do traço); não dividir cegamente 14400 pela velocidade horizontal 100. Tempo de combate/observação é adicional somente quando não sobreposto ao deslocamento. Nenhuma estimativa equivale a observação humana. Mortes não contam como conteúdo.

Validar com pelo menos um jogador familiar e dois novos se disponíveis; registrar experiência e separar rota, opcional, observação, combate, chefe e retries. Se lutas forem muito mais rápidas, rever a duração real ou adicionar conteúdo autoral aprovado; não inflar HP nem corredores.

## 17. Segundo chefe — Abade das Correntes

Identidade nominal provisória herdada do GDD; detalhamento a aprovar. Antigo guardião dos registros, figura alta/curvada, vestes escuras, aro votivo às costas e duas correntes com pesos de bronze. Não copiar a armadura/espada do Guardião. Sua responsabilidade moral continua em aberto.

Arena proposta 640 × 240 lógico, piso principal contínuo e bordas seguras. Enquadramento em até duas telas, câmera limitada sem zoom nos ataques. Nenhuma ação começa fora do quadro. Se o enquadramento ocultar origem/destino, reduzir largura ativa a480 ou sala única antes de aprovar arte. Não exigir plataforma elevada para causar dano; nenhuma habilidade nova.

| Família | Aviso inicial proposto | Resposta | Punição/limite |
|---|---|---|---|
| Peso de penitência | braço erguido/marca de chão por 0,80 s | sair da marca e voltar | peso preso~0,80 s; alvo fixado antes do impacto |
| Varredura de corrente | corrente baixa tensiona por 0,75 s | salto simples ou recuo | recuperação~0,70 s no chão; alcance não cobre arena inteira |
| Gancho comprometido | linha horizontal e inclinação por 0,90 s | ficar fora do eixo e aproximar na volta | sem mecânica nova de puxar Aren; retorno inicialmente não ofensivo |
| Passo do carrilhão | dois passos visíveis/peso alto por 0,85 s | preservar saída e ler lado | giro/perseguição limitados, sem rastrear a cada frame |
| Dois votos | primeira ação conhecida + segunda pose distinta | duas esquivas em ordem explícita | intervalo permite reposicionar; nunca rastrear pouso inevitável |
| Ressonância do sino | aro abre/dois pulsos de chão alternados por 1,00 s | ocupar faixa segura e aproximar | fase 2; sem onda de tela inteira nem armadilha concorrente invisível |

Fase 1(100–50%): ensinar três famílias básicas e Passo, evitar repetição imediata. Fase 2: transição reconhecível sem dano, remove fontes ativas; introduz Dois votos/Ressonância e combinações com cooldown/distância. Só combinar ações ensinadas e limitar a duas por sequência no primeiro protótipo. Não apenas acelerar toda a fase 1.

Postura aberta sinaliza recuperação, com janelas iniciais 0,55–0,85 s, suficientes para M1 de quem se posicionou. Prototipar HP 10/dano 1 antes de elevar qualquer valor. A dificuldade superior deve vir de reconhecer sequência, escolher lado e planejar punição, em vez de saltar/repetirJ invariavelmente. Não usar imunidade longa e sem explicação para alongar luta.

Animações necessárias: idle/marcha, quatro antecipações e ataques básicos, recuperação/peso preso, sequência dupla, ressonância, dano, transição e derrota. Conceito de vestes/armadura vazia na derrota depende da identidade aprovada. VFX localizados: corrente tensa, marca no chão, poeira, pulso votivo. Ornamentação não dá dano; atlas/âncoras aprovados antes de recorte final.

Demonstrar resposta sem dano para cada família e par permitido, usando Aren original. Origem/alvo em quadro, tempo de reação mais deslocamento fisicamente possível, nenhuma combinação fechando todas as saídas. Desarmar imediatamente em morte, saída, transformação e vitória simultânea.

Homologação humana: jogador reconhece aviso, entende erro e encontra janela sem dano obrigatório. Comparar decisões, aprendizagem e tentativas com o Guardião no mesmo participante; não exigir mortes para provar dificuldade. Veterano pode vencer de primeira. Riscos: câmera larga, cadeia inevitável, janela insuficiente para M1, guarda confusa e VFX excessivo. Prototipar física/câmera antes da arte definitiva.

## 18. Inventário de assets proposto

Nenhum asset produzido/substituído nesta etapa.

| Categoria | Produção original prevista | Reuso/condições |
|---|---|---|
| Fundos | 6 conjuntos temáticos× 2 variações=12 composições;2–3 planos onde úteis | pipeline M3-D, sem repetir PNG inteiro em corredores consecutivos |
| Terreno | 4 famílias: calcário, ardósia, bronze, alvenaria úmida; bordas/cantos/fissuras | GroundSkin como referência; cache por sala |
| Estruturas | 8 assinaturas: portal, torre, contrapeso, cisterna, turíbulo, molde, arquivo, coro | colisão independente, escala consistente |
| Decorações | ~24 motivos combináveis, selos/inscrições | reusar props M3 só quando material/época fizer sentido |
| Objetos animados | 6 famílias: corrente, pano, válvula, gota, incenso, campana | atualização local, não distante |
| Inimigos | 4 conjuntos novos com locomoção, aviso, ataque, dano, recuperação, morte | dois existentes intactos; collider não cresce com capa |
| Abade | conjunto de combate 6 famílias, transição e derrota separados | folha de escala/poses antes do atlas definitivo |
| VFX | até 6 famílias: corrente, impacto, vapor, incenso, pulso, fragmentos | feedback M1/M2 preservado |
| Narrativa | 6 composições opcionais+3 marcos principais | sem UI/inventário pressuposto |
| Aren/HUD | nenhuma substituição obrigatória | reutilizar padrão homologado |

Primeiro aprovar duas salas-piloto, exterior/interior, com Aren/HUD/perigos sobrepostos; só depois expandir produção. Registrar fontes, autoria/proveniência, prompts/licenças quando aplicáveis, dimensões, alpha, recortes/âncoras,.import e UIDs. Avaliar 1080p/1440p/4K nativos. Um fundo bonito sozinho não aprova leitura de colisão, perigo ou animação. Quantidade de arte não prova 4×.

## 19. Arquitetura técnica

### Diagnóstico da implementação atual

main.tscn contém ForgottenCemetery e GuardianEncounter. Os seis setores são uma cena; SECTOR_STARTS classifica porX, câmera usa limites próprios. Inimigos são vinculados por tipo e restaurados em lote após morte/queda. Esqueleto executa FSM enquanto carregado; o corvo verifica visibilidade para atacar, o que não desliga toda simulação distante. Backdrop preloads seis fundos e mantém superfícies/GroundSkin. Arena é lazy-loaded e suspende enemies/mechanisms por process_mode durante o encontro. Vitória/checkpoints são de sessão; não há save global.

Não escalar simplesmente adicionando números a SECTOR_STARTS e preloading tudo: mapa dobrado exige IDs de sala/portal, entradas e limites locais. A ARQUITETURA v0.1 descreve viewport/nearest de M0; DISPLAY01 posterior é referência vigente de canvas_items e filtros por camada.

### Módulos futuros, nomes indicativos

- scenes/chapters/abbey/abbey_root.tscn: composição da região, jogador, HUD e checkpoints.
- scenes/chapters/abbey/sectors/s01…s12.tscn: sólidos explícitos, arte, ameaças e entradas nomeadas; origem local.
- scripts/chapters/abbey/abbey_region.gd: coordenação concreta de limites, portais/reset/ID; evitar framework universal sem uso real.
- Manifesto por setor: conexões, AABB, entrada segura, extensão, recursos e descritores de entidades.
- Adaptador de transição de capítulo, separado de GuardianEncounter. Nova porta distinta do selo já homologado, com intenção explícita/confirmada, para não trocar de capítulo ao sair da arena involuntariamente.
- Novos inimigos, perigos e Abade em módulos próprios, contratos M1/M2 preservados e .uid versionados.
- Suítes novas de grafo, percurso, ativação, reset e integração, sem remover asserts antigos.

Todos são módulos propostos; nenhum arquivo foi criado no projeto.

### Conexão entre capítulos e política de estado

Não existe hoje roteador de capítulos ou persistência entre cenas; é trabalho real de integração. Proposta inicial reversível: hospedar a cena principal existente como uma cena completa sob um fluxo externo; ao trocar, remover sua instância da SceneTree **sem destruí-la**, conservando vitória e estado de sessão. Retornar à mesma instância. Fora da árvore não deve simular/colidir. Apenas process_mode disabled dentro do mesmo mundo **não remove colisões**.

Abadia pode instanciar a cena homologada de Aren sem editar seus scripts. **Política proposta a aprovar:** novo capítulo começa com 5 HP e respawn próprio; voltar ao Cemitério retoma seu estado congelado sem cura acidental. Caso o responsável queira um único Aren e HP contínuo entre capítulos, definir contrato específico de transferência/reorganização e testes em escopo autorizado. Não presumir essa decisão nem acrescentar save global.

Manter Cemitério em memória custa recursos; medir antes de consolidar. Descarregar/reconstruir futuramente exige snapshot de vitória/checkpoints/conclusão: escrever completed=true sozinho não reconstrói armadura/HUD/estado do encontro. Isso seria escopo explícito, nunca refatoração oculta.

### Setores, carregamento e reset

Começar por cenas separadas e geometria mínima; introduzir ativação espacial após medir. Alvo de residência: atual, anterior e próximo, mais um setor fixado pelo checkpoint ativo quando necessário. Antecipar recursos em trecho seguro; nunca liberar acesso a colisão ausente. Se não estiver pronto, transição legível aguardando recursos, não pausa surpresa durante golpe. Não fazer load síncrono pesado em combate.

Manter carregada a geometria/instância do checkpoint ativo até outro ativar. Aren mantém referência a RespawnCheckpoint; não liberar o nó e depois tentar usá-lo. Pode manter CPs em raiz estável e fixar o setor de suporte. Piso inicial mínimo de fallback sempre disponível, pois queda viva retorna ao início. Não depender de carregar disco antes dos 0,6 s da morte sem garantia.

Reset por geração: instâncias carregadas restauram pelos métodos existentes; descarregadas são marcadas para nascer no estado inicial após morte/queda. Na mesma vida, descritores preservam mortos/atalhos para evitar respawn arbitrário ao voltar à sala. Não perder restauração M3-E em inimigos que estavam descarregados. Checkpoint não se torna save em disco por isso.

Câmera por sala/portal, limites locais, FOV mantido; revelar pousos antes da decolagem. HUD usa ID de sala em vez deX absoluto. Ao adormecer entidades, desarmar fontes e gerenciar colisão/monitoramento explicitamente: esconder CanvasItem não desliga física. Testar projétil na fronteira, morte durante transição, troca de CP e retorno do capítulo. Nada foi refatorado nesta etapa.

## 20. Desempenho e riscos

| Risco | Mitigação proposta | Medida de aceite futura |
|---|---|---|
| Todos os fundos/atlas residentes | recursos compartilhados; arte por salas próximas | inventário de texturas e pico de memória |
| Carregamento travar transição | antecipar em respiro; colisão pronta antes da entrada | frametimes na primeira visita e retorno |
| IAs distantes simularem | ativação espacial, margem e desarme | contagem de IAs/fontes ativas; nada ofensivo fora de tela |
| Cache de terreno cobrir região inteira | geração por setor/visibilidade | tempo de geração e memória ao voltar |
| Cemitério suspenso reter recursos | medir e limitar a uma cena suspensa | comparar memória sem perder vitória |
| Checkpoint descarregado | raiz estável/pin e fallback inicial | morte/queda em todas as fronteiras |
| Cotas confundirem câmera | portais, AABB e destino antecipado | capturas e pousos reais nos dois sentidos |
| VFX/_draw custosos em 4K | limites locais/cadência estética/culling | cena com dupla+perigo em resolução nativa |
| Sessão longa sem save | informar limitação; marco separado se aprovado | playtest completo e retorno após fechar |

Referência histórica: RTX 2060 SUPER, Godot 4.7.2 Compatibility/OpenGL; auditoria M4-C~60 FPS e182 nós estáveis em 45 s. **Não é promessa para Abadia.** Meta futura: proximidade de 60 FPS em 4K na mesma máquina, p95 inicial≤20 ms; investigar picos>50 ms e travadas perceptíveis, não aprovar pela média apenas. Teto provisório de texturas residentes da abadia≤256 MiB, a validar com retenção do Cemitério/driver/arte; ainda não medido.

Exigir duas sessões reais≥10 min, ida/volta,20 transições, morte distante e chefe. Benchmark sem fixed-fps; headless não valida gráficos. RegistrarFPS, p95/p99/máximo, CPU/VRAM, nós/órfãos e carregamentos. Memória não deve crescer a cada ciclo. Testar 1920 × 1080,2560 × 1440,3840 × 2160 nativos.

Não instalar plugins nem migrar para TileMapLayer automaticamente. A geometria explícita funciona; mudar representação só se medição justificar, em marco aprovado. Sem trocar engine, renderer, filtro ou física para compensar custo.

## 21. Roadmap e cronograma incremental

**Conflito real:** ROADMAP reserva M5 ao slice polido(inclusive som/UX) e M6 à expansão. Usar M5-A…F para região e M6-A…C para chefe, como exemplo do pedido, redefiniria marcos. Recomendação: **M5-P** para este estudo, resolver gate M5 e usar **M6-C2-A…F** para região e **M6-C2-CHEFE-A…C** para chefe. O responsável pode aprovar outra numeração em tarefa futura; ROADMAP permanece intocado. Não presumir som/UX de M5 concluídos.

Estimativas são **dias úteis equivalentes de esforço**, não datas, SLA ou promessa de duração do agente. Excluem espera por avaliação, arte externa e retrabalho por mudanças de escopo. Reestimar após sala-piloto.

| Marco | Objetivo e módulos | Dependências/riscos | Testes, aceite e avanço | Esforço |
|---|---|---|---|---|
| M5-P | medidas, lore, layout, assets, arquitetura; este documento externo | decisões da seção 23; risco de canonizar por omissão | aprovação explícita, sem código | estudo entregue; revisão pendente |
| Gate M5 | resolver som/UX/polimento restante ou postergação consciente | ROADMAP vigente | decisão específica de escopo/numeração e autorização da expansão | 1–2 dias para escopo; produção extra não estimada |
| M6-C2-A | conexão, raiz, duas salas-piloto, câmera/fluxo de sessão | plano/gate aprovados; HP/colisões/retorno | regressãoC1; entrada/retorno sem perder vitória; Aren intacto; humano aprova | 3–5 |
| M6-C2-B | 12 setores/espinha, manifesto e medidor | A aprovado; falsa extensão/saltos | física+linha central≥12228; alvo 14400; quatro aproximações/sentido e percurso contínuo | 6–10 |
| M6-C2-C1 | Monge/Acólito e apresentações isoladas | B; tiro inevitável | aviso, parede, recuperação terrestre, resets, M1/M2 | 3–5 |
| M6-C2-C2 | Penitente/Vigia, quatro perigos novos, CPs/distribuição | C1; combinação injusta/pinCP | resposta sem dano, respawn seguro, metas 40 inimigos/30 zonas/12 dispositivos | 5–8 |
| M6-C2-D | duas provas de arte→inventário completo, VFX/animação | layout/ameaças estáveis; memória/recortes | aprovação visual piloto,1080p/1440p/4K, alpha/UID/proveniência | 8–15 |
| M6-C2-E | seis ramos, três atalhos, narrativa | B/C/D; encurtar 4× ou ramo obrigatório |3000 px exclusivos alvo; menor rota após atalhos≥12228; sem inventário novo | 3–5 |
| M6-C2-F | regressão região, duração, gráficos/desempenho | C/D/E; alvo não observado | antigas+novas suites, benchmark real e playtest; saída provisória sem chefe explicitamente declarada | 3–5 |
| M6-C2-CHEFE-A | arena/conceito/primeira família | região/conceito aprovados; câmera | um padrão justo, Aren original, morte/saída seguras, arte piloto | 3–5 |
| M6-C2-CHEFE-B | seis famílias/duas fases/combinações | chefeA; inevitabilidade/esponjaHP | respostas físicas por família/par, duelos por input, comparação humana de dificuldade | 5–8 |
| M6-C2-CHEFE-C | derrota, narrativa, integração/regressão final | chefeB homologado; estado/retorno | cancelamento, morte simultânea, reentrada, performance; homologação final | 3–5 |

Somatório indicativo A→chefeC: **42–71 dias úteis equivalentes**, sem esperas/revisões/escopo extra M5. Não é calendário aprovado. Homologar cada arquétipo/perigo antes de espalhar; arte depende de layout/escala. Nenhum trabalho paralelo é iniciado por este plano.

Fluxo: **implementação → testes → playtest do responsável → homologação → commit autorizado → publicação autorizada**. Aceitar um marco não autoriza automaticamente o seguinte ou push. Primeira tarefa técnica recomendada, após aprovação e gate macro: **M6-C2-A**, duas salas-piloto e transição, não 12 salas nem chefe de uma vez.

## 22. Critérios de homologação

1. **Extensão:** grafo/planta/traço; rota física e linha central≥12228 px, inclusive após atalhos. Alvo 14400, opcionais separados; sem combate, teleporte, mortes ou duplicação. Auditar menor caminho após desbloqueios.
2. **Navegação:** cada ligação necessária em física real nos dois sentidos/quatro aproximações, partida parada, corpo apoiado, pouso visível e percurso contínuo sem reset entre ligações. Teste geométrico identificado como tal não substitui física/playtest.
3. **Variedade:** 12 setores distintos, quatro arquétipos novos e dispositivos legíveis; nenhum ramo/corredor vazio financiando extensão. Quotas não substituem qualidade; redução exige reavaliação.
4. **Justiça:** sem tiro por parede, fonte invisível ou dano inevitável; todos puníveis com espada terrestre; contratos de Aren e sistemas homologados preservados.
5. **CP/reset:** sete ativáveis propostos, sem referências inválidas/setor ausente; respawn seguro; rota ao chefe≤10 s; queda viva não cura. Mortes/queda restauram entidades/carregadas e futuras.
6. **Exploração:** seis descobertas com pista/retorno; nenhum inventário novo obrigatório ou recompensa prometida sem sistema.
7. **Abade:** duas fases/seis famílias planejadas, resposta sem dano isolada/por par; morte, saída e vitória simultânea seguras. Dificuldade humana superior por decisões, sem depender deHP/dano aumentados.
8. **Imagem:** três resoluções nativas, filtros por camada, FOV/colisores estáveis; validar com Aren/HUD/perigos. Sem chamar headless de gráfico ou imagem ampliada de 4K.
9. **Performance:** sessões reais sem fixed-fps, memória sem crescimento por retorno, picos explicados, nada ofensivo residual após fronteira.
10. **Regressão:** cópia limpa importável; M0/M1/M2, estrutura/alcançabilidade, inimigos, mecanismos, arte/DISPLAY01, M3-E e todas M4, mais suites novas de região/streaming/Abade. Preservar histórico de 1013 verificações principais, sem retirar asserts para manter números.
11. **Duração:** amostra/experiência dos participantes e tempos por atividade;14–22 min é alvo, não resultado já medido. Ajustar conteúdo ou rever meta explicitamente conforme evidência, sem inflar tentativas.
12. **Governança:** homologação só após resposta humana; fontes, UIDs/imports, proveniências e diagnósticos preservados; reconstrução limpa antes de futura publicação.

Checklist humano futuro: conexão/retorno; orientação e próximo destino; ida/volta em todas as cotas; quatro inimigos novos isolados/combinados; quatro perigos novos; todos os checkpoints após morte/queda; seis ramos e atalhos; ameaças na borda da câmera; sessão completa; fechar/reabrir para verificar a limitação de save; aprendizagem/vitória/reentrada do Abade; nitidez/fluidez 4K. Não preencher por inferência ou substituir por contagem de colisores.

## 23. Decisões pendentes e encerramento

- Confirmar Abadia/Abade como direção definitiva e aprovar detalhes narrativos, mantendo mistérios abertos.
- Aprovar 14400 px/meta, 12228 mínimo,12 setores,3000 opcionais e mínimo após atalhos.
- Aprovar quatro inimigos/quatro perigos novos, seis segredos, sete checkpoints e processo de validação de duração 14–22 min.
- Resolver numeração M5/M6 e conclusão/postergação consciente do gate de som/UX/polimento; não presumir marco concluído.
- Aprovar política entre capítulos:5 HP iniciais/estado por capítulo/cena anterior suspensa, ou escopo separado de Aren único/HP contínuo/snapshots. Definir intenção/UX da nova porta e retorno, preservando o selo atual.
- Aceitar sessão sem save ou autorizar marco próprio de persistência, fora deste plano básico.
- Aprovar conceito/câmera/padrões do Abade e comparação humana de dificuldade; tempos ainda são sementes.
- Aprovar salas de arte-piloto e reavaliar orçamento/cronograma após medições.

**Nenhuma decisão é presumida pelo silêncio.** Não iniciar implementação, editar ROADMAP/README ou tornar proposta cânone automaticamente.

Integridade: main, HEAD `bfae340b2480dfc65dfbe1a6bde7deb7ebcae044`, índice vazio. Permanecem project.godot modificado e14 não rastreados preexistentes. O fechamento em final-integrity.json confere 222 arquivos originais por SHA-256. Somente documento/evidências fora do repositório e script em cópia isolada foram produzidos; nenhum código, cena, arte ou configuração do jogo foi alterado.

**Sem staging, commit, push, branch nova ou implementação.** Planejamento encerrado; Capítulo 2 e segundo chefe não implementados. Aguardar avaliação/autorização.

### Fontes e evidências

Projeto: README.md, ROADMAP.md, GDD.md, ARQUITETURA.md, docs/M3_A.md; cena forgotten_cemetery.tscn, controlador knight_controller.gd, knight_survival.gd, inimigos, encounter.gd, guardian.gd, guardian_conclusion.gd, guardian_arena.tscn e cemetery_visual.gd. Homologações M3/M4 e DISPLAY01 em tests/VALIDACAO_*.md, registradas em sources.json. Os documentos v0.1 são históricos e não sobrepõem o runtime DISPLAY01/M4.

Nesta pasta: measure_route.gd, route.json, measurement-console.txt/measurement.log, geometry.py, metrics.json, initial.json, sources.json, final-integrity.json. A medição isolada é nova evidência de comprimento, não nova homologação ou regressão completa. Auditoria anterior permanece na pasta irmã auditoria-publicacao. Nenhum resultado foi inserido nos documentos homologados do repositório.


## 24. Formalização M5-P/M5-A — 04/11/2026

A solicitação M5 do responsável aprova o conceito da Abadia somente para duas salas-piloto independentes: Claustro das Sombras e Galeria dos Penitentes, Monge Acorrentado e um Contrapeso. Arte, narrativa e layout definitivos continuam sujeitos a playtest. Meta futura14400 px, mínimo12227,52 (critério arredondado12228),12 setores e3000 opcionais preservados, não implementados nem comprovados pelos pilotos.

A recomendação de numeração da seção21 era uma proposta, não marco homologado. O ROADMAP v0.1 só havia publicado M0–M4; suas linhas M5(slice),M6(expansão),M7(build/publicação) eram futuras. Com a nova autorização explícita, formaliza-se M5-P(planejamento),M5-A(pilotos),M5-B(estrutura),M5-C(inimigos/perigos/CP),M5-D(arte),M5-E(exploração),M5-F(regressão/homologação); M6-A/B/C(segundo chefe). Restante da expansão e pendências de polimento/som/UX ficam em M7 futuro; build/distribuição executável em M8 futuro. Nenhum commit ou marco homologado foi renumerado. Isso substitui somente a recomendação M6-C2 da seção21, preservada acima como histórico.

Acesso experimental exclusivamente pela cena scenes/abbey/abbey_pilots.tscn; inicial oficial e selo do Guardião intocados. Não se implementa ligação canônica entre capítulos, política definitiva de HP entre capítulos, save global, demais setores ou segundo chefe. O piloto mantém um Aren original entre suas duas salas, com checkpoints isolados e carregamento antes do respawn. Estado M5-A: implementação experimental pendente de avaliação artística, funcional e técnica; relatório em tests/VALIDACAO_M5_A.md. Sem staging, commit ou push nesta entrega.

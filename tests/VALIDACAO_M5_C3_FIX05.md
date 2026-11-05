# M5-C3 FIX05 — Instrumentação e alcançabilidade

**BLOCKED.** Foi criado e exercitado um observador externo que detectou projéteis dinâmicos e fases de mecanismos. As sete combinações permanecem inconclusivas. A instrumentação ainda não identifica com segurança todas as causas de remoção nem demonstrou sensibilidade a uma janela real de pressão combinada.

## Baseline

Repositório C:/PROJETOS/CINZAS DO JURAMENTO, branch main, HEAD cda7e40b689e4e7197d2eccfb53e9fbd357032d0, índice vazio. Antes e depois foram conferidos os hashes dos 15 arquivos preexistentes. Os relatórios FIX02, FIX03 e FIX04 e as alterações locais foram mantidos. Os scripts de observação e seus logs estão fora do projeto, em `m5c3-fix05` na pasta de evidências das etapas anteriores.

## Modelo direcionado

A IA usa visão limitada a 104 px horizontais e 20 px verticais, câmera e linha de visão. Após ativação, o Acólito anuncia por 0,75 s, dispara na fase ativa e recupera por 0,90 s. O projétil tem raio 5, velocidade horizontal 65 px/s e limite temporal superior a 1,6 s. Pode ser removido por contato, colisão de cenário, expiração, morte do emissor ou descarga. A IA limita sua posição a 64 px da origem. O Penitente anuncia por 0,65 s e investe a 72 px/s por 0,30 s. O Vigia e o Monge também usam estados de aviso, ataque e recuperação.

A Comporta só inicia aviso quando Aren está a menos de 85 px horizontais e 28 verticais após o período seguro. Seus tempos são 1,6/0,8/0,5/1,5 s. Pêndulo e Jato têm ciclos próprios de 1,8/0,8/1,2/1,4 s e 1,8/0,8/0,7/1,4 s. As formas do Pêndulo, Comporta e Jato medem 24×24, 20×48 e 40×16 px. O Pêndulo desloca a forma durante o ataque. A Prensa original possui aviso de 0,8 s e ataque de 0,4 s. Atividade simultânea, interseção de hitboxes e pressão real sobre Aren são condições distintas. Não foi construído um modelo completo dos estados alcançáveis nem prova de exclusão das combinações.

| Setor | Componentes e posições locais | Restrição relevante | Classificação |
|---|---|---|---|
| 5 Cisternas | Comporta x780, Acólito x950 | 170 px entre origens. A Comporta depende de proximidade e o projétil continua após o disparo | D |
| 6 Galeria | Monge x388, Prensa x588, Jato x850 | Ciclos da Prensa e Jato independentes. O Monge tem patrulha limitada | D |
| 7 Fundição | Vigia x410, Pêndulo x690, Monge x1080 | Atores em alturas e trechos distintos. Pêndulo temporizado | D |
| 8 Ponte | Penitente x550, Comporta x850 | Vãos e sensor da Comporta restringem movimentos. Penitente patrulha e investe | D |
| 9 Arquivo | Acólito x510, Jato x800 | Distância 290 px entre origens. O disparo tem alcance finito, mas pode permanecer após o estado ativo | D |
| 10 Jardim | Penitente x450, Pêndulo x850 | Distância e relevo influenciam as janelas | D |
| 11 Campanário | Vigia x420, Comporta x850 | Distância e escadaria restringem o contato. A Comporta exige aproximação | D |

D significa inconclusivo. As distâncias indicam onde investigar, não demonstram impossibilidade para todos os estados, fases e movimentos.

## Instrumentação executada

`observer_lifecycle.gd` deriva externamente da suíte de ciclo de vida. A conexão `node_added` identifica projéteis criados durante o teste, atribui ID da instância e registra a saída da árvore. Durante quadros físicos registra direção, posição, velocidade nominal, raio, transformação e camadas. Registra transições de estado e ativação das formas dos mecanismos. Não altera código de gameplay.

O ensaio de ciclo de vida terminou com **106/106** verificações. Foram registrados 24 nascimentos e 24 saídas de projéteis, incluindo o caso de contato real já exercitado pela fixture e um disparo removido sem dano. Foram observadas formas de mecanismo habilitadas e posteriormente desabilitadas. A igualdade de contagens vale apenas para esse ensaio, não é prova de cobertura integral em toda execução. A saída registra `contacted`, tempo e posição, mas deixa o motivo como `not_inferred`. A chamada de criação precede a atribuição final da posição pelo emissor, por isso a posição inicial deve ser lida na amostra posterior à criação.

`observe_margin.gd` usa as contraprovas reais do FIX03. O observador registrou dois projéteis criados e removidos. Em S5, o salto ocorreu no quadro local 585 e o disparo no 596, com Comporta segura. Em S9, o salto ocorreu no 276 e o disparo no 286, com Jato seguro. Em S6, a Prensa estava ativa durante a espera, com Jato em aviso e Monge em patrulha, sem segunda pressão demonstrada. Os três trechos terminaram com 5 HP. Não foi executada prova sintética de duas ameaças ativas nem prova de uma janela real de pressão combinada. O observador não registra ainda todos os estados de inimigos e comandos em eventos estruturados nem distingue automaticamente contato, colisão, timeout e descarga. A observabilidade solicitada não está completa.

## Alcançabilidade e justiça

FIX04 variou entrada imediata e espera de 45 quadros, em ambos os sentidos. FIX03 testou duas posições de salto nas três contraprovas. FIX05 acrescentou a observação dos dois disparos durante a variante existente. Essas amostras não varrem todos os tempos nem demonstram uma sobreposição alcançável ou impossível. Não foi comprovado defeito de justiça, nem é possível concluir que todos os encontros sejam justos sob pressão combinada. Nenhuma correção funcional foi aplicada.

Matriz conclusiva: S5, S6, S7, S8, S9, S10 e S11 são **D** quanto à pressão simultânea. Zero casos A, B ou C foram comprovados. A jornada, regressões e medições geométricas do FIX02–FIX04 são evidências históricas reaproveitadas, sem repetição integral nesta rodada.

## Reprodução e estado final

Na raiz do projeto, Godot 4.7.2: `--headless --path . --fixed-fps 60 --log-file <log> --script <script>`. Usar `observer_lifecycle.gd` e `observe_margin.gd` no diretório de evidências C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5c3-fix05. Os logs `observer.log` e `observe-margin.log` contêm os eventos e saídas. Ambos retornaram código 0. A ressalva histórica ObjectDB permanece aberta e o ambiente voltou a registrar falha de leitura de certificados.

Único arquivo novo no projeto nesta rodada: este relatório. Sem staging, commit, push ou deploy. Branch main, HEAD e índice conferidos. Pendências concretas: validar observador para causa de remoção e duas ameaças, registrar comandos e estados sincronizados, explorar condições alcançáveis e demonstrar resposta ou impossibilidade para cada uma das sete combinações.

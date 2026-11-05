# M5-C3 FIX04 — Pressão simultânea

**BLOCKED.** Foram executadas duas travessias instrumentadas por sentido nos setores 3 e 5–11, além de uma repetição das contraprovas do FIX03. As execuções não demonstraram uma janela de pressão simultânea e não provam que ela seja impossível no comportamento canônico.

## Baseline

Projeto C:/PROJETOS/CINZAS DO JURAMENTO, branch main, HEAD cda7e40b689e4e7197d2eccfb53e9fbd357032d0, índice vazio. Os 15 hashes do inventário anterior foram verificados no início e no fim. As alterações locais M5-C3 e relatórios FIX02/FIX03 foram preservados. O único arquivo novo no projeto nesta rodada é este relatório.

## Método e evidência

Godot 4.7.2, cena real da Abadia, física a 60 Hz. A cópia externa `pressure.gd` usa o roteiro de travessias direcionais do FIX02 com ameaças ativas. A cópia `pressure-delayed.gd` acrescenta 45 quadros após a entrada antes da medição. Ambas atravessaram os oito setores nos dois sentidos, com saída 0. A instrumentação amostrou a posição de Aren e o estado de cada inimigo e mecanismo. Em cada par registrou como candidato o quadro em que Aren estivesse a menos de 104 px do inimigo e 100 px do mecanismo, com inimigo em aviso ou ataque e mecanismo em aviso ou ataque. O número de quadros candidatos foi zero em todos os trechos.

Este filtro é exploratório, usa distâncias euclidianas arbitrárias e não acompanha projéteis independentes ou todos os elementos visuais. Um resultado zero não comprova ausência de pressão simultânea, nem autoriza classificar o caso como não aplicável. O atraso de 45 quadros também não amostra todos os tempos possíveis.

A prova `margin.gd` do FIX03 foi repetida sem mudanças em `repeat-1.log`. Na ida das Cisternas, Aren saltou no quadro 585 e o Acólito disparou no 596 com Comporta segura. No Arquivo, o salto ocorreu no quadro 276 e o disparo no 286 com Jato seguro. Na volta da Galeria, a Prensa estava ativa no quadro 408, Aren estava em x≈647, o Jato em aviso e o Monge em patrulha. Os três percursos terminaram com 5 HP. Esses são comportamentos observados, sem prova de duas ameaças impondo decisões ao mesmo tempo.

| Encontro | Evidência anterior reutilizada | Resultado FIX04 | Classificação |
|---|---|---|---|
| S3 Escadaria · Pêndulo e desnível | FIX02 ida e volta sem dano | Duas travessias por sentido. Não há par inimigo/mecanismo na matriz de entidades | Individual. Pressão simultânea entre ameaças não aplicável |
| S5 Cisternas · Acólito e Comporta | FIX03 duas respostas ao projétil | Dois percursos por sentido e repetição da esquiva. Nenhum quadro candidato no filtro | Inconclusivo |
| S6 Galeria · Monge, Prensa e Jato | FIX03 espera fora da Prensa | Dois percursos por sentido. Prensa ativa com Jato em aviso, mas separados e sem segunda pressão demonstrada | Inconclusivo |
| S7 Fundição · Vigia, Pêndulo, Monge | FIX02 ida e volta | Dois percursos por sentido. Nenhum quadro candidato no filtro | Inconclusivo |
| S8 Ponte · Penitente e Comporta | FIX02 ida e volta sem dano | Dois percursos por sentido. Nenhum quadro candidato no filtro | Inconclusivo |
| S9 Arquivo · Acólito e Jato | FIX03 salto e espera | Dois percursos por sentido e repetição da esquiva. Jato seguro no disparo observado | Inconclusivo |
| S10 Jardim · Penitente e Pêndulo | FIX02 ida e volta | Dois percursos por sentido. Nenhum quadro candidato no filtro | Inconclusivo |
| S11 Campanário · Vigia e Comporta | FIX02 ida e volta | Dois percursos por sentido. Nenhum quadro candidato no filtro | Inconclusivo |

Na primeira execução, as travessias de ida S5 e S9 e de volta S6 receberam 1 ponto de dano, compatível com as fontes identificadas no FIX03. Isso não estabelece injustiça. A classificação depende de demonstrar uma janela simultânea e uma resposta, ou comprovar que a interação não pode ocorrer nas condições canônicas.

## Reprodução

Na raiz do projeto, com a Godot 4.7.2, executar `--headless --path . --fixed-fps 60 --log-file <log> --script <script>`. Scripts e logs exclusivos estão em C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5c3-fix04. Usar `pressure.gd` e `pressure-delayed.gd` com seus logs correspondentes. A repetição do FIX03 usou `../m5c3-fix03/margin.gd` e gerou `repeat-1.log`.

Nenhuma alteração funcional foi aplicada, portanto as regressões e jornada FIX02 foram reutilizadas como histórico. A ressalva histórica ObjectDB permanece aberta. O ambiente voltou a informar falha na leitura do repositório de certificados. O aceite segue bloqueado pela ausência de prova para os sete encontros combinados acima, não pela ressalva histórica.

Sem staging, commit, push ou deploy. Branch, HEAD e índice conferidos ao final.

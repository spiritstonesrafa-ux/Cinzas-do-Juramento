# M5-C3 FIX03 — Validação direcionada de encontros

**BLOCKED.** Os três danos foram reproduzidos, atribuídos e evitados em duas estratégias de tempo ligeiramente diferente. A cobertura de interação simultânea dos encontros classificados como combinados ainda é incompleta.

## Baseline

Repositório C:/PROJETOS/CINZAS DO JURAMENTO, branch main, HEAD cda7e40b689e4e7197d2eccfb53e9fbd357032d0 e índice vazio. O estado inicial continha os arquivos locais do M5-C3, seus FIX01 e FIX02, project.godot modificado e 14 arquivos anteriores não rastreados. Os 15 hashes do inventário anterior conferiram. Nenhum arquivo de gameplay ou teste homologado foi editado nesta rodada.

## Diagnóstico e contraprovas

As provas partem das entradas reais de cada setor com 5 HP, usam ações de movimento, salto e espada e exigem acionar a saída física. Todas as ameaças permaneceram habilitadas. O sinal health_changed registrou a perda de HP durante o quadro físico. Uma consulta com a forma, transformação e máscara da hurtbox registrou o colisor no mesmo quadro, inclusive o projétil já marcado para remoção. As coordenadas abaixo são locais.

| Caso | Impacto reproduzido | Estratégia demonstrada |
|---|---|---|
| A · Cisternas, ida | Quadro 597, 5→4. Aren (936,62; 515,93), avançando sem salto, sobrepôs o círculo do projétil em (930,48; 501,93). O projétil do Acólito já estava marcado para remoção após contato. | Esperar a janela da Comporta, manter o avanço e saltar no piso do Acólito, entre x≈912 e x≈915. Na variante, o disparo saiu no quadro 596 em (931,57; 501,93), com o Acólito em fase ativa e Aren em (935,00; 482,39). Saída 5→5 em 853 quadros nas duas provas. |
| B · Arquivo, ida | Quadro 287, 5→4. Aren (494,50; 371,93), avançando sem salto, sobrepôs o projétil em (488,32; 357,93). A área circular foi consumida no contato. | Saltar antes de cruzar a linha do Acólito, entre x≈470 e x≈475, e seguir pela janela do Jato. Na variante, o projétil saiu no quadro 286 em (489,40; 357,93), com o Acólito em fase ativa e Aren em (492,88; 340,15). Saída 5→5 em 836 quadros nas duas provas. |
| C · Galeria, volta | Quadro 420, 5→4. Aren (600,79; 299,93) avançava à esquerda sem salto. A forma ofensiva da Prensa em x=588 estava ativa. | Vindo da direita, soltar esquerda antes da Prensa durante aviso ou ataque e retomar após a fase ativa. Na variante, a hitbox estava ativa no quadro 408, com Aren em x≈647, fora do alcance. Saídas 5→5 em 821 e 824 quadros. |

Os resultados indicam dano evitável por timing. Nos casos A e B, o salto deslocou a hurtbox acima do disparo real. No caso C, a espera manteve Aren fora do alcance durante a descida da Prensa. Nenhum defeito de colisão foi demonstrado. O primeiro ensaio instrumentado da variante tentou ler um projétil já liberado com uma variável tipada como nó. O teste foi ajustado para verificar a validade da referência antes de acessar o objeto. A execução final saiu com código 0.

## Matriz de cobertura

| Setor | Ameaças | Evidência | Lacuna de aceite |
|---|---|---|---|
| 1 Átrio | Área de respiro | Jornada FIX02 | Nenhuma prova de combate aplicável |
| 2 Claustro | Monge | Jornada FIX02 e espada física na distribuição | Evidência individual reaproveitada |
| 3 Escadaria | Pêndulo em desnível | FIX02 sem dano nos dois sentidos e descarga da hitbox ativa | Evidência reaproveitada |
| 4 Dormitório | Acólito | FIX02, disparo real, impacto, remoção e reentrada | Evidência individual reaproveitada |
| 5 Cisternas | Comporta e Acólito | FIX02 volta sem dano. FIX03 ida sem dano duas vezes com disparo real | A Comporta estava segura quando houve disparo. Pressão simultânea não demonstrada |
| 6 Galeria | Monge, Prensa e Jato | FIX02 ida sem dano. FIX03 volta sem dano duas vezes com Prensa ativa | Na amostra de espera, Jato em aviso e Monge em patrulha. Pressão simultânea de múltiplas ameaças não demonstrada |
| 7 Fundição | Vigia, Pêndulo e Monge | FIX02 sem dano nos dois sentidos. Dois inimigos em trechos separados por 670 px | Passagem conjunta demonstrada. Sobreposição ofensiva não verificada |
| 8 Ponte | Penitente e Comporta | FIX02 sem dano nos dois sentidos | Passagem conjunta demonstrada. Sobreposição ofensiva não verificada |
| 9 Arquivo | Acólito e Jato | FIX02 volta sem dano. FIX03 ida sem dano duas vezes com disparo real | O Jato estava seguro quando houve disparo. Pressão simultânea não demonstrada |
| 10 Jardim | Penitente e Pêndulo | FIX02 sem dano nos dois sentidos | Passagem conjunta demonstrada. Sobreposição ofensiva não verificada |
| 11 Campanário | Vigia e Comporta | FIX02 sem dano nos dois sentidos | Passagem conjunta demonstrada. Sobreposição ofensiva não verificada |
| 12 Coro | Monge | Jornada FIX02 e prova do arquétipo Monge | Evidência individual reaproveitada |

O roteiro não mediu se as áreas e janelas ofensivas simultâneas são alcançáveis nas combinações pendentes. A travessia sem dano por si só não fecha esse requisito.

## Reprodução e Git

Evidências exclusivas em m5c3-fix03, sob a pasta de visualizações desta conversa. Na raiz do projeto, executar a Godot 4.7.2 com `--headless --path . --fixed-fps 60 --log-file <arquivo> --script <script>`. Usar probe.gd para reproduzir os três impactos, dodge.gd para a primeira contraprova e margin.gd para a variante com asserção de HP e ameaça observada. Os resultados correspondentes estão em baseline.log, dodge.log e margin-final.log.

Sem mudanças funcionais, foram executadas apenas as provas focadas. Jornada, 104 verificações de ciclo de vida, 157 de distribuição e demais regressões são evidências históricas do FIX02. Houve aviso ObjectDB de quatro instâncias nas provas focadas. A ressalva histórica segue aberta. O ambiente voltou a registrar falha de leitura do repositório de certificados.

O único arquivo novo no projeto nesta rodada é este relatório. HEAD e índice permaneceram como no início. Os 15 arquivos preexistentes foram reconferidos por hash. Sem staging, commit, push ou deploy.

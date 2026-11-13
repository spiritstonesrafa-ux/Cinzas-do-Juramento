# Inimigos da Fornalha do Juramento

## Composição

São **19 inimigos comuns mais o Titã Ossuário**, totalizando 20 inimigos na fase. A composição alterna ameaças terrestres e aéreas para que cada trecho peça leitura diferente sem transformar o caminho numa sequência de grupos grandes.

| Tipo | Quantidade | Vida | Função |
|---|---:|---:|---|
| Mineiro de Escória | 8 | 3 | Guarda lento com alcance curto e golpe de picareta bem sinalizado. |
| Rastejante de Cinza | 7 | 2 | Avanço rápido e bote baixo; pode ser acertado com o golpe rasteiro. |
| Corvo da Fuligem | 4 | 2 | Oponente aéreo que anuncia e cospe uma brasa em linha reta. |

Todos usam o mesmo acabamento sombrio e luminoso do Titã: ferro enegrecido, cinza e fissuras de brasa. O contraste da silhueta diferencia cada função mesmo no cenário escuro.

## Animações

Cada folha tem 16 quadros num arranjo 4 × 4: 8 de locomoção, 4 de ataque e 4 de recuperação. A recuperação é um estado vulnerável em que o inimigo não ataca.

| Tipo | Locomoção | Ataque | Recuperação |
|---|---|---|---|
| Mineiro | Marcha pesada em 8 quadros | Ergue, prepara e desfere a picareta | Baixa a arma e volta à guarda em 4 quadros |
| Rastejante | Passos alternados e cauda em 8 quadros | Agacha, prepara e salta para a frente | Aterrissa e se recompõe em 4 quadros |
| Corvo | Ciclo de voo e batida de asas em 8 quadros | Recolhe as asas e cospe brasa em 4 quadros | Paira e recupera o voo em 4 quadros |

As folhas ficam em `assets/art/m4a/furnace_enemies/`. A linha 1 e a linha 2 são a caminhada ou voo; a linha 3 é o ataque; a linha 4 é a recuperação.

## Comportamento e leitura

- O mineiro patrulha uma plataforma curta. A picareta fica erguida por 0,52 s antes de um golpe frontal de 0,20 s; depois ele recupera por 0,62 s.
- O rastejante patrulha mais rápido. Ele se comprime por 0,34 s, salta em direção ao jogador por 0,24 s e fica exposto por 0,48 s.
- O corvo paira numa faixa curta. A postura de disparo dura 0,55 s; a brasa viaja pelo cenário e o corvo fica exposto por 0,72 s depois do disparo.
- Os golpes causam 1 ponto de dano. O jogador continua usando a invulnerabilidade normal após ser atingido.
- Os inimigos terrestres respeitam bordas de plataforma; os corvos ficam em áreas abertas e recebem altura para o salto duplo alcançar seus corpos.

## Distribuição dos 20 encontros

As posições são âncoras de mundo no projeto. Em inimigos terrestres, o Y encosta os pés no piso; nos corvos, representa o centro da faixa de voo. O campo `roam` define a patrulha para cada lado.

| Nº | Região / posição (x, y) | Inimigo | Papel no trecho |
|---:|---|---|---|
| 1 | Boca da Mina (210, 1100) | Mineiro | Primeiro combate, isolado da escória. |
| 2 | Entrada do poço (410, 1100) | Rastejante | Apresenta o bote baixo após o primeiro inimigo. |
| 3 | Poço (610, 1080) | Mineiro | Guarda a travessia, longe do primeiro grupo. |
| 4 | Poço, voo (720, 990) | Corvo | Ameaça aérea opcional na passagem vertical. |
| 5 | Canal inferior (835, 1300) | Rastejante | Patrulha a primeira plataforma do laço. |
| 6 | Canal inferior (1170, 1300) | Mineiro | Encontro espaçado na travessia longa. |
| 7 | Canal inferior (1370, 1300) | Rastejante | Aumenta o ritmo antes da subida. |
| 8 | Canal, voo (1550, 1160) | Corvo | Pressiona o salto para a escadaria. |
| 9 | Galeria, plataforma (500, 880) | Mineiro | Protege a plataforma lateral. |
| 10 | Galeria, plataforma (740, 860) | Rastejante | Encontro rápido após a subida do poço. |
| 11 | Câmara, plataforma (1120, 880) | Mineiro | Guarda a passagem entre galerias. |
| 12 | Câmara, voo (1350, 760) | Corvo | Força o uso do salto duplo em espaço aberto. |
| 13 | Câmara, plataforma (1520, 860) | Rastejante | Protege o retorno à rota alta. |
| 14 | Câmara, plataforma (1740, 840) | Mineiro | Ataque de alcance curto perto da saída. |
| 15 | Escadaria (1900, 910) | Rastejante | Mantém pressão durante a subida. |
| 16 | Arquivo, plataforma (2130, 860) | Mineiro | Encontro antes da aproximação final. |
| 17 | Santuário, voo (2350, 790) | Corvo | Ameaça aérea antes da arena do chefe. |
| 18 | Santuário, degrau (2420, 990) | Rastejante | Guarda a primeira plataforma da subida final. |
| 19 | Santuário, degrau (2580, 870) | Mineiro | Último inimigo comum antes da arena do chefe. |

O chefe não é acompanhado por inimigos comuns dentro da arena. A composição dos 19 inimigos comuns por trecho é 4 na entrada/poço, 4 no canal, 7 nas galerias/câmara/escadaria, 1 no arquivo e 3 na aproximação do santuário.

# M5-C3 FIX02 — Encontros e ciclo de vida

**FIX02 BLOQUEADO.** A jornada completa, as sondagens de travessia e o descarregamento de projéteis passaram. A evidência de justiça individual ainda é incompleta nos três percursos direcionais em que Aren tomou dano e cuja origem e contramedida não foram isoladas. A cobertura de limites de hitbox nas instâncias combinadas também está incompleta.

## Baseline

Branch `main`, HEAD `cda7e40b689e4e7197d2eccfb53e9fbd357032d0`, índice vazio. Os hashes dos 15 arquivos anteriores ao M5-C3 correspondem ao inventário original. Distribuição, arte, IA, geometria e checkpoints permanecem com os dados de entrada. São 11 inimigos e 9 perigos. Nenhuma correção de gameplay necessária nos casos reproduzidos. Alterações desta rodada: nova suíte `tests/m5_c3_lifecycle_test.gd`, este relatório e um adendo em `tests/VALIDACAO_M5_C3.md`. O relatório FIX01 permanece histórico.

## Encontros

Oito setores de interesse e 16 sondagens direcionais independentes. S1 é área de respiro. S2 e S12 têm Monges isolados em relevo. S4 contém o Acólito isolado e foi usado para a prova real de projétil. A Fundição abriga dois inimigos separados por 670 px, em trechos sucessivos. A execução não demonstrou ataque simultâneo dos dois.

As sondagens partem da entrada normal do setor com 5 HP. Usam caminhada, salto para desníveis ou vãos, pulsos de espada e espera durante o aviso e a fase ativa das armadilhas. Todas as ameaças continuam habilitadas. A travessia exige acionar a saída física. O teste não atribui vitória sobre inimigos à mera passagem.

| Setor | Instâncias e coordenadas locais | Classe | Ida (quadros, HP) | Volta (quadros, HP) | Resultado |
|---|---|---|---|---|---|
| 3 Escadaria | Pêndulo (340,516) | Plataforma + armadilha | 875, 5→5 | 789, 5→5 | Estratégia sem dano nos dois sentidos |
| 5 Cisternas | Comporta (780,492), Acólito (950,516) | Inimigo + armadilha + projétil | 853, 5→4 | 880, 5→5 | Travessia passou. Dano em um sentido ainda sem contraprova |
| 6 Galeria | Monge (388,300), Prensa (588,300), Jato (850,300) | Inimigo + armadilhas | 750, 5→5 | 782, 5→4 | Travessia passou. Dano em um sentido ainda sem contraprova |
| 7 Fundição | Vigia (410,300), Pêndulo (690,348), Monge (1080,276) | Ameaças sucessivas em cotas distintas | 880, 5→5 | 1000, 5→5 | Estratégia sem dano nos dois sentidos |
| 8 Ponte | Penitente (550,300), Comporta (850,300) | Vãos + inimigo + armadilha | 758, 5→5 | 759, 5→5 | Estratégia sem dano nos dois sentidos |
| 9 Arquivo | Acólito (510,372), Jato (800,300) | Inimigo + projétil + armadilha | 836, 5→4 | 770, 5→5 | Travessia passou. Dano em um sentido ainda sem contraprova |
| 10 Jardim | Penitente (450,252), Pêndulo (850,324) | Inimigo + armadilha | 817, 5→5 | 802, 5→5 | Estratégia sem dano nos dois sentidos |
| 11 Campanário | Vigia (420,516), Comporta (850,372) | Inimigo + armadilha | 883, 5→5 | 791, 5→5 | Estratégia sem dano nos dois sentidos |

As suítes homologadas de armadilhas, combate e inimigos exercitam sobreposição, limites e fases de ataque em separado. Nas instâncias combinadas, faltam a atribuição precisa dos danos em S5 ida, S6 volta e S9 ida, a contraprova com recuo ou esquiva e casos direcionados de colisão nas bordas durante salto. Nenhum dano inevitável ou softlock foi demonstrado. As sondagens não substituem essa cobertura.

## Ciclo de vida

A suíte nova passou **104/104**. Usou o Acólito real no Dormitório, com Aren posicionado como preparação a 55 px. A IA iniciou aviso e disparou. O projétil avançou, sobrepôs a hurtbox física, retirou exatamente 1 HP e foi consumido. Um disparo sem acerto foi removido sem dano. Não foi discriminado nesse caso se a remoção veio de expiração ou choque com cenário. A prova de morte induzida com disparo em voo confirmou remoção e respawn com vida cheia. O teste também descarregou o Pêndulo do setor 3 durante a fase ativa, com a hitbox ligada. A liberação durante aviso do Acólito não gerou disparo na sala seguinte.

Foram 24 ciclos S4→S5, com reentrada e novo disparo. Referências fracas confirmaram a liberação da sala e do projétil. Um Aren e uma HUD permaneceram com as mesmas identidades, uma única sala residente e contagem estável das conexões de morte. Os períodos de ataque da IA e dos mecanismos novos são contadores de física no próprio nó. O código de distribuição não instancia Timer nem Tween. A execução verificou o efeito funcional da descarga e a ausência de disparo atrasado no caso do Acólito. Não instrumentou todos os callbacks de animação nem morte por hitbox de armadilha em cada CP. A primeira tentativa da própria suíte confundiu HP herdado e espera de respawn com defeitos. As fixtures agora restauram HP na preparação e aguardam o fim real do carregamento após a morte.

Nos pontos equivalentes de 12 e 48 trocas, havia 98 nós e 1.731→1.730 objetos. O ensaio não mostrou crescimento nessa janela. A suíte de distribuição voltou a emitir aviso ObjectDB de quatro instâncias no encerramento. A ressalva histórica dos sete RefCounted em carregamento assíncrono continua aberta. A comparação não atribui identidade comum aos avisos. O diagnóstico de certificados do Windows voltou a ocorrer.

## Jornada e regressões atuais

A jornada ativa FIX01 foi reexecutada com saída 0. Aren fez 1→12→1, 22 transições, acionou os sete checkpoints e passou de 5 a 1 HP sem morrer. S8 passou sem perder vida nos dois sentidos. O teste também verificou a liberação da sala anterior.

A suíte de distribuição passou 157/157, incluindo as provas de ativação e respawn dos sete CPs com morte induzida. Passaram smoke 14, combate 36, sobrevivência 59, Guardião 59/152/59, piloto 357, estrutura 105, M5-C1 41/46/116/78, M5-C2 115/239, continuidade 118 e teto 7. As verificações não são independentes entre suítes. O teste estrutural legado da jornada não foi repetido. A última medida estrutural, 17.360,4052 px, pertence ao FIX01. As capturas e o benchmark 4K também são históricos. Não houve mudança de gameplay, carregamento ou renderização nesta rodada.

Comandos executados na Godot 4.7.2 com `--path . --headless --fixed-fps 60 --log-file <log> --script <teste>`, usando `res://tests/m5_c3_journey_test.gd`, `res://tests/m5_c3_lifecycle_test.gd` (também `--verbose`) e o script externo `encounters.gd`. A distribuição foi executada com `res://tests/m5_c3_distribution_test.gd`. Os comandos individuais de regressão constam no JSON. Continuidade e teto foram executados com renderização.

Evidências no diretório `m5c3-fix02`, incluindo `journey.log`, `encounters.log`, `lifecycle-complete.log`, `distribution.log` e `regression-results.json`. Sem staging, commit ou push. M5-D e M6 permanecem fora do escopo.

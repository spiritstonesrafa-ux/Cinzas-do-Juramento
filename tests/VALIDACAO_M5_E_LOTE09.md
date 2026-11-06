# M5-E — Lote 09: atalhos da Abadia

**Atualização posterior:** o responsável realizou o playtest e informou “Tudo OK”, homologando os três atalhos e o M5-E visual e funcionalmente. Os resultados e limitações técnicas abaixo permanecem históricos; essa aprovação não representa nova execução automatizada.

O responsável informou a homologação visual e funcional dos seis percursos opcionais O1–O6. Os três atalhos abaixo foram implementados; a homologação humana dos atalhos e do M5-E permanece pendente.

## Implementação e condições

As portas usam arquitetura existente, sem alterar as superfícies da espinha ou a física global de Aren. As coordenadas são locais a cada setor e representam o piso no ponto de interação:

| Atalho | Lado anterior | Lado avançado | Corredor físico |
|---|---|---|---|
| A1 | S3 (1040, 300) | S4 (250, 276) | 192 px |
| A2 | S7 (1360, 324) | S8 (280, 284) | 208 px |
| A3 | S9 (1270, 228) | S11 (270, 564) | 1056 px |

Perto da porta, E mostra o estado e, após cumprir os requisitos, abre a ligação pelo lado avançado; outro E entra. A passagem possui piso com colisão e precisa ser percorrida. Nas extremidades utiliza a transferência de sala preexistente; não contabilizamos a mudança de coordenadas dessa transferência como deslocamento. A trava impede logicamente a instanciação da passagem antes do desbloqueio, e o destino é conferido para segurança de reaparecimento. A porta é decorativa: não se trata de uma parede física adicionada ao percurso principal.

O setor avançado precisa ter sido concluído pela saída normal e ambos os setores visitados. A3 exige também visita a S10. Desbloqueios, visitas e conclusão ficam em memória de sessão, preservados na morte e no retorno por queda; F7 inicia outra sessão. Não foi adicionado salvamento em disco.

## Medição física

As distâncias abaixo somam deslocamentos de Aren medidos em quadros de física, descontando as mudanças de coordenadas entre salas. A rota normal inclui manobras e saltos do controlador de teste com perigos ativos; não é garantia de trajeto ótimo. O atalho foi percorrido em ambos os sentidos, com resultado simétrico na amostra.

| Atalho | Caminho normal (px) | Caminho pelo corredor (px) | Economia observada (px) |
|---|---:|---:|---:|
| A1 | 406,73 | 159,76 | 246,97 |
| A2 | 360,48 | 174,74 | 185,74 |
| A3 | 1596,91 | 1023,41 | 573,50 |

Cada economia observada é inferior a 960 px; a soma aritmética das três, 1006,21 px, supera essa meta histórica em 46,21 px. Somar ensaios independentes não comprova a menor jornada completa após desbloqueio. A geometria principal histórica de 17.360,42 px não foi reduzida nem novamente medida nesta etapa. A primeira passagem obrigatória, incluindo S10, permanece exigida antes da abertura.

## Validação e matriz

- `m5_e_lote09_segment_journey.gd`: três trechos executados fisicamente a partir da entrada do setor anterior, com ameaças ativas; verificados bloqueio, conclusão, visita a S10 para A3, desbloqueio, retorno pela rota principal e três travessias alternadas de cada corredor. Os testes de cada trecho usam uma cena nova e uma entrada inicial preparada; não constituem uma única jornada contínua por toda a Abadia.
- `m5_e_lote09_shortcut_fixture.gd`: portas bloqueadas, condições de progressão, ida e volta dos três pares, dano letal e reaparecimento reais. A queda foi induzida por posição fora dos limites, acionando o tratamento real; não é uma trajetória de queda controlada pelo jogador. Três desbloqueios permaneceram após morte e queda. O fixture prepara posições e estado para testes isolados.
- A1, A2 e A3: evidência funcional e vantagem medidas; **PASS técnico nos cenários ensaiados**, sujeito às limitações acima e à homologação do responsável. O1–O6: homologados pelo responsável, com regressões relacionadas registradas abaixo. Seis inscrições: resultados prévios preservados, sem nova homologação inferida. Ausência universal de softlock não é demonstrável por esses ensaios.
- Capturas reais em `tests/evidencias/m5_e_lote09_A{1,2,3}_{1280x720,1920x1080,2560x1440,3840x2160}.png`: quadros dos corredores durante ensaio físico; o movimento foi pausado apenas para trocar a resolução e capturar. Avaliação estética e conforto da câmera dependem do playtest.

## Regressão executada

- O1 (`m5_e_lote06_o1_journey.gd`) e O2–O6 (`m5_e_lote08_o2_test.gd` a `o6_test.gd`): código 0, sem falhas registradas. O teste de salto breve passou 15/15 verificações.
- Jornada principal (`m5_c3_journey_test.gd`): os 12 setores foram percorridos nos dois sentidos, com código 0.
- Distribuição e mecanismos (`m5_c3_distribution_test.gd`): 157/157, incluindo ativação e respawn dos sete checkpoints e verificações de combate. Os logs estão em `.godot/lote09-*.log` (diretório de cache local).
- Renderização real OpenGL em quatro resoluções: as 12 imagens foram geradas durante os três ensaios físicos; após identificar uma borda vazia, o preenchimento visual foi corrigido e as capturas e o ensaio completo foram repetidos. Diagnósticos de perfil/certificados e aviso ObjectDB registrados no log; execução retornou 0.

## Integridade, ressalvas e próximos passos

Os 15 arquivos da lista protegida coincidem por SHA-256 com `m5c3-20261104-01/baseline.json`. Não foi alterada a geometria principal. As ressalvas históricas do M5-C3 e ObjectDB permanecem: avisos de instâncias ObjectDB no encerramento foram novamente observados; não foram investigados nesta etapa. O ambiente também relatou certificados e escrita do log no perfil. Os avisos não foram confundidos com aprovação de testes.

Os arquivos alterados para o lote são `scripts/abbey/chapter.gd`, `scripts/abbey/chapter_sector.gd`, os novos `scripts/abbey/m5e_shortcuts.gd` e `scripts/abbey/m5e_service_passage.gd`, testes `tests/m5_e_lote09_*.gd`, capturas e este relatório, além do registro de homologação em `docs/PLANEJAMENTO_M5_E.md` e `tests/VALIDACAO_M5_E_LOTE08.md`. Estes arquivos compartilham modificações anteriores do M5-E já existentes; a lista não afirma que todo o conteúdo deles surgiu neste lote. `m5_e_lote09_journey.gd` é ensaio exploratório anterior, não constitui evidência final.

Playtest: iniciar a Abadia por F6; para cada par, confirmar porta bloqueada no lado inicial e avançado, percorrer normalmente até sair do setor avançado, retornar, abrir com E e atravessar em ambas as direções. Em A3 visitar S10 e concluir S11 antes de abrir. Depois morrer, reaparecer e testar uma queda, conferindo que os atalhos permanecem abertos; F7 inicia nova sessão. Avaliar sinalização, legibilidade, câmera, colisões e conforto nos corredores. Não considerar M5-E homologado até essa avaliação.

Git final: branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`, índice vazio e 101 entradas no status, incluindo alterações e arquivos não rastreados preexistentes e desta entrega. `git diff --check` não apontou erros; Git avisou sobre conversão futura LF/CRLF em `project.godot`, que permanece com o hash protegido. Sem staging, commit, push ou deploy; M5-F não iniciado.

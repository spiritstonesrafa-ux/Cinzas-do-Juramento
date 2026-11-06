# SAVE-SAFETY-01 — persistência de recompensas

**Estado: implementação local testada; sem homologação automática.** O desaparecimento histórico do save permanece sem causa comprovada. A implementação anterior removia o arquivo principal antes de mover o novo: falha nesse intervalo poderia deixar a pasta sem o único save válido. Além disso, JSON inválido era tratado como dicionário vazio em uma das versões locais. Nenhuma dessas hipóteses comprova o evento histórico.

## Protocolo

`scripts/abbey/abbey_progress.gd` continua utilizando `user://cinzas_abbey_progress_v1.json` e mantém as duas recompensas e campos desconhecidos do JSON. Saves legados versão 1 sem os novos metadados continuam aceitos.

1. Uma `Mutex` no processo e a criação exclusiva de um diretório `.lock` coordenam escritores que usam este protocolo. Outra gravação concorrente é recusada; não há espera nem limpeza automática de trava antiga.
2. Os candidatos principal e backups são lidos e validados. Flags conhecidas precisam ser booleanas. A maior `_save_revision` válida vence; dados diferentes empatados na maior revisão tornam a seleção ambígua e a escrita é recusada. Um save legado sem revisão equivale a revisão zero.
3. O novo JSON, que conserva campos desconhecidos, recebe revisão e `_save_checksum` SHA-256 sobre conteúdo normalizado. É escrito em nome temporário único, descarregado, fechado e relido para comparação. Um temporário incompleto ou não confirmado não é promovido pela recuperação.
4. Antes de substituir um principal existente, uma cópia independente da última versão válida é escrita em nome único e relida. No primeiro save, uma cópia é criada após a gravação e verificação do principal. Backups não são reutilizados nem apagados automaticamente.
5. O temporário é renomeado para o principal e o conteúdo final é relido e verificado. Um principal inválido é mantido em arquivo de quarentena antes da substituição, somente se houver outra versão válida. Falhas retornam `false`; a cópia válida anterior permanece disponível quando a etapa de backup foi concluída.
6. Se o principal estiver ausente ou inválido, `read_progress()` usa o backup válido de maior revisão sem alterar arquivos. Uma concessão posterior de recompensa reconstitui o principal a partir dessa versão. Sem versão válida ou em caso de empate conflitante, nenhuma recompensa é inventada e a gravação é recusada.

O checksum detecta alterações acidentais em saves novos; não é assinatura contra adulteração deliberada. Saves legados sem checksum não ganham essa proteção retroativamente até serem atualizados. A escolha de um backup mais antigo pode perder eventos que só existiam em um principal corrompido e irrecuperável.

## Limites reais

`FileAccess.flush()` e a leitura posterior detectam vários erros, mas `close()` não devolve código de erro independente; a API usada não comprova persistência física da unidade ou diretório após queda de energia. `DirAccess.rename_absolute()` informa sucesso/falha e foi exercitado no Windows desta máquina, mas não se promete substituição atômica ou durabilidade universal. Ver [FileAccess](https://docs.godotengine.org/en/4.5/classes/class_fileaccess.html) e [DirAccess](https://docs.godotengine.org/en/4.6/classes/class_diraccess.html).

A trava só coordena processos que respeitam o protocolo; não impede editores externos, versões antigas do jogo ou testes que alterem arquivos diretamente. Uma interrupção pode deixar a pasta `.lock`: a gravação fica recusada até sua remoção manual, após confirmar que nenhum processo está gravando e preservar os arquivos. Temporários, quarentenas e backups se acumulam; não existe política automática de limpeza. A falha histórica de energia e perda do único save continua não reproduzida.

## Proteção de testes

`tests/recompensa_guardiao_test.gd`, `tests/abbot_cinematic_test.gd`, `tests/recompensas_visual_capture.gd`, `tests/dash_visual_capture.gd` e `tests/m5_g_invalid_save_test.gd` agora recusam execução sem `SAVE_SAFETY_ISOLATED_ROOT` correspondente ao diretório de usuário isolado e recusam o caminho pessoal padrão do Windows. Os testes que limpam arquivos fazem isso somente após essa verificação e incluem os backups do fixture. Eles são alterações de arquivos locais preexistentes; não apagam o perfil pessoal.

## Testes executados

Godot 4.7.2 no Windows; cópia isolada da candidata, `APPDATA` dedicado por teste, `SAVE_SAFETY_ISOLATED_ROOT` igual à raiz isolada. O script de teste também verifica o caminho real de `OS.get_user_data_dir()` antes de limpar fixtures. Comando-base: `Godot_v4.7.2-stable_win64_console.exe --headless --path <candidata> --script res://tests/<teste>.gd`.

| Teste | Resultado |
| --- | --- |
| `save_safety_01_test.gd` | **44/44**: criação, cópia inicial, atualização, erro de escrita simulado, temporário parcial, interrupções, erro real de renomeação para destino inválido, backups, recuperação, checksum, JSON inválido, legado de 56 bytes, campos desconhecidos, revisão maior, empate ambíguo e trava já existente. As falhas de escrita são simulações controladas, não falhas físicas de disco. |
| `save_safety_01_restart.gd` | Gravação em um processo e leitura em outro: dash ativo, vida máxima 6 e revisão inalterada após pedidos duplicados. |
| `recompensa_guardiao_test.gd` | **33/33** com perfil isolado; melhoria única e compatibilidade com legado. |
| `abbot_cinematic_test.gd` | **26/26** com perfil isolado; vitória do Abade, dash e retorno. A primeira tentativa não carregou um script local não rastreado que faltava à candidata; após incluir a dependência na cópia isolada, a execução acima passou. |
| Proteção do teste do Guardião | Sem marcador de isolamento, recusou execução com código 2, em perfil descartável. |
| `m5_g_invalid_save_test.gd` | Passou na versão de persistência anterior ao acréscimo final de checksum e backup inicial; a cobertura equivalente de JSON inválido foi repetida na bateria 44/44 final. |

Os avisos esperados para conflito e trava foram observados. A engine também emitiu o diagnóstico ambiental histórico de certificados; o teste do Abade terminou com quatro avisos históricos de ObjectDB. Não houve execução dos testes com o perfil pessoal.

## Arquivos e segurança

- Alterado: `scripts/abbey/abbey_progress.gd`; testes locais citados em Proteção de testes.
- Novos: `tests/save_safety_01_test.gd`, `tests/save_safety_01_restart.gd` e este relatório.
- Save pessoal antes e depois: **56 bytes**, SHA-256 `DFCAEFA0CE82A0E25852789596CDA63F394A85C05F8511D3D7D6A7D575DA2293`. Não foi modificada nem adicionada a recompensa do Guardião ao perfil pessoal.
- Os 15 arquivos protegidos conferiram sem divergências. Branch `main`, HEAD `2ac02cf0344b5fa5fc447b301cfdd8bae397be43`, índice vazio. As demais alterações locais existentes foram preservadas.
- Não houve staging, commit, push, deploy ou início de M6-B.

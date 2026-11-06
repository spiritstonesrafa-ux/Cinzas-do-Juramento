# M5-G FIX03 — acesso ao Abade pela campanha

**Estado: correção implementada e testes automatizados aprovados; playtest do responsável e acionamento manual de F6 ainda pendentes. M5-G não está homologado.**

## Causa

O gatilho da saída normal de S12 já chamava a arena para uma progressão sem vitória. Porém, se `AbbeyProgress.unlocked()` reconhecesse o arquivo `user://cinzas_abbey_progress_v1.json` com vitória e dash, a saída marcava `completed` e não chamava a arena. A rotina da HUD então apresentava a mensagem legada “Fim da versão estrutural da Abadia — M5-B.” O mesmo registro é lido ao criar Aren e explica o dash inicial quando há vitória salva. Não foi inspecionado nem alterado o save pessoal do responsável, portanto não se afirma que ele contenha esse estado: é a explicação compatível com o comportamento observado.

O gatilho exige alcançar a coordenada de saída do setor 12, estar na altura da saída e voltado para a direita. A arena é instanciada pelo capítulo a partir de `abbot_arena.tscn`; o mesmo Aren é levado à entrada após desativar e descarregar o setor. `reset_to` cancela ataque e dash em andamento, mas não restaura vida nem troca checkpoint. A câmera é posicionada na arena e os checkpoints ficam desativados enquanto ela está carregada. Em morte, a rotina existente recarrega o setor do checkpoint e realiza o respawn.

## Mudança

A saída passa a abrir a arena também com vitória persistida. Nesse caso o Abade é instanciado já derrotado, com fonte de dano desativada, e a instrução E permite voltar ao Coro. Sem vitória, a luta permanece normal e o dash continua bloqueado até a recompensa ser salva. A aproximação ao extremo do Coro informa que a arena está à direita; a mensagem estrutural antiga deixou o fluxo. Não foram alterados balanceamento, arte, efeitos, dano ou física.

Arquivos de implementação alterados: `scripts/abbey/chapter.gd` e `scripts/abbey/abbot_arena.gd`. Teste anterior `tests/m5_g_abbot_test.gd` atualizado para verificar a revisita à arena em vez do encerramento legado; novo `tests/m5_g_fix03_completed_test.gd` verifica retorno e preservação de estado. Todos os arquivos tinham as alterações locais anteriores preservadas.

## Verificações realizadas

Godot 4.7.2, cópia isolada do projeto e perfis APPDATA separados:

- Inicialização direta da cena real do capítulo por 120 quadros, código 0.
- Perfil novo sem recompensa: dash inicialmente bloqueado, PASS.
- `m5_g_full_journey_test.gd`: percorreu S1–S12 por entradas, entrou na arena pela saída real, venceu com ataques e ameaças ativos, viu dash do Abade e obteve o dash; restaram 2 de vida. Não houve teletransporte para a arena nem carregamento direto da cena.
- Em **outro processo**, com o save produzido nessa jornada: persistência, cooldown, bloqueio por parede e ausência de invulnerabilidade no dash passaram.
- Com o mesmo save, `m5_g_fix03_completed_test.gd` preparou uma posição em S12 como fixture e atravessou a saída com movimento real: vitória e dash reconhecidos, Abade derrotado e desarmado, HP e CP7 mantidos, retorno com E, sem reentrada automática nem mensagem M5-B: 8 verificações PASS. Também passou com perfil que havia vencido na sessão anterior.
- `m5_g_respawn_test.gd`: CP7, morte, ausência de recompensa indevida e reentrada passaram.
- `m5_g_abbot_test.gd`: combate com controles, vitória, recompensa, retorno e revisita da arena concluída passaram.

As simulações carregaram a mesma cena de capítulo usada pelo F6, mas não acionaram fisicamente F6 no editor. A janela da Godot do responsável estava aberta com uma sessão de jogo, e não foi usada para evitar operar sobre o perfil pessoal. Assim, **a execução manual por F6 e a clareza da entrada no percurso visual ainda precisam ser conferidas no playtest**. Os testes não provam ausência de softlock em todos os estados. O diagnóstico de certificados e o aviso histórico de três instâncias ObjectDB apareceram na saída; não foram reabertas auditorias históricas.

## Segurança e estado

Os 15 hashes protegidos coincidiram com `m5c3-20261104-01/baseline.json` antes e após. Nenhum save pessoal foi lido, apagado ou modificado; os testes usaram perfis descartáveis separados. Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`, alterações locais anteriores preservadas. Sem staging, commit, push ou deploy.

Para o playtest: reiniciar a cena aberta no editor com F6 para carregar os scripts atualizados; seguir até S12, observar a indicação da arena e entrar pela direita. Em um save já concluído, conferir o dash e o Abade derrotado, pressionar E e verificar o retorno. A experiência de uma campanha nova deve ser testada em um perfil separado, sem apagar o progresso pessoal.

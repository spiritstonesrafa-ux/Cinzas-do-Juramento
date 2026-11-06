# M5-G FIX04 — perfis isolados de playtest

O F6 da cena normal usa o diretório `%APPDATA%\Godot\app_userdata\Cinzas do Juramento`. O arquivo `cinzas_abbey_progress_v1.json` existente nesse perfil contém versão 1, vitória e dash ativados. Isso explica a aparição do Abade derrotado e o dash. O arquivo não registra a origem da vitória: os testes recentes documentados usaram APPDATA isolado, mas não é possível provar quem criou o registro atual. Ele não foi alterado.

## Como jogar

Abra o PowerShell e entre no projeto:

```powershell
Set-Location 'C:\PROJETOS\CINZAS DO JURAMENTO'
```

Para iniciar diretamente a batalha com um perfil novo:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\playtest_m5g.ps1 -Cenario Boss
```

Para iniciar a campanha com outro perfil novo:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\playtest_m5g.ps1 -Cenario Campanha
```

O jogo abre pela Godot instalada no caminho configurado no script. A janela de PowerShell mostra o nome do perfil e o comando para retomá-lo; por exemplo:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\playtest_m5g.ps1 -Cenario Boss -Perfil NOME_MOSTRADO
```

Retomar o mesmo perfil preserva a recompensa e, após a vitória, o Abade aparece derrotado. Para enfrentá-lo novamente vivo, execute o primeiro comando **sem** `-Perfil`, criando outro perfil. Para usar outra instalação da Godot, acrescente `-Godot 'C:\caminho\Godot.exe'`.

Antes da vitória, F7 reinicia o cenário direto no mesmo perfil com o Abade vivo; depois da vitória, o progresso permanece salvo.

Os perfis são pastas em `.godot\playtest-m5g\`, que é cache ignorado pelo Git; não são destinados a armazenamento permanente e desapareceriam caso essa pasta fosse apagada. O inicializador altera APPDATA somente no processo iniciado e restaura o ambiente de quem o chamou. F6 no editor aberto continua usando o perfil normal e seu progresso permanece intacto. A cena especial de boss recusa execução fora do inicializador isolado.

## Implementação e verificação

`scenes/dev/m5g_boss_playtest.tscn` estende o capítulo real; `scripts/dev/m5g_boss_playtest.gd` inicia S12 e a arena, sem alterar o combate. O inicializador `tools/playtest_m5g.ps1` gera um nome único por padrão ou retoma o nome solicitado. Um perfil separado de campanha usa a cena normal.

Em cópia isolada, Godot 4.7.2:

- Inicializador Boss novo: arena ativa, vida 5/5, dash bloqueado, Abade 10/10.
- Inicializador Campanha novo: cena abriu; teste independente confirmou dash bloqueado.
- No perfil de campanha criado pelo inicializador, a jornada automatizada atravessou os 12 setores, venceu com golpes reais e obteve o dash; outro processo confirmou a persistência.
- `m5_g_fix04_boss_test.gd`: duas fases e dash ofensivo observados, vitória com controles e golpes reais, recompensa obtida.
- Inicializador reaberto no mesmo perfil premiado: arena ativa, dash disponível e Abade 0/10. Outro perfil de campanha permaneceu sem dash.
- F7 no cenário direto antes da vitória voltou à arena com Abade 10/10 e dash bloqueado.
- Abertura direta da cena especial sem isolamento foi recusada com código 1, antes de iniciar o capítulo.
- O SHA-256 do save normal foi `DFCAEFA0CE82A0E25852789596CDA63F394A85C05F8511D3D7D6A7D575DA2293` antes e depois. Os 15 arquivos protegidos coincidiram com o baseline.

Os testes dirigidos usam perfis de teste e não demonstram diversão ou dificuldade percebida. Os avisos históricos de certificados e ObjectDB ocorreram também nesta execução. A homologação visual e de dificuldade do M5-G continua com o responsável.

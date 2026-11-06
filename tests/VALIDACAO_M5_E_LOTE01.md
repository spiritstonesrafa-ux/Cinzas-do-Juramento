# M5-E — Lote 01: validação da inscrição do Claustro

**Homologação visual:** o responsável aprovou a pista e a adotou como referência de qualidade para a continuidade do M5-E. A aprovação foi informada pelo responsável e não representa nova execução de testes automatizados.

**Situação atual: PASS técnico do lote; homologação visual do responsável pendente.** A finalização abaixo substitui o bloqueio da avaliação anterior: há agora capturas da aproximação, salto e caminhada com movimento real nas quatro resoluções. A percepção e a integração artística da pista continuam sujeitas ao playtest humano; M5-E não está concluído.

## Baseline e preservação

Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`. Os 15 arquivos protegidos foram comparados ao inventário de hashes de referência, sem divergências. O planejamento M5-E e a alteração local anterior de `ROADMAP.md` foram preservados. As ressalvas históricas dos sete encontros M5-C3 e ObjectDB continuam vigentes. A geometria principal, os 12 setores, os sete checkpoints e os sistemas homologados não foram alterados; o valor histórico de 17.360,42 px não foi medido novamente nesta etapa.

## Implementação e localização

- `scripts/abbey/chapter.gd`: indicação contextual e estado de sessão independente da flag `discovered` de Votos sem Nome.
- `scripts/abbey/chapter_sector.gd`: instancia a marca apenas no setor 2.
- `scripts/abbey/m5e_names_relief.gd`: traços decorativos sem colisão no segundo patamar opcional, próximo de `(867,108)` local.
- `tests/m5_e_lote01_test.gd`: teste físico e capturas; este relatório registra seus limites.

No Claustro Fraturado, siga pela rota principal e enfrente ou evite o Monge. Próximo ao topo da escadaria, use os dois primeiros patamares acima do caminho, à esquerda do monumento Votos sem Nome. Ao aproximar-se da inscrição surge na faixa contextual: “Nomes riscados: seus votos ainda sustentam estas pedras.” Não há novo botão; a indicação reaparece por proximidade e o estado permanece enquanto a instância do capítulo existir. A marca original de Votos sem Nome e sua flag continuam separadas. Desça à esquerda para voltar à rota principal; o checkpoint existente fica adiante à direita. Nenhuma extensão adicional de 360 px é reivindicada.

## Resultados reais

- Godot 4.7.2, com física e entradas reais: acesso a partir da entrada do setor, combate com Monge ativo, pouso nos dois patamares, texto, separação de Votos sem Nome, câmera próxima ao alvo, retorno à rota e ativação física do checkpoint S2: **10 verificações passaram**. A entrada de S2 foi instalada pela troca normal de sala do controlador antes de iniciar o percurso, não houve teleporte após essa entrada.
- Pilotos M5-A: **357/357**. Distribuição M5-C3: **157/157**; esta é regressão direcionada, não reabertura das provas inconclusivas.
- Continuidade gráfica: **118/118**, executada com renderização. Uma tentativa anterior sem interface falhou na exigência de renderização e foi interrompida; não é prova gráfica válida.
- Capturas da descoberta em 1280×720, 1920×1080, 2560×1440 e 3840×2160 foram geradas com renderização após a última alteração visual. As imagens são quadros parados; não comprovam legibilidade durante movimento em todas as resoluções. O ensaio físico inclui movimento e salto, mas não substitui essa avaliação visual.
- Godot registrou falha ao ler certificados raiz do ambiente e aviso de três instâncias ObjectDB ao terminar o teste do lote; não se conclui a causa do aviso nem se declara resolvida a pendência histórica.

As evidências estão em `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote01/`, arquivos `descoberta-1280x720.png`, `descoberta-1920x1080.png`, `descoberta-2560x1440.png` e `descoberta-3840x2160.png`. Logs em `.godot/m5e-lote01-visual.log`, `.godot/m5e-abbey_pilot_test.log`, `.godot/m5e-m5_c3_distribution_test.log` e `.godot/m5e-continuity-graphical.log`.

## Checklist de playtest

1. Abra `scenes/abbey/abbey_chapter.tscn` na Godot e pressione F6; F5 permanece a campanha original.
2. Entre no setor 2, lide com o Monge e observe a indicação da rota superior. Suba os dois primeiros patamares e procure a marca discreta no segundo.
3. Aproxime-se, leia a mensagem e afaste-se; volte para verificar que ela reaparece sem repetir efeitos ou interromper controles.
4. Continue até Votos sem Nome e confirme que o monumento segue distinto; retorne à esquerda ou desça à rota principal.
5. Confira o checkpoint adiante, a câmera e a clareza da pista durante movimentos e saltos nas quatro resoluções, especialmente 4K. Avalie se a marca é perceptível sem ser excessiva.

## Git

Alterações deste lote permanecem locais e sem staging, commit ou push. Além dos quatro arquivos do lote e deste relatório, permanecem o planejamento M5-E, o roadmap e os 15 arquivos protegidos preexistentes. Não foram iniciados os demais lotes, atalhos ou M5-F.

## Finalização da legibilidade

A marca anterior consistia em linhas finas sobre o mesmo desenho da plataforma, com pouca separação visual. A alteração em `scripts/abbey/m5e_names_relief.gd` acrescenta uma pequena placa escura, contorno de pedra e riscos claros desgastados na face do mesmo patamar. Não há seta nova, brilho, colisão, mudança de câmera ou interação. A marca pode ser vista a partir da aproximação e durante o salto; sua adequação estética e facilidade de descoberta ainda são subjetivas e dependem do responsável.

O teste `tests/m5_e_lote01_test.gd` foi ampliado para registrar quadros reais durante a execução, após o desenho da Godot. Em cada resolução, ele registrou caminhada de aproximação no solo, salto ascendente e caminhada de retorno no patamar: velocidades observadas, respectivamente, `(100,0)`, `(100,-82,67)` e `(-80,0)` px/s; no salto o personagem estava sem apoio. A cena foi carregada normalmente, a sala 2 aberta pelo controlador e o restante da prova executado com inputs reais. A câmera acompanhou Aren. O teste completo passou nas quatro execuções: acesso, Monge ativo, dois pousos, texto, separação de Votos sem Nome, câmera, retorno, checkpoint e sete checkpoints. As capturas são quadros de momentos reais, não vídeo contínuo ou homologação humana.

Evidência **antes**: `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote01/descoberta-1920x1080.png` (parada). Evidências **depois**: diretório `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-final/`, com `aproximacao-`, `salto-` e `caminhada-` para cada um dos sufixos `1280x720.png`, `1920x1080.png`, `2560x1440.png` e `3840x2160.png`. Logs: `.godot/m5e-final-1280.log`, `m5e-final-1920.log`, `m5e-final-2560.log` e `m5e-final-3840.log`. Os resultados históricos 357/357, 157/157 e 118/118 acima não foram repetidos nesta alteração exclusivamente visual.

Os logs voltaram a registrar o erro de leitura de certificados e o aviso de três instâncias ObjectDB no encerramento; não houve nova investigação de causa. Os 15 hashes protegidos foram novamente conferidos. Índice vazio, branch e HEAD inalterados; alteração local adicional do planejamento documenta a proposta de lote conjunto para S3, S5, S7, S9 e S10. Não há staging, commit, push ou deploy.

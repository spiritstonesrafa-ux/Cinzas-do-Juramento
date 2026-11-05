# M5-C2 — perigos ambientais da Abadia

**M5-C2 — HOMOLOGADO FUNCIONAL E VISUALMENTE PELO RESPONSÁVEL; AUDITORIA TÉCNICA APROVADA COM RESSALVAS.** Playtest informado: **16/16 PASSOU, nenhuma observação**. Reteste posterior da correção do sensor da comporta: **2/2 PASSOU, nenhuma observação**. A ressalva histórica ObjectDB permanece aberta, com origem inconclusiva; detalhes em `tests/VALIDACAO_M5_C2_AUDITORIA.md`. M5-A e M5-B permanecem homologados. M5-C1 está homologado e commitado localmente. M5-C3 não foi iniciado.

### Playtest manual informado — 16/16

1. Prensa: aparência e animação preservadas do M5-A — PASSOU.
2. Prensa: aviso e janela segura — PASSOU.
3. Prensa: dano evitável e travessia — PASSOU.
4. Pêndulo: arte e balanço — PASSOU.
5. Pêndulo: aviso e previsibilidade — PASSOU.
6. Pêndulo: travessia segura — PASSOU.
7. Comporta: aparência e movimento mecânico — PASSOU.
8. Comporta: proximidade e tempo de reação — PASSOU.
9. Comporta: área de dano e reset — PASSOU.
10. Jato: arte, efeito de incenso e animações — PASSOU.
11. Jato: pulsos e intervalos — PASSOU.
12. Jato: dano evitável e limites — PASSOU.
13. Integração: quatro mecanismos acessíveis — PASSOU.
14. Integração: morte e respawn seguros — PASSOU.
15. Integração: F7 — PASSOU.
16. Integração: qualidade visual e fluidez em 4K — PASSOU.

O responsável não relatou observações. Esta é a homologação humana informada; não equivale aos testes automatizados. Após a correção da condição de proximidade da comporta, o responsável informou novo playtest: **fora do sensor por mais de dois segundos — PASSOU; aproximação, aviso e fechamento — PASSOU**. Nenhuma observação foi relatada.

## Baseline e planejamento

Branch `main`, HEAD inicial `149c02e06b7f9309e766209ed8e30abafdd67556`; índice vazio. `project.godot` e os 14 arquivos locais anteriores permanecem fora da entrega. O documento histórico `planejamento-capitulo-02/PLANEJAMENTO_CAPITULO_02.md`, §13, lista **quatro famílias novas e duas reutilizadas**, 12 dispositivos propostos. `tests/VALIDACAO_M5_A.md`, §7, identifica a Prensa de Contrapeso homologada como variante da família prensa de moldes frios, não como pêndulo.

| Família canônica | Estado anterior | M5-C2 |
|---|---|---|
| Contrapeso pendular | Pendente | Cena própria experimental |
| Comporta votiva | Pendente | Cena própria experimental |
| Jato de incenso abrasivo | Pendente | Cena própria experimental |
| Prensa de moldes frios | Prensa de Contrapeso homologada | Cena homologada reutilizada sem alterações |
| Lâmina oscilante | Existente | Preservada, fora da demonstração |
| Perigo temporizado | Existente | Preservado, fora da demonstração |

Não há distribuição definitiva nos 12 setores nesta entrega.

## Mecanismos

Cada novo mecanismo deriva de `DamageSource` e usa o receptor e a invulnerabilidade de Aren existentes. Dano: **1 PV**, uma aplicação por pessoa e ciclo. Estados: SAFE → WARNING → ACTIVE → RECOVER → SAFE. Ao morrer, a estação desarma; no respawn, a sala do checkpoint é recriada em estado seguro. Ao descarregar, sala e hitbox são liberadas.

| Família | Ativação | Seguro / aviso / ativo / recuperação | Área de dano | Leitura e resposta |
|---|---|---|---|---|
| Contrapeso pendular | Cíclica | 1,8 / 0,8 / 1,2 / 1,4 s | Retângulo 24×24 acompanhando massa de x −30 a +30 | Linha mostra varredura; aguardar ou recuar. Retorno ocorre sem dano durante recuperação. |
| Comporta votiva | Proximidade a menos de 85 px após 1,6 s seguros | 1,6 / 0,8 / 0,5 / 1,5 s | Retângulo 20×48, centrado em y −24 | Trava recua; a faixa mostra fechamento. Aguardar ou sair do alcance. |
| Jato de incenso abrasivo | Cíclica | 1,8 / 0,8 / 0,7 / 1,4 s | Retângulo 40×16, x 18 a 58, y −24 a −8 | Linha antecipa o tubo; atlas animado de fumaça e marcas nos limites superior/inferior indicam o pulso à direita. Aguardar, recuar ou atravessar durante segurança. |

Tempos são parâmetros nominais; a suíte mediu a janela ativa com tolerância de dois frames. A travessia em ambos os sentidos durante segurança foi feita por inputs e física reais. A composição e a legibilidade em movimento ainda precisam de avaliação do responsável. A área da comporta é fonte de dano e não é um bloqueio físico permanente.

## Demonstração e arte

Abrir `res://scenes/abbey/abbey_hazards_demo.tscn` no Godot e pressionar **F6**. Estações da esquerda para a direita: Prensa homologada, pêndulo, comporta, jato. A/D movimenta, espaço salta, J ataca; **F7** reinicia a demonstração. Cruzar o limite direito passa à estação seguinte; o esquerdo retorna. Os checkpoints são locais à demonstração; F5 mantém a campanha principal.

As quatro imagens originais e sua origem estão em `assets/art/m5c2/PROVENANCE.md`. Movimento da massa, trava e lâmina da comporta são procedurais; o jato usa um atlas de quatro quadros. A qualidade artística final, transparência em movimento, correspondência percebida das hitboxes e leitura em TV permanecem para playtest. Não se afirma que as imagens estáticas comprovem todas as animações.

## Verificações realizadas

- Godot 4.7.2, `--headless --fixed-fps 60 --script res://tests/m5_c2_hazards_test.gd`: **115/115** verificações passaram. Exercitou Prensa original, estado seguro, aviso de pelo menos 0,6 s, duração ativa, dano real, invulnerabilidade, recuperação, dois ciclos, áreas imediatamente fora do limite com a hurtbox real de Aren, travessia segura e recuo por inputs, descarga de fonte ativa, reentrada, reset direto, morte em aviso/ativo/recuperação, checkpoint, respawn, F7 durante cada perigo ativo e consecutivo, e navegação de ida e volta.
- Dez amostras após aquecimento em reinserções equivalentes ficaram em **1601 objetos**; a suíte nova não emitiu aviso ObjectDB. Esta amostra limitada não demonstra ausência universal de vazamentos. A ressalva histórica de `RefCounted` no carregamento assíncrono da Abadia permanece aberta; não foi reaberta nem declarada resolvida.
- Regressão herdada: suítes executadas de M0, M1, sobrevivência, cemitério, alcançabilidade, esqueleto, corvo, distribuição, mecanismos, integração, Guardião, piloto M5-A, estrutura e capítulo M5-B passaram; funcional M5-B **2299/2299**, estrutura **105/105**, piloto **357/357**. M5-C1: **41/41, 46/46, 116/116 e 78/78**. FIX01 gráfico **118/118**; FIX02 **7/7**. Os conjuntos podem se sobrepor e não são somados como testes independentes.
- Gráfico: 48 capturas em janela nativa de 1280×720, 1920×1080, 2560×1440 e 3840×2160, quatro estados por família; amostras da comporta, do pêndulo e do jato foram inspecionadas em 1280×720. Não são teste físico na TCL nem inspeção completa em movimento. Capturas e logs estão no diretório de evidências indicado abaixo.
- Um ensaio de 60 s em janela 3840×2160 na RTX 2060 SUPER, com os três mecanismos separadamente e vida de Aren restaurada pelo instrumento: **59,90 FPS**, p95 **17,014 ms**, máximo **52,453 ms**, máximo 38 nós e 1588 objetos; após liberação, 1 nó e 1541 objetos. Outras verificações rodaram em paralelo, e o instrumento não mede todos os casos de F7, morte ou carga combinada. Não se pode concluir equivalência exata com o benchmark histórico de M5-C1.
- Ambiente: importação concluiu com os diagnósticos conhecidos de certificados e de gravação das configurações do editor. As suítes herdadas da Abadia voltaram a emitir avisos ObjectDB ao encerrar; FIX01 gráfico registrou cinco instâncias. Não houve erro de script no teste final M5-C2.

## Limitações e checklist para playtest

As amostras automáticas não cobrem todas as alturas de salto, todas as margens dos colisores, reinícios consecutivos em todas as combinações, estabilidade da câmera em movimento com cada estado, nem uma carga combinada de mecanismos. A revisão visual em movimento, justiça percebida e aceitação artística são humanas. Marcar **PASSOU / FALHOU / NÃO TESTADO**:

- Prensa: confirmar que funciona como na sala homologada.
- Pêndulo: aviso da varredura, movimento e retorno, intervalo seguro, dano e coerência visual da massa com a hitbox; observar e atravessar nos dois sentidos.
- Comporta: aproximação, trava e aviso, fechamento, recuperação, limites de dano e segurança dos dois lados.
- Incenso: válvula, aviso, nuvens e direção, início/fim do dano, recuo e travessia segura.
- Em todas as estações: aparência, animação e nitidez 4K; morte e respawn; F7; ida/volta; ausência de dano invisível ou travamento; fluidez.

## Arquivos e Git

Novos: `scenes/abbey/abbey_hazards_demo.tscn`, as três cenas `scenes/props/abbey_{pendulum,sluice,incense_jet}.tscn`, `scripts/abbey/m5c2_demo.gd`, `scripts/abbey/m5c2_hazard.gd`, seus UIDs, `tests/m5_c2_hazards_test.gd`, UID, e os quatro PNGs originais, imports e proveniência em `assets/art/m5c2/`. Evidências exclusivas: `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5c2-20261104-01`. Branch e HEAD permanecem os da base; nenhum staging, commit ou push foi executado.

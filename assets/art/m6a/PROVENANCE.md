# M6-A ART FIX03 — Proveniência e Especificação Técnica dos Assets da Floresta dos Ossos

Assets desenvolvidos e consolidados em 06/11/2026 para sanar em definitivo as colagens, recortes retangulares e duplicações visuais do FIX02, implementando uma arquitetura 100% modular, limpa e fidedigna à referência conceitual oficial (`media_1793989659838_5135ea43.jpg`).

## 1. forest_sector1_bg.png
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 1 (Entrada da Floresta).
- **Conteúdo:** Céu noturno tormentoso em tons de azul-petróleo escuro e índigo, névoa espectral ascendente, silhuetas do dossel ósseo distante e lua cheia velada.
- **Isolamento:** Fundo puro de paisagem distante. Não contém personagens, plataformas, HUD ou estruturas de primeiro plano.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08) preenchendo a tela sem emendas.

## 2. forest_sector2_bg.png
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 2 (Bosque das Raízes e Santuário do Cervo).
- **Conteúdo:** Céu noturno tormentoso com lua cheia luminosa, nuvens escuras rasgadas e névoa espectral verde-esmeralda fluindo sobre cordilheiras distantes.
- **Isolamento:** Fundo puro. O Santuário do Cervo NÃO foi queimado no céu desta imagem (evitando a duplicação do FIX02). O Altar do Santuário existe exclusivamente como elemento arquitetural no plano jogável.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08).

## 3. forest_materials.png
- **Dimensões:** 1024 × 512 px (RGBA 32-bit com transparência real)
- **Finalidade:** Atlas de materiais de terreno e superfícies jogáveis.
- **Regiões Fatiadas:**
  - `(0, 0, 512, 48)`: Segmento central modular de solo de raízes retorcidas, musgo denso e folhas carmesim, com linha de topo reta (alinhamento físico pixel-perfect com os colisores) e borda inferior orgânica em alfa.
  - `(512, 0, 128, 48)`: Extremidade esquerda (cap arredondado de musgo e raízes).
  - `(640, 0, 128, 48)`: Extremidade direita (cap arredondado de musgo e raízes).
  - `(0, 64, 512, 32)`: Ramos e galhos elevados de madeira e marfim petrificado para o caminho alto (altura física 12–14 px), com transparência total acima e abaixo.
  - `(0, 128, 256, 256)`: Preenchimento subterrâneo contínuo de terra profunda, rocha estratificada e raízes entrelaçadas (ladrilhado sem emendas).
  - `(256, 128, 64, 64)` a `(384, 128, 64, 64)`: 3 aglomerados isolados de cogumelos bioluminescentes (verde esmeralda / menta).
  - `(448, 128, 64, 64)` e `(512, 128, 64, 64)`: Espículas de ossadas e costelas saindo do solo.
  - `(576, 128, 64, 128)`: Véus de musgo espanhol e líquen suspenso.

## 4. forest_props.png
- **Dimensões:** 1024 × 512 px (RGBA 32-bit com transparência real)
- **Finalidade:** Atlas de estruturas decorativas e adereços monumentais isolados.
- **Regiões Fatiadas:**
  - `(0, 0, 240, 480)`: Árvore monumental de ossos de marfim petrificado com cavidades vertebrais e raízes âncora colossais, recortada com alfa 100% limpo.
  - `(260, 0, 360, 220)`: Arco colossal de costelas antigas cruzando o horizonte.
  - `(260, 240, 220, 180)`: Formação de chifres e estacas de ossadas ancestrais.
  - `(640, 0, 280, 360)`: Altar do Santuário do Cervo com degraus de pedra musgosa trabalhada, crânio monumental do cervo, velas votivas e braseiro sagrado para chama esmeralda (renderizado unicamente sobre o patamar do Setor 2).
  - `(940, 0, 64, 96)`: Brasão heráldico do Cervo Ancestral.

## 5. forest_stag_crest.png
- **Dimensões:** 16 × 24 px (RGBA 32-bit com transparência)
- **Finalidade:** Ícone heráldico do Cervo Ancestral para o HUD de exploração.

## 6. forest_sector3_bg.png (M6-B1)
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 3 (Passagem dos Fósseis).
- **Conteúdo:** Vista panorâmica atmosférica de uma passagem profunda entre montanhas de vértebras fossilizadas e copas retorcidas em silhueta, céu noturno sombrio com luar espectral frio e neblina verde-esmeralda/teal.
- **Isolamento:** Fundo puro de paisagem distante. Não contém plataformas, chão, personagens, HUD ou estruturas de primeiro plano.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08) preenchendo a tela sem emendas.

## 7. forest_sector4_bg.png (M6-B1)
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 4 (Clareira Ancestral).
- **Conteúdo:** Clareira gótica ampla com ruínas de arcos ogivais em pedra e ossos gigantes semi-enterrados na neblina profunda, céu tempestuoso noturno com luar radiante quebrando nuvens escuras.
- **Isolamento:** Fundo puro. Sem plataformas, chão ou personagens.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08).

## 8. forest_sector5_bg.png (M6-B2)
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 5 (Passagem das Raízes Profundas).
- **Conteúdo:** Túnel e abóbada profunda dominada por raízes retorcidas gigantescas, arcos ósseos e árvores fósseis densas em silhueta, ruínas antigas partidas engolidas pela vegetação fóssil, névoa espectral esverdeada/esmeralda e frestas de céu noturno com luar tímido.
- **Isolamento:** Fundo puro de paisagem distante. Não contém plataformas, chão, personagens, HUD ou estruturas de primeiro plano.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08).

## 9. forest_sector6_bg.png (M6-B2)
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 6 (Galeria dos Ossos Antigos).
- **Conteúdo:** Grande ossuário cavernoso com arcadas monumentais de costelas titânicas e vértebras colossais formando corredores de abóbadas góticas, ruínas de catedral ancestral entrelaçadas à ossada petrificada, névoa rasteira turquesa/esmeralda sobre abismo profundo e feixes de luar espectral filtrados pelo teto ósseo.
- **Isolamento:** Fundo puro. Não contém chão jogável, plataformas, personagens, HUD ou molduras.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08).

## 10. forest_sector7_bg.png (M6-B3)
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 7 (Fenda das Vértebras).
- **Conteúdo:** Fenda natural profunda e íngreme cruzada por pontes colossais de colunas vertebrais e costelas fossilizadas de titãs antigos, árvores de marfim petrificado inclinadas sobre o abismo, fragmentos de arcos góticos em ruínas engolidos por névoa espectral esverdeada e luar frio filtrado entre as frestas ósseas.
- **Isolamento:** Fundo puro de paisagem distante. Não contém plataformas jogáveis, chão, personagens, HUD ou molduras.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08).

## 11. forest_sector8_bg.png (M6-B3)
- **Dimensões:** 1774 × 887 px (RGB 24-bit)
- **Finalidade:** Fundo panorâmico distante do Setor 8 (Bosque dos Ecos).
- **Conteúdo:** Santuário vegetal e ósseo ancestral e silencioso, abóbada gótica natural formada pelo entrelaçamento de árvores fossilizadas e raízes titânicas, feixes de luz espectral celeste descendo pela copa fechada, névoa turquesa e partículas bioluminescentes flutuando sobre monólitos e ruínas de criptas esquecidas.
- **Isolamento:** Fundo puro. Não contém chão jogável, plataformas, personagens, HUD ou molduras.
- **Renderização:** Paralaxe distante com fator (0.12, 0.08).

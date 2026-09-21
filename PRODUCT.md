# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users
- **Cliente final:** pessoa interessada em streetwear que navega o catálogo, vê o detalhe de uma peça, compra e acompanha os próprios pedidos. Usa muito celular (360px) e desktop.
- **Equipe/admin da loja:** cadastra categorias e produtos (com foto), acompanha pedidos e altera o status. Usa a ferramenta no desktop, com tarefas repetidas e tabelas.

## Product Purpose
Loja online de streetwear autoral (jaquetas, moletons, camisetas), organizada em "drops". A aplicação web (Java 21, Tomcat 9, JSP + Servlets, MVC) atende a área do cliente e a área administrativa; existe também um app mobile (Flutter) e uma API `/api/*`, fora do escopo do redesign.

## Positioning
Marca de streetwear com identidade própria de sistema de transporte urbano (trens, plataformas, sinalização), e não uma loja genérica de e-commerce.

## Operating Context
- Área do cliente: vitrine de marca (registro Persuade). Respiro e foco no produto.
- Área admin: ferramenta (registro Operate). Mais densa e funcional.
- Status de pedido: pendente, em preparo, enviado, entregue, cancelado.
- Fotos de produto existem: são servidas por `/imagens/produtos/*` e ficam no banco. O placeholder em CSS é fallback para produto sem foto.

## Capabilities and Constraints
- Escopo do redesign: SOMENTE a camada de visão (HTML/CSS e JS leve). Nenhuma mudança de servlet, DAO, filtro, banco, `com.vagao.api` ou `mobile/`.
- Preservar nomes de campos, `action`, métodos, parâmetros, JSTL/EL/scriptlets, mensagens e redirecionamentos.
- HTML + CSS puro; sem frameworks. Responsivo (mobile-first, 360px até desktop) e acessível (`lang="pt-BR"`, viewport, foco visível, labels, `prefers-reduced-motion`).
- Views ficam em `WEB-INF/views` (só alcançáveis via servlet). Estáticos em `webapp/css`, `webapp/fonts`, `webapp/img` não passam por filtro.
- Não decidido: handles reais de Instagram/WhatsApp do rodapé e o texto da faixa "DROP ESPECIAL" (não há no código nem nos docs).

## Brand Commitments
- Nome/wordmark: "V A G Ã O //" com letter-spacing largo. Headline de impacto: "VISTA SUA IDENTIDADE.", em sans condensada bold caixa alta.
- Cores: vermelho #a8192e, preto #111, cinza claro #d9d9d9, off-white para texto sobre vermelho e áreas de leitura.
- Tipografia: títulos em serifada; labels, tags, preços e números em monoespaçada.
- Linguagem visual: sombra dura (sem blur), bordas 2px sólidas pretas, cantos retos (um elemento em pílula), faixa preta no topo, navegação em caixa alta espaçada.
- Ideias subway com moderação: status como "bullets de linha de metrô", cabeçalhos como placas de estação, setas de plataforma em voltar, tabelas como painel de horários.
- Tom de voz: direto e seco no dia a dia; vocabulário de metrô só nos detalhes (nomes de seção, status, microcopy pontual).
- Personalidade: urbana e crua, autêntica, confiante.
- Referências: streetwear brutalista; sinalização de transporte.
- Anti-referências: e-commerce genérico (template de loja, cards arredondados, gradientes, sombras suaves) e luxo minimalista (muito respiro, tipografia fina, paleta neutra).
- Motion: só feedback. Transições curtas de hover/foco/press, sombra dura que "afunda" ao clicar, respeitando `prefers-reduced-motion`.

## Evidence on Hand
- Sem depoimentos, casos ou métricas, e nada disso deve ser inventado.
- Fotos de produto reais só existem se cadastradas pelo admin no banco.
- Estilos atuais embutidos em cada JSP (Georgia + Courier New, paleta #a8192e/#111/#f2f2f2) como estado de partida.

## Product Principles
1. A identidade VAGÃO (subway/streetwear brutalista) manda sobre padrões genéricos de skill ou de e-commerce.
2. Vitrine com foco no produto para o cliente; ferramenta densa e legível para o admin.
3. Metrô é tempero: presente nos detalhes, nunca fantasia que atrapalhe a compra ou a operação.
4. Nenhuma mudança de funcionalidade: só a camada visual muda.
5. Acessibilidade e responsividade fazem parte do padrão, não do polimento.

## Accessibility & Inclusion
Contraste adequado (atenção a texto sobre #a8192e), foco visível, `<label>` em todos os inputs, `lang="pt-BR"`, respeito a `prefers-reduced-motion`. Uso frequente em celular (360px).

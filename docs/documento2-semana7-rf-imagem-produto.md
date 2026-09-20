# Documento 2 — Requisitos Funcionais de upload e exibição de imagem de produto — Semana 7

Os arquivos reais (`Documento2_Especificacao_de_Requisitos_VAGAO.docx` e
`Plano_de_Acao_Individual_VAGAO.docx`) estão fora do repositório, em `~/Downloads`, e são
`.docx` binários — este arquivo reúne o texto pronto para copiar neles manualmente.

## 12.1 🔴 Pendência das semanas anteriores — resolver antes de prosseguir

O `.docx` real ainda **termina no RF21**: os RF22 (Semana 4), RF23/RF24 (Semana 5) e
RF25/RF26 (Semana 6) foram redigidos nos respectivos `docs/documento2-semana*.md`, mas
**nunca copiados para o documento oficial**. Antes de acrescentar o ajuste e o RF novo desta
semana, copiar os cinco pendentes — senão o RF27 abaixo fica órfão, sem RF22–26 antecedendo-o
no documento real.

## 12.2 Ajuste de texto — RF04

O texto oficial do RF04 enumera os campos do cadastro de forma fechada (texto literal
extraído do `.docx`):

> RF04 — Cadastrar produto. *"O sistema deverá permitir que o administrador cadastre novos
> produtos (nome, descrição, preço, estoque, categoria)."*

Com o upload de foto, essa enumeração fica factualmente incompleta. Ajuste proposto:

> **RF04 — Cadastrar produto.** O sistema deverá permitir que o administrador cadastre novos
> produtos (nome, descrição, preço, estoque, categoria e, opcionalmente, uma imagem).

**RF06 (editar produto) não precisa de ajuste** — o texto *"altere os dados de um produto
existente"* já é genérico e cobre a troca ou remoção da foto. **RF12/RF13** (catálogo/detalhe
Web) e **RF17/RF25** (catálogo/detalhe Mobile) também são genéricos e continuam válidos sem
alteração — nenhum deles descreve *o que* é exibido a ponto de precisar mencionar a imagem.

## 12.3 RF novo — RF27 (exibir imagem do produto)

Nem o RF04 nem o RF06 descrevem o comportamento de *exibição com fallback* nas quatro telas
(catálogo Web, detalhe Web, catálogo Mobile, detalhe Mobile), que é funcional e visível ao
usuário. Acrescentar à tabela de RFs do Documento 2, **ao final, sem renumerar os
existentes** (o maior RF em uso até a Semana 6 é o RF26):

> **RF27 — Exibir imagem do produto.** O sistema deverá exibir a imagem cadastrada do
> produto nas telas de catálogo e de detalhe, tanto na aplicação Web quanto no aplicativo
> Mobile, exibindo uma representação alternativa com as iniciais do nome quando o produto
> não possuir imagem cadastrada.

## 12.4 Plano de Ação — marcar semana como concluída

No `Plano_de_Acao_Individual_VAGAO.docx`, marcar como **Feito** na coluna correspondente:

- **Semana 7** — Upload e exibição de imagem de produto (esta entrega).

## 12.5 Observação para RNF03/RNF05/RNF06

- **RNF03** (MySQL relacional): o banco passa a armazenar também o binário das fotos, em
  tabela própria (`produto_imagem`, `LONGBLOB`) com `FOREIGN KEY ... ON DELETE CASCADE` —
  continua um único banco relacional, sem infraestrutura externa.
- **RNF05** (segurança — nada sensível vaza): o teste S9 (regressão) confirmou que a
  introdução do upload não abriu nenhum novo vazamento de senha/hash nas respostas da API.
  Adicionalmente, a decisão de detectar o tipo do arquivo pelos *magic bytes* do conteúdo —
  nunca pela extensão do nome nem pelo `Content-Type` enviado pelo cliente, ambos forjáveis
  — é a defesa central desta entrega (testes S1–S3).
- **RNF06** (desempenho aceitável): o binário da imagem nunca é lido em consultas de
  listagem — `ProdutoDAO.SELECT_BASE` traz apenas um booleano derivado (`tem_imagem`) e uma
  data de versão; os bytes só saem do banco através da `ImagemServlet`, sob demanda, uma
  imagem por vez.

## 12.6 Evidência de segurança (não é RNF novo, é registro de teste)

A bateria de segurança da Semana 7 (S1–S9) validou, entre outros pontos: rejeição de
arquivo com extensão de imagem mas conteúdo inválido (S1); aceitação de imagem válida com
extensão trocada, provando que a decisão é pelo conteúdo (S2); rejeição de SVG (S3); limite
de 2 MB respeitado com mensagem amigável, sem stack trace (S4); proteção contra path
traversal na rota de imagem, id sempre validado por `Integer.parseInt` (S5/S6); cabeçalhos
`X-Content-Type-Options: nosniff` e `Content-Disposition: inline` na resposta da imagem,
para impedir que um arquivo poliglota seja interpretado como HTML na própria origem (S7).

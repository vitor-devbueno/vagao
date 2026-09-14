-- Pedidos de teste para o CRUD administrativo (Semana 3).
-- Pre-requisitos: seed_usuarios.sql e seed_catalogo.sql ja executados.

USE vagao;

-- Pedido 1: pendente, 2 itens
INSERT INTO pedido (status, id_usuario)
VALUES ('pendente', (SELECT id_usuario FROM usuario WHERE email = 'cliente@vagao.com'));
SET @pedido1 = LAST_INSERT_ID();

INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
VALUES (
  2,
  (SELECT preco FROM produto WHERE nome = 'Camiseta Vagão Metrô'),
  @pedido1,
  (SELECT id_produto FROM produto WHERE nome = 'Camiseta Vagão Metrô')
);

INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
VALUES (
  1,
  (SELECT preco FROM produto WHERE nome = 'Boné Vagão Aba Reta'),
  @pedido1,
  (SELECT id_produto FROM produto WHERE nome = 'Boné Vagão Aba Reta')
);

-- Pedido 2: em preparo, 1 item
INSERT INTO pedido (status, id_usuario)
VALUES ('em preparo', (SELECT id_usuario FROM usuario WHERE email = 'cliente@vagao.com'));
SET @pedido2 = LAST_INSERT_ID();

INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
VALUES (
  1,
  (SELECT preco FROM produto WHERE nome = 'Moletom Vagão Noturno'),
  @pedido2,
  (SELECT id_produto FROM produto WHERE nome = 'Moletom Vagão Noturno')
);

-- Pedido 3: enviado, 3 itens
INSERT INTO pedido (status, id_usuario)
VALUES ('enviado', (SELECT id_usuario FROM usuario WHERE email = 'cliente@vagao.com'));
SET @pedido3 = LAST_INSERT_ID();

INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
VALUES (
  3,
  (SELECT preco FROM produto WHERE nome = 'Meia Trilho Tripla (Kit 3 pares)'),
  @pedido3,
  (SELECT id_produto FROM produto WHERE nome = 'Meia Trilho Tripla (Kit 3 pares)')
);

INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
VALUES (
  1,
  (SELECT preco FROM produto WHERE nome = 'Camiseta Trilho Duplo'),
  @pedido3,
  (SELECT id_produto FROM produto WHERE nome = 'Camiseta Trilho Duplo')
);

INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
VALUES (
  1,
  (SELECT preco FROM produto WHERE nome = 'Moletom Estação Central'),
  @pedido3,
  (SELECT id_produto FROM produto WHERE nome = 'Moletom Estação Central')
);

-- Segundo cliente de teste, para validar isolamento entre clientes (Semana 4).
-- Pre-requisitos: seed_usuarios.sql e seed_catalogo.sql ja executados.
--
-- Credenciais de teste:
--   cliente2@vagao.com -> cliente123
-- (reaproveita literalmente o hash bcrypt de cliente@vagao.com em seed_usuarios.sql,
--  ja que o mesmo hash vale a mesma senha "cliente123")
--
-- O pedido criado aqui pertence a este segundo cliente e serve para provar
-- que o cliente 1 nao consegue ver/acessar pedidos do cliente 2 e vice-versa
-- (checagem de propriedade em PedidoDAO.buscarPorIdEUsuario).

USE vagao;

INSERT INTO usuario (nome, email, senha, perfil, telefone) VALUES
  ('Segundo Cliente Teste', 'cliente2@vagao.com', '$2a$12$gVXgKdyIPQrZM2y.o9Zu1.gz6M.AVnmDEUdJ5cFjNb7veXuGaogLa', 'cliente', '(11) 90000-0003');

-- Pedido do cliente2: pendente, 1 item
INSERT INTO pedido (status, id_usuario)
VALUES ('pendente', (SELECT id_usuario FROM usuario WHERE email = 'cliente2@vagao.com'));
SET @pedido_cliente2 = LAST_INSERT_ID();

INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
VALUES (
  1,
  (SELECT preco FROM produto WHERE nome = 'Camiseta Drop 01 Edição Limitada'),
  @pedido_cliente2,
  (SELECT id_produto FROM produto WHERE nome = 'Camiseta Drop 01 Edição Limitada')
);

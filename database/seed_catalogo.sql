-- Dados de teste de categorias e produtos para o CRUD administrativo (Semana 3).

USE vagao;

INSERT INTO categoria (nome) VALUES
  ('Drop 01 — Linha Férrea'),
  ('Camisetas'),
  ('Moletons'),
  ('Acessórios');

INSERT INTO produto (nome, descricao, preco, estoque, id_categoria) VALUES
  ('Camiseta Vagão Metrô', 'Camiseta oversized estampa metrô, 100% algodão.', 89.90, 25,
    (SELECT id_categoria FROM categoria WHERE nome = 'Camisetas')),
  ('Camiseta Trilho Duplo', NULL, 79.90, 40,
    (SELECT id_categoria FROM categoria WHERE nome = 'Camisetas')),
  ('Camiseta Linha 4', 'Estampa minimalista inspirada nos painéis de linha.', 84.90, 0,
    (SELECT id_categoria FROM categoria WHERE nome = 'Camisetas')),
  ('Moletom Vagão Noturno', 'Moletom canguru, capuz forrado, silk frente e costas.', 189.90, 15,
    (SELECT id_categoria FROM categoria WHERE nome = 'Moletons')),
  ('Moletom Estação Central', 'Moletom careca com ribana reforçada.', 159.90, 10,
    (SELECT id_categoria FROM categoria WHERE nome = 'Moletons')),
  ('Boné Vagão Aba Reta', 'Boné aba reta bordado, ajuste snapback.', 69.90, 30,
    (SELECT id_categoria FROM categoria WHERE nome = 'Acessórios')),
  ('Meia Trilho Tripla (Kit 3 pares)', 'Kit com 3 pares, cano médio, logo bordado.', 39.90, 50,
    (SELECT id_categoria FROM categoria WHERE nome = 'Acessórios')),
  ('Camiseta Drop 01 Edição Limitada', 'Peça exclusiva do primeiro drop da coleção.', 129.90, 8,
    (SELECT id_categoria FROM categoria WHERE nome = 'Drop 01 — Linha Férrea'));

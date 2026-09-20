-- Migração aditiva: tabela separada para a foto do produto (BLOB), em vez
-- de coluna em `produto` ou arquivo em disco. Ver docs/documento3-secao3-classes.md
-- para a justificativa. Não altera nenhuma tabela existente.

USE vagao;

CREATE TABLE IF NOT EXISTS produto_imagem (
  id_produto    INT PRIMARY KEY,
  mime          VARCHAR(40)  NOT NULL,
  conteudo      LONGBLOB     NOT NULL,
  atualizado_em TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                             ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_produto_imagem_produto FOREIGN KEY (id_produto)
    REFERENCES produto(id_produto) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

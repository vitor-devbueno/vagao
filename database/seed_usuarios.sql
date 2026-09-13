-- Usuários de teste para a Semana 2 (login/autenticação).
-- Senhas em texto puro (apenas para referência de teste manual):
--   admin@vagao.com   -> admin123
--   cliente@vagao.com -> cliente123
-- Hashes gerados com bcrypt (jBCrypt, custo 12) via com.vagao.util.SenhaUtil.

USE vagao;

INSERT INTO usuario (nome, email, senha, perfil, telefone) VALUES
  ('Administrador VAGÃO', 'admin@vagao.com',   '$2a$12$mStpj.b0I7FYUZZGGm0eXOD9qQXfI/H5JMXoWYH8KBErzLedoLDp2', 'admin',   '(11) 90000-0001'),
  ('Cliente Teste',       'cliente@vagao.com', '$2a$12$gVXgKdyIPQrZM2y.o9Zu1.gz6M.AVnmDEUdJ5cFjNb7veXuGaogLa', 'cliente', '(11) 90000-0002');

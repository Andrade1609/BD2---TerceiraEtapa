drop database LojaBancoDados2;

create database LojaBancoDados2;
use LojaBancoDados2;

create table if not exists Produto (
	CodigoProduto int primary key auto_increment,
    Nome varchar(50) not null,
    Descricao text not null, 
    Qtde_estoque int not null
)engine=InnoDB;

create table if not exists Cliente (
	CodigoCliente int auto_increment primary key, 
    Nome varchar(100) not null, 
    Email varchar(100) not null, 
    Cpf char(11) not null
)engine=InnoDB;

create table if not exists Pedido (
	CodigoPedido int primary key auto_increment, 
    DataPedido datetime default current_timestamp() not null, 
    Status varchar(10) not null
)engine=InnoDB;

create table if not exists ItemPedido (
	CodigoPedido int not null,
    CodigoProduto int not null, 
    PrecoVenda decimal(10, 2) not null, 
    Qtde int not null,
    
    foreign key (CodigoProduto) references Produto(CodigoProduto),
    foreign key (CodigoPedido) references Pedido(CodigoPedido)
);

create table if not exists Funcionario (
	CodigoFuncionario int auto_increment primary key, 
    nome varchar(100) not null, 
    funcao varchar(100) not null, 
    cidade varchar(100) not null
);

-- --------------------------------------------------------------------------
-- 3 - Criar a tabela Auditoria (DataModificao, nometabela, historico)
-- --------------------------------------------------------------------------

create table if not exists Auditoria (
	DataModificao datetime default current_timestamp(), 
    nometabela varchar(12) not null, 
    historico varchar(100) not null
)engine=InnoDB;

-- --------------------------------------------------------------------------
-- Triggers dos Produtos
-- --------------------------------------------------------------------------

delimiter %
create trigger trg_inserir_produto after insert on produto for each row
begin

insert into auditoria (nometabela, historico) values ("produto", concat("O produto: ", new.codigoProduto, " foi inserido"));

end %
delimiter ;    

delimiter %
create trigger trg_update_produto after update on produto for each row
begin

insert into auditoria (nometabela, historico) values ("produto", concat("O produto: ", old.codigoProduto, " foi alterado"));

end %
delimiter ;  

delimiter %
create trigger trg_delete_produto after delete on produto for each row
begin

insert into auditoria (nometabela, historico) values ("produto", concat("O produto: ", old.CodigoProduto, " foi deletado"));

end %
delimiter ; 

-- --------------------------------------------------------------------------
-- Triggers dos clientes
-- --------------------------------------------------------------------------

delimiter %
create trigger trg_inserir_cliente after insert on cliente for each row
begin

insert into auditoria (nometabela, historico) values ("cliente", concat("O cliente: ", new.codigoCliente, " foi inserido"));

end %
delimiter ;  

end %
delimiter ;

delimiter %
create trigger trg_update_cliente after update on cliente for each row
begin

insert into auditoria (nometabela, historico) values ("cliente", concat("O cliente: ", old.codigoCliente, " foi alterado"));

end %
delimiter ;

delimiter %
create trigger trg_delete_cliente after delete on cliente for each row
begin

insert into auditoria (nometabela, historico) values ("cliente", concat("O cliente: ", old.CodigoCliente, " foi deletado"));

end %
delimiter ; 

-- --------------------------------------------------------------------------
-- Triggers dos funcionarios
-- --------------------------------------------------------------------------

delimiter %
create trigger trg_inserir_funcionario after insert on funcionario for each row
begin

insert into auditoria (nometabela, historico) values ("funcionario", concat("O funcionário: ", new.codigoFuncionario, " foi inserido"));

end %
delimiter ;  

end %
delimiter ; 

delimiter %
create trigger trg_update_funcionario after update on funcionario for each row
begin

insert into auditoria (nometabela, historico) values ("funcionario", concat("O funcionário: ", old.codigoFuncionario, " foi alterado"));

end %
delimiter ; 

delimiter %
create trigger trg_delete_funcionario after delete on funcionario for each row
begin

insert into auditoria (nometabela, historico) values ("funcionario", concat("O funcionário: ", old.codigoFuncionario, " foi deletado"));

end %
delimiter ; 


-- --------------------------------------------------------------------------
-- Triggers dos pedidos
-- --------------------------------------------------------------------------

delimiter %
create trigger trg_inserir_pedido after insert on pedido for each row
begin

insert into auditoria (nometabela, historico) values ("pedido", concat("O pedido: ", new.codigoPedido, " foi inserido"));

end %
delimiter ;  

end %
delimiter ; 

delimiter %
create trigger trg_update_pedido after update on pedido for each row
begin

insert into auditoria (nometabela, historico) values ("pedido", concat("O pedido: ", old.codigoPedido, " foi alterado"));

end %
delimiter ; 

delimiter %
create trigger trg_delete_pedido after delete on pedido for each row
begin

insert into auditoria (nometabela, historico) values ("pedido", concat("O pedido: ", old.CodigoPedido, " foi deletado"));

end %
delimiter ; 


-- --------------------------------------------------------------------------
-- Triggers dos itens pedidos
-- --------------------------------------------------------------------------

delimiter %
create trigger trg_inserir_item_pedido after insert on itempedido for each row
begin

insert into auditoria (nometabela, historico) values ("item_pedido", concat("O item_pedido do produto: ", new.codigoProduto, " do pedido: ", new.codigoPedido, " foi inserido"));

end %
delimiter ;  

end %
delimiter ; 

delimiter %
create trigger trg_update_item_pedido after update on itempedido for each row
begin

insert into auditoria (nometabela, historico) values ("item_pedido", concat("O item_pedido do produto: ", new.codigoProduto, " do pedido: ", new.codigoPedido, " foi alterado"));

end %
delimiter ; 

delimiter %
create trigger trg_delete_item_pedido after delete on itempedido for each row
begin

insert into auditoria (nometabela, historico) values ("item_pedido", concat("Os códigos: ", old.CodigoProduto, old.CodigoPedido, "foram deletados de item pedido"));

end %
delimiter ; 

-- -------------------------------------------------------------------------------------------
-- Criar uma procedure para cada tabela para inserir os dados, exceto para Pedido e ItemPedido.
-- -------------------------------------------------------------------------------------------

delimiter *
create procedure insert_produto (in param_nome varchar(20), in param_descricao text, in param_qtde int)
begin
	insert into Produto (nome, descricao, qtde_estoque) values (param_nome, param_descricao, param_qtde);
end *
delimiter ;

delimiter *
create procedure insert_cliente (in param_nome varchar(100), in param_email varchar(100), in param_cpf char(11))
begin
	insert into Cliente (nome, email, cpf) values (param_nome, param_email, param_cpf);
end *
delimiter ;

delimiter *
create procedure insert_pedido (in param_status varchar(10))
begin
	insert into Pedido (status) values (param_status);
end *
delimiter ;

delimiter *
create procedure insert_funcionario (in param_nome varchar(100), in param_funcao varchar(100), in param_cidade varchar(100))
begin
	insert into Funcionario (nome, funcao, cidade) values (param_nome, param_funcao, param_cidade);
end *
delimiter ;

-- ------------------------------------------------------------------------------------------------
-- Criar a JSON Carrinho (CodigoProduto, CodigoCliente, CodigoVendedor, Qtde). Aplicar JSON extract
-- ------------------------------------------------------------------------------------------------

create table if not exists carrinho (
    codigoCarrinho int primary key auto_increment,
    dados json not null
);

insert into carrinho (dados)
values ('{
    "CodigoProduto": 10,
    "CodigoCliente": 1,
    "CodigoVendedor": 2,
    "Qtde": 40
}');

insert into carrinho (dados)
values ('{
  "CodigoProduto": 10,
  "CodigoCliente": 1,
  "CodigoVendedor": 2,
  "Qtde": -5
}');

insert into carrinho (dados)
values ('{
  "CodigoProduto": 10,
  "CodigoCliente": 1,
  "CodigoVendedor": 2,
  "Qtde": 9999
}');

insert into carrinho (dados)
values ('{
  "CodigoProduto": 10,
  "CodigoCliente": 999999,
  "CodigoVendedor": 2,
  "Qtde": 5
}');

insert into carrinho (dados)
values ('{
  "CodigoProduto": 10,
  "CodigoCliente": 1,
  "CodigoVendedor": 999999,
  "Qtde": 5
}');

select 
    json_unquote(json_extract(dados, '$.CodigoProduto')) as CodigoProduto,
    json_unquote(json_extract(dados, '$.CodigoCliente')) as CodigoCliente,
    json_unquote(json_extract(dados, '$.CodigoVendedor')) as CodigoVendedor,
    json_unquote(json_extract(dados, '$.Qtde')) as Quantidade
from carrinho;

-- ------------------------------------------------------------------------------------------------
-- Criar um procedure para inserir Pedido e ItemPedido precisa ter: Transação, Cursor e validações.
-- ------------------------------------------------------------------------------------------------

delimiter /
create procedure ProcessarPedidoCarrinho (in param_codigoCliente int, out param_mensagem varchar(255))
begin
    declare done int default 0;
    declare var_codigoProduto int;
    declare var_qtde int;
    declare var_preco decimal(10,2);
    declare var_estoqueAtual int;
    declare v_novoPedido int;

    declare cur_carrinho cursor for
        select 
            cast(json_unquote(json_extract(dados, '$.CodigoProduto')) as unsigned),
            cast(json_unquote(json_extract(dados, '$.Qtde')) as unsigned)
        from carrinho
        where cast(json_unquote(json_extract(dados, '$.CodigoCliente')) as unsigned) = param_codigoCliente;

    declare continue handler for not found set done = 1;
    
    declare exit handler for sqlexception
    begin
        rollback;
        set param_mensagem = 'erro: transação cancelada (rollback). estoque insuficiente ou produto não encontrado.';
    end;
 
    start transaction;
 
    insert into Pedido (CodigoCliente, Status) values (param_codigoCliente, 'Processado');
    set v_novoPedido = last_insert_id();

    open cur_carrinho;

    read_loop: loop
        fetch cur_carrinho into var_codigoProduto, var_qtde;
        
        if done = 1 then
            leave read_loop;
        end if;

        select Qtde_estoque into var_estoqueAtual 
        from Produto 
        where CodigoProduto = var_codigoProduto;

        if var_estoqueAtual is null then
            signal sqlstate '45000' set message_text = 'falha: produto não encontrado.';
        elseif var_estoqueAtual < var_qtde then
            signal sqlstate '45000' set message_text = 'falha: estoque insuficiente.';
        end if;

        set var_preco = 50.00;

        insert into ItemPedido (CodigoPedido, CodigoProduto, PrecoVenda, Qtde)
        values (v_novoPedido, var_codigoProduto, var_preco, var_qtde);

        update Produto 
        set Qtde_estoque = Qtde_estoque - var_qtde 
        where CodigoProduto = var_codigoProduto;

    end loop;

    close cur_carrinho;

    delete from carrinho where cast(json_unquote(json_extract(dados, '$.CodigoCliente')) as unsigned) = param_codigoCliente;

    commit;
    
    set param_mensagem = concat('pedido: ', v_novoPedido, ' processado com sucesso!');
end /
delimiter ;

-- ------------------------------------------------------------------------------------------------
-- Criar uma View para visualizar os Produtos mais vendidos.
-- ------------------------------------------------------------------------------------------------

create or replace view vw_produtos_mais_vendido as (
	select 
		p.codigoProduto,
        p.Nome,
        sum(ip.qtde) as Total_vendido
	from produto as p
    inner join itempedido as ip on(p.codigoProduto = ip.codigoProduto)
    group by p.codigoProduto
    order by total_vendido desc
);

select * from vw_produtos_mais_vendido;

CALL insert_funcionario('Carlos Silva', 'Vendedor', 'São Paulo');
SELECT * FROM Funcionario;
SELECT * FROM auditoria;

INSERT INTO Cliente (Nome, Email, Cpf) VALUES
('Ana Silva', 'ana@email.com', '11122233344'),
('Bruno Souza', 'bruno@email.com', '55566677788');

INSERT INTO Produto (Nome, Descricao, Qtde_estoque) VALUES
('Teclado Mecânico', 'Teclado RGB switch azul', 50),
('Mouse Gamer', 'Mouse 10000 DPI', 80),
('Monitor 24', 'Monitor Full HD 144Hz', 30);

INSERT INTO Pedido (Status) VALUES
('Processado'),
('Processado'),
('Pendente');

INSERT INTO ItemPedido (CodigoPedido, CodigoProduto, PrecoVenda, Qtde) VALUES
(1, 1, 250.00, 2),
(1, 2, 120.00, 5);

INSERT INTO ItemPedido (CodigoPedido, CodigoProduto, PrecoVenda, Qtde) VALUES
(2, 1, 250.00, 1),
(2, 3, 900.00, 2);

INSERT INTO ItemPedido (CodigoPedido, CodigoProduto, PrecoVenda, Qtde) VALUES
(3, 2, 120.00, 10);

SELECT * FROM vw_produtos_mais_vendido;

DELETE FROM ItemPedido;
DELETE FROM Pedido;
DELETE FROM Produto;

INSERT INTO Produto (CodigoProduto, Nome, Descricao, Qtde_estoque) VALUES
(1, 'Teclado Mecânico', 'Teclado RGB', 50),
(2, 'Mouse Gamer', 'Mouse 10000 DPI', 80),
(3, 'Monitor 24', 'Monitor Full HD', 30);

INSERT INTO Pedido (CodigoPedido, Status) VALUES
(101, 'Processado'),
(102, 'Processado');

INSERT INTO ItemPedido (CodigoPedido, CodigoProduto, PrecoVenda, Qtde) VALUES
(101, 1, 250.00, 2),
(101, 2, 120.00, 5);

INSERT INTO ItemPedido (CodigoPedido, CodigoProduto, PrecoVenda, Qtde) VALUES
(102, 1, 250.00, 1),
(102, 3, 900.00, 2);

SELECT * FROM vw_produtos_mais_vendido;

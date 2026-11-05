#####################################################################################################################
-- 1 - Criar um database com o nome: LojaBancoDados2
#####################################################################################################################

create database if not exists LojaBancoDados2;
use LojaBancoDados2;

#####################################################################################################################
-- 2 - Criar as tabelas
#####################################################################################################################

create table if not exists produto ( 
    CodigoProduto int primary key auto_increment,
    nome varchar(50) not null,
    descricao text not null,
    qtde_estoque int not null
) engine=InnoDB;

create table if not exists cliente (
    CodigoCliente int primary key auto_increment,
    nome varchar(100) not null,
    email varchar(100) not null,
    cpf varchar(11) null
) engine=InnoDB;

create table if not exists pedido (
    CodigoPedido int primary key auto_increment,
    dataPedido date not null,
    status bool not null
) engine=InnoDB;

create table if not exists itempedido (
    CodigoPedido int not null,
    CodigoProduto int not null,
    PrecoVenda float not null,
    Qtde int not null,
    foreign key (CodigoProduto) references produto(CodigoProduto),
    foreign key (CodigoPedido) references pedido(CodigoPedido)
) engine=InnoDB;

create table if not exists funcionario (
    CodigoFuncionario int primary key auto_increment,
    nome varchar(50) not null,
    funcao text not null,
    cidade text not null
) engine=InnoDB;

#####################################################################################################################
-- 3 - Criar a tabela Auditoria (DataModificao, nometabela, historico)
#####################################################################################################################

create table if not exists auditoria (
    DataModificada datetime default current_timestamp(),
    nometabela varchar(50) not null,
    historico text not null
) engine=InnoDB;

#####################################################################################################################
-- 4 - Criar as triggers: Insert, Update, Delete para as tabelas (Produto, Cliente, Pedido, ItemPedido, Funcionario)
#####################################################################################################################

############
-- INSERT
############

delimiter %
create trigger trg_insert_produto after insert on produto for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('produto', concat('O produto de código: ', new.CodigoProduto, ' foi inserido.'));
end%
delimiter ;

delimiter %
create trigger trg_insert_cliente after insert on cliente for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('cliente', concat('O cliente de código: ', new.CodigoCliente, ' foi inserido.'));
end%
delimiter ;

delimiter %
create trigger trg_insert_pedido after insert on pedido for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('pedido', concat('O pedido de código: ', new.CodigoPedido, ' foi inserido.'));
end%
delimiter ;

delimiter %
create trigger trg_insert_itempedido after insert on itempedido for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('ItemPedido', concat('O item do pedido código: ', new.CodigoPedido, ' foi inserido com o produto: ', new.CodigoProduto));
end%
delimiter ;

delimiter %
create trigger trg_insert_funcionario after insert on funcionario for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('funcionario', concat('O funcionário de código: ', new.CodigoFuncionario, ' foi inserido.'));
end%
delimiter ;

############
-- UPDATE
############

delimiter %
create trigger trg_update_produto after update on produto for each row
begin 
    insert into auditoria (nometabela, historico) 
    values ('produto', concat('O produto de código: ', old.CodigoProduto, ' foi modificado. Antes: ', old.nome, ' / Estoque: ', old.qtde_estoque, ' - Agora: ', new.nome, ' / Estoque: ', new.qtde_estoque));
end %
delimiter ;

delimiter %
create trigger trg_update_cliente after update on cliente for each row
begin 
    insert into auditoria (nometabela, historico) 
    values ('cliente', concat('O cliente de código: ', old.CodigoCliente, ' foi modificado. Antes: ', old.nome, ', ', old.email, ' - Agora: ', new.nome, ', ', new.email));
end %
delimiter ;

delimiter %
create trigger trg_update_pedido after update on pedido for each row
begin 
    insert into auditoria (nometabela, historico) 
    values ('pedido', concat('O pedido de código: ', old.CodigoPedido, ' foi modificado. Antes: ', old.dataPedido, ' - Agora: ', new.dataPedido));
end %
delimiter ;

delimiter %
create trigger trg_update_itempedido after update on itempedido for each row
begin 
    insert into auditoria (nometabela, historico) 
    values ('ItemPedido', concat('O item do pedido: ', old.CodigoPedido, ' foi modificado. Qtd antiga: ', old.Qtde, ' - Qtd nova: ', new.Qtde));
end %
delimiter ;

delimiter %
create trigger trg_update_funcionario after update on funcionario for each row
begin 
    insert into auditoria (nometabela, historico) 
    values ('funcionario', concat('O funcionário de código: ', old.CodigoFuncionario, ' foi modificado. Antes: ', old.nome, ' - Agora: ', new.nome));
end %
delimiter ;

############
-- DELETE
############

delimiter %
create trigger trg_delete_produto after delete on produto for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('produto', concat('O produto de código: ', old.CodigoProduto, ' foi deletado.'));
end %
delimiter ;

delimiter %
create trigger trg_delete_cliente after delete on cliente for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('cliente', concat('O cliente de código: ', old.CodigoCliente, ' foi deletado.'));
end %
delimiter ;

delimiter %
create trigger trg_delete_pedido after delete on pedido for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('pedido', concat('O pedido de código: ', old.CodigoPedido, ' foi deletado.'));
end %
delimiter ;

delimiter %
create trigger trg_delete_itempedido after delete on itempedido for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('ItemPedido', concat('O item do pedido código: ', old.CodigoPedido, ' foi deletado.'));
end %
delimiter ;

delimiter %
create trigger trg_delete_funcionario after delete on funcionario for each row
begin
    insert into auditoria (nometabela, historico) 
    values ('funcionario', concat('O funcionário de código: ', old.CodigoFuncionario, ' foi deletado.'));
end %
delimiter ;

#####################################################################################################################
-- 5 - Criar uma procedure para cada tabela para inserir os dados, exceto para Pedido e ItemPedido.
#####################################################################################################################

##########################################
-- Procedure para a tabela Produto
##########################################

delimiter %
create procedure sp_inserir_produto (
    in p_nome varchar(50),
    in p_descricao text,
    in p_qtde_estoque int
)
begin
    insert into produto (nome, descricao, qtde_estoque) 
    values (p_nome, p_descricao, p_qtde_estoque);
end%
delimiter ;

##########################################
-- Procedure para a tabela Cliente
##########################################

delimiter %
create procedure sp_inserir_cliente (
    in p_nome varchar(100),
    in p_email varchar(100),
    in p_cpf varchar(11)
)
begin
    insert into cliente (nome, email, cpf) 
    values (p_nome, p_email, p_cpf);
end%
delimiter ;

##########################################
-- Procedure para a tabela Funcionario
##########################################

delimiter %
create procedure sp_inserir_funcionario (
    in p_nome varchar(50),
    in p_funcao text,
    in p_cidade text
)
begin
    insert into funcionario (nome, funcao, cidade) 
    values (p_nome, p_funcao, p_cidade);
end%
delimiter ;

#####################################################################################################################
-- 6 -  Criar a JSON Carrinho (CodigoProduto, CodigoCliente, CodigoVendedor, Qtde). Aplicar JSON extract.
#####################################################################################################################

create table carrinho (
	codigoCliente int primary key auto_increment,
    dados json not null
);

#####################################################################################################################
-- 7 -  Criar um procedure para inserir Pedido e ItemPedido precisa ter: Transação, Cursor e validações.
#####################################################################################################################
     
drop procedure if exists sp_inserir_pedido_com_itens;
 delimiter %
create procedure sp_inserir_pedido_com_itens (
    in p_CodigoCliente int,
    in p_ItensJson json,
    out p_Sucesso boolean,
    out p_Mensagem varchar(255)
)
proc_main: begin
########################################################################
-- DECLARAÇÃO DE VARIÁVEIS
########################################################################
    
    declare v_done int default false;
    declare v_CodigoProduto int;
    declare v_PrecoVenda float;
    declare v_Qtde int;
    declare v_EstoqueAtual int;
    declare v_CodigoPedido int;

########################################################################
-- DECLARAÇÃO DO CURSOR
########################################################################
    
    declare cur_itens cursor for 
        select CodigoProduto, PrecoVenda, Qtde
        from json_table(
            p_ItensJson,
            '$[*]' columns (
                CodigoProduto int path '$.CodigoProduto',
                PrecoVenda float path '$.PrecoVenda',
                Qtde int path '$.Qtde'
            )
        ) as jt;
	
########################################################################
-- DECLARAÇÃO DOS HANDLERS (Devem vir após as variáveis e cursores)
########################################################################
    
    declare continue handler for not found set v_done = true;

    declare exit handler for sqlexception
    begin
        rollback;
        set p_Sucesso = false;
        set p_Mensagem = 'Erro inesperado no banco de dados. Transação cancelada!';
    end;

########################################################################
-- VALIDAÇÕES INICIAIS
########################################################################
    
    if not exists(select 1 from cliente where CodigoCliente = p_CodigoCliente) then
        set p_Sucesso = false;
        set p_Mensagem = 'Validação falhou: Cliente não encontrado!';
        leave proc_main;
    end if;

    if p_ItensJson is null or json_length(p_ItensJson) = 0 then
        set p_Sucesso = false;
        set p_Mensagem = 'Validação falhou: Nenhum item informado no pedido!';
        leave proc_main;
    end if;

########################################################################
-- VALIDAÇÃO DE ESTOQUE (Checagem inicial com Cursor)
########################################################################
    
    open cur_itens;

    check_loop: loop
        fetch cur_itens into v_CodigoProduto, v_PrecoVenda, v_Qtde;
        if v_done then
            leave check_loop;
        end if;
        
        select qtde_estoque into v_EstoqueAtual 
        from produto 
        where CodigoProduto = v_CodigoProduto;
        if v_EstoqueAtual is null then
            close cur_itens;
            set p_Sucesso = false;
            set p_Mensagem = concat('Validação falhou: Produto ', v_CodigoProduto, ' não existe!');
            leave proc_main;
        end if;
        if v_EstoqueAtual < v_Qtde then
            close cur_itens;
            set p_Sucesso = false;
            set p_Mensagem = concat('Validação falhou: Estoque insuficiente para o produto ID ', v_CodigoProduto, '. Disponível: ', v_EstoqueAtual);
            leave proc_main;
        end if;
    end loop;
    close cur_itens;

########################################################################
-- TRANSAÇÃO E INSERÇÕES
########################################################################
    
    start transaction;

    insert into pedido(dataPedido, status) 
    values (curdate(), true);
    set v_CodigoPedido = last_insert_id();
    set v_done = false;
    open cur_itens;

    insert_loop: loop
        fetch cur_itens into v_CodigoProduto, v_PrecoVenda, v_Qtde;
        if v_done then
            leave insert_loop;
        end if;
        insert into itempedido(CodigoPedido, CodigoProduto, PrecoVenda, Qtde) 
        values (v_CodigoPedido, v_CodigoProduto, v_PrecoVenda, v_Qtde);
        update produto 
        set qtde_estoque = qtde_estoque - v_Qtde 
        where CodigoProduto = v_CodigoProduto;
    end loop;
    close cur_itens;
    commit;
    set p_Sucesso = true;
    set p_Mensagem = concat('Pedido ', v_CodigoPedido, ' inserido com sucesso!');

end%
delimiter ;

#####################################################################################################################
-- 8 -   Criar uma View para visualizar os Produtos mais vendidos.
#####################################################################################################################

create or replace view vw_produtos_mais_vendidos as
select 
    p.CodigoProduto,
    p.nome as NomeProduto,
    p.descricao as Descricao,
    p.qtde_estoque as EstoqueAtual,
    sum(ip.Qtde) as TotalUnidadesVendidas,
    sum(ip.Qtde * ip.PrecoVenda) as ValorTotalArrecadado
from produto p
inner join itempedido ip on p.CodigoProduto = ip.CodigoProduto
group by p.CodigoProduto, p.nome, p.descricao, p.qtde_estoque
order by TotalUnidadesVendidas desc;
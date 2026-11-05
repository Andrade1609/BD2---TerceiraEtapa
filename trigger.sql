use classicModels;

-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Ensinando trigger
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- Criando um trigger
select * from customers;

create table log_auditoria (
	dado_alterado text,
    data_alteracao datetime default current_timestamp()
)Engine=InnoDb;

delimiter %
create trigger trg_update_customer after update on customers for each row
begin 
	insert into log_auditoria(dado_alterado) values(concat('O cliente de código: ', old.customerNumber, ' sofreu uma modificação do seu limite de crédito. Antes era: ', old.creditLimit, ' e agora é: ', new.creditLimit));
end %
delimiter ;

drop trigger trg_update_customer;

update customers set creditLimit = 100000 where customerNumber = 103;

select * from log_auditoria;


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Atividade 1
-- ----------------------------------------------------------------------------------------------------------------------------------------------

delimiter $
create trigger trg_insert_customer after insert on customers for each row
begin
	insert into log_auditoria(dado_alterado) values(concat('O cliente de código: ', new.customerNumber, ' foi inserido.'));
end $
delimiter ;

drop trigger trg_insert_customer;

insert into customers (customerNumber, customerName, contactLastName, contactFirstName, phone, addressLine1, addressLine2, city, state, postalCode, country)
values (497, 'Fulano Cotemig', 'Mãe Fulano Cotemig', 'Pai Fulano Cotemig', '9999888777', 'Rua Fulano Mae e pai Cotemig', ' ', 'Belo Horizonte', 'MG', '31800457', 'Brasil'); 
select * from log_auditoria;


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Atividade 2
-- ----------------------------------------------------------------------------------------------------------------------------------------------

delimiter $
create trigger trg_delete_customer after delete on customers for each row
begin
	insert into log_auditoria(dado_alterado) values(concat('O cliente de código: ', old.customerNumber, ' foi deletado.'));
end $
delimiter ;

drop trigger trg_delete_customer;

select * from customers;
delete from customers where customerNumber = 497;
select * from log_auditoria;

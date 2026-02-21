--crea una base de datos con postgresql
--crear tabla e inserto de datos
create table cuentas(
	id serial primary key,
	nombre varchar(50),
	saldo numeric(10,2)
);

insert into cuentas (nombre, saldo) values
('Ana', 1000),
('Luis', 1500),
('Carlos', 2000);
 
--Ejemplo 1 TRANSACCION DE SAVEPOINT
--se ejecuta en una sola sesión
--click derecho sobre la base de datos -> editor sql -> nuevo script sql
--asi tienes una sesion iniciada
begin;

update cuentas
set saldo = saldo - 300 
where nombre = 'Ana';

savepoint sp1;

update cuentas
set saldo = saldo - 200
where nombre = 'Ana';

--ver saldo antes del rollback
select * from cuentas where nombre = 'Ana';

rollback to sp1;

--ver saldo despues del rollback parcial
select * from cuentas where nombre = 'Ana';

commit;

--que observe 
--antes del rollback el saldo = 500
--despues del rollback el saldo = 700
--demostrando la reversion parcial



--EJEMPLO 2 LOCK CON NOWAIT
--es necesario dos sesiones SQL
--click derecho conexion y new sql script abriendo dos pestañas

--Sesion1
begin;
lock table cuentas in access exclusive mode;
--bloquea en su totalidad la tabla

--sesion2
lock table cuentas in access exclusive mode nowait;
--resultado observado
--SQL Error [25P01]: ERROR: la orden LOCK TABLE sólo puede ser usada en bloques de transacción



--EJEMPLOS 3 READ COMMITTED vs SERIALIZABLE
--Parte1 READ COMMITTED
--SESION1
begin;
set transaction isolation level read committed;
select saldo from cuentas where id = 1;

--SESION2
update cuentas set saldo = 5000 where id = 1;
commit;

--SESION1 NUEVAMENTE
select saldo from cuentas where id = 1;
commit;

--Resultado observado
--la segunda consulta ve el nuevo saldo
--demuestra lectura no repetible

--Parte2 SERIALIZABLE
--Sesion 1
begin;
set transaction isolation level serializable;
select saldo from cuentas where id = 1;

--sesion 2
update cuentas set saldo = saldo + 100 where id = 1;
commit;

--sesion1 nuevamente
commit;

--resultados observables
--aparece Error: could not serialize access due to concurrent update
--PostgreSQL protege consistencia











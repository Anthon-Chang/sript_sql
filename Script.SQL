create database tienda_online;
use tienda_online;

create table clientes (
    id int auto_increment primary key,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    email varchar(100) not null unique,
    telefono varchar(15),
    fecha_registro date not null
);

create table productos (
    id int auto_increment primary key,
    nombre varchar(100) not null unique,
    precio decimal(10, 2) not null check (precio > 0),
    stock int not null check (stock >= 0),
    descripcion text
);

create table pedidos (
    id int auto_increment primary key,
    cliente_id int not null,
    fecha_pedido date not null,
    total decimal(10, 2) not null check (total > 0),
    foreign key (cliente_id) references clientes(id)
);

create table detalles_pedido (
    id int auto_increment primary key,
    pedido_id int not null,
    producto_id int not null,
    cantidad int not null check (cantidad > 0),
    precio_unitario decimal(10, 2) not null check (precio_unitario > 0),
    foreign key (pedido_id) references pedidos(id),
    foreign key (producto_id) references productos(id)
);

insert into clientes (nombre, apellido, email, telefono, fecha_registro) values
('Juan', 'Pérez', 'juan.perez@example.com', '123456789', '2021-05-10'),
('María', 'Gómez', 'maria.gomez@example.com', '987654321', '2020-08-15'),
('Carlos', 'López', 'carlos.lopez@example.com', '456123789', '2019-11-20');

insert into productos (nombre, precio, stock, descripcion) values
('Laptop', 800.00, 10, 'Laptop de alto rendimiento'),
('Mouse', 25.00, 50, 'Mouse inalámbrico'),
('Teclado', 45.00, 30, 'Teclado mecánico retroiluminado');

insert into pedidos (cliente_id, fecha_pedido, total) values
(1, '2023-12-01', 850.00),
(2, '2023-12-05', 70.00),
(3, '2023-12-10', 45.00);

insert into detalles_pedido (pedido_id, producto_id, cantidad, precio_unitario) values
(1, 1, 1, 800.00),
(2, 2, 2, 25.00),
(3, 3, 1, 45.00);

-- función para obtener el nombre de un cliente

delimiter //
create function obtener_nombre(cliente_id int) returns varchar(101)
deterministic
begin
    return (select nombre from clientes where id = cliente_id limit 1); -- Devuelve el nombre del cliente.
end //
delimiter ;

-- función para calcular el descuento de un producto
delimiter //
create function descuento(precio decimal(10, 2), descuento decimal(5, 2)) returns decimal(10, 2)
deterministic
begin
    return precio - (precio * (descuento / 100)); -- Calcula y devuelve el precio con descuento.
end //
delimiter ;

-- Función para calcular el total de un pedido
delimiter //
create function total_pedido(pedido_id int) returns decimal(10, 2)
deterministic
begin
    declare total_pedido decimal(10, 2);
    select precio_unitario * cantidad into total_pedido
    from detalles_pedido
    where detalles_pedido.pedido_id = pedido_id; -- Calcula el total del pedido.
    return total_pedido; 
end //
delimiter ;

-- función para verificar la disponibilidad de stock de un producto
delimiter //
create function verificar_stock(producto_id int, cantidad int) returns varchar(10)
    deterministic
begin
    declare stock_disponible int;
    select stock into stock_disponible
    from productos
    where productos.id = producto_id; -- Obtiene el stock disponible del producto.
    if stock_disponible >= cantidad then
        return 'true'; -- Retorna 'true' si hay suficiente stock
    else
        return 'false'; -- Retorna 'false' si no hay suficiente stock.
    end if;
end //
delimiter ;

-- función para calcular la antigüedad de un cliente
delimiter //
create function calcular_antiguedad(cliente_id int) returns int
    deterministic
begin
    declare antiguedad int;
    select timestampdiff(year, fecha_registro, curdate()) into antiguedad
    from clientes
    where id = cliente_id; -- Calcula la diferencia en años desde la fecha de registro.
    return antiguedad;
end //
delimiter ;

-- CONSULTAS

-- Obtener el nombre del cliente con ID 1.
select obtener_nombre (1) as nombre_cliente;

-- Obtener el total del pedido con ID 3.
select descuento (25.00, 10) as precio_descuento;

-- Obtener el total del pedido con ID 3.
select total_pedido (3) as pedido_total;

-- Verificar si hay suficiente stock para 40 unidades del producto con ID 1.
select 	verificar_stock (1, 40) as stock;

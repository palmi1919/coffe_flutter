-- ===== TABLAS DE LOGIN =====
create table tipo_usu (
  pk_tipo_usu smallserial primary key,
  nom_tipo    text not null,
  estatus     boolean not null default true
);

create table persona (
  pk_persona  serial primary key,
  nom_persona text not null,
  apaterno    text,
  amaterno    text
);

create table usuario (
  pk_usuario  serial primary key,
  auth_id     uuid unique references auth.users(id) on delete cascade,
  nom_usuario text not null unique,
  contrasena  text not null,
  fk_persona  integer references persona(pk_persona),
  fk_tipo_usu smallint references tipo_usu(pk_tipo_usu),
  estatus     boolean not null default true
);

-- ===== PRODUCTOS =====
create table categoria (
  pk_categoria  smallserial primary key,
  nom_categoria text not null,
  descripcion   text,
  estatus       boolean not null default true
);

create table tamano (
  pk_tamano         smallserial primary key,
  nom_tamano        text not null,
  descripcion_corta text
);

create table producto (
  pk_producto  serial primary key,
  nom_producto text not null,
  descripcion  text,
  precio_base  numeric(10,2) not null,
  fk_categoria smallint references categoria(pk_categoria),
  existencias  integer not null default 0,
  estatus      boolean not null default true
);

create table producto_tamano (
  fk_producto      integer references producto(pk_producto) on delete cascade,
  fk_tamano        smallint references tamano(pk_tamano),
  precio_adicional numeric(10,2) not null default 0,
  primary key (fk_producto, fk_tamano)
);

-- ===== PEDIDOS =====
create table estatus_pedido (
  pk_estatus_pedido smallserial primary key,
  nom_estatus       text not null
);

create table pedido (
  pk_pedido         bigserial primary key,
  fk_usuario        integer references usuario(pk_usuario),
  fecha             timestamptz not null default now(),
  total             numeric(10,2) not null default 0,
  fk_estatus_pedido smallint not null default 1 references estatus_pedido(pk_estatus_pedido)
);

create table detalle_pedido (
  pk_detalle      bigserial primary key,
  fk_pedido       bigint references pedido(pk_pedido) on delete cascade,
  fk_producto     integer references producto(pk_producto),
  fk_tamano       smallint references tamano(pk_tamano),
  cantidad        integer not null,
  precio_unitario numeric(10,2) not null
);

-- ===== IMÁGENES DE PRODUCTOS =====
create table imagen_producto (
  pk_imagen    serial primary key,
  fk_producto  integer not null references producto(pk_producto) on delete cascade,
  url          text not null,
  es_principal boolean not null default false,
  orden        smallint not null default 1
);

-- ===== DATOS INICIALES =====
insert into tipo_usu (nom_tipo) values ('Administrador'), ('Cliente');

insert into categoria (nom_categoria, descripcion) values
  ('Bebidas calientes', 'Espressos, capuchinos, lattes y chocolates artesanales.'),
  ('Bebidas frías', 'Cold brew, frappés refrescantes e iced lattes.'),
  ('Panadería', 'Croissants recién horneados, roles de canela y muffins.'),
  ('Postres', 'Rebanadas de pastel, tartas finas y cheesecakes.'),
  ('Alimentos', 'Chapatas, baguettes preparados y sándwiches gourmet.');

insert into tamano (nom_tamano, descripcion_corta) values
  ('Chico', '8 oz / 240 ml'),
  ('Mediano', '12 oz / 360 ml'),
  ('Grande', '16 oz / 480 ml'),
  ('Individual', '1 pieza'),
  ('Doble', '2 piezas');

insert into estatus_pedido (nom_estatus) values
  ('Pendiente'), ('En preparación'), ('Listo para entrega'), ('Entregado'), ('Cancelado');

-- ===== PERSONAS Y USUARIOS DE PRUEBA =====
insert into persona (nom_persona, apaterno, amaterno) values
  ('Mateo', 'Salazar', 'Reyes'),
  ('Valeria', 'Mendoza', 'Cruz');

insert into usuario (nom_usuario, contrasena, fk_persona, fk_tipo_usu) values
  ('admin', 'admin123', 1, 1),
  ('cliente', 'cliente123', 2, 2);
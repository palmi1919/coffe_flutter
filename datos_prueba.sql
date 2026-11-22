-- ==============================================================================
-- DATOS DE PRUEBA: 15 PRODUCTOS CON EXISTENCIAS Y TAMAÑOS (SIN IMÁGENES)
-- ==============================================================================
-- Ejecutar en el SQL Editor de Supabase después de codigo_db.sql.
-- Las imágenes se subirán desde el panel de administración de la aplicación.
-- ==============================================================================

-- 1. Capuchino italiano (Bebidas calientes - Cat: 1)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (1, 'Capuchino italiano', 'Espresso balanceado preparado con granos de altura de Chiapas, leche entera texturizada con una corona densa y espolvoreado con cacao fino.', 58.00, 1, 24, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (1, 1, 0.00),   -- Chico
  (1, 2, 12.00),  -- Mediano
  (1, 3, 22.00);  -- Grande

-- 2. Latte de caramelo salado (Bebidas calientes - Cat: 1)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (2, 'Latte de caramelo salado', 'Doble carga de espresso suave, leche vaporizada y jarabe casero de caramelo tostado con granos de sal marina de Colima.', 65.00, 1, 18, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (2, 1, 0.00),
  (2, 2, 12.00),
  (2, 3, 22.00);

-- 3. Espresso doble especial (Bebidas calientes - Cat: 1)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (3, 'Espresso doble especial', 'Extracción concentrada de 60 ml con notas cítricas a naranja y un regusto persistente a chocolate amargo.', 42.00, 1, 30, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (3, 1, 0.00),   -- 1 shot / Chico
  (3, 5, 14.00);  -- Doble shot

-- 4. Chocolate caliente oaxaqueño (Bebidas calientes - Cat: 1)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (4, 'Chocolate caliente oaxaqueño', 'Tradicional tablilla de cacao criollo molido con canela y almendra, batido en leche con molinillo de madera hasta obtener espuma sedosa.', 55.00, 1, 15, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (4, 1, 0.00),
  (4, 2, 12.00),
  (4, 3, 22.00);

-- 5. Flat white de vainilla natural (Bebidas calientes - Cat: 1)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (5, 'Flat white de vainilla natural', 'Ristretto doble con microespuma de leche aterciopelada infusionada con vaina de vainilla de Papantla.', 60.00, 1, 20, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (5, 1, 0.00),
  (5, 2, 12.00),
  (5, 3, 22.00);

-- 6. Cold brew reserva de la casa (Bebidas frías - Cat: 2)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (6, 'Cold brew reserva de la casa', 'Café macerado en frío durante 18 horas para extraer una acidez aterciopelada y sutiles notas a frutos secos, servido con hielos esfera.', 62.00, 2, 16, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (6, 1, 0.00),
  (6, 2, 12.00),
  (6, 3, 22.00);

-- 7. Frappé moka y avellana (Bebidas frías - Cat: 2)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (7, 'Frappé moka y avellana', 'Bebida cremosa licuada con hielo, espresso intenso, cocoa belga, crema de avellanas y copete de crema batida con chispas de cacao.', 74.00, 2, 12, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (7, 1, 0.00),
  (7, 2, 12.00),
  (7, 3, 22.00);

-- 8. Iced matcha latte (Bebidas frías - Cat: 2)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (8, 'Iced matcha latte', 'Té verde japonés grado ceremonial batido con leche de almendras y toque dulce de agave orgánico, servido sobre hielo fresco.', 68.00, 2, 14, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (8, 1, 0.00),
  (8, 2, 12.00),
  (8, 3, 22.00);

-- 9. Croissant de mantequilla francesa (Panadería - Cat: 3)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (9, 'Croissant de mantequilla francesa', 'Hojaldrado artesanalmente con mantequilla de Nueva Zelanda, corteza dorada y crujiente con un interior tierno y aromático.', 48.00, 3, 10, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (9, 4, 0.00),   -- Individual
  (9, 5, 40.00);  -- Doble (2 pzas)

-- 10. Rol de canela horneado (Panadería - Cat: 3)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (10, 'Rol de canela horneado', 'Masa brioche esponjosa enrollada con canela de Ceilán y azúcar mascabado, cubierta con abundante glaseado de queso crema.', 52.00, 3, 8, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (10, 4, 0.00),
  (10, 5, 45.00);

-- 11. Chocolatín hojaldrado (Panadería - Cat: 3)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (11, 'Chocolatín hojaldrado', 'Pain au chocolat con dos barras internas de chocolate semiamargo al 60% que se funden al hornearse.', 50.00, 3, 6, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (11, 4, 0.00),
  (11, 5, 42.00);

-- 12. Cheesecake neoyorquino con frutos rojos (Postres - Cat: 4)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (12, 'Cheesecake neoyorquino con frutos rojos', 'Tarta de queso crema suave sobre base de galleta crocante con mantequilla, coronada con coulis artesanal de zarzamoras y fresas frescas.', 78.00, 4, 7, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (12, 4, 0.00),
  (12, 5, 70.00);

-- 13. Tiramisú clásico al café (Postres - Cat: 4)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (13, 'Tiramisú clásico al café', 'Soletas bañadas en espresso intenso y licor de café, intercaladas con crema ligera de mascarpone italiano y espolvoreadas con cocoa.', 72.00, 4, 5, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (13, 4, 0.00),
  (13, 5, 65.00);

-- 14. Chapata caprese con pesto (Alimentos - Cat: 5)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (14, 'Chapata caprese con pesto', 'Pan chapata recién horneado con rebanadas de mozzarella fresca, jitomate bola maduro, hojas de albahaca y pesto casero al aceite de oliva.', 95.00, 5, 9, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (14, 4, 0.00),
  (14, 5, 85.00);

-- 15. Baguette de pechuga de pavo y gouda (Alimentos - Cat: 5)
insert into producto (pk_producto, nom_producto, descripcion, precio_base, fk_categoria, existencias, estatus)
values (15, 'Baguette de pechuga de pavo y gouda', 'Baguette rústica con finas láminas de pechuga de pavo ahumada, queso gouda fundido, espinacas baby y mostaza dijon suave.', 98.00, 5, 11, true);

insert into producto_tamano (fk_producto, fk_tamano, precio_adicional) values
  (15, 4, 0.00),
  (15, 5, 88.00);

-- Ajustar el serial de la tabla producto para que las nuevas inserciones arranquen desde el id 16
select setval(pg_get_serial_sequence('producto', 'pk_producto'), 15);

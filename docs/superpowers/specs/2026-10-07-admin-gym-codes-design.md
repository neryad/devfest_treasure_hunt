# Admin Gym Codes Design

## Objetivo

Hacer que el Panel Staff muestre la informacion operativa minima de cada gimnasio para resolver problemas durante el evento sin buscar en el codigo fuente.

## Alcance

La seccion existente `Gestion de tesoros` se mantiene como punto unico para operar gimnasios. Cada fila de gimnasio mostrara:

- Estado activo o inactivo.
- Nombre del gimnasio o reto.
- Cantidad de descubrimientos.
- Codigo manual (`TreasureItem.code`).
- Valor QR (`TreasureItem.qrValue`).

No se agrega edicion de codigos, generacion de QR, Firebase ni exportacion en este cambio.

## Arquitectura

La UI ya recibe `controller.treasures` desde `AppController`. El cambio se limita a `AdminDashboardScreen`: `_TreasureManagement` pasara el `TreasureItem` completo a `_TreasureRow`, y `_TreasureRow` renderizara los campos operativos.

No se modifican entidades, repositorios ni use cases porque los datos ya existen en `TreasureItem` y `MockData`.

## Flujo Staff

1. Staff entra al Panel Staff.
2. Baja a `Gestion de tesoros`.
3. Ve cada gimnasio con su codigo manual y QR value.
4. Puede activar o desactivar el gimnasio con el switch existente.

## Responsive

La informacion se mostrara dentro de la misma lista vertical. Se evitara una tabla porque el panel debe funcionar en movil. Los textos se organizaran como lineas cortas bajo cada gimnasio.

## Testing

Agregar o actualizar un widget test de admin para verificar que el panel muestra al menos un codigo manual y un QR value de los gimnasios seed.

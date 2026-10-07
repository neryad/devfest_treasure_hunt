# DevDex Copy Cleanup Design

## Objetivo

Pulir la app para demo/stakeholders eliminando lenguaje heredado de treasure hunt que confunde la experiencia DevFest Master.

## Alcance

- Renombrar textos visibles `Pokédex` a `DevDex`.
- Ocultar `Pistas` del flujo principal de navegación.
- Cambiar acciones rápidas de Home para hablar de gimnasios/medallas, no tesoros/pistas.
- Cambiar textos visibles del Panel Staff de tesoros a gimnasios/medallas.

No se borraran entidades ni lógica interna `Treasure*` en este bloque para evitar una refactorizacion riesgosa antes de la demo.

## Diseño

La navegación principal quedara:

- Inicio
- DevDex
- Ranking

La pantalla DevDex seguirá usando el componente actual `PokedexScreen`, pero los textos visibles hablaran de DevDex y medallas.

El Home eliminará la card `Mis pistas`. La acción principal seguirá siendo escanear QR o introducir código de gimnasio.

## Testing

Actualizar tests visibles para esperar textos nuevos y que ya no aparezca la pantalla/pestaña Pistas en la navegación principal.

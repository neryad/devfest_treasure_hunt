# Admin Ranking CSV Design

## Objetivo

Permitir que staff saque una copia rapida del ranking desde el Panel Staff durante el evento, sin dependencias nuevas ni flujos especificos por plataforma.

## Alcance

Se agregara un boton `Copiar ranking CSV` en la seccion `Ranking` del Panel Staff. Al tocarlo, la app generara un texto CSV desde `controller.leaderboard`, lo copiara al portapapeles y mostrara un `SnackBar` de confirmacion.

El cambio no descargara archivos, no compartira archivos nativos y no modificara el calculo del ranking.

## Formato CSV

Columnas:

- `position`
- `name`
- `nickname`
- `points`
- `medals`
- `total_medals`
- `elapsed`
- `status`

Cada valor de texto se escapara de forma compatible con CSV: si contiene coma, comillas o salto de linea, se envolvera en comillas dobles y las comillas internas se duplicaran.

## Arquitectura

La generacion de CSV vivira en una funcion pequena y testeable dentro de `admin_dashboard_screen.dart` o en un helper privado del mismo archivo. La UI seguira leyendo `controller.leaderboard`; no se agregan cambios a entidades, repositorios ni use cases.

Para copiar se usara `Clipboard.setData` de Flutter, que no requiere dependencias nuevas.

## Flujo Staff

1. Staff entra al Panel Staff.
2. En `Ranking`, toca `Copiar ranking CSV`.
3. La app copia el CSV al portapapeles.
4. Staff pega el contenido en Google Sheets, Excel, WhatsApp o notas.

## Estados

Si el ranking esta vacio, el CSV incluira solo la fila de headers. El boton seguira disponible para que staff tenga una salida consistente.

## Testing

Se agregaran tests para verificar que el CSV incluye headers, ranking rows y escaping basico. Tambien se agregara o actualizara un widget test para confirmar que el boton aparece en el Panel Staff.

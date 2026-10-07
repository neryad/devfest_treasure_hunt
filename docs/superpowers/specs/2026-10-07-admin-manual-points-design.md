# Admin Manual Points Design

## Objetivo

Permitir que staff corrija puntos de un participante durante el evento sin editar datos manualmente ni recalcular el ranking fuera de la app.

## Alcance

Se agregara una accion `Ajustar puntos` dentro del detalle de participante del Panel Staff. La accion permitira introducir un delta numerico positivo o negativo y aplicar el cambio al total actual del participante.

El cambio no agregara historial de auditoria, roles granulares, Firebase ni motivos obligatorios. La prioridad es resolver errores operativos en vivo con bajo riesgo.

## Reglas

- El ajuste se interpreta como delta, no como total absoluto.
- Se aceptan numeros positivos y negativos.
- El total final no puede bajar de `0` puntos.
- Si el participante no existe, la operacion falla sin cambiar datos.
- Despues de aplicar el ajuste, el ranking se recarga y la UI se notifica.

## Arquitectura

La logica vivira en `AppController` como metodo staff:

```dart
Future<bool> adjustParticipantPoints({
  required String participantId,
  required int delta,
})
```

El metodo usara `ParticipantRepository.getParticipant`, actualizara `points` con `copyWith`, guardara con `updateParticipant`, refrescara leaderboard y llamara `notifyListeners`.

La UI se limitara a `AdminDashboardScreen`: en el modal de detalle de participante se mostrara `Ajustar puntos`, abrira un dialogo con campo numerico y preview de puntos actuales/nuevo total.

## Flujo Staff

1. Staff busca y abre un participante.
2. Toca `Ajustar puntos`.
3. Introduce un delta, por ejemplo `50` o `-20`.
4. La app muestra el nuevo total calculado.
5. Staff confirma con `Aplicar ajuste`.
6. El detalle y el ranking reflejan el nuevo puntaje.

## Estados y Errores

Si el valor esta vacio o no es un entero, el boton de aplicar no ejecutara cambios y el dialogo mostrara un mensaje breve de error.

Si el delta negativo excede los puntos actuales, el resultado se limita a `0`.

## Testing

Se agregaran tests de controller para ajuste positivo, ajuste negativo y limite inferior en cero. Se agregara un widget test para confirmar que staff puede abrir el detalle, aplicar un ajuste y ver los puntos actualizados.

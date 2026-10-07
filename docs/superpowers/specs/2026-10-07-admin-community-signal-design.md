# Admin Community Signal Design

## Objetivo

Dar a staff un flujo claro para validar manualmente la evidencia de Community Signal y otorgar la medalla Comunidad durante el evento.

## Alcance

En el detalle de participante del Panel Staff, si el participante no tiene `gym-community`, se mostrara una accion destacada `Validar Community Signal`. Al tocarla, staff vera una confirmacion y podra otorgar la medalla Comunidad.

El cambio no integrara Instagram, subida de evidencia, auditoria ni Firebase. Staff revisa la evidencia fuera de la app y usa este flujo para registrar la validacion.

## Reglas

- Solo se muestra la accion destacada si `gym-community` esta pendiente.
- Confirmar la accion llama al flujo existente `grantMedal(participantId, gymId: 'gym-community')`.
- Si la medalla ya fue otorgada, no se muestra la accion destacada.
- El boton generico `Otorgar Community` no se duplicara cuando exista la accion destacada.

## Arquitectura

El cambio se limita a `AdminDashboardScreen`. El controller y los repositorios no cambian porque `grantMedal` ya cubre validacion de participante, gimnasio activo, duplicados, puntos, medallas y ranking.

## Flujo Staff

1. Staff busca y abre el detalle de un participante.
2. Staff revisa evidencia de Community Signal fuera de la app.
3. Staff toca `Validar Community Signal`.
4. Staff confirma en el dialogo.
5. La app otorga `gym-community`, actualiza puntos/medallas y refresca el detalle.

## Testing

Se agregara un widget test para abrir el detalle, confirmar `Validar Community Signal` y verificar que el participante recibe `gym-community` y puntos base.

# Product Roadmap — DevFest Treasure Hunt

## Fase 1 · MVP Demo (implementado)

- Registro simple (nombre + alias, id local).
- Dashboard con progreso, tiempo y posición.
- Descubrimiento por QR (`mobile_scanner`) y código manual (misma lógica).
- Modo demo de escaneo para presentaciones.
- 10 tesoros, pistas, descubrimiento libre en cualquier orden.
- `isActive` como único bloqueo, controlado desde el panel admin demo.
- Ranking mock por nº de tesoros y tiempo.
- Pantalla de finalización (sin asumir ganador oficial).
- Persistencia mock detrás de abstracciones (`MockLocalDataSource` +
  `AppLocalStorage`).

## Fase 2 · MVP Real (siguiente)

- Firebase Authentication (email/código del evento).
- Firestore con `events / treasures / participants / discoveries`.
- Ranking en tiempo real calculado por Cloud Functions.
- `isActive` gestionado tras un panel admin con roles.
- QR únicos por participante/tesoro (anti-re-escaneo por otro asistente).
- Escaneo con confirmación de batido/errores (doble escaneo, cámara).
- Mensajes cortos de estado por evento (apertura/cierre).
- Onboarding y correcciones de UX validadas con asistentes reales.

## Fase 3 · Producción

- **Auth:** Firebase Authentication + verificación de participante registrado.
- **Firestore + Security Rules** con reglas transaccionales anti-duplicado.
- **Cloud Functions:** cálculo de ranking, desbloqueo, validación de premios.
- **Firebase Analytics / Crashlytics** y medición de conversión de la dinámica.
- **Panel administrativo real** (web o Flutter) con alta de tesoros, patrocinadores,
  QR por tesoro y temporización.
- **Anti-cheat:** ventanas de activación, distancias entre descubrimientos,
  códigos de verificación del premio al ganador.
- **Gestión de premios:** generación y canje de códigos ganadores.
- **Configuración del evento:** múltiples eventos, plantillas reutilizables.
- **Geolocalización opcional** (bonificación cerca del tesoro, sin ser obligatoria).
- **Estadísticas del evento:** pico de participación, tesoros más/menos
  visitados, embudo de completar el reto.

> Fuera de alcance por ahora: pagos, push masivos, chat, amigos, moderación
> social y analytics avanzado.
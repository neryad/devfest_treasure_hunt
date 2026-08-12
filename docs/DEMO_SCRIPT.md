# Demo Script (~5 minutos) — DevFest Treasure Hunt

Guion pensado para presentar el MVP a los organizadores. Flujo: **app del
asistente → gameplay → ranking → panel admin → cierre**.

---

### 1. El problema (10 s)

> "Durante un evento de 1.000 personas, los asistentes apenas interactúan con
> los stands. Queremos convertir DevFest en un juego: recorrer el venue,
> descubrir tesoros, desbloquear pistas y competir en un ranking."

### 2. Bienvenida (20 s)

Pantalla: **Welcome**.

> "DevFest Treasure Hunt: 10 tesoros escondidos en el evento. Escaneas su QR
> o escribes el código manual. Cada tesoro desbloquea una pista hacia otro.
> Gana quien encuentre todos primero."

Mostrar: los pills `10 tesoros` y `Sin orden obligatorio`.

### 3. Registro (20 s)

Toca **"Comenzar aventura"** → pantalla de registro.

> "Solo nombre y alias. En producción esto será autenticación real, pero para
> evaluar la idea el demo guarda un id local."

Registrar "Demo User".

### 4. Dashboard 0/10 (30 s)

Pantalla: **Home**.

> "El participante ve su progreso, tiempo, posición y cuántos tesoros le
> faltan. 'Te faltan 10 tesoros'. Todo vacío todavía."

Señalar: FAB **"Encontrar tesoro"**.

### 5. Descubrimiento por QR (45 s)

FAB → **"Escanear QR"**. En **modo Demo**, tocar `Tesoro #04`.

Modal: **"¡Tesoro encontrado!"** → botón **"Revelar pista"**.

> "Escaneo el QR del Tesoro #04 que está en la zona de expositores. La app
> valida que exista, que esté activo y que no lo hayas encontrado ya."

Progreso `1/10`.

### 6. Fuera de orden (30 s)

Volver → FAB → **"Introducir código"** → escribir `DEVFEST-002`
(otro tesoro que no es el "siguiente").

> "La pista orienta, pero NO obliga. El participante decide el orden. Aquí
> encontramos el #2 antes que el #1 y la app lo acepta perfectamente."

Progreso `2/10`.

### 7. Contenido descubierto (20 s)

Tabs **Tesoros** y **Pistas**.

> "Lo ya encontrado se marca; lo pendiente solo muestra un número para no
> arruinar la búsqueda. Las pistas aparecen como desbloqueadas 🔓 o
> bloqueadas 🔒."

### 8. Ranking (20 s)

Tab **Ranking**.

> "Los 15 participantes mock ordenados por nº de tesoros y, en empate, por
> tiempo: Carlos 10/10 en 18:32, Ana y Marco completaron después. Eso se
> calcula igual desde Firebase."

### 9. Panel admin — disponibilidad (60 s)

Icono admin (AppBar) → **Panel admin demo**.

> "El organizador ve métricas del evento y puede activar/desactivar tesoros
> en vivo. Voy a desactivar el #03."

Switch OFF en Tesoro #03 → vuelta al participante → escaneo manual
`DEVFEST-003` → Snackbar **"No disponible todavía: este tesoro está
desactivado"**.

> "Si un patrocinador llegara tarde, el tesoro de su stand se desactiva hasta
> que esté listo. El descubrimiento no se registra."

Reactivar el #03.

### 10. Compleción (45 s)

> "Para cerrar rápido, activo #03 y completo los 10."

(Truco: usar el modo Demo del escáner + códigos manuales de los 6 restantes;
o bien en el panel admin el "reset" para empezar de cero otra vez.)

Pantalla: **"¡Completaste la aventura!"** con tiempo, tesoros y posición.

> "Importante: completar el reto no equivale a ganar. La posición final la
> define el ranking oficial; en producción el organizador verifica al ganador
> con un código del premio."

### 11. Cierre (30 s)

> "Todo esto funciona 100% offline con datos mock, y la arquitectura está
> lista para Firebase: basta intercambiar la data source — ni una pantalla
> cambia. Para producción: auth, ranking en tiempo real con Cloud Functions,
> QR únicos por participante y panel admin real."

**Pregunta clave al terminar:** *"¿Qué premio verías funcionando para este
tipo de dinámica?"*
# DevFest Master - Diseno de Retos y Medallas

## Objetivo

Convertir el juego actual de caza de tesoros en una experiencia de gamificacion para DevFest basada en 8 gimnasios tecnologicos. Cada gimnasio entrega una medalla al completar una mision corta, clara y facil de operar durante el evento.

La experiencia no debe sentirse como una lista de cuestionarios. Aunque varias medallas usen preguntas, cada una debe tener identidad propia, narrativa y una mecanica diferenciada.

## Concepto General

El participante se registra en la app y ve 8 medallas bloqueadas. Para convertirse en DevFest Master debe completar los 8 gimnasios tecnologicos:

1. Android
2. IA
3. Security
4. Web
5. Startup
6. Cloud
7. Speaker
8. Comunidad

Cada medalla debe cumplir estas reglas:

- Tener una mision corta.
- Tener una condicion clara para ganar.
- Ser completada en 1 a 5 minutos, excepto Security, que puede tomar mas por ser busqueda fisica.
- Tener validacion automatica cuando sea posible.
- Tener un codigo manual de respaldo para staff.

## Modelo de Intentos y Ranking

Los participantes pueden intentar los retos varias veces. La experiencia prioriza participacion y evita frustracion, pero el ranking premia precision y velocidad.

Puntuacion recomendada:

```text
Medalla completada: +100 puntos
Correcto al primer intento: +30 puntos extra
Correcto al segundo intento: +15 puntos extra
Correcto desde el tercer intento: +0 puntos extra
Primero en completar una medalla: +20 puntos extra
Completar las 8 medallas: +100 puntos extra
```

No se recomienda cooldown global. Si se quiere limitar spam, usar una regla suave solo despues de 3 fallos consecutivos.

## Distribucion de Medallas

| Medalla | Nombre del reto | Tipo | Validacion principal | Responsable |
|---|---|---|---|---|
| Android | Debug Droid | Quiz tecnico | App | App |
| IA | Prompt Master | Quiz de charla | App | App |
| Security | The Hidden Exploit | Busqueda fisica | Codigo final | App + staff |
| Web | Pixel Perfect | Quiz visual/frontend | App | App |
| Startup | Runway Rush | Mini juego | Puntaje objetivo | App |
| Cloud | Scale the Cloud | Quiz arquitectura | App | App |
| Speaker | Hall of Voices | Trivia de charlas | App | App o staff |
| Comunidad | Community Signal | Reto social | Codigo por DM | Staff + app |

## Android - Debug Droid

### Mision

Demostrar dominio basico de Android, Kotlin o Jetpack Compose.

### Flujo

1. El usuario toca la medalla Android.
2. La app muestra 3 preguntas tecnicas.
3. Las preguntas son de opcion multiple.
4. Al responder correctamente, gana la medalla.

### Ejemplos de preguntas

```text
Que funcion tiene remember en Jetpack Compose?
Que archivo define permisos Android?
Que hace un ViewModel?
```

### Responsable

App.

### Plan B

Staff puede entregar un codigo Android si la app falla.

## IA - Prompt Master

### Mision

Responder 4 preguntas basadas en la charla de Carmelo.

### Flujo

1. La medalla se activa durante o despues de la charla.
2. El usuario responde 4 preguntas.
3. Las preguntas deben estar basadas en cosas mencionadas por Carmelo.
4. Al completar, gana la medalla.

### Ejemplos de preguntas

```text
Que herramienta menciono Carmelo para trabajar con agentes?
Que riesgo destaco sobre IA generativa?
Que diferencia hay entre un prompt simple y un flujo agentic?
```

### Responsable

App.

### Plan B

Staff entrega un codigo IA al final de la charla.

## Security - The Hidden Exploit

### Mision

Encontrar pistas fisicas en el venue y descifrar un codigo final.

### Flujo

1. El usuario toca la medalla Security.
2. La app muestra el primer acertijo.
3. El acertijo lo lleva a un QR fisico.
4. Cada QR revela una pista o fragmento.
5. Al juntar todos los fragmentos, el usuario introduce el codigo final.
6. La app valida el codigo y entrega la medalla.

### Ejemplo

```text
Pista inicial: Donde los paquetes descansan antes de salir a produccion.
QR 1 revela: SEC
QR 2 revela: URE
QR 3 revela: 2026
Codigo final: SECURE2026
```

### Responsable

App y staff que coloca los QR fisicos.

### Plan B

Staff tiene el codigo final impreso o disponible en el panel admin.

## Web - Pixel Perfect

### Mision

Resolver retos de UI, frontend o accesibilidad.

### Flujo

1. El usuario toca la medalla Web.
2. La app muestra 3 preguntas visuales o frontend.
3. Puede incluir preguntas de HTML, CSS, responsive design, UX o accesibilidad.
4. Al responder correctamente, gana la medalla.

### Ejemplos de preguntas

```text
Cual boton tiene mejor contraste?
Que etiqueta HTML es mas semantica para navegacion?
Que layout se adapta mejor a movil?
```

### Responsable

App.

### Plan B

Codigo manual Web.

## Startup - Runway Rush

### Mision

Sobrevivir en un mini juego y alcanzar una meta de puntaje.

### Flujo

1. El usuario toca la medalla Startup.
2. Entra a un mini juego estilo dinosaurio o flappy.
3. Debe llegar a una puntuacion objetivo.
4. Al lograrlo, gana la medalla.

### Concepto narrativo

El jugador representa una startup evitando obstaculos como bugs, falta de funding, churn y errores de deploy.

La narrativa puede hablar de llegar a 1 millon de puntos, pero la meta real debe ser corta para que el reto no tome demasiado tiempo.

### Responsable

App.

### Plan B

Si hay problema tecnico, staff entrega codigo Startup.

## Cloud - Scale the Cloud

### Mision

Responder preguntas de arquitectura cloud, Firebase, GCP o CI/CD.

### Flujo

1. El usuario toca la medalla Cloud.
2. Responde 3 preguntas.
3. Las preguntas evaluan conceptos practicos de cloud.
4. Al completar, gana la medalla.

### Ejemplos de preguntas

```text
Que servicio usarias para base de datos en tiempo real?
Que ventaja tiene serverless?
Que practica ayuda a evitar secretos en el repo?
```

### Responsable

App.

### Plan B

Codigo manual Cloud.

## Speaker - Hall of Voices

### Mision

Probar que el participante estuvo atento a las charlas.

### Flujo

1. El usuario toca la medalla Speaker.
2. La app muestra preguntas sobre speakers o charlas.
3. Las preguntas pueden ser rotativas por dia.
4. Al responder correctamente, gana la medalla.

### Ejemplos de preguntas

```text
De que pais vino el speaker X?
Que tema presento la speaker Y?
Que herramienta mencionaron en la charla de IA?
```

### Recomendacion

No hacer obligatoria la selfie con speaker. Puede existir como bonus social, pero no como requisito principal, para evitar carga operativa y friccion con los speakers.

### Responsable

App. Opcionalmente staff o speaker puede entregar codigo al final de una charla.

### Plan B

Codigo entregado por staff o speaker.

## Comunidad - Community Signal

### Mision

Activar networking, redes sociales y visibilidad del evento.

### Flujo

1. El usuario toca la medalla Comunidad.
2. La app muestra instrucciones del reto social.
3. El usuario sube una selfie, story o post del evento.
4. Etiqueta a GDG Santo Domingo.
5. Etiqueta a 5 personas o menciona a su equipo.
6. Agrega un comentario sobre su experiencia.
7. Envia captura o evidencia por DM.
8. Un humano revisa el DM y responde con un codigo.
9. El usuario introduce el codigo en la app.
10. Gana la medalla.

### Responsable

Staff que maneja Instagram/DM y app que valida el codigo.

### Plan B

Si Instagram falla, staff valida presencialmente y entrega el codigo.

## Responsabilidades Operativas

### App

- Mostrar medallas y progreso.
- Ejecutar quizzes.
- Validar respuestas.
- Ejecutar mini juego Startup.
- Escanear QR de Security.
- Validar codigos finales.
- Calcular puntos y ranking.

### Staff

- Colocar QR fisicos de Security.
- Tener codigos de respaldo por medalla.
- Manejar DM de Instagram para Comunidad.
- Entregar codigos manuales si una dinamica falla.

### Speakers

- Opcionalmente compartir una pista o codigo al final de una charla.
- No deben cargar con validaciones complejas durante el evento.

## Riesgos y Mitigaciones

| Riesgo | Mitigacion |
|---|---|
| Un QR fisico se pierde | Staff tiene codigo final de respaldo |
| Instagram/DM se satura | Validacion presencial alternativa |
| Participantes adivinan respuestas | Bonus solo al primer o segundo intento |
| Demasiadas medallas son quizzes | Diferenciar narrativa, UI y mecanica por medalla |
| Mini juego toma demasiado tiempo | Meta corta y dificultad baja |
| Speaker no esta disponible | Trivia en app o codigo entregado por staff |

## Prioridades de Preparacion

1. Security, porque requiere QR fisicos y ubicaciones.
2. IA, porque depende del contenido de la charla de Carmelo.
3. Comunidad, porque necesita una persona manejando Instagram/DM.
4. Startup, porque requiere una mecanica jugable estable.
5. Android, Web, Cloud y Speaker, porque pueden resolverse con contenido cargado en app.

## Proximos Pasos

1. Definir las preguntas reales de Android, IA, Web, Cloud y Speaker.
2. Definir los acertijos y ubicaciones fisicas de Security.
3. Definir el codigo y reglas exactas del reto Comunidad.
4. Definir la meta real del mini juego Startup.
5. Preparar codigos manuales de respaldo para cada medalla.
6. Convertir este diseno en plan de implementacion cuando el contenido este aprobado.

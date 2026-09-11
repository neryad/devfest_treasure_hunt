# DevFest Treasure Hunt
## Propuesta de Gamificación — DevFest Master

**Preparado por:** Neryad  
**Fecha:** Septiembre 2026  
**Demo funcional:** https://demo-dev-tesoros.netlify.app/

---

## El Punto de Partida

Actualmente existe un MVP funcional de caza del tesoro para DevFest. Los asistentes se registran, escanean códigos QR repartidos por el venue, descubren tesoros, desbloquean pistas y compiten en un ranking en tiempo real.

La propuesta es llevar esa experiencia al siguiente nivel: convertirla en una experiencia de gamificación completa que mezcle escaneo, trivia técnica, acertijos y retos de código, todo bajo una narrativa temática que haga que los asistentes quieran participar activamente desde que llegan hasta el cierre del evento.

---

## La Idea Central — DevFest Master

> *En Pokémon, un entrenador debe conquistar 8 gimnasios y conseguir sus medallas para convertirse en el Campeón. Aquí, cada área o stand del DevFest es un **Gimnasio Tecnológico**. Solo quien supere los 8 se convierte en **DevFest Master**.*

La narrativa funciona perfectamente para este público: genera nostalgia, tiene una meta clara (8 medallas), obliga a recorrer todo el venue y fomenta que la gente asista a las charlas. La mecánica es universalmente conocida por la comunidad tech, sin necesidad de explicación.

> **Nota de marca:** La mecánica es inspirada en Pokémon, pero el nombre, los personajes y todos los elementos visuales son completamente originales. No se usa ningún activo con copyright de Nintendo.

---

## Los 8 Gimnasios Tecnológicos

Cada stand o área del evento se convierte en un gimnasio con su propia medalla y tipo de reto:

| # | Gimnasio | Tecnología | Tipo de reto |
|---|---|---|---|
| 🤖 | Gimnasio Android | Android / Kotlin | Pregunta de código |
| 🌐 | Gimnasio Web | Flutter Web / PWA | Acertijo de UI/UX |
| ☁️ | Gimnasio Cloud | Firebase / GCP | Pregunta de arquitectura |
| 🧠 | Gimnasio IA | Gemini / ML | Reto de lógica / prompt |
| 🔒 | Gimnasio Seguridad | DevSecOps | Acertijo de seguridad |
| 💻 | Gimnasio Code | DSA / Algoritmos | Mini reto de lógica |
| 🎙️ | Gimnasio Speaker | Charlas del evento | Pregunta sobre una charla |
| 🌟 | Gimnasio Comunidad | Open Source / GDG | Escaneo + trivia |

> Los gimnasios se adaptan según los stands, patrocinadores y charlas del evento real.

---

## Tipos de Retos

### 🔍 Escaneo QR
El reto más sencillo: encontrar el QR físico en el venue y escanearlo. Punto de entrada al reto del gimnasio. Ya implementado en el MVP.

### ❓ Trivia Técnica
Pregunta de opción múltiple sobre tecnología o sobre el evento. Con un timer de 60 segundos. Si la respuesta es incorrecta, hay un cooldown de 5 minutos antes de intentarlo de nuevo (evita el spam y la aleatoriedad).

Ejemplos:
- *"¿Cuál es el ciclo de vida de un Activity en Android?"*
- *"¿Qué protocolo usa Firebase Realtime Database?"*

### 🧩 Acertijos
Una pista que lleva a un lugar físico del venue o a un código oculto.

Ejemplos:
- *"Soy el lugar donde el café se convierte en código. ¿Dónde estoy?"*
- *"Tengo miles de estrellas pero ninguna es del cielo. ¿Qué soy?"*

### 💻 Retos de Código (sin escribir)
Un snippet de código incompleto o una pregunta de razonamiento. No se necesita teclear código, solo pensar.

Ejemplos:
- *"¿Qué devuelve esta función en Dart?"* — 4 opciones de respuesta
- *"¿Cuál es la complejidad de este algoritmo?"*

### 🎯 Retos de Completar
El participante realiza una acción en el mundo real que el administrador verifica.

Ejemplos:
- *"Hazte una foto con el speaker de la charla de IA y muéstrala"*
- *"Deja una pregunta en el tablón de la comunidad"*

### 🤝 Retos Sociales
Requieren interactuar con otros asistentes o con el equipo del evento.

Ejemplos:
- *"Encuentra a alguien con badge de Speaker y pídele su código especial"*
- *"Forma equipo con otro participante para resolver este acertijo de dos partes"*

---

## Sistema de Medallas y Recompensas

La progresión es visible y motivadora. No hace falta completar todo para recibir algo:

| Medallas | Título | Recompensa sugerida |
|---|---|---|
| 1 – 2 | 🥉 Aprendiz Tech | Sticker digital / reconocimiento |
| 3 – 4 | 🥈 Developer | Cupón de descuento GDG |
| 5 – 6 | 🥇 Senior Dev | Acceso a sesión VIP o taller |
| 7 | 💎 Lead Engineer | Merchandising exclusivo |
| 8 | 🏆 **DevFest Master** | Premio principal + reconocimiento en escenario |

### Cómo se calcula el ranking

1. Número de medallas conseguidas (mayor es mejor)
2. Puntos por tipo de reto (los retos más difíciles dan más puntos)
3. Tiempo total (menor es mejor, como desempate)
4. Bonus por velocidad: el primero en completar cada reto gana puntos extra

---

## Flujo de la Experiencia

```
LLEGADA AL EVENTO
       │
       ▼
  [Registro en la app]
  Nombre + Alias + Elige tu avatar (😎 / 🦊 / 🐉)
       │
       ▼
  [Tu "DevFest Pokédex"]
  8 slots de medalla vacíos — ranking — tiempo transcurrido
       │
       ▼
  [Exploras el venue y encuentras un Gimnasio]
  Escaneas el QR físico del stand
       │
       ▼
  [Pantalla del Reto]
  "¡Gimnasio Cloud! Demuestra que dominas Firebase..."
  Trivia / Acertijo / Código — timer 60 seg
       │
       ├── ✅ Correcto → Animación de medalla 🏅
       │              → Pista desbloqueada
       │              → Ranking actualizado
       │
       └── ❌ Incorrecto → Cooldown 5 min
                        → "El Líder del Gimnasio te desafía de nuevo..."
       │
       ▼
  [Al completar los 8 gimnasios]
  Pantalla de DevFest Master 🏆
  Posición final · Tiempo · Certificado digital descargable
```

---

## Lo Que Ya Existe (MVP Actual)

El MVP funcional ya incluye:

- ✅ Registro de participantes (nombre + alias)
- ✅ Escaneo de QR físico y código manual
- ✅ Sistema de tesoros con control de disponibilidad desde el admin
- ✅ Pistas desbloqueadas al descubrir cada tesoro
- ✅ Ranking en tiempo real
- ✅ Panel de administración completo
- ✅ Arquitectura lista para conectar a Firebase sin rehacer la app

---

## Lo Que Hay Que Agregar

### Para el evento (corto plazo)
- Tipos de reto por gimnasio (trivia, acertijo, código)
- Pantalla del reto con timer y validación
- Sistema de intentos y cooldown
- Progreso visual tipo Pokédex (8 slots con estado)
- Animación de medalla al completar un gimnasio
- Ranking con puntos (no solo por cantidad)

### Post-evento (mediano plazo)
- Firebase Authentication
- Firestore en tiempo real
- Panel admin web para crear y editar retos
- Sistema de aprobación de retos manuales
- Analytics del evento

---

## Ideas Bonus

- **El Cuarto de Élite:** Los top 4 del ranking al final del evento compiten en vivo en el escenario
- **Tesoro Secreto:** Un gimnasio extra no listado que aparece solo si completas los 8 en menos de 2 horas
- **Modo Equipo:** 2-3 personas, uno escanea mientras el otro responde
- **Historia por capítulos:** Cada charla desbloquea un fragmento del lore del DevFest Master
- **Certificado coleccionable:** "DevFest Master [Ciudad] [Año]" en PDF o digital

---

## Paleta de Colores Oficial — GDG

Fuente: [gdgportharcourt.com.ng/brand-guidelines](https://gdgportharcourt.com.ng/brand-guidelines)

### Core Colors
| Color | HEX | Uso |
|---|---|---|
| 🔵 Blue 500 | `#4285F4` | Color primario — botones, badges, acentos |
| 🟢 Green 500 | `#34A853` | Éxito — medalla desbloqueada, completado |
| 🟡 Yellow 600 | `#F9AB00` | Recompensas, puntos, energía |
| 🔴 Red 500 | `#EA4335` | Errores, cooldown, tesoro inactivo |

### Halftones
| Color | HEX |
|---|---|
| Halftone Blue | `#57CAFF` |
| Halftone Green | `#5CDB6D` |
| Halftone Yellow | `#FFD427` |
| Halftone Red | `#FF7DAF` |

### Pastels
| Color | HEX |
|---|---|
| Pastel Blue | `#C3ECF6` |
| Pastel Green | `#CCF6C5` |
| Pastel Yellow | `#FFE7A5` |
| Pastel Red | `#F8D8D8` |

### Neutros
| Color | HEX |
|---|---|
| Off White | `#F0F0F0` |
| Black 02 | `#1E1E1E` |

---

## Prompt para IA — Generación de Assets Visuales

Para generar cualquier pieza visual que respete la identidad de GDG:

```
Identidad de marca: GDG (Google Developer Groups) — DevFest Treasure Hunt / DevFest Master
Paleta oficial: Google Developer Groups brand colors

CORE:
- Azul:    #4285F4  → botones, badges, acentos
- Verde:   #34A853  → éxito, logros, medallas
- Amarillo:#F9AB00  → recompensas, puntos
- Rojo:    #EA4335  → alertas, errores

HALFTONES (highlights):
- #57CAFF / #5CDB6D / #FFD427 / #FF7DAF

PASTELS (fondos suaves):
- #C3ECF6 / #CCF6C5 / #FFE7A5 / #F8D8D8

NEUTROS:
- Fondo dark:  #1E1E1E
- Fondo light: #F0F0F0

ESTILO:
- Tipografía: Google Sans. Bold para títulos.
- Bordes redondeados 16-18px.
- Accesibilidad WCAG AA.
- Gamificado pero profesional.
- Iconografía: Google Material Symbols.
- Referencias: Google I/O, Duolingo, Material 3.
```

---

## Propuesta de Timeline

| Semana | Hito |
|---|---|
| Semana 1 | Alinear narrativa + definir los 8 gimnasios y sus retos |
| Semana 2 | Desarrollo: tipos de reto en el modelo + pantalla de reto |
| Semana 3 | Visualización Pokédex / badges + animaciones |
| Semana 4 | QR físicos impresos + integración Firebase básica |
| Semana 5 | Testing con voluntarios + ajustes finales |
| **Evento** | 🚀 Launch |

---

## Próximos Pasos

1. Reunión para alinear narrativa, alcance y premios
2. Definir los 8 retos de contenido (preguntas, acertijos)
3. Confirmar cuántos stands/áreas participan como gimnasios
4. Kickoff de desarrollo de la siguiente fase

---

*Demo disponible en: https://demo-dev-tesoros.netlify.app/*

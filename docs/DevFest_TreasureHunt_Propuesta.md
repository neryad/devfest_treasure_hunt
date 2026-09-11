# 🏆 DevFest Treasure Hunt — Propuesta de Gamificación Extendida

> **Preparado para:** Eury Pérez / Organización DevFest  
> **Preparado por:** Neryad (con apoyo de IA)  
> **Demo actual:** [demo-dev-tesoros.netlify.app](https://demo-dev-tesoros.netlify.app/)  
> **Fecha:** Septiembre 2026

---

![DevFest Master — Conquista los 8 Gimnasios Tecnológicos](/Users/neryad/.gemini/antigravity/brain/83674728-a504-4548-b8f5-f2138910d2cd/devfest_master_banner.png)

---

## 🎯 Resumen Ejecutivo

Tenemos un MVP funcional de caza del tesoro para DevFest. La propuesta es llevarlo al siguiente nivel convirtiéndolo en una experiencia de gamificación completa que mezcle **escaneo de QR, preguntas técnicas, retos de código y acertijos** — todo bajo una narrativa temática que haga que los asistentes quieran participar activamente.

Proponemos dos variantes de narrativa (y puedes elegir una o combinarlas):

---

## 🗺️ Opción A — DevFest Quest: La Búsqueda del Tesoro (Evolución del MVP)

La experiencia original, potenciada con nuevos tipos de desafíos.

## 🔴 Opción B — DevFest Master: Conviértete en el Maestro Pokémon del Dev

> **La idea:** En Pokémon, el entrenador debe conquistar 8 gimnasios y conseguir 8 medallas para convertirse en el Campeón. Aquí, cada stand/área del DevFest es un **Gimnasio Tecnológico**, y para convertirse en **DevFest Master** hay que superar el reto de cada uno.

---

## 🔴 OPCIÓN B EN DETALLE — DevFest Master

### La Narrativa

> *"El mundo del tech está en peligro. Los saberes de Android, Web, Cloud, IA y más han quedado dispersos por el venue del DevFest. Solo un verdadero DevFest Master puede reunir todas las medallas, dominar las 8 disciplinas y salvar el ecosistema. ¿Tienes lo que se necesita?"*

### Los 8 Gimnasios Tecnológicos

Cada área/stand del evento se convierte en un **Gimnasio** con su propia medalla:

| # | Gimnasio | Tecnología | Tipo de reto |
|---|---|---|---|
| 🤖 | Gimnasio Android | Android / Kotlin | Pregunta técnica de código |
| 🌐 | Gimnasio Web | Flutter Web / PWA | Acertijo de UI/UX |
| ☁️ | Gimnasio Cloud | Firebase / GCP | Pregunta de arquitectura |
| 🧠 | Gimnasio IA | Gemini / ML | Reto de prompt / lógica |
| 🔒 | Gimnasio Seguridad | DevSecOps | Acertijo de seguridad |
| 💻 | Gimnasio Code | DSA / Algoritmos | Mini reto de lógica |
| 🎙️ | Gimnasio Speaker | Charlas del evento | Pregunta sobre una charla |
| 🌟 | Gimnasio Comunidad | Open Source / GDG | Reto de escaneo + trivia |

### Cómo funciona

```
1. Registro → Recibes tu "Pokédex DevFest" (perfil con 8 espacios vacíos de medalla)
2. Encuentras el QR del gimnasio → Escaneas
3. Aparece el reto del gimnasio (pregunta / acertijo / código)
4. Respondes correctamente → ¡Medalla desbloqueada! 🏅
5. Completas los 8 gimnasios → "DevFest Master" 🏆
```

### ¿Por qué funciona esta narrativa?

- ✅ **Nostalgia + cultura geek** — Pokémon es universalmente reconocido en la comunidad tech
- ✅ **Estructura clara** — los asistentes saben exactamente qué hacer (8 medallas = meta)
- ✅ **Exploración del venue** — obliga a visitar todos los stands y charlas
- ✅ **Competencia sana** — ranking de quién tiene más medallas en tiempo real
- ✅ **Recompensas escalonadas** — no hay que completar todo para ganar algo

---

## 🎮 Tipos de Retos (para ambas opciones)

Basado en la petición de Eury: *"escaneo, preguntas, retos (acertijos, de código), tema de completar cosas"*

### 🔍 Tipo 1 — Escaneo QR
- El reto más básico: encontrar el QR físico en el venue
- Ya implementado en el MVP ✅
- **Extensión propuesta:** QR dinámicos que cambian de ubicación durante el evento (admin lo controla)

### ❓ Tipo 2 — Preguntas de Trivia Tech
- Pregunta de opción múltiple sobre tecnología o sobre el evento
- Ejemplos:
  - *"¿Cuál es el ciclo de vida de un Activity en Android?"*
  - *"¿Qué protocolo usa Firebase Realtime Database?"*
  - *"¿Cuántos eventos ha organizado GDG [ciudad] este año?"*
- Tiempo límite de 60 segundos para responder
- Respuesta incorrecta → espera de 5 minutos antes de intentar de nuevo (anti-spam)

### 🧩 Tipo 3 — Acertijos
- Pistas que llevan a una ubicación física o a un código
- Ejemplos:
  - *"Soy el lugar donde el café se convierte en código. ¿Dónde estoy?"* → Cafetería
  - *"Tengo miles de estrellas pero ninguna es del cielo. ¿Qué soy?"* → Repositorio de GitHub
- Resuelven el acertijo → reciben el código del tesoro

### 💻 Tipo 4 — Retos de Código (mini)
- Snippet incompleto que hay que completar (visible en la app)
- Ejemplos:
  - *"¿Qué devuelve esta función en Dart?"* → 4 opciones
  - *"Completa la línea que falta para que el Widget compile"*
  - *"¿Cuál es la complejidad de este algoritmo?"*
- Diseñados para ser resolubles en 2-3 minutos
- **No se necesita escribir código**, solo razonar

### 🎯 Tipo 5 — Retos de Completar
- El participante completa una acción en el mundo real
- Ejemplos:
  - *"Hazte una foto con el speaker de la charla de IA"* → sube foto
  - *"Síguenos en LinkedIn y muéstralo"*
  - *"Deja una pregunta en el tablón de la comunidad"*
- El admin verifica y aprueba manualmente desde el panel

### 🤝 Tipo 6 — Retos Sociales / Colaborativos
- Requieren interactuar con otros participantes
- Ejemplos:
  - *"Encuentra a alguien con el badge de Speaker y pídele su código especial"*
  - *"Forma equipo con otro participante para resolver este acertijo de 2 partes"*

---

## 🏅 Sistema de Recompensas y Niveles

### Medallas / Logros progresivos

| Medallas conquistadas | Título | Recompensa |
|---|---|---|
| 1-2 | 🥉 Aprendiz Tech | Sticker digital |
| 3-4 | 🥈 Developer | Cupón de descuento GDG |
| 5-6 | 🥇 Senior Dev | Entrada a sesión VIP / taller |
| 7 | 💎 Lead Engineer | Merchandising exclusivo |
| 8 | 🏆 **DevFest Master** | Premio principal + reconocimiento en escenario |

### Puntuación

La posición en el ranking se determina por:
1. **Número de retos completados** (desc)
2. **Puntos por tipo de reto** (los más difíciles dan más puntos)
3. **Tiempo total** (asc, como desempate)
4. **Bonificación por velocidad** (primero en completar cada reto = puntos extra)

---

## 🔧 Qué hay que agregar al MVP actual

### Lo que ya existe ✅
- Registro de participantes
- Escaneo de QR y código manual
- Sistema de tesoros con estado (activo/inactivo)
- Pistas desbloqueadas al descubrir
- Ranking en tiempo real
- Panel de administración
- Arquitectura preparada para Firebase

### Nuevas features a desarrollar 🚀

#### Corto plazo (para el evento)
- [ ] **Tipos de reto por tesoro/gimnasio** — agregar `challengeType` y `challengeData` a `TreasureItem`
- [ ] **Pantalla de reto** — UI para trivia, acertijo o reto de código antes de revelar el tesoro
- [ ] **Sistema de intentos y cooldown** — no permitir spam en respuestas
- [ ] **Progreso visual tipo Pokédex** — 8 gimnasios con estado visual (vacío/conquistado)
- [ ] **Notificación de medalla** — animación satisfactoria al conseguir cada medalla
- [ ] **Ranking con puntos** — no solo por cantidad, también por tipo de reto

#### Mediano plazo (post-evento)
- [ ] Firebase Authentication
- [ ] Firestore en tiempo real
- [ ] Panel admin web para crear/editar retos
- [ ] Sistema de aprobación de retos manuales (fotos, verificaciones)
- [ ] Analytics del evento

---

## 📱 Flujo de Usuario (experiencia completa)

```
INICIO
  │
  ▼
[Pantalla de Bienvenida] 
  "¡Bienvenido, futuro DevFest Master!"
  "Tienes que conquistar 8 Gimnasios Tecnológicos"
  │
  ▼
[Registro] → Nombre + Alias + "elige tu starter" (avatar emoji 😎/🦊/🐉)
  │
  ▼
[Pokédex DevFest / Dashboard]
  8 slots de medalla vacíos + ranking + tiempo transcurrido
  │
  ▼
[Encuentra un Gimnasio]
  Escaneas QR físico en el stand → app identifica el gimnasio
  │
  ▼
[Pantalla de Reto del Gimnasio]
  "¡Gimnasio Cloud! Demuestra que dominas Firebase..."
  [Trivia / Acertijo / Código] con timer de 60s
  │
  ├── Correcto ──▶ [Animación de medalla 🏅] → Pista desbloqueada → Dashboard actualizado
  │
  └── Incorrecto ▶ [Cooldown 5min] → "El Líder del Gimnasio te desafía de nuevo más tarde..."
  │
  ▼
[Al completar los 8] → [Pantalla de DevFest Master] 🏆
  Posición final, tiempo, certificado digital descargable
```

---

## 🎨 Dirección Visual

### Para la Opción B (DevFest Master / Pokémon-inspired)

- **Colores:** Mantener los colores de GDG (azul, rojo, verde, amarillo) mapeados a los 4 tipos de Pokémon (agua, fuego, planta, eléctrico)
- **Iconos de medalla:** Cada gimnasio tiene su badge único con logo de la tecnología
- **Pantalla de perfil:** Muestra los 8 badges como una Pokédex horizontal
- **Animaciones:** Revelar medalla con efecto de "badge earned" tipo videojuego
- **Lenguaje:** Mezcla de gaming y tech ("¡Has vencido al Líder Cloud!", "Tu ranking de entrenador")

---

## ❓ Preguntas Abiertas / Decisiones

> [!IMPORTANT]
> Estas decisiones impactan el alcance del desarrollo antes del evento.

1. **¿Cuántos tipos de retos quieren para el primer evento real?**
   - Opción mínima: solo QR + trivia
   - Opción completa: los 6 tipos descritos

2. **¿La narrativa Pokémon / DevFest Master o prefieren algo más neutro?**
   - Si hay restricciones de marca con Nintendo, podemos crear lore propio
   - Alternativa: "DevFest Hero: Las 8 Pruebas del Conocimiento"

3. **¿Cuántos stands/gimnasios tendría el evento real?** — Esto define cuántos tesoros crear

4. **¿Habrá premios físicos o solo digitales/reconocimiento?** — Impacta el sistema de verificación

5. **¿El evento es en una sola ciudad o planean multi-sede?** — Impacta la arquitectura Firebase

6. **¿Hay patrocinadores que quieran tener su propio gimnasio?** — Oportunidad de patrocinio para stands

---

## 🗓️ Propuesta de Timeline

| Semana | Hito |
|---|---|
| Semana 1 | Decisión de narrativa + diseño de los 8 retos de contenido |
| Semana 2 | Desarrollo: `challengeType` en modelo + pantalla de reto |
| Semana 3 | Visualización Pokédex/badges + animaciones |
| Semana 4 | QR físicos impresos + integración Firebase básica |
| Semana 5 | Testing con voluntarios + ajustes |
| Evento | 🚀 Launch |

---

## 💡 Ideas Bonus (para futuro)

- **"El Cuarto de Elite"** — Los top 4 del ranking al finalizar el evento compiten en un reto en vivo en el escenario
- **Reto secreto:** Un tesoro extra no listado que solo aparece si completas los 8 en menos de 2 horas
- **Modo Team:** Equipos de 2-3 personas, uno escanea mientras el otro responde
- **Historia en capítulos:** Cada charla del evento desbloquea una parte de la historia de lore del DevFest Master
- **Certificado digital** NFT/PDF del "DevFest Master [Ciudad] [Año]" — coleccionable

---

> 💬 *"La mezcla de cultura Pokémon + comunidad tech es perfecta: genera nostalgia, es universalmente entendida por el público objetivo, tiene una mecánica clara (8 medallas = meta), y por sobre todo — hace que la gente QUIERA recorrer todo el venue y participar en todas las charlas."*

---

**Próximos pasos:**
1. ✅ Reunión para alinear narrativa y alcance
2. 📋 Definir los 8 retos de contenido (preguntas, acertijos, etc.)
3. 🛠️ Kickoff de desarrollo de la siguiente fase

---

## 🎨 Paleta Oficial GDG — DevFest Treasure Hunt

> Fuente oficial: [gdgportharcourt.com.ng/brand-guidelines](https://gdgportharcourt.com.ng/brand-guidelines)

La paleta tiene 3 capas: **Core** (colores base del brand), **Halftones** (vibrantes, para highlights) y **Pastels** (suaves, para fondos y estados).

### Core Colors
| | Nombre | HEX | Uso en la app |
|---|---|---|---|
| 🔵 | Blue 500 | `#4285F4` | Color primario — botones, badges, acentos principales |
| 🟢 | Green 500 | `#34A853` | Éxito — tesoro encontrado, medalla desbloqueada, completado |
| 🟡 | Yellow 600 | `#F9AB00` | Atención — recompensas, puntos, alertas importantes |
| 🔴 | Red 500 | `#EA4335` | Énfasis — errores, cooldown, tesoro inactivo |

### Halftones (vibrantes)
| | Nombre | HEX | Uso |
|---|---|---|---|
| 🩵 | Halftone Blue | `#57CAFF` | Highlights, íconos seleccionados, ranking activo |
| 💚 | Halftone Green | `#5CDB6D` | Animación de logro, progreso positivo |
| 💛 | Halftone Yellow | `#FFD427` | Efecto de brillo en medallas, estrella de puntos |
| 🌸 | Halftone Red | `#FF7DAF` | Notificaciones suaves, detalles decorativos |

### Pastels (fondos y estados suaves)
| | Nombre | HEX | Uso |
|---|---|---|---|
| 🫧 | Pastel Blue | `#C3ECF6` | Fondo de cards de info, estado "disponible" suave |
| 🌿 | Pastel Green | `#CCF6C5` | Fondo de tesoro descubierto (light mode) |
| 🌼 | Pastel Yellow | `#FFE7A5` | Fondo de pistas/hints |
| 🌷 | Pastel Red | `#F8D8D8` | Fondo de estado de error suave |

### Grayscale
| | Nombre | HEX | Uso |
|---|---|---|---|
| 🤍 | Off White | `#F0F0F0` | Texto principal en dark, fondo en light mode |
| ⬛ | Black 02 | `#1E1E1E` | Fondo principal dark, texto sobre colores claros |

---

## 🤖 Prompt para Generar Diseños con IA

Copia y pega este prompt en cualquier IA generativa (Gemini, ChatGPT, Midjourney, etc.) para que respete la identidad visual oficial de GDG:

---

```
Identidad de marca: GDG (Google Developer Groups) — DevFest Treasure Hunt / DevFest Master
Paleta oficial: Google Developer Groups brand colors (gdgportharcourt.com.ng/brand-guidelines)
Estilo visual: Tech moderno, vibrante, gamificado. Limpio y accesible (WCAG AA).

=== PALETA OBLIGATORIA ===

CORE (colores principales):
- Azul principal:   #4285F4  → botones, acentos, badges, color dominante
- Verde:            #34A853  → éxito, logros, medalla desbloqueada
- Amarillo/Naranja: #F9AB00  → recompensas, puntos, energía
- Rojo:             #EA4335  → alertas, errores, énfasis

HALFTONES (highlights vibrantes):
- Halftone Blue:    #57CAFF  → glow en badges, íconos activos
- Halftone Green:   #5CDB6D  → animación de logro, progreso
- Halftone Yellow:  #FFD427  → brillo en medallas, estrella de puntos
- Halftone Red:     #FF7DAF  → detalles decorativos, notificaciones

PASTELS (fondos suaves):
- Pastel Blue:      #C3ECF6  → cards de información
- Pastel Green:     #CCF6C5  → estado "completado"
- Pastel Yellow:    #FFE7A5  → pistas y hints
- Pastel Red:       #F8D8D8  → error suave / inactivo

NEUTROS:
- Fondo oscuro:  #1E1E1E  → dark mode background
- Fondo claro:   #F0F0F0  → light mode / off-white

=== ESTILO ===
- Tipografía: Google Sans o sans-serif moderno. Bold para títulos. Regular para cuerpo.
- Bordes redondeados: 16-18px border-radius en cards y botones.
- Accesibilidad: contraste WCAG AA mínimo en todos los textos.
- Estética: gamificado pero profesional. Energético sin ser caótico.
- Iconografía: estilo Google Material Symbols / outlined.
- Referencias: Google I/O design, Duolingo (gamificación), Google Material 3.
```

---

### Variaciones del prompt por caso de uso

**Para generar un badge / medalla de gimnasio:**
```
Diseña un badge circular de medalla para el "Gimnasio Cloud ☁️" del DevFest Master.
Paleta GDG oficial: usa #4285F4 como color base del badge, con glow en #57CAFF.
Ícono de nube en blanco #F0F0F0. Borde metálico con degradado azul.
Estilo: gaming + Google brand. Efecto de brillo/shine sutil.
Fondo transparente. Tamaño 256x256px. Sin texto.
```

**Para generar una pantalla / mockup UI (DevFest Master / Pokédex):**
```
Diseña una pantalla móvil (375x812px) para una app llamada "DevFest Master".
Muestra 8 slots de medallas: 4 obtenidas (con colores vivos GDG: #4285F4, #34A853, #F9AB00, #EA4335)
y 4 bloqueadas (en gris #AAB2D9 semi-transparente).
Fondo: #1E1E1E. Cards con borde sutil. Título en #F0F0F0.
Estilo dark mode Google, bordes redondeados, sin marco de teléfono.
Fuente: Google Sans.
```

**Para generar un banner del evento:**
```
Crea un banner horizontal (1920x640px) para el evento "DevFest Treasure Hunt".
Texto principal: "DevFest Master — Conquista los 8 Gimnasios Tecnológicos"
Paleta GDG oficial: fondo #1E1E1E, acentos en #4285F4, #34A853, #F9AB00, #EA4335.
Elementos visuales: QR codes, iconos de tecnología, medallas/badges tipo gaming.
Estilo tech profesional, dark mode, Google brand guidelines.
Sin fotografías de personas.
```

**Para generar ilustración de personaje / avatar starter:**
```
Diseña 3 avatares de personaje estilo pixel-art / flat para una app de gamificación DevFest.
Opción 1: personaje azul (#4285F4) → "Android Dev"
Opción 2: personaje verde (#34A853) → "Web Dev"  
Opción 3: personaje rojo (#EA4335) → "Cloud Dev"
Estilo: flat design moderno, friendly, sin copyright. Fondos en pasteles GDG.
Tamaño: 256x256px, fondo transparente.
```

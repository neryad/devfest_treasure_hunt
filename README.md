# DevFest Treasure Hunt

MVP / demo de juego de **caza de tesoros** para eventos tecnológicos tipo
DevFest. Los asistentes registran su participación, descubren tesoros físicos
escaneando QR o introduciendo códigos manuales, reciben pistas, avanzan en un
ranking en vivo y compiten por el premio final.

> **Estado:** MVP demo con datos mock 100% locales (sin servidor, sin
> Firebase). Arquitectura preparada para migrar a Firebase sin tocar la UI.

---

## Características del demo

- Vista de bienvenida + registro simple (nombre + alias, sin autenticación).
- Dashboard del participante con progreso, tiempo, posición y acciones.
- Descubrimiento por **QR real** (`mobile_scanner`) o **código manual**,
  ambos terminan en la misma regla `discoverTreasure()`.
- **Modo demo de escaneo** para presentaciones en simulador o sin cámara.
- 10 tesoros, 15 participantes ficticios, pistas y estados.
- Descubrimiento **libre en cualquier orden** (sin secuencia obligatoria).
- El único bloqueo real es `isActive == false` (control del administrador).
- Ranking ordenado por nº de tesoros (desc) y tiempo (asc).
- Pantalla de finalización al completar el reto (la posición final la define
  el ranking oficial, no se asume ganador).
- **Panel admin demo**: métricas, ranking, lista de participantes y toggles de
  disponibilidad de tesoros, más "reset" de la demo.

## Requisitos

- Flutter **3.44+** (Dart 3.12+).
- Xcode (iOS) y/o Android SDK (Android).
- CocoaPods para iOS.

## Instalación y ejecución

```bash
cd devfest_treasure_hunt
flutter pub get
flutter run                # elige dispositivo / simulador
```

## Estructura del proyecto

```
lib/
├── main.dart                 # composición de dependencias
├── app/
│   └── app.dart              # DevFestApp, MaterialApp, inyección mock
├── core/
│   ├── theme/app_theme.dart  # paleta y Material 3
│   ├── utils/                # formatos, ids, iconos por tesoro
│   ├── widgets/              # progress bar, pills, stat cards, headers
│   └── (qr)                  # integración del scanner (en screens/discovery)
├── domain/
│   ├── entities/             # Event, TreasureItem, Participant, Discovery, Clue, LeaderboardEntry
│   ├── repositories/         # interfaces (Treasure, Participant, Leaderboard, Event)
│   └── use_cases/            # DiscoverTreasureUseCase, LeaderboardUseCase, StartParticipantUseCase
├── data/
│   ├── datasources/          # AppDataSource (abstracción) + MockLocalDataSource + MockData
│   ├── local/                # AppLocalStorage (abstracción) + SharedPrefsLocalStorage
│   └── repositories/         # MockAppRepository (implementa las 4 interfaces)
├── state/
│   ├── app_controller.dart   # ChangeNotifier central (ViewModel)
│   └── app_scope.dart        # InheritedWidget propio (sin terceros)
└── ui/
    ├── screens/              # welcome, setup, home, discovery, treasures, clues, leaderboard, completion, admin
    └── admin_navigation.dart # acceso al panel admin
```

Capas: **UI → AppScope (InheritedWidget) → Use Cases → Repositories → MockDataSource**.
La UI nunca toca almacenamiento.

## Cómo probar el flujo demo (5–10 min)

1. Abre la app → pantalla de bienvenida.
2. "Comenzar aventura" → regístrate (nombre + alias).
3. Dashboard 0/10 con progreso vacío.
4. FAB **"Encontrar tesoro"** → "Escanear QR" → cambia a **Demo** y toca un
   tesoro (o usa "Introducir código").
5. Modal de tesoro encontrado → revela la pista.
6. "Mis tesoros" (bottom nav) → consulta encontrados/pendientes.
7. Descubre otro tesoro **fuera de orden** (p. ej. Tesoro #7 y luego #2).
8. "Ranking" → comprueba tu posición (los seed data están más arriba).
9. **Panel admin** (icono de admin en el AppBar o desde bienvenida):
   - Desactiva un tesoro, vuelve e intenta descubrirlo → "No disponible".
   - Reactívalo.
   - Consulta métricas, ranking y participantes.
10. Activa el Tesoro #3 y completa el resto → pantalla de finalización.

### Códigos de ejemplo (código manual)

| Tesoro | Código manual | QR value |
|---|---|---|
| El Punto de Encuentro | `DEVFEST-001` | `DEVFEST-TREASURE-001` |
| El Escenario Principal | `DEVFEST-002` | `DEVFEST-TREASURE-002` |
| El Rincón del Café | `DEVFEST-003` *(inactivo por defecto)* | `DEVFEST-TREASURE-003` |
| ... | `DEVFEST-004` … `DEVFEST-010` | `DEVFEST-TREASURE-004` … `-010` |

> El modo demo del escáner permite simular cualquier QR desde el listado.

## Tests

```bash
flutter analyze
flutter test
```

- `test/use_cases/` → reglas centrales: orden libre, `isActive`, duplicados,
  completado, orden/tiempo del ranking.
- `test/widgets/` → registro → dashboard, descubrimientos fuera de orden y
  pistas desbloqueadas.

## Persistencia

El estado del demo (participante actual, descubrimientos y toggles del admin)
se guarda con `shared_preferences`, siempre **detrás** de la abstracción
`AppLocalStorage`. Con `MockLocalDataSource()` sin storage todo queda en
memoria.

## Migración a Firebase

Ver [docs/FIREBASE_MIGRATION.md](docs/FIREBASE_MIGRATION.md).

## Script de demo para organizadores

Ver [docs/DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md).

## Roadmap

Ver [docs/ROADMAP.md](docs/ROADMAP.md).
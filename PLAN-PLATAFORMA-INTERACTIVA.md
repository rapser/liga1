# Plan Técnico y de Producto — Liga 1: Plataforma Interactiva

> Rama de trabajo: `feat/plataforma-interactiva`
> Objetivo: evolucionar la app (marcador + noticias) hacia una plataforma interactiva, gamificada y de alta retención.
> Estado al 2026-09-02: Fase 1 en curso — "Sabor Local" (estadio + árbitro) implementado; **clima** y **simulador** pendientes; Fases 2–3 sin empezar.

---

## 0. Decisiones de arquitectura (marco general)

| Componente | Rol | Qué vive aquí |
|---|---|---|
| **App iOS** | Cliente Firebase puro (Firestore + Auth + FCM + Storage + Remote Config). Sin runtime servidor. | Lectura de datos, UI, simulador en cliente, render de imágenes para compartir, envío de votos/pronósticos. |
| **Admin web** (`liga1-admin-next`, Next.js/Vercel) | Ingesta de datos curados y tareas **no time-critical**. Ya tiene Firebase Admin SDK y escribe a Firestore. | Catálogo de sedes, alta de árbitros e historial, **ingesta de clima (Open-Meteo)**, carga de XI titular por partido, disparo manual de trabajos. |
| **Cloud Functions** (carpeta `functions/` **dentro de `liga1-admin-next`**, **NO** en el repo iOS) | Trabajos programados y triggers de Firestore **time-critical**. | Cierre de pronósticos, cálculo de puntos post-partido, agregación de votos (MVP / encuestas / 11 ideal), fan-out FCM en vivo. |

**Por qué el clima va en el Admin y no en Cloud Functions (por ahora):** el Admin ya es dueño del dato operativo del partido (sede, fecha, hora), ya tiene credenciales server-side y ya escribe a Firestore. El clima no es time-critical (forecast de partidos a días vista). Cuando entre la Fase 2 se añade `liga1-admin-next/functions/` y, si conviene, el clima se puede mover allí sin cambiar el contrato de datos (siempre aterriza en `jornadas/{id}/matches/{matchId}.clima`).

**Decisión (2026-09-03):** las Cloud Functions viven en una carpeta `functions/` **dentro del repo `liga1-admin-next`**, no en un repo separado. El admin ya es el "backend" (Admin SDK, service account, `firestore.rules`). `firebase init functions` crea la estructura anidada; Vercel compila solo `src/` e ignora `functions/`, y `firebase deploy --only functions` sube solo `functions/`. `firebase.json` + `.firebaserc` + `firestore.rules` + `firestore.indexes.json` van en la raíz del admin.

**Regla de auth (heredada):** cualquier feature nueva inyecta `AuthServiceProtocol`; nunca `AuthManager.shared` salvo en `DIContainer.makeAuthService()` y `AppDelegate.configure(provider:)`.

**Convenciones de código iOS ya vigentes:**
- Entidades en `Domain/Entities/<Grupo>/`, DTOs en `Data/DTOs/<Grupo>/`, mappers en `Data/Mappers/`, repos en `Data/Repositories/`, casos de uso en `Domain/UseCases/<Grupo>/`.
- Todo asíncrono con Combine: `AnyPublisher<T, Error>`.
- IDs de documento derivados de texto libre con `Slug.make(...)` (ya se usa para `referees/{id}`).
- Decorador de caché para catálogos poco cambiantes (patrón `CachingTeamsRepository`).

---

## 1. Modelado de Datos e Infraestructura

### 1.1 Colecciones y documentos nuevos en Firestore

```text
firestore
├── venues/{venueId}                         # catálogo de sedes (lat/lon/altitud)
├── referees/{refereeId}                     # ficha + historial de árbitro   (YA EXISTE base)
├── jornadas/{jornadaId}/matches/{matchId}   # se le añaden sub-objetos: clima, arbitroId, xiCargado
│
├── polls/{pollId}                           # micro-encuesta arbitral en vivo ("¿fue penal?")
│   └── shards/{shardId}                     # contadores distribuidos de votos
├── pollVotes/{pollId}/votes/{uid}           # 1 voto por usuario (anti-fraude, no se lee en cliente)
│
├── predictions/{jornadaId}/entries/{uid}    # polla: pronósticos del usuario para la jornada
├── predictionScores/{jornadaId}/entries/{uid}  # puntos calculados por Function
├── leaderboards/{scopeId}/entries/{uid}     # scopeId = "global" | "group_{groupId}" | "season_{año}"
├── friendGroups/{groupId}                   # liga entre amigos (codigoInvitacion)
│
├── matchVotes/{matchId}/votes/{uid}         # voto MVP (1 por usuario)
├── mvpResults/{matchId}                     # agregado mantenido por Function
│   └── shards/{shardId}
│
├── bestXIBallots/{jornadaId}/ballots/{uid}  # voto "11 ideal" del usuario
├── bestXIResults/{jornadaId}                # 11 ideal agregado
│
└── config/scoring                           # reglas de puntuación (editable sin deploy)
```

#### `venues/{venueId}`
| Campo | Tipo | Descripción |
|---|---|---|
| `nombre` | string | "Estadio Monumental" |
| `ciudad` | string | "Lima" |
| `pais` | string | "PE" |
| `lat` | number | latitud (para Open-Meteo) |
| `lon` | number | longitud |
| `altitudMsnm` | number | 3399 (Cusco), 154 (Lima)… factor de cancha |
| `capacidad` | number | aforo |
| `timezone` | string | "America/Lima" |

> Semilla desde un JSON local en el Admin (son ~20 sedes). El id puede ser `Slug.make(nombre)` o el código de estadio ya usado en `TeamVenues.json`.

#### `jornadas/{jornadaId}/matches/{matchId}` — campos añadidos
| Campo | Tipo | Escrito por | Descripción |
|---|---|---|---|
| `venueId` | string | Admin | referencia a `venues` |
| `arbitroId` | string | Admin | referencia a `referees` (ya se deriva por `Slug.make` del campo `arbitro`) |
| `clima` | map | Admin (Open-Meteo) | ver 1.2 |
| `xiLocal` / `xiVisitante` | array | Admin | XI titular (para MVP / 11 ideal); reusa el módulo de alineaciones |
| `kickoff` | Timestamp | Admin | hora de inicio **fija** (fuente de verdad para bloqueos) |

#### `clima` (map dentro del match)
```jsonc
{
  "tempC": 18.4,
  "sensacionC": 17.1,
  "humedad": 72,          // %
  "vientoKmh": 14.0,
  "precipProb": 20,       // %
  "codigoWMO": 3,         // WMO weather_code de Open-Meteo
  "condicion": "nublado", // derivado: despejado|nubes|lluvia|tormenta|niebla|nieve
  "iconoSF": "cloud.fill",// SF Symbol sugerido
  "horaReferencia": "2026-03-15T20:00:00-05:00", // hora del match usada para el forecast
  "actualizadoEn": "<Timestamp>",
  "fuente": "open-meteo"
}
```

#### `referees/{refereeId}` — ampliar la ficha existente
| Campo | Tipo | Descripción |
|---|---|---|
| `nombre` | string | |
| `fotoURL` | string | Storage |
| `partidosDirigidos` | number | |
| `amarillasPromedio` | number | |
| `rojasPromedio` | number | |
| `penalesPitados` | number | |
| `historialPorEquipo` | map<teamCode, {pj, g, e, p}> | dato "termómetro" |
| `temporada` | string | "2026" |

#### `polls/{pollId}`
| Campo | Tipo | Descripción |
|---|---|---|
| `matchId` | string | |
| `pregunta` | string | "¿Fue penal la jugada del min 63?" |
| `opciones` | array<{id, texto}> | ej. `[{sí},{no},{dudoso}]` |
| `abreEn` / `cierraEn` | Timestamp | ventana de votación (minutos) |
| `estado` | string | `programada` \| `activa` \| `cerrada` |
| `totales` | map<opcionId, number> | agregado (suma de shards) — único doc que lee el cliente |
| `totalVotos` | number | |

`polls/{pollId}/shards/{n}`: `{ counts: map<opcionId, number> }` — N=10–20.
`pollVotes/{pollId}/votes/{uid}`: `{ opcionId, ts }` — garantiza 1 voto/uid; el cliente lo escribe pero nunca lista la colección.

#### `predictions/{jornadaId}/entries/{uid}`
```jsonc
{
  "uid": "…",
  "displayName": "…",       // desnormalizado para leaderboard
  "avatarURL": "…",
  "items": [
    { "matchId": "ali_uni", "golesLocal": 2, "golesVisitante": 1, "resultado": "L" } // L|E|V derivado
  ],
  "enviadoEn": "<Timestamp>",
  "bloqueadoEn": "<Timestamp|null>"  // set por Function al primer kickoff de la jornada
}
```

#### `predictionScores/{jornadaId}/entries/{uid}`
```jsonc
{
  "uid": "…",
  "puntos": 7,
  "aciertosExactos": 2,
  "aciertos1x2": 3,
  "detalle": [ { "matchId": "ali_uni", "puntos": 3, "tipo": "exacto" } ],
  "calculadoEn": "<Timestamp>",
  "matchesContabilizados": ["ali_uni", "..."]   // idempotencia
}
```

#### `leaderboards/{scopeId}/entries/{uid}`
`{ uid, displayName, avatarURL, puntosTotales, jornadasJugadas, posicion, actualizadoEn }`
Mantenido incrementalmente por Function. El cliente pagina (25–50) y consulta su propia entrada por id.

#### `friendGroups/{groupId}`
`{ nombre, ownerUid, codigoInvitacion (6 chars), miembros: array<uid>, creadoEn, maxMiembros }`

#### `matchVotes/{matchId}/votes/{uid}` + `mvpResults/{matchId}`
Voto: `{ jugadorId, jugadorNombre, equipoCode, ts }`.
Resultado: `{ ganador: {jugadorId, nombre, votos}, ranking: array<{jugadorId, nombre, votos}>, totalVotos, ventanaCerrada: bool, actualizadoEn }` + subcolección `shards/{n}`.

#### `bestXIBallots/{jornadaId}/ballots/{uid}` + `bestXIResults/{jornadaId}`
Ballot: `{ formacion: "4-3-3", jugadores: array<{slot, jugadorId, equipoCode}> }`.
Resultado: `{ formacion, once: array<{slot, jugadorId, nombre, equipoCode, votos}>, totalBallots, actualizadoEn }`.

#### `config/scoring`
`{ exacto: 3, resultado1x2: 1, bonusRachaJornada: 1, cierrePorMatch: true }` — leído por la Function de scoring; editable desde el Admin o Remote Config.

### 1.2 Ingesta de clima (Open-Meteo) — módulo del Admin  ✅ IMPLEMENTADO (backend)

> **Estado 2026-09-02:** hecho en `liga1-admin-next`. La sede **no** usa un catálogo nuevo:
> se reutiliza la colección `stadiums/{slug}` ya sembrada desde iOS (tiene `lat`, `lng`,
> `altitudeMsnm`, `homeTeamCodes`). El partido se enlaza a su sede por `equipoLocalId`.
> Archivos: `src/domain/services/weather.service.ts`, `src/app/api/weather/refresh/route.ts`,
> `vercel.json`, `src/core/config/firebase-admin.ts` (nuevo export `adminDb`).
> Falta: botón manual en el dashboard + configurar `CRON_SECRET` en Vercel + lado iOS.


**Endpoint Open-Meteo (gratis, sin API key):**
```
https://api.open-meteo.com/v1/forecast
  ?latitude={lat}&longitude={lon}
  &hourly=temperature_2m,apparent_temperature,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m
  &timezone=America/Lima
  &start_date={YYYY-MM-DD}&end_date={YYYY-MM-DD}
```
- Horizonte fiable del forecast: ~16 días. Solo se consultan partidos dentro de esa ventana.
- Se toma la hora `hourly` más cercana al `kickoff` del partido.
- `weather_code` (WMO) → `condicion` + `iconoSF`:

| WMO | condicion | SF Symbol |
|---|---|---|
| 0 | despejado | `sun.max.fill` |
| 1–2 | parcialmente nublado | `cloud.sun.fill` |
| 3 | nublado | `cloud.fill` |
| 45,48 | niebla | `cloud.fog.fill` |
| 51–67 | lluvia | `cloud.rain.fill` |
| 71–77 | nieve | `snowflake` |
| 80–82 | chubascos | `cloud.heavyrain.fill` |
| 95–99 | tormenta | `cloud.bolt.rain.fill` |

**Cambios en el Admin (`liga1-admin-next`) — implementados:**
1. `src/core/config/firebase-admin.ts` → nuevo export `adminDb` (`getFirestore(adminApp)`).
2. `src/core/config/firestore-constants.ts` → `FIRESTORE_COLLECTIONS.STADIUMS = "stadiums"`.
3. `src/domain/services/weather.service.ts` → `fetchWeatherForKickoff({lat,lng,kickoff})`:
   - URL Open-Meteo con `start_date = end_date` = día local (America/Lima) del partido.
   - Elige la hora `hourly` exacta del inicio (o la más cercana del día).
   - Mapeo WMO `weather_code` → `condicion` + `iconoSF` (SF Symbol).
   - Lanza `WeatherError` con `reason` (`fuera-de-horizonte` | `respuesta-invalida` | `sin-hora-en-respuesta`).
4. `src/app/api/weather/refresh/route.ts` (`GET` para cron + `POST` para manual):
   - Auth: `Authorization: Bearer $CRON_SECRET` **o** cookie de sesión de admin válida (`verifySessionCookie`).
   - Lee `stadiums` una vez → índice `teamCode → {lat,lng}`.
   - Recorre `jornadas` con `mostrar: true` → `matches` con `estado ∈ {pendiente, envivo}` y `fecha` en `[ahora−4h, ahora+16d]`.
   - Resuelve sede por `equipoLocalId` → Open-Meteo (pool de concurrencia 5) → `BulkWriter.set({ clima }, { merge:true })`.
   - Responde `{ ok, actualizados, sinSede, fueraDeHorizonte, errores, detalleErrores, duracionMs }`.
5. `vercel.json` → cron `0 */12 * * *` a `/api/weather/refresh`.
   - Plan **Hobby**: 1 cron/día, máx 2 jobs. Para partidos a días vista alcanza; si se quiere más frecuencia → **GitHub Action** con `schedule` que hace `curl` al endpoint con el `CRON_SECRET`.
   - Plan **Pro**: sin límite práctico.
6. `.env.example` → `CRON_SECRET` documentado (`openssl rand -hex 32`).

**Pendiente en el Admin:** botón "Actualizar clima" en `/dashboard/jornadas` (llama al `POST` con la cookie de sesión); añadir `CRON_SECRET` en `.env.local` y en las env vars de Vercel.

**Forma exacta del sub-objeto `clima`** que escribe el endpoint (lo consume iOS):
```jsonc
{
  "tempC": 14.1, "sensacionC": 11.5, "humedad": 56,
  "vientoKmh": 9.8, "precipProb": 21,
  "codigoWMO": 1, "condicion": "nubes", "iconoSF": "cloud.sun.fill",
  "horaReferencia": "2026-09-05T18:00",   // hora local Lima usada del forecast
  "fuente": "open-meteo",
  "sede": "estadio-inca-garcilaso-de-la-vega",  // doc id en stadiums/
  "actualizadoEn": "<serverTimestamp>"
}
```
`condicion ∈ { despejado, nubes, niebla, lluvia, chubascos, tormenta, nieve }`.

### 1.3 Cloud Functions necesarias (`liga1-admin-next/functions/`, firebase-functions v2)

| Función | Tipo | Cuándo | Qué hace |
|---|---|---|---|
| `lockPredictions` | scheduled (cada 5 min) | siempre | Marca `bloqueadoEn` en `entries` de jornadas cuyo primer `kickoff` ya pasó. (Respaldo; el bloqueo real lo imponen las rules por partido.) |
| `scorePredictions` | Firestore trigger `onDocumentUpdated` match | match → `finalizado` | Recalcula puntos de todos los `entries` de esa jornada para los matches ya finalizados; escribe `predictionScores`; actualiza `leaderboards/global` y grupos. **Idempotente** (`matchesContabilizados`). |
| `aggregatePollVotes` | scheduled (cada 30–60 s) mientras haya poll `activa` + `onDocumentCreated` en `pollVotes/*/votes` | ventana de encuesta | Suma shards → `polls/{id}.totales`. |
| `aggregateMatchVotes` | igual patrón que polls | ventana MVP | Mantiene `mvpResults/{matchId}`. |
| `sendMvpPushAt75` | scheduled (cada 1 min) | partidos `envivo` | Si `now >= kickoff + 75min` y `!mvpPushEnviado` → publica push interactivo al topic `match_{id}`, marca flag. |
| `closeMvpVoting` | scheduled (cada 5 min) | — | Cierra `mvpResults` de partidos finalizados hace > 10 min (`ventanaCerrada = true`). |
| `computeBestXI` | scheduled (cada 30 min) | tras cierre de jornada | Si todos los matches de la jornada están finalizados hace > X h y la ventana de votación cerró → agrega `bestXIBallots` → `bestXIResults`. |
| `onGroupJoin` (opc.) | callable / trigger | usuario se une a grupo | Copia su puntaje histórico a `leaderboards/group_{id}`. |
| `weatherRefresh` (opcional) | scheduled (cada 6 h) | — | Alternativa al cron del Admin si se decide centralizar en Functions. |

### 1.4 `firestore.rules` — reglas clave anti-fraude

```
function isSignedIn() { return request.auth != null; }
function isAdmin() { return isSignedIn() &&
  exists(/databases/$(database)/documents/admins/$(request.auth.uid)); }

// --- Catálogos: lectura pública, escritura solo admin/functions ---
match /venues/{id}      { allow read: if true;  allow write: if isAdmin(); }
match /referees/{id}    { allow read: if true;  allow write: if isAdmin(); }
match /config/{doc}     { allow read: if true;  allow write: if isAdmin(); }

// --- Agregados: el cliente NUNCA escribe ---
match /polls/{id}                 { allow read: if true; allow write: if false; }
match /mvpResults/{id}            { allow read: if true; allow write: if false; }
match /bestXIResults/{id}         { allow read: if true; allow write: if false; }
match /predictionScores/{j}/entries/{uid} { allow read: if true; allow write: if false; }
match /leaderboards/{s}/entries/{uid}     { allow read: if true; allow write: if false; }

// --- Pronósticos: dueño + antes del kickoff + forma válida ---
match /predictions/{jornadaId}/entries/{uid} {
  allow read: if isSignedIn() && request.auth.uid == uid;
  allow create, update: if isSignedIn()
    && request.auth.uid == uid
    && request.resource.data.items.size() > 0
    && request.resource.data.items.size() <= 12
    && request.time < get(/databases/$(database)/documents/jornadas/$(jornadaId)).data.fechaInicio;
  allow delete: if false;
}

// --- Voto MVP: 1 por uid, dentro de ventana, sin update posterior ---
match /matchVotes/{matchId}/votes/{uid} {
  allow read: if false;                       // el cliente lee mvpResults, no votos
  allow create: if isSignedIn() && request.auth.uid == uid
    && request.time > get(/databases/$(database)/documents/.../matches/$(matchId)).data.kickoff
    // (ventana min 75 → fin) validada además en la Function
    ;
  allow update, delete: if false;             // voto inmutable
}

// --- Encuesta arbitral: 1 voto/uid, ventana ---
match /pollVotes/{pollId}/votes/{uid} {
  allow read: if false;
  allow create: if isSignedIn() && request.auth.uid == uid
    && request.time < get(/databases/$(database)/documents/polls/$(pollId)).data.cierraEn;
  allow update, delete: if false;
}

// --- 11 ideal: 1 ballot/uid ---
match /bestXIBallots/{jornadaId}/ballots/{uid} {
  allow read: if isSignedIn() && request.auth.uid == uid;
  allow create, update: if isSignedIn() && request.auth.uid == uid
    && request.resource.data.jugadores.size() == 11;
  allow delete: if false;
}

// --- Grupos de amigos ---
match /friendGroups/{groupId} {
  allow read: if isSignedIn() && request.auth.uid in resource.data.miembros;
  allow create: if isSignedIn() && request.resource.data.ownerUid == request.auth.uid;
  allow update: if isSignedIn() && (
      request.auth.uid == resource.data.ownerUid ||
      // unirse: solo se añade a sí mismo
      request.resource.data.miembros.hasOnly(resource.data.miembros.concat([request.auth.uid]))
  );
}
```

> Los `get()` dentro de rules cuestan 1 lectura documental cada uno — aceptable a este volumen. El bloqueo temporal definitivo lo refuerza la Function (defensa en profundidad).

### 1.5 Estrategia anti-costos en Firestore

- **Votos (MVP, encuestas):** contador distribuido (sharded counter, 10–20 shards). El cliente escribe su voto en `.../votes/{uid}` y hace `increment` en un shard aleatorio; la Function/agregador consolida en el doc `totales`. **El cliente solo lee el doc agregado**, nunca la colección de votos → 1 lectura, no N.
- **Leaderboard:** nada de `orderBy` sobre toda la colección en cada apertura. Se mantiene incremental por Function. Cliente: `limit(50)` + `get` de su propia entrada. "Mi posición" = campo `posicion` recalculado por la Function (o `count()` aggregation query puntual).
- **Scoring:** `BulkWriter` / batches de 500; una sola pasada por jornada al finalizar cada match.
- **Clima:** 1 fetch por sede-jornada (no por usuario). ~10 matches × 1–2 refrescos/día ≈ nada.
- **Catálogos (venues, referees):** `CachingVenuesRepository` / `CachingRefereesRepository` en el cliente con TTL lógico; Firestore offline persistence activada.
- **Snapshot listeners:** solo mientras la vista está viva; `cancellables` liberados en `deinit`. Resultados "en vivo" (poll, MVP) con listener **solo dentro de la ventana activa**; fuera de ella, un `getDocs` puntual.

### 1.6 Sincronización horaria cliente–servidor

- **El cliente no decide bloqueos.** El corte real lo imponen `firestore.rules` (`request.time`) y la Function `lockPredictions`.
- **UI countdown:** al abrir la pantalla, obtener `serverOffset`:
  - opción A: doc `serverClock/now` que una Function ligera actualiza, o
  - opción B: leer cualquier doc y usar su `updateTime`, o
  - opción C: callable `getServerTime()` → `{ now }`.
  - `delta = serverNow - Date.now()`; el countdown usa `kickoff - (Date.now() + delta)`.
- **Envío tardío:** si el usuario manda el pronóstico pasado el `kickoff`, las rules lo rechazan; el cliente traduce el error a "Jornada cerrada" y descarta cambios locales.
- **Almacenamiento:** `kickoff` siempre como `Timestamp` (UTC); la zona (`America/Lima`) solo para presentación.

### 1.7 Escalabilidad de FCM

| Escenario | Mecanismo |
|---|---|
| Broadcast (goles, inicio, noticias) | **Topics** (`team_{code}`, `general`) — ya en uso. |
| Evento en vivo puntual (voto MVP al min 75) | Topic efímero por partido `match_{matchId}`. El cliente se **suscribe al abrir** `MatchDetail`, se **desuscribe al salir** (o a las 24 h). Un solo `send` a topic, no N `send` a tokens. |
| Grupos de amigos | `sendEachForMulticast` por tokens (lotes ≤ 500); grupos pequeños. |
| Push interactivo iOS | `mutable-content: 1`, `UNNotificationCategory` + `UNNotificationAction` ("Votar MVP" sin abrir la app → notification service/content extension o handler en background que escribe el voto). |
| Anti-reenvío | `sendMvpPushAt75` marca `mvpPushEnviado: true` en el match. |

---

## 2. Diseño de Arquitectura iOS (Clean Architecture + MVVM)

### 2.1 Entidades de Dominio nuevas

`Domain/Entities/…`

| Entidad | Grupo | Campos clave |
|---|---|---|
| `Venue` | `Venue/` | `id, nombre, ciudad, altitudMsnm, lat, lon, capacidad, timezone` |
| `MatchWeather` | `Match/` | `tempC, sensacionC, vientoKmh, humedad, precipProb, condicion: WeatherCondition, iconoSF, actualizadoEn` |
| `WeatherCondition` (enum) | `Match/` | `.despejado .nubes .lluvia .tormenta .niebla .nieve` |
| `RefereeStats` (amplía `RefereeProfile`) | `Referee/` | `partidosDirigidos, amarillasProm, rojasProm, penales, historialPorEquipo: [String: RefereeH2H]` |
| `RefereePoll` | `Poll/` | `id, matchId, pregunta, opciones: [PollOption], abreEn, cierraEn, estado` |
| `PollResult` | `Poll/` | `pollId, conteos: [String: Int], total: Int, miVoto: String?` |
| `Prediction` | `Prediction/` | `jornadaId, items: [MatchPrediction], enviadoEn, bloqueado: Bool` |
| `MatchPrediction` | `Prediction/` | `matchId, golesLocal, golesVisitante, resultado1X2: Outcome` |
| `PredictionScore` | `Prediction/` | `jornadaId, puntos, aciertosExactos, aciertos1X2, detalle` |
| `LeaderboardEntry` | `Leaderboard/` | `uid, displayName, avatarURL, puntosTotales, posicion` |
| `FriendGroup` | `Leaderboard/` | `id, nombre, ownerUid, miembros, codigoInvitacion` |
| `MvpBallot` | `Mvp/` | `matchId, jugadorId, minutoVoto` |
| `MvpResult` | `Mvp/` | `matchId, ganador: PlayerRef?, ranking: [PlayerVoteCount], total, ventanaCerrada` |
| `BestXIBallot` | `BestXI/` | `jornadaId, formacion, jugadores: [PlayerSlot]` |
| `BestXIResult` | `BestXI/` | `jornadaId, formacion, once: [PlayerSlotResult]` |
| `TableSimulation` | `Simulator/` | `torneo, proyecciones: [String: MatchPrediction], tabla: [StandingRow], clasificados: [Qualification], descendidos: [String]` |
| `Qualification` (enum) | `Simulator/` | `.libertadoresGrupos .libertadoresPrevia .sudamericana .descenso .ninguno` |
| `ServerTimeOffset` | `Core/` | `delta: TimeInterval, medidoEn: Date` |

> `Stadium` + `RefereeProfile` ya existen y se reutilizan/amplían (no se rehacen).

### 2.2 Casos de Uso nuevos

`Domain/UseCases/…` — cada uno con su `…Protocol` y devolviendo `AnyPublisher<_, Error>`.

**Fase 1**
- `MatchContext/GetVenueForMatchUseCase` — sede + altitud (reusa/renombra `GetStadiumForTeamUseCase`).
- `MatchContext/GetMatchWeatherUseCase` — lee `clima` del match doc.
- `MatchContext/GetRefereeStatsUseCase` — amplía `GetRefereeProfileUseCase` con historial.
- `Poll/SubmitRefereePollVoteUseCase` — valida ventana con `ServerTimeOffset`, escribe voto + increment de shard.
- `Poll/ObservePollResultUseCase` — publisher del doc agregado.
- `Simulator/SimulateStandingsUseCase` — **puro**: `(standingsBase, [MatchPrediction]) -> [StandingRow]` con desempates Liga 1 (pts → dif. gol → GF → resultado entre sí). Reusa lógica de `CalculateAccumulatedStandingsUseCase`.
- `Simulator/ProjectQualificationUseCase` — de la tabla simulada a copas + zona de descenso.
- `Share/RenderShareImageUseCase` — envuelve `UIView -> UIImage`.

**Fase 2**
- `Prediction/GetJornadaFixturesForPredictionUseCase`
- `Prediction/SubmitPredictionUseCase` — arma payload, valida `request.time`/offset, mapea error de rules a "jornada cerrada".
- `Prediction/ObserveMyPredictionUseCase`
- `Prediction/GetPredictionScoresUseCase`
- `Leaderboard/GetLeaderboardUseCase` — scope global | grupo | temporada, paginado.
- `Leaderboard/CreateFriendGroupUseCase`, `Leaderboard/JoinFriendGroupUseCase`
- `Core/GetServerTimeOffsetUseCase`

**Fase 3**
- `Mvp/CastMvpVoteUseCase`
- `Mvp/ObserveMvpResultUseCase`
- `Mvp/RegisterMatchLiveTopicUseCase` / `Mvp/UnregisterMatchLiveTopicUseCase` (FCM subscribe/unsubscribe; reusa `NotificationTopicManager`).
- `BestXI/SubmitBestXIBallotUseCase`
- `BestXI/ObserveBestXIResultUseCase`
- `Share/RenderBestXIGraphicUseCase`

### 2.3 Contratos de Repositorio + integración Combine

`Domain/Repositories/…Protocol.swift`, implementados en `Data/Repositories/…`

| Protocolo | Métodos | Notas |
|---|---|---|
| `VenuesRepositoryProtocol` | `fetchAll()`, `fetch(id:)` | + `CachingVenuesRepository` (decorador). |
| `WeatherRepositoryProtocol` | `fetchWeather(jornadaId:matchId:)` | lee sub-objeto `clima`. |
| `RefereesRepositoryProtocol` | `fetchReferee(id:)` (existe), `fetchStats(id:)` | + `CachingRefereesRepository`. |
| `PollsRepositoryProtocol` | `observeResult(pollId:) -> AnyPublisher<PollResult,Error>`, `vote(pollId:opcionId:uid:)` | `observeResult` envuelve `addSnapshotListener` en `PassthroughSubject`. |
| `PredictionsRepositoryProtocol` | `observeMine(jornadaId:uid:)`, `submit(_:)`, `fetchScores(jornadaId:)` | |
| `LeaderboardRepositoryProtocol` | `page(scope:cursor:)`, `entry(scope:uid:)` | |
| `FriendGroupsRepositoryProtocol` | `create(_:)`, `join(codigo:uid:)`, `observeMine(uid:)` | |
| `MvpRepositoryProtocol` | `castVote(_:)`, `observeResult(matchId:)` | |
| `BestXIRepositoryProtocol` | `submitBallot(_:)`, `observeResult(jornadaId:)` | |
| `ServerTimeRepositoryProtocol` | `currentOffset() -> AnyPublisher<ServerTimeOffset,Error>` | |

**Patrón Combine para snapshots** (helper reutilizable):
```swift
extension Query {
    func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {
        let subject = PassthroughSubject<QuerySnapshot, Error>()
        let reg = addSnapshotListener { snap, err in
            if let err { subject.send(completion: .failure(err)) }
            else if let snap { subject.send(snap) }
        }
        return subject.handleEvents(receiveCancel: { reg.remove() })
                      .eraseToAnyPublisher()
    }
}
```

### 2.4 ViewModels: patrón `Action / Mutation / State`

Patrón unidireccional (ya insinuado en el Admin con `match-live-controller`). Ejemplo — **Simulador**:

```swift
enum SimulatorAction {
    case load(torneo: Torneo)
    case setResult(matchId: String, local: Int, visita: Int)
    case reset
    case share
}

enum SimulatorMutation {
    case setFixtures([Match])
    case setBase([StandingRow])
    case setProjectedTable([StandingRow])
    case setQualification([Qualification])
    case setLoading(Bool)
    case setError(String?)
    case setShareImage(UIImage?)
}

struct SimulatorViewState {
    var fixturesRestantes: [Match] = []
    var proyecciones: [String: MatchPrediction] = [:]
    var tabla: [StandingRow] = []
    var clasificados: [Qualification] = []
    var descendidos: [String] = []
    var isLoading = false
    var error: String?
    var shareImage: UIImage?
}
```
`func send(_ action: SimulatorAction)` → produce `[Mutation]` (vía use cases) → `reduce(state, mutation)` → `@Published var state` que la vista observa. `SimulateStandingsUseCase` es puro → recálculo instantáneo al mover un stepper, sin red.

**ViewModels nuevos:**
| ViewModel | Pantalla |
|---|---|
| `MatchWeatherViewModel` (o extensión de `MatchDetailViewModel`) | panel clima en `MatchDetailViewController` |
| `RefereePanelViewModel` | ficha árbitro + historial |
| `RefereePollViewModel` | micro-encuesta en vivo |
| `StandingsSimulatorViewModel` | simulador de tabla/descenso |
| `PollaViewModel` | entrada de pronósticos por jornada |
| `LeaderboardViewModel` | ranking global / amigos |
| `FriendGroupsViewModel` | crear/unirse a grupo |
| `MvpVotingViewModel` | votación MVP + resultado en vivo |
| `BestXIViewModel` | armado y votación del 11 ideal |

### 2.5 Inyección de dependencias

Registrar en `DIContainer` los nuevos repos (con sus decoradores de caché) y use cases. Mantener `lazy var` para los repos con caché (patrón `teamsRepository`). Auth siempre vía `AuthServiceProtocol`.

---

## 3. Roadmap de Sprints

### FASE 1 — Quick Wins / Datos

**Sprint 1 — Sedes y altitud** ✅ (en parte hecho: panel estadio con altura/ciudad)
- Entidad `Venue`, `VenuesRepository` + `CachingVenuesRepository`, `GetVenueForMatchUseCase`.
- Catálogo `venues` sembrado desde el Admin (JSON → colección).
- UI: panel "Factores de cancha" en `MatchDetailViewController` (altitud, ciudad, capacidad).
- Tests: use case + mapper.

**Sprint 2 — Clima (Open-Meteo vía Admin)**  ✅ COMPLETO (falta solo `CRON_SECRET` en Vercel)
- Admin ✅: `adminDb` en `firebase-admin.ts`; `weather.service.ts`; `GET/POST /api/weather/refresh` con `CRON_SECRET` o sesión admin; `vercel.json` cron 12 h; botón "Actualizar clima" en `/dashboard/jornadas` (`weather-refresh-button.tsx`). Reutiliza `stadiums/{slug}`. `tsc` + `next build` OK; verificado contra Open-Meteo real.
- Admin ⏳: añadir `CRON_SECRET` en env vars de Vercel (y `.env.local` para probar en dev).
- iOS ✅: `MatchWeather` + `Condition`, `MatchWeatherDTO`/`Mapper`, `WeatherRepository` (lee sub-objeto `clima` de `jornadas/{id}/matches/{id}`), `GetMatchWeatherUseCase`, wired en `DIContainer` + `MatchDetailViewModel` (`weather`, `clima*Display`) + `MatchDetailViewController` (filas en "Sabor Local", aparece aunque no haya altitud). BUILD + TEST OK.
- Tests ✅: `GetMatchWeatherUseCaseTests` (4) + `MatchDetailViewModelTests` clima (6), `MockWeatherRepository`. Todos verdes.

**Sprint 3 — Termómetro arbitral + Simulador**
- Árbitro: ampliar `RefereeProfile` → `RefereeStats` (historial por equipo); form de alta/edición en el Admin; UI de ficha + historial en `MatchDetail`.
- Micro-encuesta: colección `polls` + `pollVotes` + shards; `RefereePollViewModel` con resultado en vivo (`snapshotPublisher`); rules (1 voto/uid, ventana); agregación (Function `aggregatePollVotes` o contador distribuido puro si aún no hay Functions).
- Simulador: `SimulateStandingsUseCase` (puro, desempates Liga 1) + `ProjectQualificationUseCase` (copas/descenso) + `StandingsSimulatorViewModel` (Action/Mutation/State) + UI con steppers por partido restante.
- Compartir: `ShareImageRenderer` (`UIGraphicsImageRenderer`, `UIView -> UIImage`) + hoja nativa a IG/WhatsApp.
- Tests: batería de desempates y frontera de descenso; render snapshot.

> **Cierre Fase 1:** todo el valor "datos" sin backend nuevo salvo el endpoint de clima en el Admin.

**Sprint 3 — Termómetro arbitral + Simulador**

*3A. Encuesta arbitral en vivo ("¿fue penal?")*
- **Modelo Firestore** (implementado en admin):
  - `polls/{pollId}`: `{ matchId, jornadaId, pregunta, opciones:[{id,texto}], estado:'activa'|'cerrada', cierraEn:Timestamp, creadoEn, cerradaEn, numShards:10 }`
  - `polls/{pollId}/shards/{0..9}`: `{ counts:{opcionId:number} }` — contador distribuido; la app iOS hace `increment` en un shard al azar; el conteo = suma de los 10 shards (1 listener a la subcolección). Cuando exista `liga1-admin-next/functions/`, una `aggregatePollVotes` recalculará un `totales` autoritativo desde `pollVotes`.
  - `pollVotes/{pollId}/votes/{uid}`: `{ opcionId, ts }` — 1 voto/uid, create-only (anti-fraude). La app lo escribe; el admin no lo lee.
- **Admin ✅** (`liga1-admin-next`, rama develop): stack Clean Arch completo — `poll.entity.ts`, `poll.dto.ts`, `poll.mapper.ts` (incl. `tallyFromShards`), `poll.repository.interface.ts`, `poll.repository.ts` (`createPoll` con batch de shards, `closePoll`, `observePollsForMatch`, `observeTally`), UI `referee-poll-panel.tsx` (crear pregunta+opciones+duración, resultado en vivo con barras, "Cerrar ahora"), montado dentro de `MatchLiveController` (solo con partido `envivo`). `tsc` + `next build` OK.
- **Reglas ⏳**: `firestore.poll.rules` (snippet para pegar en la consola — polls read público / write admin; shards write si `estado=='activa'` y `now<cierraEn`; `pollVotes` create-only por uid en ventana). **Aún no aplicado.**
- **iOS ✅** (rama feat/plataforma-interactiva): primer snapshot listener real del proyecto.
  - `Core/Firebase/QuerySnapshotPublisher.swift` — `Query.snapshotPublisher()` / `DocumentReference.snapshotPublisher()` (wrap de `addSnapshotListener` en `PassthroughSubject`; quita el listener en `receiveCancel`).
  - Domain: `RefereePoll` (+`Option`/`Estado`/`isOpen`), `PollResult` (`percent(for:)`), `PollRepositoryProtocol`.
  - Data: `PollDTO`/`PollShardDTO`/`PollVoteDTO` Codable, `PollMapper` (`toDomain`, `tally(fromShards:)`), `PollRepository` (`observeActivePoll` filtra abierta+reciente en cliente ⇒ sin índice compuesto; `observeTally` escucha subcolección `shards`; `fetchMyVote` one-shot; `vote` = batch `setData(pollVotes/{uid})` + `updateData(counts.<op> increment)` en shard al azar).
  - UseCases (`MatchContext/`): `ObserveRefereePollUseCase`, `ObservePollResultUseCase` (tally en vivo + `fetchMyVote` 1 vez; uid vía `AuthServiceProtocol`), `SubmitRefereePollVoteUseCase` (valida sesión/opción/ventana → `RefereePollVoteError`).
  - `MatchDetailViewModel`: `refereePoll`/`pollTally`/`myPollVote`/`pollVoteInFlight`/`pollVoteError`, `voteRefereePoll(optionId:)`, `refereePollOpciones`, `puedeVotarRefereePoll`. `myPollVote` se siembra 1 vez y luego lo fija el voto (el stream de tally no lo pisa).
  - `MatchDetailViewController`: sección "Termómetro Arbitral" (1ª del bloque de contexto) — botones tappables si `puedeVotar`, si no filas de resultado con barra; footer estado+total; muestra error de voto.
  - DI + tests: `MockPollRepository`, `ObserveRefereePollUseCaseTests` (3), `SubmitRefereePollVoteUseCaseTests` (5), +7 tests en `MatchDetailViewModelTests`, `RefereePoll.fixture`. `xcodebuild build` + `test` OK.

*3B. Simulador de tabla / descenso* (100% iOS, sin backend)
- **Motor puro ✅** (rama feat/plataforma-interactiva): `Domain/Entities/Simulator/MatchPrediction.swift` (resultado proyectado + `outcome`), `QualificationZone.swift` (`QualificationZone` enum + `QualificationRules` con default `.liga1`). `Domain/UseCases/Simulator/SimulateStandingsUseCase.swift` (puro: `(base:[Team], predictions:[MatchPrediction]) -> [Team]`, aplica deltas + ordena con `Team.isOrderedAboveInStandings` — pts>DG>GF>PG>nombre) y `ProjectQualificationUseCase.swift` (puro: tabla ordenada + reglas → `[teamCode: QualificationZone]`, descenso = últimos N, con precedencia sobre copas). Tests: `SimulateStandingsUseCaseTests` (11: aplicación de resultados, no muta input, batería de desempates pts>DG>GF>PG>nombre, flip de frontera) + `ProjectQualificationUseCaseTests` (6: bandas Liga 1 en 18, escalado del descenso, precedencia descenso, reglas custom). Fixture `Team.standing(code:pts:pj:…)`. `xcodebuild test` OK (17/17).
- **UI + datos ✅** (rama feat/plataforma-interactiva):
  - `JornadasRepository.fetchAllJornadas()` (nuevo en protocolo + impl: todas las jornadas sin filtro `mostrar`).
  - `Domain/Entities/Simulator/RemainingFixture.swift` + `Domain/UseCases/Simulator/FetchRemainingFixturesUseCase.swift` (por prefijo de torneo → matches `pendiente`, ordenados por jornada/fecha; `.acumulado` usa fixtures de Clausura).
  - `StandingsSimulatorViewModel` (patrón `Action`/`State`: `send(.load/.setScore/.resetScores)`, `@Published state`, recálculo síncrono con el motor puro; base = `FetchTeamsUseCase` o `CalculateAccumulatedStandingsUseCase` para `.acumulado`; `groupedFixtures` agrupado por jornada; `ProjectedRow.deltaVsBase` = movimiento de posición vs tabla actual).
  - `StandingsSimulatorViewController` (segmentado Apertura/Clausura/Acumulado, filas de partido con `−`/`+` por marcador, tabla proyectada con barra de color por zona + ▲/▼ delta, leyenda, disclaimer, botón "Compartir").
  - `Core/Utils/ShareImageRenderer.swift` (`UIView` → `UIImage` a 1080×1920, escala 1) + tarjeta de compartir generada en el VC.
  - Entrada: botón `slider.horizontal.3` en `TablaViewController` (nav bar) → `onSimulate` cableado en `MainTabBarController` → push del simulador con el torneo activo. DI: `makeStandingsSimulator*`, `makeFetchRemainingFixturesUseCase`, `makeSimulateStandingsUseCase`, `makeProjectQualificationUseCase`.
  - Tests: `FetchRemainingFixturesUseCaseTests` (5) + `StandingsSimulatorViewModelTests` (7). Mocks `MockJornadasRepository.fetchAllJornadas` + `MockMatchesRepository.resultsByJornada`. **Suite completa `TEST EXECUTE SUCCEEDED`** (29 tests del simulador, 0 fallos).

### FASE 2 — Gamificación Core  *(requiere añadir `liga1-admin-next/functions/`)*

**Sprint 4 — Infra de polla + envío**
- Scaffold `liga1-admin-next/functions/` (`firebase init functions`, TS, firebase-functions v2, ESLint; deploy `firebase deploy --only functions`). `firebase.json`/`.firebaserc`/`firestore.rules`/`firestore.indexes.json` en la raíz del admin.
- Colecciones `predictions`, `predictionScores`, `config/scoring`.
- Rules: create/update solo `uid==userId` y `request.time < jornada.fechaInicio`, forma estricta.
- iOS: `PollaViewModel`, `SubmitPredictionUseCase`, `GetServerTimeOffsetUseCase`, `ObserveMyPredictionUseCase`; UI de entrada por jornada con countdown (offset servidor).

**Sprint 5 — Functions de validación y cálculo**
- `lockPredictions` (scheduled 5 min).
- `scorePredictions` (trigger match→finalizado): puntos por `config/scoring` (exacto 3, 1X2 1, bonus racha), idempotente, `BulkWriter`.
- Tests con emulador: empates, no-show, re-finalización (no recuenta).

**Sprint 6 — Leaderboards + amigos**
- `leaderboards/global` + `leaderboards/group_{id}` mantenidos por `scorePredictions`.
- `friendGroups` con `codigoInvitacion`; `CreateFriendGroupUseCase`, `JoinFriendGroupUseCase`.
- iOS: `LeaderboardViewModel` (paginado, top N + mi posición), `FriendGroupsViewModel`.

### FASE 3 — Social y Viralidad

**Sprint 7 — Voto MVP en vivo**
- `matchVotes` + `mvpResults` + shards; `aggregateMatchVotes`; `closeMvpVoting`.
- Ventana: `kickoff + 75min` → fin + 10 min (rules + Function).
- Push: `RegisterMatchLiveTopicUseCase` al abrir `MatchDetail`; `sendMvpPushAt75` (scheduler 1 min) publica push interactivo a `match_{id}`.
- iOS: `MvpVotingViewModel`, `UNNotificationCategory` con acción de voto rápido, pantalla con plantel (reusa `MatchLineupModels`), resultado en vivo.

**Sprint 8 — 11 Ideal de la Fecha**
- `bestXIBallots` + `bestXIResults` + `computeBestXI` (post-jornada, ventana 48 h).
- iOS: `BestXIViewModel`, selector de formación + huecos por posición.
- Anti-fraude: 1 ballot/uid; solo jugadores que jugaron esa jornada (validar contra `xiLocal/xiVisitante`).

**Sprint 9 — Motor de gráficos compartibles**
- `ShareGraphicRenderer` genérico con plantillas `UIView`: (a) simulador de tabla, (b) mi polla/ranking, (c) 11 ideal, (d) MVP.
- Tamaños story `1080×1920` y post `1080×1350`; branding + deep link / QR.
- Hoja de compartir nativa; opcional subir a `Storage` y compartir URL.

---

## 4. Consideraciones Técnicas Críticas (resumen accionable)

1. **Costos Firestore**
   - Contadores distribuidos para todos los votos; el cliente lee solo el doc agregado.
   - Leaderboard incremental por Function; cliente pagina + consulta su entrada; nunca `orderBy` global.
   - Scoring en una pasada por jornada con `BulkWriter`.
   - Catálogos con `CachingRepository` + persistence offline.
   - Listeners solo con la vista viva y solo dentro de ventanas "en vivo".

2. **Sincronización horaria**
   - Bloqueo real = rules (`request.time`) + Function; el cliente solo hace UI con `ServerTimeOffset`.
   - `kickoff` en `Timestamp` UTC; envío tardío → error de rules → "jornada cerrada".

3. **Escalabilidad FCM**
   - Topics para broadcast; topic efímero `match_{id}` para eventos en vivo (sub al abrir, unsub al salir); multicast por tokens solo para grupos de amigos.
   - Push interactivo con `mutable-content` + `UNNotificationCategory`; flag anti-reenvío.

4. **Testing**
   - Simulador: batería exhaustiva de desempates Liga 1 y frontera copas/descenso.
   - Use cases con mocks (patrón `MockAuthService` ya establecido).
   - Functions: emulador Firebase; idempotencia de `scorePredictions`.
   - Rules: `@firebase/rules-unit-testing` (pronóstico tardío, doble voto, voto ajeno).

5. **Riesgos / decisiones abiertas**
   - Fuente de historial de árbitros → carga manual inicial desde el Admin; definir dataset mínimo.
   - Planteles para MVP / 11 ideal → dependen de que el Admin cargue el XI titular por partido (módulo de alineaciones ya existe en iOS).
   - Open-Meteo sin SLA → cachear último valor, rotular "estimado".
   - Vercel Hobby cron 1×/día → si insuficiente, GitHub Action o mover clima a `liga1-admin-next/functions/`.
   - Moderación de encuestas / 11 ideal (reportes, límites de tasa).

---

## Rediseño visual "Fan Experience" (2026-09-03, componentes nativos)

Aproximación a la captura de referencia usando UIKit nativo (sin librerías de UI):
- **`AppKit/Components/FanCardView.swift`** — card elevada (`appSecondaryBackground`, esquina continua 16, borde sutil o dorado), encabezado en mayúsculas, `contentStack` + helpers `infoRow`/`separator`. Trait-aware.
- **`AppKit/Components/PollBarView.swift`** — barra de resultados segmentada (dorado + grises), pesos = votos.
- **`AppColors`** — `liga1Gold` (#FFCC00) y `cardStroke` (dinámico).
- **MatchDetail**:
  - *Termómetro del arbitraje*: card con borde dorado → ficha compacta del juez (foto Kingfisher + "JUEZ" + nombre; a la derecha penales/partido en dorado) · pregunta · botones-pastilla `.filled()` (Sí verde / No rojo / resto dorado) · `PollBarView` + filas nombre/% · footer "En vivo" en dorado. La ficha del árbitro se oculta en "Información adicional" cuando hay encuesta.
  - *Factor altura & clima*: card → bloque geográfico centrado (ciudad grande + `2,335 MSNM` en dorado + pastilla de factor) · "DATO CALETA" · fila de clima (SF Symbol dorado + `24°C` + condición + ⚠️ si `climaAdvertencia`) con línea de detalle (viento · humedad · lluvia).
- **Simulador**: cards "Partidos restantes" (con "Reiniciar" dorado, subtítulos "FECHA N", filas con `−`/`+`) y "Tabla proyectada" (filas-cápsula con tinte de zona al 14% + barra de color + `▲/▼` en verde/rojo + puntos en negrita) + leyenda + CTA dorado "Compartir simulación".
- VM: `climaAdvertencia` (tormenta/nieve, frío/calor extremo, lluvia ≥70%) y `climaDetalleDisplay`.
- No fuerza tema oscuro: se ve oscuro-primero para usuarios en dark mode y limpio en claro. `xcodebuild build` OK.

## Anexo — Estado actual del código (2026-09-02)

- **iOS** (`feat/plataforma-interactiva`, sin cambios pendientes):
  - Ya existen: `Domain/Entities/Referee/RefereeProfile`, `Domain/Entities/Stadium/Stadium`,
    `Domain/UseCases/MatchContext/GetRefereeProfileUseCase`, `…/GetStadiumForTeamUseCase`,
    `Data/Repositories/RefereeRepository`, `…/StadiumRepository`, `…/CachingTeamsRepository`.
  - Módulo de alineaciones: `Presentation/Models/Match/MatchLineupModels`, `MatchLineupComponents`.
  - Convención `Slug.make(...)` para ids de `referees/{id}`.
- **Admin** (`liga1-admin-next`): Next.js 16 / Vercel. `firebase-admin.ts` hoy solo exporta `adminAuth` + `messaging` (falta `adminDb`). API routes en `src/app/api/**`. Scripts Node con `firebase-admin/firestore` ya funcionando (`scripts/rebuild-clausura-standings.mjs`). Sin `vercel.json`.
- **`functions/`** dentro del repo iOS: scaffolding retirado. Las Cloud Functions irán en `liga1-admin-next/functions/` (mismo repo que el admin web).
</content>
</invoke>

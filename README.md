# Liga 1 - App iOS

Aplicación iOS para seguir la Liga 1 de Fútbol Profesional del Perú. Consulta partidos, resultados, tabla de posiciones y noticias del torneo peruano.

## 📱 Características

- **Partidos por Jornada**: Visualiza los partidos organizados por jornadas con resultados en tiempo real. Header de fecha inteligente que muestra el día del próximo partido con icono de calendario
- **Tabla de Posiciones**: Consulta las tablas de Apertura, Clausura y Acumulado con estadísticas detalladas. Indicador visual especial (cuadrado amarillo) para el puesto 1 (campeón)
- **Favoritos**: Marca tus partidos favoritos para seguimiento rápido con sincronización en tiempo real
- **Noticias**: Mantente informado con las últimas noticias del fútbol peruano (solo publicadas), agrupadas por categoría; la categoría Destacado siempre primero, el resto ordenadas por fecha
- **Autenticación**: Ingresa con Google o correo electrónico para sincronizar tus favoritos
- **Modo Oscuro**: Soporte completo para Dark Mode que sigue automáticamente la configuración del sistema
- **UI Programático**: Interfaz construida 100% con código (sin Storyboards) usando APIs modernas de iOS 18
- **Recarga Automática**: Datos se actualizan automáticamente al entrar a las tabs de Torneo y Noticias
- **Gestión de Notificaciones**: Badge de notificaciones se limpia automáticamente al abrir la app
- **Historial de Notificaciones**: Visualiza y gestiona todas las notificaciones recibidas en el dispositivo
- **Configuración Mejorada**: Tab de Configuración con opciones de notificaciones, historial y gestión de cuenta

## ⚙️ Features Detalladas

### 🏠 Home - Partidos por Jornada

#### Visualización de Partidos
- **Una Jornada en Home**: Solo se muestra la jornada con `mostrar == true` y **menor fecha de inicio** (regla de negocio en Domain vía `GetJornadaToDisplayUseCase`)
- **Sistema de Jornadas**: Estructura anidada en Firestore (`jornadas/{jornadaId}/matches/{matchId}`)
- **Headers Duales**:
  - **Header de Fecha**: Muestra la fecha del próximo partido con formato inteligente
    - Si es hoy: "Hoy 30.01"
    - Si es futuro: "Viernes 30.01"
    - Icono de calendario alineado a la derecha
  - **Header de Jornada**: Muestra "Fecha X" y "Liga 1 - Torneo 2026" con fondo diferenciado
- **Pull-to-Refresh**: Actualización manual con spinner visible en modo claro y oscuro (blanco en oscuro)
- **Listado de Partidos**: Cada jornada muestra sus partidos con:
  - Logos de equipos local y visitante
  - Marcador en tiempo real (si está en vivo)
  - Estado del partido (pendiente, envivo, finalizado)
  - Botón de favorito por partido

#### Gestión de Datos
- **Actualización Reactiva**: Listeners de Firestore para jornada a mostrar y favoritos
- **Filtrado en Domain**: `GetJornadaToDisplayUseCase` devuelve la única jornada a mostrar; `FetchMatchesUseCase` filtra partidos al día más próximo (hoy o futuro)
- **Recarga Automática**: Al entrar a la tab se recargan los datos (`viewWillAppear`)

### 📊 Tabla de Posiciones

#### Características Visuales
- **Indicador de Campeón**: Cuadrado amarillo dorado alrededor del número 1 (no fondo en toda la celda)
- **Zonas de Clasificación** (modo claro):
  - 🟡 **Puesto 1**: Cuadrado amarillo en el número de posición
  - 🟢 **Zona Libertadores**: Fondo dorado (puestos 1-4 según torneo)
  - 🔵 **Zona Sudamericana**: Fondo azul (puestos 5-8)
  - 🔴 **Zona Descenso**: Fondo rojo (últimos 3 puestos)
- **Modo Oscuro Optimizado**: Sin fondos de colores, solo indicador amarillo para campeón
- **Header Personalizado**: Columnas "Equipo", "PJ", "GF-GC", "DG", "Pts"

#### Lógica de Ordenamiento
- **Orden Alfabético**: Cuando todos los equipos tienen 0 puntos
- **Orden por Rendimiento**: Por puntos (descendente), luego diferencia de goles (descendente)
- **Recarga Automática**: Al entrar a la tab se recargan los datos sin usar caché

### 📰 Noticias

#### Filtrado y Categorías
- **Solo publicadas**: El listado muestra únicamente noticias con `publicada == true` (filtro en Data layer)
- **Categorías**: destacado, partidos, fichajes, equipos, jugadores, tabla, estadísticas (definidas en `NewsCategory`)
- **Orden de secciones**: La categoría **Destacado** siempre aparece primera; el resto ordenadas por fecha de la noticia más reciente (`sortedForNewsDisplay` en Core/Utils)

#### Agrupación y Celdas
- **Agrupación por Categoría**: Noticias agrupadas por categoría; dentro de cada categoría ordenadas por fecha (más reciente primero)
- **Tipos de Celdas**:
  - **FeaturedNewsContentCell**: Para noticias de categoría Destacado (imagen grande + título)
  - **NewsCell**: Para el resto (formato compacto). El criterio "destacado" para el layout viene de `NewsItemUI.esDestacada` (categoría == .destacado)

#### Características
- **Navegación Web**: Al tocar una noticia se abre Safari (`SFSafariViewController`)
- **Recarga Automática**: Al entrar a la tab se recargan las noticias

### ⭐ Favoritos

#### Gestión de Favoritos
- **Marcado Visual**: Botón de corazón en cada partido
- **Persistencia**: Favoritos guardados en Firestore bajo `users/{userId}/favorites`
- **Sincronización en Tiempo Real**: Listeners de Firestore para actualización automática
- **ID Completo**: `{jornadaId}_{matchId}` (ej: "apertura_01_adt_utc")
- **Actualización Automática**: UI se actualiza reactivamente con Combine

### 🔐 Autenticación

#### Métodos de Login
- **Google Sign-In**: Inicio de sesión con cuenta de Google (OAuth 2.0)
- **Email/Password**: Autenticación tradicional con Firebase Auth
- **Persistencia de Sesión**: Firebase Auth mantiene la sesión activa
- **Navegación Automática**: Al iniciar sesión, navega automáticamente al MainTabBar

#### Gestión de Sesión
- **SessionManager**: Gestión de timeout de inactividad (5 días)
- **Cierre Automático**: Cierra sesión automáticamente después de inactividad prolongada

### ⚙️ Configuración

#### Opciones Disponibles
- **Notificaciones Push**:
  - **Ajustes de Notificaciones**: Pantalla dedicada que muestra el estado de las notificaciones y permite abrir Configuración del sistema
  - **Historial de Notificaciones**: Visualiza todas las notificaciones entregadas al dispositivo con posibilidad de eliminarlas
- **Usuario**: Información del usuario y nombre de usuario
- **Administración**: Herramientas para registro masivo de partidos
- **Otros**: Comentarios, términos, políticas de privacidad y versión
- **Cerrar Sesión**: Opción al final de todas las secciones con estilo destructivo (rojo)

**Nota**: El tema de la app (modo claro/oscuro) sigue automáticamente la configuración del sistema del dispositivo del usuario.

### 🛠 Panel de Administración

#### Registro Masivo
- **Registro de Jornadas**: Crear múltiples jornadas de forma masiva
- **Registro de Partidos**: Asignar partidos a jornadas con fixture completo
- **Validación de Datos**: Validación antes de registrar en Firestore
- **Feedback Visual**: Indicadores de éxito/error en las operaciones

### 📱 Notificaciones Push

#### Características
- **Registro Automático**: Se registra automáticamente para notificaciones remotas
- **FCM Integration**: Integración con Firebase Cloud Messaging
- **Badge Management**: Limpieza automática de badge al abrir la app (API moderna iOS 18)
- **Topics**: Suscripción a topics (ej: "live_matches")
- **Pantalla de Ajustes**: Pantalla dedicada que muestra el estado de las notificaciones y permite abrir Configuración del sistema
- **Historial de Notificaciones**: Visualización de todas las notificaciones entregadas al dispositivo
  - Tabla plana con celdas de mayor altura para mejor legibilidad
  - Posibilidad de eliminar notificaciones mediante swipe
  - Ordenadas por fecha (más recientes primero)
  - Muestra título, cuerpo y fecha de cada notificación

## 🛠 Tecnologías y Frameworks

### Lenguaje y Runtime
- **Swift 5.0+** - Lenguaje de programación principal
- **iOS 18.0+** - Versión mínima del sistema operativo
- **UIKit Programático** - Construcción de interfaces 100% con código (sin Storyboards)
- **Combine Framework** - Framework reactivo para manejo de eventos y flujo de datos asíncronos

### Dependencias Principales (Swift Package Manager)

#### Firebase SDK (v11.0.0)
- **Firebase/Firestore**: Base de datos NoSQL en tiempo real
  - Persistencia offline habilitada
  - Listeners reactivos para actualización automática
  - Estructura anidada: `jornadas/{jornadaId}/matches/{matchId}`
  
- **Firebase/Auth**: Sistema de autenticación
  - Soporte para Google Sign-In (OAuth 2.0)
  - Autenticación con Email/Password
  - Gestión de sesiones persistente
  
- **Firebase/Storage**: Almacenamiento de recursos multimedia
  - Imágenes de equipos
  - Logos y assets

- **Firebase/Messaging**: Notificaciones push
  - FCM (Firebase Cloud Messaging)
  - Gestión de tokens
  - Notificaciones remotas

#### Google Sign-In SDK (v8.0.0)
- **GoogleSignIn-iOS**: SDK oficial para autenticación con Google
  - OAuth 2.0 flow
  - Gestión de sesiones de Google
  - Integración con Firebase Auth

#### Dependencias de Soporte
- **AppAuth-iOS** (v1.7.5): Framework OAuth/OpenID Connect
- **Promises** (v2.4.0): Manejo de promesas asíncronas
- **Swift Protobuf** (v1.27.1): Serialización de protocol buffers
- **LevelDB** (v1.22.5): Base de datos embebida para cache local de Firestore
- **Nanopb** (v2.30910.0): Implementación ligera de protocol buffers

### Gestión de Dependencias
- **Swift Package Manager (SPM)**: Gestión nativa de dependencias
  - Todas las dependencias se resuelven automáticamente
  - Sin necesidad de CocoaPods o Carthage
  - Integración directa con Xcode

## 🏗 Arquitectura

La aplicación sigue **Clean Architecture** con el patrón **MVVM + Combine**:

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                   │
│  (Views, ViewModels, Components, Mappers)   │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│          Domain Layer                        │
│  (Entities, Use Cases, Repository Protocols)│
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│           Data Layer                         │
│  (Repositories, DTOs, Mappers, Services)    │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│          Core Layer                          │
│  (Extensions, Utils, Constants, Firebase)   │
└─────────────────────────────────────────────┘
```

### Flujo de Datos

El flujo de datos sigue esta arquitectura en capas:

1. **View** (UIViewController) → Llama métodos del **ViewModel**
2. **ViewModel** → Ejecuta **Use Cases** del dominio
3. **Use Case** → Usa **Repository Protocols** (definidos en Domain)
4. **Repository Implementation** (Data Layer) → Accede a Firestore a través de **FirestoreManager**
5. Los datos se transforman: **DTO** → **Domain Entity** → **UI Model**
6. El flujo inverso actualiza la UI de forma reactiva usando **Combine**

```
View → ViewModel → UseCase → Repository → Firestore
                        ↑                      ↓
                    Combine Publishers ← DTO → Entity → UI Model
```

### Capas de la Arquitectura

#### 📱 Presentation Layer

**Responsabilidad**: Interfaz de usuario y lógica de presentación

- **Views/**: ViewControllers construidos programáticamente
  - `Home/` - Pantalla principal con jornadas y partidos
  - `News/` - Lista de noticias
  - `Tabla/` - Tabla de posiciones (Apertura/Clausura/Acumulado)
  - `Favoritos/` - Partidos favoritos del usuario
  - `Profile/` - Configuración y gestión de cuenta
  - `Login/` - Autenticación
  - `TabBar/` - Navegación principal
  - `Admin/` - Registro de partidos (administradores)

- **ViewModels/**: Lógica de presentación con `@Published` properties
  - `HomeViewModel` - Usa `GetJornadaToDisplayUseCase` para la jornada a mostrar; gestión de partidos y favoritos
  - `NewsViewModel` - Gestión de noticias (agrupación por categoría, orden vía `NewsCategory.sortedForNewsDisplay`)
  - `TorneoViewModel` - Gestión de tabla de posiciones
  - `FavoritosViewModel` - Gestión de favoritos
  - `ProfileViewModel` - Gestión de configuración
  - `LoginViewModel` - Gestión de autenticación
  - `RegistrarPartidosViewModel` - Registro masivo de partidos

- **Components/**: Componentes UI reutilizables
  - `Cells/` - Celdas de table view (Match, Team, News)
  - `Headers/` - Headers personalizados
  - `DividerView` - Separadores

- **Models/**: Modelos específicos de UI
  - `MatchUI`, `TeamUI`, `NewsItemUI`, `JornadaUI`, `JornadaSection` (sección jornada + partidos para Home)

- **Mappers/**: Transformación de Domain Entities a UI Models
  - `MatchUIMapper`, `TeamUIMapper`, `NewsItemUIMapper`, `JornadaUIMapper`

#### 🎯 Domain Layer

**Responsabilidad**: Lógica de negocio pura (independiente de frameworks)

- **Entities/**: Entidades de dominio
  - `Match` - Partido de fútbol
  - `Jornada` - Jornada del torneo
  - `Team` - Equipo de fútbol
  - `NewsItem` - Noticia

- **UseCases/**: Casos de uso (lógica de negocio)
  - **Jornadas/**: `FetchActiveJornadasUseCase`, `ObserveActiveJornadasUseCase`, `GetJornadaToDisplayUseCase` (jornada única a mostrar: menor `fechaInicio` entre activas)
  - **Matches/**: `FetchMatchesUseCase`, `ObserveMatchesUseCase`
  - **Teams/**: `FetchTeamsUseCase`
  - **News/**: `FetchNewsUseCase`
  - **Favorites/**: `ToggleFavoriteUseCase`, `ObserveFavoritesUseCase`, `FetchFavoriteMatchesUseCase`
  - **Auth/**: `LoginUseCase`, `LogoutUseCase`
  - **Admin/**: `RegisterMatchesUseCase`

- **Repositories/**: Protocolos (contratos) que definen operaciones de datos
  - `JornadasRepositoryProtocol`
  - `MatchesRepositoryProtocol`
  - `TeamsRepositoryProtocol`
  - `NewsRepositoryProtocol`
  - `AdminMatchRepositoryProtocol`

**Principios**:
- No depende de ninguna capa externa
- Define interfaces (protocolos) para repositorios
- Contiene la lógica de negocio pura
- Es testeable sin dependencias externas

#### 💾 Data Layer

**Responsabilidad**: Acceso a datos y transformaciones

- **Repositories/**: Implementaciones concretas de los protocolos del Domain
  - `JornadasRepository` - Implementa `JornadasRepositoryProtocol`
  - `MatchesRepository` - Implementa `MatchesRepositoryProtocol`
  - `TeamsRepository` - Implementa `TeamsRepositoryProtocol`
  - `NewsRepository` - Implementa `NewsRepositoryProtocol`
  - `AdminMatchRepository` - Implementa `AdminMatchRepositoryProtocol`

- **DTOs/**: Data Transfer Objects (estructuras que coinciden con Firestore)
  - `MatchDTO`, `JornadaDTO`, `TeamDTO`, `NewsItemDTO`

- **Mappers/**: Transformación entre DTOs y Domain Entities
  - `MatchMapper`, `JornadaMapper`, `TeamMapper`, `NewsItemMapper`

- **Services/**: Servicios transversales
  - `AuthService` - Autenticación con Firebase
  - `FavoritesService` - Gestión de favoritos

- **Helpers/**: Utilidades para datos
  - `AperturaFixtureData` - Datos del fixture del torneo Apertura

**Características**:
- Retornan `AnyPublisher<T, Error>` usando Combine
- Transforman DTOs a Domain Entities
- Implementan los protocolos definidos en Domain
- Manejan la persistencia con Firestore

#### 🔧 Core Layer

**Responsabilidad**: Funcionalidades compartidas y configuración

- **Firebase/**: Configuración y abstracción de Firebase
  - `FirestoreManager` - Implementa `DatabaseProtocol`
  - `DatabaseProtocol` - Abstracción para testing

- **Extensions/**: Extensions de UIKit para facilitar el desarrollo
  - `UIView+Layout` - DSL para Auto Layout programático
  - `UIStackView+Builder` - Builder pattern para stack views
  - `Color+Extension` - Colores personalizados (`.liga1Red`)
  - `UIViewController+Alert` - Helpers para mostrar alerts

- **Utils/**: Utilidades compartidas
  - `LayoutPresets` - Componentes UI reutilizables (botones, labels)
  - `EquipoPeruano` - Enum con códigos y nombres de equipos
  - `TorneoType` - Enum para tipos de torneo (Apertura, Clausura, Acumulado)
  - `TablePosition` - Cálculo de zonas de clasificación
  - `NewsCategory` - Categorías de noticias (destacado, partidos, fichajes, equipos, jugadores, tabla, estadísticas); incluye `sortedForNewsDisplay` para orden de secciones

- **Constants/**: Constantes de la aplicación
  - `FirestoreConstants` - Nombres de colecciones y campos

- **Logging/**: Sistema de logging
  - `Logger` - Logger centralizado con niveles (debug, info, warning, error)

- **Auth/**: Abstracción de autenticación
  - `AuthProvider` - Protocolo para autenticación

- **Application/**: Configuración de la app
  - `AppDelegate`, `SceneDelegate`
  - `SessionManager` - Gestión de sesión
  - `Coordinator/` - Coordinadores de navegación

- **DI/**: Dependency Injection
  - `DIContainer` - Contenedor centralizado para inyección de dependencias

- **Resources/**: Recursos de la app
  - `Assets.xcassets` - Imágenes, logos, colores
  - `GoogleService-Info.plist` - Configuración de Firebase
  - `Info.plist` - Configuración de la app

### Dependency Injection (DI)

La aplicación utiliza un patrón de **Dependency Injection** centralizado mediante `DIContainer`:

```swift
// El DIContainer crea todas las dependencias
final class DIContainer {
    static let shared = DIContainer()
    
    // Crea Repositories
    func makeJornadasRepository() -> JornadasRepositoryProtocol
    func makeMatchesRepository() -> MatchesRepositoryProtocol
    // ...
    
    // Crea Use Cases
    func makeFetchActiveJornadasUseCase() -> FetchActiveJornadasUseCaseProtocol
    func makeGetJornadaToDisplayUseCase() -> GetJornadaToDisplayUseCaseProtocol
    // ...
    
    // Crea ViewModels
    func makeHomeViewModel() -> HomeViewModel  // Inyecta getJornadaToDisplayUseCase, fetchMatchesUseCase, etc.
    // ...
    
    // Crea ViewControllers
    func makeHomeViewController() -> HomeViewController
    // ...
}
```

**Ventajas**:
- Facilita el testing (puedes inyectar mocks)
- Centraliza la creación de objetos
- Reduce el acoplamiento entre componentes
- Sigue el principio de Inversión de Dependencias (SOLID)

### Patrón MVVM + Combine

**ViewModels**:
- Contienen `@Published` properties para actualización reactiva
- No conocen UIKit (son fácilmente testeables)
- Ejecutan Use Cases para obtener datos
- Transforman Domain Entities a UI Models

**Views**:
- Se suscriben a `@Published` properties usando Combine
- Actualizan la UI reactivamente cuando cambian los datos
- Envían acciones del usuario al ViewModel

**Ejemplo de flujo**:
```swift
// ViewModel (Home): la jornada a mostrar viene del Domain
class HomeViewModel {
    @Published private(set) var jornadaSections: [JornadaSection] = []
    
    func fetchActiveJornadas() {
        getJornadaToDisplayUseCase.execute()
            .sink { [weak self] jornada in
                self?.loadMatchesForJornadas(jornada.map { [$0] } ?? [])
            }
            .store(in: &cancellables)
    }
}

// ViewController
class HomeViewController {
    func bindViewModel() {
        viewModel.$jornadaSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}
```

## 📁 Estructura Detallada del Proyecto

### Estructura de Directorios y Archivos

```
liga1/
│
├── 📱 Application/
│   ├── AppDelegate.swift                    # Configuración inicial de la app, notificaciones push
│   ├── SceneDelegate.swift                  # Gestión de escenas y ciclo de vida
│   ├── SessionManager.swift                 # Gestión de sesión y timeout de inactividad
│   └── Coordinator/
│       ├── Coordinator.swift                # Protocolo base para coordinadores
│       ├── AppCoordinator.swift             # Coordinador principal (Login/Main flow)
│       └── LoginCoordinator.swift           # Coordinador de flujo de autenticación
│
├── 🎨 Presentation/ (Capa de Presentación)
│   ├── Views/
│   │   ├── Home/
│   │   │   ├── HomeViewController.swift     # ViewController principal con tabla de jornadas
│   │   │   └── HomeTableViewAdapter.swift   # Adapter para lógica de UITableView (headers, celdas)
│   │   ├── News/
│   │   │   ├── NewsViewController.swift     # ViewController de noticias
│   │   │   └── NewsViewController+TableView.swift # Extension con dataSource/delegate
│   │   ├── Tabla/
│   │   │   ├── TablaViewController.swift    # ViewController de tabla de posiciones
│   │   │   └── TorneoViewController+TableView.swift # Extension con lógica de tabla
│   │   ├── Favoritos/
│   │   │   ├── FavoritosViewController.swift # ViewController de favoritos
│   │   │   └── TeamSearchModalViewController.swift # Modal de búsqueda de equipos
│   │   ├── Profile/
│   │   │   ├── ProfileViewController.swift  # ViewController de configuración
│   │   │   ├── ProfileViewController+TableView.swift # Extension con opciones de configuración
│   │   │   ├── NotificationHistoryViewController.swift # Historial de notificaciones
│   │   │   └── NotificationSettingsViewController.swift # Ajustes de notificaciones
│   │   ├── Login/
│   │   │   └── LoginViewController.swift    # Pantalla de autenticación
│   │   ├── TabBar/
│   │   │   └── MainTabBarController.swift   # Tab bar principal con 5 tabs
│   │   └── Admin/
│   │       └── RegistrarPartidosViewController.swift # Panel de administración
│   │
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift              # Estado y lógica de Home (jornadas activas)
│   │   ├── NewsViewModel.swift              # Estado y lógica de Noticias (agrupación por categoría)
│   │   ├── TorneoViewModel.swift            # Estado y lógica de Tabla (cache de posiciones)
│   │   ├── FavoritosViewModel.swift         # Estado y lógica de Favoritos
│   │   ├── ProfileViewModel.swift           # Estado y lógica de Configuración
│   │   ├── LoginViewModel.swift             # Estado y lógica de Login
│   │   └── RegistrarPartidosViewModel.swift # Estado y lógica de registro masivo
│   │
│   ├── Models/ (Modelos específicos de UI)
│   │   ├── Match/
│   │   │   └── MatchUI.swift                # Modelo UI con propiedades formateadas
│   │   ├── Team/
│   │   │   └── TeamUI.swift                 # Modelo UI de equipo
│   │   ├── NewsItem/
│   │   │   └── NewsItemUI.swift             # Modelo UI con fecha formateada y esDestacada (categoría == .destacado)
│   │   └── Jornada/
│   │       ├── JornadaUI.swift              # Modelo UI de jornada
│   │       └── JornadaSection.swift         # Sección para Home (jornadaId, numero, torneo, matches)
│   │
│   ├── Mappers/
│   │   ├── MatchUIMapper.swift              # Domain Entity → UI Model (Match)
│   │   ├── TeamUIMapper.swift               # Domain Entity → UI Model (Team)
│   │   ├── NewsItemUIMapper.swift           # Domain Entity → UI Model (NewsItem)
│   │   └── JornadaUIMapper.swift            # Domain Entity → UI Model (Jornada)
│   │
│   └── Components/
│       ├── Cells/
│       │   ├── MatchTableViewCell.swift     # Celda de partido con logos y marcador
│       │   ├── EquipoTableViewCell.swift    # Celda de equipo en tabla de posiciones
│       │   ├── NewsCell.swift               # Celda estándar de noticia
│       │   ├── FeaturedNewsContentCell.swift # Celda destacada de noticia (imagen grande)
│       │   ├── HeaderView.swift             # Header de tabla de posiciones
│       │   ├── CategoryHeaderView.swift     # Header de categoría de noticias
│       │   └── FeaturedNewsTitleHeaderView.swift # Header "NOTICIA DESTACADA"
│       └── DividerView.swift                # Separador visual reutilizable
│
├── 🎯 Domain/ (Capa de Dominio - Lógica de Negocio)
│   ├── Entities/ (Entidades puras, sin dependencias)
│   │   ├── Match/
│   │   │   └── Match.swift                  # Entidad: Partido (fecha, equipos, resultado, estado)
│   │   ├── Jornada/
│   │   │   └── Jornada.swift                # Entidad: Jornada (id, torneo, numero, fechaInicio)
│   │   ├── Team/
│   │   │   └── Team.swift                   # Entidad: Equipo (nombre, estadísticas, puntos)
│   │   └── NewsItem/
│   │       └── NewsItem.swift               # Entidad: Noticia (titulo, url, categoria, fecha)
│   │
│   ├── Repositories/ (Protocolos - Contratos)
│   │   ├── JornadasRepositoryProtocol.swift # Protocolo: Operaciones con jornadas
│   │   ├── MatchesRepositoryProtocol.swift  # Protocolo: Operaciones con partidos
│   │   ├── TeamsRepositoryProtocol.swift    # Protocolo: Operaciones con equipos
│   │   ├── NewsRepositoryProtocol.swift     # Protocolo: Operaciones con noticias
│   │   └── AdminMatchRepositoryProtocol.swift # Protocolo: Operaciones admin
│   │
│   └── UseCases/ (Casos de Uso - Lógica de Negocio)
│       ├── Jornadas/
│       │   ├── FetchActiveJornadasUseCase.swift      # Obtener jornadas activas (mostrar == true)
│       │   ├── ObserveActiveJornadasUseCase.swift   # Observar cambios en jornadas activas
│       │   └── GetJornadaToDisplayUseCase.swift     # Jornada única a mostrar (menor fechaInicio)
│       ├── Matches/
│       │   ├── FetchMatchesUseCase.swift             # Obtener partidos de una jornada
│       │   └── ObserveMatchesUseCase.swift           # Observar cambios en partidos
│       ├── Teams/
│       │   └── FetchTeamsUseCase.swift               # Obtener equipos de un torneo
│       ├── News/
│       │   └── FetchNewsUseCase.swift                # Obtener todas las noticias
│       ├── Favorites/
│       │   ├── ToggleFavoriteUseCase.swift           # Marcar/desmarcar favorito
│       │   ├── ObserveFavoritesUseCase.swift         # Observar cambios en favoritos
│       │   └── FetchFavoriteMatchesUseCase.swift     # Obtener partidos favoritos
│       ├── Auth/
│       │   ├── LoginUseCase.swift                    # Iniciar sesión
│       │   └── LogoutUseCase.swift                   # Cerrar sesión
│       └── Admin/
│           └── RegisterMatchesUseCase.swift          # Registro masivo de partidos
│
├── 💾 Data/ (Capa de Datos - Acceso a Firebase)
│   ├── Repositories/ (Implementaciones)
│   │   ├── JornadasRepository.swift         # Implementa JornadasRepositoryProtocol
│   │   ├── MatchesRepository.swift          # Implementa MatchesRepositoryProtocol
│   │   ├── TeamsRepository.swift            # Implementa TeamsRepositoryProtocol
│   │   ├── NewsRepository.swift             # Implementa NewsRepositoryProtocol
│   │   └── AdminMatchRepository.swift       # Implementa AdminMatchRepositoryProtocol
│   │
│   ├── DTOs/ (Data Transfer Objects - Firestore)
│   │   ├── Match/
│   │   │   └── MatchDTO.swift               # Estructura que coincide con Firestore
│   │   ├── Jornada/
│   │   │   └── JornadaDTO.swift             # Estructura que coincide con Firestore
│   │   ├── Team/
│   │   │   └── TeamDTO.swift                # Estructura que coincide con Firestore
│   │   └── NewsItem/
│   │       └── NewsItemDTO.swift            # Estructura que coincide con Firestore
│   │
│   ├── Mappers/
│   │   ├── MatchMapper.swift                # DTO → Domain Entity (Match)
│   │   ├── JornadaMapper.swift              # DTO → Domain Entity (Jornada)
│   │   ├── TeamMapper.swift                 # DTO → Domain Entity (Team)
│   │   └── NewsItemMapper.swift             # DTO → Domain Entity (NewsItem)
│   │
│   ├── Services/ (Servicios transversales)
│   │   ├── AuthService.swift                # Autenticación con Firebase Auth
│   │   └── FavoritesService.swift           # Gestión de favoritos en Firestore
│   │
│   └── Helpers/
│       └── AperturaFixtureData.swift        # Datos del fixture completo del torneo
│
├── 🔧 Core/ (Capa Core - Utilidades y Configuración)
│   ├── Firebase/
│   │   ├── FirestoreManager.swift           # Abstracción de Firestore (implementa DatabaseProtocol)
│   │   ├── DatabaseProtocol.swift           # Protocolo para testing y abstracción
│   │   └── NotificationService.swift        # Gestión de notificaciones push
│   │
│   ├── Extensions/
│   │   ├── UIView+Layout.swift              # DSL para Auto Layout declarativo
│   │   ├── UIStackView+Builder.swift        # Builder pattern para stack views
│   │   ├── Color+Extension.swift            # Colores personalizados (.liga1Red, .libertadoresGold)
│   │   └── UIViewController+Alert.swift     # Helpers para mostrar alerts
│   │
│   ├── Utils/
│   │   ├── LayoutPresets.swift              # Componentes UI reutilizables (botones, labels, tables)
│   │   ├── EquipoPeruano.swift              # Enum con códigos de 18 equipos (ali, utc, etc.)
│   │   ├── TorneoType.swift                 # Enum: .apertura, .clausura, .acumulado
│   │   ├── TablePosition.swift              # Enum y lógica de zonas (libertadores, sudamericana, descenso)
│   │   └── NewsCategory.swift               # Categorías: destacado, partidos, fichajes, equipos, jugadores, tabla, estadísticas; sortedForNewsDisplay
│   │
│   ├── Constants/
│   │   └── FirestoreConstants.swift         # Nombres de colecciones y campos
│   │
│   ├── Logging/
│   │   └── Logger.swift                     # Logger centralizado (debug, info, warning, error)
│   │
│   └── Auth/
│       └── AuthProvider.swift               # Protocolo de autenticación
│
├── 🔌 DI/ (Dependency Injection)
│   └── DIContainer.swift                    # Contenedor centralizado para inyección de dependencias
│
└── 📦 Resources/
    ├── Assets.xcassets/                     # Imágenes, logos de 18 equipos, colores
    ├── GoogleService-Info.plist             # Configuración de Firebase
    ├── Info.plist                           # Configuración de la app (URL schemes, etc.)
    └── [Archivos JSON de datos]             # Datos estáticos si los hay
```

## 🗄 Estructura de Datos en Firestore

### Colección: `jornadas`

Cada jornada es un documento con ID en formato `{torneo}_{numero}` (ej: `apertura_01`)

```
jornadas/
├── {jornadaId}              # Ejemplo: "apertura_01"
│   ├── mostrar: Bool        # Si se muestra en el home
│   ├── fechaInicio: Date    # Fecha de inicio de la jornada
│   └── matches/             # Subcolección de partidos
│       └── {matchId}        # Ejemplo: "adt_utc"
│           ├── fecha: Timestamp
│           ├── estado: String    # "pendiente", "envivo", "finalizado", "anulado", "suspendido"
│           ├── golesEquipoLocal: Int
│           ├── golesEquipoVisitante: Int
│           └── suspendido: Bool
```

**Nota**: Los campos `torneo` y `numero` se extraen del `documentID`, no se almacenan como campos.

### Colección: `teams`

```
teams/
└── {teamId}                 # Ejemplo: "ali" (Alianza Lima)
    ├── name: String
    ├── logo: String         # Nombre del asset de imagen
    └── ... (otros campos)
```

### Colección: `users`

```
users/
└── {userId}/
    └── favorites/
        └── {matchId}: Bool  # Ejemplo: "apertura_01_adt_utc": true
```

### Colección: `news`

```
news/
└── {noticiaId}
    ├── title: String
    ├── image: String
    ├── url: String
    ├── fecha: Timestamp
    ├── categoria: String    # destacado, partidos, fichajes, equipos, jugadores, tabla, estadísticas
    ├── periodico: String
    └── publicada: Bool      # Solo se listan noticias con publicada == true
```

## 🎨 Características de UI/UX

- **Layout Programático**: 100% código con Auto Layout
- **Diseño Adaptativo**: Soporte completo para modo claro y oscuro
- **Pull-to-Refresh**: Actualización manual de datos con spinner visible en ambos modos
- **Loading States**: Indicadores de carga
- **Error Handling**: Mensajes informativos para errores
- **Custom Extensions**: Helpers para layout declarativo
- **Reactive UI**: Actualización automática con Combine
- **APIs Modernas**: Uso de APIs de iOS 17+ y iOS 18 sin deprecaciones
- **Gestión de Badge**: Limpieza automática de badges de notificaciones al abrir la app
- **Headers Inteligentes**: Headers con información contextual (fechas, iconos) adaptados al contenido

## 🚀 Instalación y Configuración

### Requisitos Previos

- Xcode 15.0+
- iOS 18.0+
- Cuenta de Firebase
- Cuenta de desarrollador de Google (para Google Sign-In)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/rapser/liga1.git
   cd liga1
   ```

2. **Configurar Firebase**
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com)
   - Descarga `GoogleService-Info.plist`
   - Coloca el archivo en `liga1/Resources/`

3. **Configurar Google Sign-In**
   - En Firebase Console, habilita el proveedor de Google
   - Copia el `CLIENT_ID` de Google
   - Actualiza el `Info.plist` con tu URL Scheme

4. **Instalar dependencias**
   - Abre `liga1.xcodeproj` en Xcode
   - Las dependencias SPM se resolverán automáticamente

5. **Ejecutar el proyecto**
   - Selecciona un simulador o dispositivo con iOS 18.0+
   - Presiona `Cmd + R` para compilar y ejecutar

## 📚 Documentación Adicional

- [CHANGELOG.md](CHANGELOG.md) - Estado actual del proyecto

## 👥 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Guías de Estilo

- Sigue la arquitectura Clean Architecture establecida
- Usa programmatic UI (sin Storyboards)
- Implementa Combine para operaciones asíncronas
- Escribe código siguiendo Swift style guide
- Documenta cambios en CHANGELOG.md

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📧 Contacto

Miguel Tomairo - [@rapser](https://github.com/rapser)

Project Link: [https://github.com/rapser/liga1](https://github.com/rapser/liga1)

---

**Hecho con ❤️ para los fanáticos del fútbol peruano**

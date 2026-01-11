# Liga 1 - App iOS

Aplicación iOS para seguir la Liga 1 de Fútbol Profesional del Perú. Consulta partidos, resultados, tabla de posiciones y noticias del torneo peruano.

## 📱 Características

- **Partidos por Jornada**: Visualiza los partidos organizados por jornadas con resultados en tiempo real
- **Tabla de Posiciones**: Consulta las tablas de Apertura, Clausura y Acumulado con estadísticas detalladas
- **Favoritos**: Marca tus partidos favoritos para seguimiento rápido con sincronización en tiempo real
- **Noticias**: Mantente informado con las últimas noticias del fútbol peruano
- **Autenticación**: Ingresa con Google o correo electrónico para sincronizar tus favoritos
- **Modo Oscuro**: Soporte completo para Dark Mode
- **UI Programático**: Interfaz construida 100% con código (sin Storyboards)

## 🛠 Tecnologías y Frameworks

### Lenguaje
- **Swift 5.0+**
- **UIKit Programático** - Construcción de interfaces sin Storyboards
- **Combine** - Framework reactivo para manejo de eventos y flujo de datos

### Backend & Servicios
- **Firebase**
  - **Firestore**: Base de datos NoSQL para almacenamiento de partidos, jornadas, equipos y noticias
  - **Authentication**: Sistema de autenticación con Google Sign-In y Email/Password
  - **Storage**: Almacenamiento de imágenes y recursos multimedia

### Autenticación
- **Google Sign-In SDK**: Inicio de sesión con Google
- **Firebase Auth**: Gestión de usuarios y sesiones

### Gestión de Dependencias
- **Swift Package Manager (SPM)**: Manejo de dependencias externas

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
  - `Profile/` - Perfil y configuración
  - `Login/` - Autenticación
  - `TabBar/` - Navegación principal
  - `Admin/` - Registro de partidos (administradores)

- **ViewModels/**: Lógica de presentación con `@Published` properties
  - `HomeViewModel` - Gestión de jornadas activas y partidos
  - `NewsViewModel` - Gestión de noticias
  - `TorneoViewModel` - Gestión de tabla de posiciones
  - `FavoritosViewModel` - Gestión de favoritos
  - `ProfileViewModel` - Gestión de perfil
  - `LoginViewModel` - Gestión de autenticación
  - `RegistrarPartidosViewModel` - Registro masivo de partidos

- **Components/**: Componentes UI reutilizables
  - `Cells/` - Celdas de table view (Match, Team, News)
  - `Headers/` - Headers personalizados
  - `DividerView` - Separadores

- **Models/**: Modelos específicos de UI
  - `MatchUI`, `TeamUI`, `NewsItemUI`, `JornadaUI`

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
  - **Jornadas/**: `FetchActiveJornadasUseCase`, `ObserveActiveJornadasUseCase`
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
  - `NewsCategory` - Categorías de noticias

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
    // ...
    
    // Crea ViewModels
    func makeHomeViewModel() -> HomeViewModel
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
// ViewModel
class HomeViewModel {
    @Published private(set) var jornadaSections: [JornadaSection] = []
    
    func fetchActiveJornadas() {
        fetchActiveJornadasUseCase.execute()
            .sink { [weak self] jornadas in
                self?.loadMatchesForJornadas(jornadas)
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

### Estructura del Proyecto

```
liga1/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── SessionManager.swift
│   └── Coordinator/
│       ├── AppCoordinator.swift
│       ├── Coordinator.swift
│       └── LoginCoordinator.swift
│
├── Presentation/
│   ├── Views/
│   │   ├── Home/
│   │   ├── News/
│   │   ├── Tabla/
│   │   ├── Favoritos/
│   │   ├── Profile/
│   │   ├── Login/
│   │   ├── TabBar/
│   │   └── Admin/
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   ├── NewsViewModel.swift
│   │   ├── TorneoViewModel.swift
│   │   ├── FavoritosViewModel.swift
│   │   ├── ProfileViewModel.swift
│   │   ├── LoginViewModel.swift
│   │   └── RegistrarPartidosViewModel.swift
│   ├── Models/
│   │   ├── Match/
│   │   ├── Team/
│   │   ├── NewsItem/
│   │   └── Jornada/
│   ├── Mappers/
│   │   ├── MatchUIMapper.swift
│   │   ├── TeamUIMapper.swift
│   │   ├── NewsItemUIMapper.swift
│   │   └── JornadaUIMapper.swift
│   └── Components/
│       ├── Cells/
│       └── Headers/
│
├── Domain/
│   ├── Entities/
│   │   ├── Match/
│   │   ├── Jornada/
│   │   ├── Team/
│   │   └── NewsItem/
│   ├── Repositories/
│   │   ├── JornadasRepositoryProtocol.swift
│   │   ├── MatchesRepositoryProtocol.swift
│   │   ├── TeamsRepositoryProtocol.swift
│   │   ├── NewsRepositoryProtocol.swift
│   │   └── AdminMatchRepositoryProtocol.swift
│   └── UseCases/
│       ├── Jornadas/
│       ├── Matches/
│       ├── Teams/
│       ├── News/
│       ├── Favorites/
│       ├── Auth/
│       └── Admin/
│
├── Data/
│   ├── Repositories/
│   │   ├── JornadasRepository.swift
│   │   ├── MatchesRepository.swift
│   │   ├── TeamsRepository.swift
│   │   ├── NewsRepository.swift
│   │   └── AdminMatchRepository.swift
│   ├── DTOs/
│   │   ├── Match/
│   │   ├── Jornada/
│   │   ├── Team/
│   │   └── NewsItem/
│   ├── Mappers/
│   │   ├── MatchMapper.swift
│   │   ├── JornadaMapper.swift
│   │   ├── TeamMapper.swift
│   │   └── NewsItemMapper.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   └── FavoritesService.swift
│   └── Helpers/
│       └── AperturaFixtureData.swift
│
├── Core/
│   ├── Firebase/
│   │   ├── FirestoreManager.swift
│   │   └── DatabaseProtocol.swift
│   ├── Extensions/
│   │   ├── UIView+Layout.swift
│   │   ├── UIStackView+Builder.swift
│   │   ├── Color+Extension.swift
│   │   └── UIViewController+Alert.swift
│   ├── Utils/
│   │   ├── LayoutPresets.swift
│   │   ├── EquipoPeruano.swift
│   │   ├── TorneoType.swift
│   │   ├── TablePosition.swift
│   │   └── NewsCategory.swift
│   ├── Constants/
│   │   └── FirestoreConstants.swift
│   ├── Logging/
│   │   └── Logger.swift
│   └── Auth/
│       └── AuthProvider.swift
│
├── DI/
│   └── DIContainer.swift
│
└── Resources/
    ├── Assets.xcassets/
    ├── GoogleService-Info.plist
    └── Info.plist
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
    ├── categoria: String
    ├── periodico: String
    └── destacada: Int       # 0 o 1
```

## 🎨 Características de UI/UX

- **Layout Programático**: 100% código con Auto Layout
- **Diseño Adaptativo**: Soporte completo para modo claro y oscuro
- **Pull-to-Refresh**: Actualización manual de datos
- **Loading States**: Indicadores de carga
- **Error Handling**: Mensajes informativos para errores
- **Custom Extensions**: Helpers para layout declarativo
- **Reactive UI**: Actualización automática con Combine

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

# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [1.0.0 (5)] - 2026-01-XX

### ✨ Added
- **Historial de Notificaciones**: Nueva opción en Configuración para ver todas las notificaciones entregadas al dispositivo
- **Pantalla de Ajustes de Notificaciones**: Pantalla dedicada que muestra el estado de las notificaciones y permite abrir Configuración del sistema
- **Eliminación de notificaciones**: Posibilidad de eliminar notificaciones del historial mediante swipe

### 🔧 Changed
- **Tab "Perfil" renombrado a "Configuración"**: El tab ahora se llama "Configuración" con icono de engranaje (gearshape)
- **Tema automático**: El tema de la app ahora sigue automáticamente la configuración del sistema del dispositivo (se eliminó la opción manual de seleccionar tema)
- **Ubicación de "Cerrar Sesión"**: Movido al final de todas las secciones de configuración con estilo destructivo (rojo)
- **Historial de notificaciones**: Tabla plana con mayor altura de celdas para mejor legibilidad

### 🐛 Fixed
- **Login con Email/Password**: Corregido problema de navegación después del login exitoso usando NotificationCenter como mecanismo principal
- **Login con Google**: Corregido problema donde el coordinatorDelegate se perdía durante el flujo, ahora usa NotificationCenter para navegación robusta
- **Logout**: Mejorado el flujo de logout para asegurar que cierra sesión correctamente en Firebase y navega al login

### 🗑️ Removed
- **Service Extension de notificaciones push rich**: Eliminado PushServiceExtension y todas sus referencias
- **Opción de selección de tema**: Eliminada la opción manual de cambiar entre modo claro/oscuro/automático

### 🏗️ Refactor
- **Sistema de navegación post-login**: Refactorizado para usar NotificationCenter como mecanismo principal de comunicación entre ViewModels y Coordinators
- **AppCoordinator**: Ahora escucha directamente notificaciones de login/logout para navegación más robusta

---

## [1.0.0 (4)] - 2026-01-XX

### ✨ Added
- Header de fecha en Home: Muestra la fecha del próximo partido con icono de calendario antes del header de jornada
- Formato inteligente de fecha: Muestra "Hoy" cuando el partido es el día actual, o el día de la semana con fecha (ej: "Viernes 30.01")
- Fondo diferenciado en header de jornada: Uso de `.secondarySystemBackground` para distinguir visualmente el header de fecha del header de jornada

### 🔧 Changed
- **Tabla de Posiciones**: El puesto 1 (campeón) ahora muestra un cuadrado amarillo solo alrededor del número de posición en lugar de fondo amarillo en toda la celda
- **Noticias - Ordenamiento**: Las categorías ahora se ordenan por fecha de la noticia destacada más reciente (no alfabético)
- **Noticias - Estructura**: Refactorizado para agrupar todas las noticias por categoría, mostrando primero las destacadas y luego las normales dentro de cada categoría
- **Spinner en Home**: Color blanco en modo oscuro para mejor visibilidad del refresh control
- **Recarga automática**: Las tabs de Torneo y Noticias ahora recargan datos automáticamente al entrar (`viewWillAppear`)
- **Badge de notificaciones**: Se limpia automáticamente al abrir la app usando la API moderna de iOS 18

### 🏗️ Refactor
- Migración a APIs modernas de iOS 17+: Uso de `registerForTraitChanges` en lugar de `traitCollectionDidChange` (deprecado)
- Migración a APIs modernas de iOS 18: Uso de `UNUserNotificationCenter.setBadgeCount()` en lugar de `applicationIconBadgeNumber` (deprecado)
- Refactor de noticias: Eliminada sección global de destacadas, ahora todas las noticias se agrupan por categoría con ordenamiento inteligente

### 🐛 Fixed
- Espacio entre header de tabla y navigation bar en Home eliminado mediante `sectionHeaderTopPadding = 0`

---

## [1.0.0(3)] - 2026-01-03

### 📱 Aplicación iOS - Liga 1 del Perú

Aplicación iOS nativa desarrollada con Swift y UIKit para seguir la Liga 1 de Fútbol Profesional del Perú.

#### ✨ Características Principales

##### 🏠 Home - Visualización de Partidos por Jornada
- Visualización de jornadas activas con sus partidos correspondientes
- Sistema de jornadas con estructura anidada en Firestore (`jornadas/{jornadaId}/matches/{matchId}`)
- Pull-to-refresh para actualizar datos manualmente
- Headers de sección mostrando número de jornada y torneo
- IDs de partidos compuestos que codifican equipos (`equipoLocal_equipoVisitante`)
- Estados de partido: pendiente, envivo, finalizado, anulado, suspendido
- Integración con sistema de favoritos en tiempo real
- Actualización reactiva de jornadas activas mediante listeners de Firestore

##### ⭐ Sistema de Favoritos
- Marcado de partidos favoritos con persistencia en Firestore
- Sincronización en tiempo real con listeners de Firestore
- ID completo de favoritos: `{jornadaId}_{matchId}` (ej: "apertura_01_adt_utc")
- Actualización automática de UI mediante Combine
- Persistencia por usuario en colección `users/{userId}/favorites`

##### 📊 Tabla de Posiciones
- Vista de tabla con torneo Apertura (Clausura y Acumulado preparados para futuro)
- Códigos de color por posición:
  - 🟢 Zona de clasificación directa
  - 🟡 Zona de playoffs
  - 🔴 Zona de descenso
- Modo oscuro optimizado
- Estadísticas completas: PJ, GF, GC, DG, Pts
- Logos de equipos desde Assets
- Ordenamiento inteligente: alfabético cuando todos tienen 0 puntos, luego por puntos y diferencia de goles
- Header personalizado con columnas: Equipo, PJ, GF-GC, DG, Pts

##### 📰 Sección de Noticias
- Visualización de noticias con imágenes
- Marcado de noticias destacadas
- Integración con Firestore
- Formato de fecha en español
- Agrupación por categorías

##### 🔐 Autenticación
- Login con Google Sign-In (OAuth 2.0)
- Login con Email/Password de Firebase
- Pantalla de login moderna con logo de Liga 1
- Loading overlay durante autenticación
- Manejo de errores con alerts
- Navegación automática al MainTabBar después del login
- Persistencia de sesión con Firebase Auth

##### 👤 Perfil de Usuario
- Visualización de información del usuario autenticado
- Opción de cerrar sesión
- Navegación de vuelta al login después de logout

##### 🛠 Panel de Administración
- Pantalla para registro masivo de jornadas y partidos
- Registro de 17 jornadas del torneo Apertura
- Generación automática de fixture completo
- Validación de datos antes de registro
- Feedback visual de éxito/error

#### 🏗 Arquitectura

##### Clean Architecture + MVVM + Combine

La aplicación sigue **Clean Architecture** con separación en 4 capas:

1. **Presentation Layer**
   - ViewControllers construidos programáticamente
   - ViewModels con `@Published` properties para actualización reactiva
   - Componentes UI reutilizables (Cells, Headers)
   - Modelos específicos de UI (MatchUI, TeamUI, NewsItemUI, JornadaUI)
   - Mappers de Domain Entities a UI Models

2. **Domain Layer**
   - Entidades de negocio (Match, Jornada, Team, NewsItem)
   - Use Cases (lógica de negocio pura)
   - Protocolos de Repositories (contratos)

3. **Data Layer**
   - Implementaciones de Repositories
   - DTOs (Data Transfer Objects) para Firestore
   - Mappers de DTOs a Domain Entities
   - Services (AuthService, FavoritesService)

4. **Core Layer**
   - FirestoreManager (abstracción de Firebase)
   - Extensions de UIKit para layout programático
   - Utilidades compartidas
   - Constantes
   - Logger centralizado
   - Dependency Injection Container (DIContainer)

##### Patrón MVVM

- **ViewModels**: Contienen `@Published` properties, ejecutan Use Cases, no conocen UIKit
- **Views**: Se suscriben a ViewModels usando Combine, actualizan UI reactivamente
- **Separación de responsabilidades**: View solo presenta, ViewModel coordina, Use Case ejecuta lógica

##### Dependency Injection

- Contenedor centralizado (`DIContainer`) para creación de dependencias
- Inyección de dependencias mediante protocolos
- Facilita testing y reduce acoplamiento

##### Reactive Programming

- **Combine Framework** para todas las operaciones asíncronas
- Publishers para flujo de datos
- `@Published` properties en ViewModels
- `sink` y `store(in:)` para subscripciones
- Operadores: `map`, `filter`, `compactMap`, `receive(on:)`, `collect()`, `MergeMany`

#### 📦 Use Cases Implementados

##### Jornadas
- `FetchActiveJornadasUseCase` - Obtener jornadas activas
- `ObserveActiveJornadasUseCase` - Observar cambios en jornadas activas

##### Partidos (Matches)
- `FetchMatchesUseCase` - Obtener partidos de una jornada
- `ObserveMatchesUseCase` - Observar cambios en partidos (disponible para uso futuro)

##### Equipos (Teams)
- `FetchTeamsUseCase` - Obtener equipos de un torneo

##### Noticias (News)
- `FetchNewsUseCase` - Obtener noticias

##### Favoritos
- `ToggleFavoriteUseCase` - Marcar/desmarcar favorito
- `ObserveFavoritesUseCase` - Observar cambios en favoritos
- `FetchFavoriteMatchesUseCase` - Obtener partidos favoritos

##### Autenticación
- `LoginUseCase` - Iniciar sesión
- `LogoutUseCase` - Cerrar sesión

##### Administración
- `RegisterMatchesUseCase` - Registro masivo de jornadas y partidos

#### 📦 Repositories Implementados

- `JornadasRepository` - Acceso a jornadas en Firestore
- `MatchesRepository` - Acceso a partidos en Firestore
- `TeamsRepository` - Acceso a equipos en Firestore
- `NewsRepository` - Acceso a noticias en Firestore
- `AdminMatchRepository` - Operaciones administrativas de partidos

Todos los repositories:
- Implementan protocolos definidos en Domain Layer
- Retornan `AnyPublisher<T, Error>` usando Combine
- Transforman DTOs a Domain Entities
- Manejan errores de forma consistente

#### 🔧 Services

- `AuthService` - Autenticación con Firebase (Google Sign-In, Email/Password)
- `FavoritesService` - Gestión de favoritos con sincronización en tiempo real

#### 🎨 UI Programático

- **100% código**: Sin Storyboards, todo construido programáticamente
- **Auto Layout**: Constraints mediante código con extensions personalizadas
- **Custom Extensions**:
  - `UIView+Layout` - DSL para Auto Layout
  - `UIStackView+Builder` - Builder pattern para stack views
  - `Color+Extension` - Colores personalizados (`.liga1Red`)
  - `UIViewController+Alert` - Helpers para mostrar alerts
- **LayoutPresets**: Componentes reutilizables (botones, labels, etc.)
- **Dark Mode**: Soporte completo para modo claro y oscuro

#### 🔄 Gestión de Datos

- **Firestore**: Base de datos NoSQL para almacenamiento
- **Estructura de datos**:
  - Jornadas como documentos con subcolecciones de matches
  - IDs compuestos para identificar partidos (`equipoLocal_equipoVisitante`)
  - Extracción de `torneo` y `numero` desde `documentID`
- **Listeners reactivos**: Para jornadas activas y favoritos
- **Pull-to-refresh**: Para actualización manual de partidos
- **Cache de Firestore**: Datos disponibles offline

#### 🛠 Utilidades y Helpers

- `EquipoPeruano` - Enum con códigos y nombres de todos los equipos
- `TorneoType` - Enum para tipos de torneo (Apertura, Clausura, Acumulado)
- `TablePosition` - Cálculo de zonas de clasificación
- `NewsCategory` - Categorías de noticias
- `LayoutPresets` - Componentes UI reutilizables
- `AperturaFixtureData` - Datos del fixture completo del torneo Apertura (17 jornadas)
- `Logger` - Sistema de logging centralizado con niveles (debug, info, warning, error)
- `FirestoreConstants` - Constantes para nombres de colecciones y campos

#### 📱 Navegación

- **UITabBarController**: Navegación principal con 5 pestañas
  - Home (Partidos por Jornada)
  - Favoritos
  - Tabla de Posiciones
  - Noticias
  - Perfil
- **Coordinator Pattern**: Gestión de navegación mediante coordinadores
- **Session Management**: Gestión de sesión de usuario

#### 🔐 Seguridad y Autenticación

- Firebase Authentication
- Google Sign-In SDK
- Persistencia de sesión
- Validación de usuarios autenticados
- Protección de datos por usuario (favoritos)

#### 📊 Estructura de Datos

- **Jornadas**: Documentos con ID `{torneo}_{numero}` (ej: `apertura_01`)
- **Matches**: Subcolecciones dentro de jornadas, ID `{equipoLocal}_{equipoVisitante}`
- **Teams**: Documentos con códigos de 3 letras (ej: `ali` para Alianza Lima)
- **News**: Documentos con información de noticias
- **Users/Favorites**: Subcolección por usuario con IDs de partidos completos

#### 🎯 Características Técnicas

- **Swift 5.0+**
- **iOS 18.0+**
- **UIKit Programático**
- **Combine Framework**
- **Firebase/Firestore**
- **Firebase/Auth**
- **Firebase/Storage**
- **GoogleSignIn SDK**
- **Swift Package Manager (SPM)**
- **Protocol-Oriented Programming**
- **Dependency Injection**
- **Clean Architecture**
- **MVVM Pattern**
- **Reactive Programming**

#### 🎨 Assets y Recursos

- Logos de 18 equipos de Liga 1 en Assets
- Logo de Google para sign-in
- Logo de Liga 1 para pantalla de login
- Colores brand personalizados (liga1Red)
- Soporte para Dark Mode en todos los assets

#### 📝 Logging y Debugging

- Sistema de logging centralizado (`Logger`)
- Niveles de log: debug, info, warning, error
- Logging en todas las capas (Repositories, Use Cases, ViewModels)
- Mensajes descriptivos para debugging

---

## Formato

Los tipos de cambios incluidos son:

- `✨ Added` para nuevas características
- `🔧 Changed` para cambios en funcionalidad existente
- `🗑️ Deprecated` para características que serán removidas
- `🐛 Fixed` para corrección de bugs
- `🔒 Security` para vulnerabilidades corregidas
- `⚡ Performance` para mejoras de rendimiento
- `🏗️ Refactor` para refactorizaciones importantes
- `📝 Docs` para cambios en documentación

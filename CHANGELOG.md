# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [2.0.0] - 2026-01-02

### 🏗️ REFACTORIZACIÓN MAYOR - Clean Architecture

#### Arquitectura
- **🎯 Migración a Clean Architecture**: Reorganización completa del proyecto en 4 capas principales
  - **Presentation Layer**: Views, ViewModels, Components
  - **Domain Layer**: Models, Use Cases
  - **Data Layer**: Repositories, Services, Managers
  - **Core Layer**: Extensions, Utils, Resources

- **📱 Nueva estructura de carpetas**:
  ```
  liga1/
  ├── Presentation/     # Capa de presentación
  │   ├── Views/        # ViewControllers
  │   ├── ViewModels/   # Lógica de presentación
  │   └── Components/   # Componentes UI reutilizables
  ├── Domain/           # Capa de dominio
  │   ├── Models/       # Entidades de negocio
  │   └── UseCases/     # Casos de uso
  ├── Data/             # Capa de datos
  │   ├── Repositories/ # Acceso a datos
  │   ├── Services/     # Servicios transversales
  │   └── Managers/     # Gestión de persistencia
  └── Core/             # Capa central
      ├── Extensions/   # Extensions de UIKit
      ├── Utils/        # Utilidades generales
      └── Resources/    # Recursos compartidos
  ```

#### ✨ Patrón MVVM + Combine

- **ViewModels implementados**:
  - ✅ `HomeViewModel` - Gestión de jornadas activas
  - ✅ `NewsViewModel` - Gestión de noticias
  - ✅ `TorneoViewModel` - Gestión de tabla de posiciones
  - ✅ `FavoritosViewModel` - Gestión de favoritos
  - ✅ `ProfileViewModel` - Gestión de perfil y configuración
  - ✅ `LoginViewModel` - Gestión de autenticación

- **Características de ViewModels**:
  - `@Published` properties para reactive updates
  - Dependency injection con protocolos
  - Separación clara de lógica de presentación
  - Sin referencias a UIKit
  - Testing-friendly

#### 📦 Repositories Pattern

- **Nuevos Repositories**:
  - `JornadasRepository` - Obtención de jornadas desde Firestore
  - `MatchesRepository` - Obtención de partidos
  - `TeamsRepository` - Obtención de equipos
  - `NewsRepository` - Obtención de noticias
  - `AdminMatchRepository` - Operaciones administrativas

- **Características**:
  - Retornan `AnyPublisher<T, Error>` usando Combine
  - Implementan protocolos para facilitar testing
  - Abstracción de la fuente de datos
  - Cache-first strategy

#### 🔧 Services Layer

- **Nuevos Services**:
  - `AuthService` - Servicio de autenticación con Firebase
  - `FavoritesService` - Gestión de favoritos con Combine

- **Características**:
  - Protocolos para dependency injection
  - Operaciones asíncronas con Combine
  - Manejo centralizado de lógica transversal

#### 🎨 UI Programático - 100% Código

- **Refactorización de ViewControllers**:
  - `HomeViewController` - Ahora usa HomeViewModel + Combine
  - `NewsViewController` - Usa NewsViewModel
  - `TorneoViewController` - Usa TorneoViewModel
  - `FavoritosViewController` - Usa FavoritosViewModel
  - `ProfileViewController` - Usa ProfileViewModel
  - `LoginViewController` - Usa LoginViewModel

- **Características**:
  - Layout 100% programático (sin Storyboards)
  - Extensions para TableView delegates en archivos separados
  - Binding reactivo con Combine
  - Manejo de errores centralizado

#### 🔄 Reactive Programming

- **Combine Framework**:
  - Publishers para todas las operaciones asíncronas
  - `@Published` properties en ViewModels
  - `sink` y `store(in:)` para subscripciones
  - `AnyCancellable` para gestión de memoria
  - Operadores: `map`, `filter`, `compactMap`, `receive(on:)`

#### 📐 Custom Extensions

- **Layout Extensions**:
  - `UIView+Layout.swift` - DSL para Auto Layout
  - `UIStackView+Builder.swift` - Builder pattern
  - `Color+Extension.swift` - Colores custom

- **Layout Helpers**:
  - `LayoutPresets.swift` - Componentes reutilizables
  - `LayoutExamples.swift` - Ejemplos de uso

### 📝 Documentación

- **Nuevos archivos de documentación**:
  - `ARCHITECTURE.md` - Documentación completa de arquitectura
    - Diagramas de capas
    - Flujo de datos
    - Estructura del proyecto
    - Mejores prácticas
    - Convenciones de nombres
    - Guía de migración

- **README.md actualizado**:
  - Nueva sección de arquitectura
  - Diagramas de Clean Architecture
  - Ejemplos de código con Combine
  - Roadmap actualizado
  - Guías de contribución

### 🔧 Mejoras Técnicas

- **Dependency Injection**: Inyección de dependencias en ViewModels
- **Protocol-Oriented**: Abstracciones con protocolos
- **Memory Management**: Uso correcto de `[weak self]`
- **Error Handling**: Manejo centralizado de errores
- **Loading States**: Estados de carga reactivos

### 🎯 Beneficios de la Refactorización

1. ✅ **Separación clara de responsabilidades**
2. ✅ **Mayor testabilidad** (cada capa es independiente)
3. ✅ **Código más mantenible** y escalable
4. ✅ **Reutilización de código** mejorada
5. ✅ **Flujo de datos reactivo** con Combine
6. ✅ **Preparado para crecimiento** del equipo
7. ✅ **Sigue principios SOLID**

### 📊 Estadísticas de Migración

- 📁 **40+ archivos** reorganizados
- 🎯 **6 ViewModels** creados
- 📦 **5 Repositories** implementados
- 🔧 **2 Services** nuevos
- 📐 **3 Extension files** para UI
- 📝 **2 archivos** de documentación

### ⚠️ Breaking Changes

- **Estructura de carpetas completamente reorganizada**
- **Migración de MVC a MVVM + Clean Architecture**
- **Requiere actualización del proyecto en Xcode**:
  1. Eliminar referencias antiguas (View/, ViewModel/, Cell/, etc.)
  2. Agregar nuevas carpetas (Presentation/, Domain/, Data/, Core/)
  3. Agregar nuevos archivos al target

### 🔄 Migration Guide

Ver `ARCHITECTURE.md` para la guía completa de migración:

```
Estructura Anterior → Nueva
View/              → Presentation/Views/
ViewModel/         → Presentation/ViewModels/
Cell/              → Presentation/Components/Cells/
Model/             → Domain/Models/
Repository/        → Data/Repositories/
Service/           → Data/Services/
Manager/           → Data/Managers/
Extensions/        → Core/Extensions/
Util/              → Core/Utils/
```

---

## [1.0.0] - 2025-12-25

### ✨ Características Principales

#### 🏠 Home - Visualización de Partidos
- Sistema de jornadas con estructura anidada en Firestore (`jornadas/{jornadaId}/matches/{matchId}`)
- Visualización de múltiples jornadas simultáneas con header personalizado
- Cache-first loading: carga instantánea desde caché con actualización en background
- Headers de sección mostrando "Fecha X" y torneo (Apertura/Clausura 2026)
- IDs de partidos compuestos que codifican equipos (`equipoLocal_equipoVisitante`)
- Propiedades computadas para extraer IDs de equipos desde el documento ID
- Estados de partido: pendiente, enJuego, finalizado, anulado, suspendido
- Integración con sistema de favoritos en tiempo real

#### ⭐ Sistema de Favoritos
- Marcado de partidos favoritos con persistencia en Firestore
- Sincronización en tiempo real con listeners de Firestore
- ID completo de favoritos: `{jornadaId}_{matchId}` (ej: "apertura_01_adt_utc")
- FavoritesManager compartido para gestión centralizada
- Actualización automática de UI mediante listeners
- Persistencia por usuario en colección `users/{userId}/favorites`

#### 📊 Tabla de Posiciones
- Vista de tabla con segmented control (Apertura/Clausura)
- Códigos de color por posición:
  - 🟢 Zona de clasificación directa
  - 🟡 Zona de playoffs
  - 🔴 Zona de descenso
- Modo oscuro optimizado: colores solo en posiciones importantes
- Estadísticas completas: PJ, GF, GC, Pts
- Logos de equipos (20x20 pts)
- Header personalizado con columnas: Equipo, PJ, GF-GC, Pts

#### 📰 Sección de Noticias
- Visualización de noticias con imágenes
- Marcado de noticias destacadas
- Integración con Firestore
- Formato de fecha en español

#### 🔐 Autenticación
- Login con Google Sign-In (OAuth 2.0)
- Login con Email/Password de Firebase
- Pantalla de login moderna con:
  - Logo de Liga 1
  - Campos de email y contraseña
  - Botón de Google Sign-In
  - Loading overlay con activity indicator
  - Manejo de errores con alerts
- Navegación automática al MainTabBar después del login
- Persistencia de sesión con Firebase Auth

#### 👤 Perfil de Usuario
- Visualización de información del usuario autenticado
- Selector de tema (Claro/Oscuro/Automático)
- Opción de cerrar sesión
- Navegación de vuelta al login después de logout

### 🏗 Arquitectura y Optimizaciones

#### Estructura de Datos
- **Modelo Match**:
  - IDs de equipos como propiedades computadas (no almacenadas)
  - Campo `suspendido` con valor por defecto para retrocompatibilidad
  - Propiedades UI: `jornadaNumero`, `torneoNombre`, `isFavorite`
  - Función `toDictionary()` para serialización a Firestore

- **Modelo Jornada**:
  - Campo `mostrar` para controlar visibilidad en home
  - Propiedades computadas: `torneo` y `numero` extraídas del ID
  - Ordenamiento por `fechaInicio` descendente

#### Rendimiento
- **Cache-first Strategy**:
  - Primera consulta desde `.cache` (instantánea)
  - Segunda consulta desde `.server` (actualización en background)
  - Aplicado a jornadas y partidos
- **DispatchGroup**: Coordinación de cargas paralelas de múltiples jornadas
- **Listeners eficientes**: Un solo listener de favoritos para toda la app
- **Logging diagnóstico**: Mensajes de depuración para tracking de cargas

#### UI/UX
- Soporte completo para Dark Mode
- Navegación con UITabBarController (5 tabs)
- Safe area handling optimizado
- Constraints responsivos
- Colores personalizados: `.liga1Red`
- Separación de concerns: ViewControllers + Extensions para TableView

### 🔧 Mejoras Técnicas

#### Eliminación de Redundancia
- Removidos campos `equipoLocalId` y `equipoVisitanteId` almacenados
- Implementación de propiedades computadas basadas en document ID
- Reducción de espacio en Firestore y sincronización más rápida

#### Compatibilidad con Datos Legacy
- Campo `suspendido` con valor por defecto `false`
- Manejo graceful de documentos sin campos nuevos
- Logging para identificar documentos con problemas

#### Clean Code
- Eliminación de archivos no utilizados (`MatchesViewController`)
- Organización clara de extensiones
- Comentarios descriptivos en código crítico
- Uso de `@DocumentID` property wrapper de Firebase

### 🐛 Correcciones de Bugs

- **Fix**: Error de decodificación por tipos incorrectos (goles como String vs Int)
- **Fix**: Crash al intentar modificar array `let` en `JornadaSection`
- **Fix**: Uso incorrecto de método `documentID()` deprecado
- **Fix**: Optional unwrapping en carga de logos de equipos
- **Fix**: Missing `suspendido` field en documentos legacy

### 📦 Dependencias

- Firebase/Firestore
- Firebase/Auth
- Firebase/Storage
- GoogleSignIn
- FirebaseFirestoreSwift (para @DocumentID)

### 🎨 Assets y Recursos

- Logos de 18 equipos de Liga 1
- Logo de Google para sign-in (g-logo)
- Logo de Liga 1 para pantalla de login
- Colores brand personalizados

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

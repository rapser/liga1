# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

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
- Navegación con UITabBarController (4 tabs)
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

### 📝 Documentación

- README completo con:
  - Descripción del proyecto
  - Stack tecnológico
  - Arquitectura MVC
  - Estructura de Firestore
  - Guía de instalación
  - Estrategia de caché
  - Roadmap

---

## Formato

Los tipos de cambios incluidos son:

- `✨ Added` para nuevas características
- `🔧 Changed` para cambios en funcionalidad existente
- `🗑️ Deprecated` para características que serán removidas
- `🐛 Fixed` para corrección de bugs
- `🔒 Security` para vulnerabilidades corregidas
- `⚡ Performance` para mejoras de rendimiento

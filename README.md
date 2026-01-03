# Liga 1 - App iOS

Aplicación iOS para seguir en tiempo real la Liga 1 de Fútbol Profesional del Perú. Consulta partidos, resultados, tabla de posiciones y noticias del torneo peruano.

## 📱 Características

- **Partidos en Vivo**: Visualiza los partidos por jornada con resultados en tiempo real
- **Tabla de Posiciones**: Consulta las tablas de Apertura y Clausura con estadísticas detalladas
- **Favoritos**: Marca tus partidos favoritos para seguimiento rápido
- **Noticias**: Mantente informado con las últimas noticias del fútbol peruano
- **Autenticación**: Ingresa con Google o correo electrónico para sincronizar tus favoritos
- **Modo Oscuro**: Soporte completo para Dark Mode
- **UI Programático**: Interfaz construida 100% con código (sin Storyboards)

## 🛠 Tecnologías y Frameworks

### Lenguaje
- **Swift 5.0+**
- **UIKit Programático** - Construcción de interfaces sin Storyboards
- **Combine** - Framework reactivo para manejo de eventos

### Backend & Servicios
- **Firebase**
  - **Firestore**: Base de datos NoSQL para almacenamiento de partidos, jornadas y noticias
  - **Authentication**: Sistema de autenticación con Google Sign-In y Email/Password
  - **Storage**: Almacenamiento de imágenes y recursos multimedia

### Autenticación
- **Google Sign-In SDK**: Inicio de sesión con Google
- **Firebase Auth**: Gestión de usuarios y sesiones

### Gestión de Dependencias
- **Swift Package Manager (SPM)**: Manejo de dependencias externas

## 🏗 Arquitectura

### Patrón de Diseño
La aplicación sigue **Clean Architecture** con el patrón **MVVM + Combine**:

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                   │
│  (Views, ViewModels, Components)            │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│          Domain Layer                        │
│      (Models, Use Cases)                    │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│           Data Layer                         │
│  (Repositories, Services, Managers)         │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│          Core Layer                          │
│     (Extensions, Utils, Resources)          │
└─────────────────────────────────────────────┘
```

### Capas de la Arquitectura

#### 📱 Presentation Layer
- **Views**: ViewControllers construidos programáticamente con UIKit
- **ViewModels**: Lógica de presentación con `@Published` properties
- **Components**: Celdas y componentes UI reutilizables

#### 🎯 Domain Layer
- **Models**: Entidades de negocio (`Codable` para Firestore)
- **Use Cases**: Lógica de negocio pura (en desarrollo)

#### 💾 Data Layer
- **Repositories**: Abstracción de acceso a datos con Combine
- **Services**: Servicios transversales (Auth, Favorites)
- **Managers**: Gestión de persistencia local

#### 🔧 Core Layer
- **Extensions**: Extensions de UIKit para layout programático
- **Utils**: Utilidades compartidas y presets de UI

### Características Técnicas

- **Reactive Programming**: Uso de Combine para flujo de datos reactivo
- **Dependency Injection**: Protocolos e inyección de dependencias
- **Programmatic UI**: 100% código, layout con Auto Layout + Extensions
- **Protocol-Oriented**: Abstracciones con protocolos para testing

### Estructura de Navegación
- **UITabBarController**: Navegación principal con 5 pestañas
  - Home (Partidos)
  - Favoritos
  - Tabla de Posiciones
  - Noticias
  - Perfil

### Estructura del Proyecto

```
liga1/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── SessionManager.swift
│   └── AppRouter.swift
│
├── Presentation/
│   ├── Views/
│   │   ├── Home/               # Pantalla principal
│   │   ├── News/                # Noticias
│   │   ├── Tabla/               # Tabla de posiciones
│   │   ├── Favoritos/           # Partidos favoritos
│   │   ├── Profile/             # Perfil de usuario
│   │   ├── Login/               # Autenticación
│   │   └── TabBar/              # Navegación principal
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   ├── NewsViewModel.swift
│   │   ├── TorneoViewModel.swift
│   │   ├── FavoritosViewModel.swift
│   │   ├── ProfileViewModel.swift
│   │   └── LoginViewModel.swift
│   └── Components/
│       └── Cells/               # Celdas reutilizables
│
├── Domain/
│   ├── Models/
│   │   ├── Team.swift
│   │   ├── Match.swift
│   │   ├── Jornada.swift
│   │   ├── NewsItem.swift
│   │   └── Partido.swift
│   └── UseCases/                # (En desarrollo)
│
├── Data/
│   ├── Repositories/
│   │   ├── JornadasRepository.swift
│   │   ├── MatchesRepository.swift
│   │   ├── TeamsRepository.swift
│   │   ├── NewsRepository.swift
│   │   └── AdminMatchRepository.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   └── FavoritesService.swift
│   └── Managers/
│       └── FavoritesManager.swift
│
├── Core/
│   ├── Extensions/
│   │   ├── UIView+Layout.swift
│   │   ├── UIStackView+Builder.swift
│   │   └── Color+Extension.swift
│   └── Utils/
│       ├── LayoutPresets.swift
│       ├── EquipoPeruano.swift
│       └── TorneoType.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── GoogleService-Info.plist
    └── Info.plist
```

Para más detalles sobre la arquitectura, consulta [ARCHITECTURE.md](ARCHITECTURE.md).

## 🗄 Estructura de Datos en Firestore

### Colección: `jornadas`
```
jornadas/
├── {jornadaId}              # Ejemplo: "apertura_2026_01"
│   ├── mostrar: Bool        # Si se muestra en el home
│   ├── numero: Int          # Número de jornada
│   ├── torneo: String       # apertura/clausura
│   ├── fechaInicio: Date    # Fecha de inicio de la jornada
│   └── matches/             # Subcolección de partidos
│       └── {matchId}        # Ejemplo: "adt_utc"
│           ├── fecha: Timestamp
│           ├── golesTeamA: Int
│           ├── golesTeamB: Int
│           ├── estado: String    # pendiente, enJuego, finalizado
│           ├── suspendido: Bool
│           └── equipoLocalId: String
│           └── equipoVisitanteId: String
```

### Colección: `users`
```
users/
└── {userId}/
    └── favorites/
        └── {matchId}: Bool  # Ejemplo: "apertura_2026_01_adt_utc"
```

### Colección: `noticias`
```
noticias/
└── {noticiaId}
    ├── titulo: String
    ├── descripcion: String
    ├── imageUrl: String
    ├── fecha: Timestamp
    └── destacado: Bool
```

## 🎨 Características de UI/UX

- **Layout Programático**: 100% código con Auto Layout
- **Diseño Adaptativo**: Soporte completo para modo claro y oscuro
- **Animaciones**: Transiciones suaves entre pantallas
- **Pull-to-Refresh**: Actualización manual de datos
- **Loading States**: Indicadores de carga para mejor experiencia
- **Error Handling**: Mensajes informativos para errores de red
- **Custom Extensions**: Helpers para layout declarativo

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

## 📊 Estrategia de Caché

La aplicación implementa una estrategia de **Cache-First** con actualización en background usando Combine:

1. **Primera carga**: Lee desde caché de Firestore (offline) → Respuesta instantánea
2. **Segunda carga**: Actualiza desde servidor en background
3. **Persistencia**: Los datos se mantienen disponibles offline
4. **Reactive Updates**: ViewModels publican cambios automáticamente

```swift
// Ejemplo de implementación con Combine
func fetchJornadas() -> AnyPublisher<[Jornada], Error> {
    return Future<[Jornada], Error> { promise in
        // Carga desde caché primero
        self.db.collection("jornadas")
            .getDocuments(source: .cache) { snapshot, error in
                // Procesar caché...
            }

        // Actualización desde servidor
        self.db.collection("jornadas")
            .getDocuments(source: .server) { snapshot, error in
                // Actualizar datos...
            }
    }
    .eraseToAnyPublisher()
}
```

## 🔐 Autenticación

### Métodos Soportados
1. **Google Sign-In**: OAuth 2.0 con Firebase
2. **Email/Password**: Autenticación tradicional con Firebase Auth

### Flujo de Autenticación
1. Usuario selecciona método de login
2. LoginViewModel valida credenciales usando AuthService
3. Firebase Auth retorna UID del usuario
4. Se sincroniza colección de favoritos con FavoritesService
5. Navegación reactiva a pantalla principal usando Combine

## 🎯 Roadmap

- [x] Arquitectura Clean Architecture + MVVM
- [x] UI Programático completo
- [x] Reactive Programming con Combine
- [x] Modo Oscuro
- [ ] Push Notifications para partidos en vivo
- [ ] Widget de iOS para próximos partidos
- [ ] Compartir resultados en redes sociales
- [ ] Estadísticas detalladas por jugador
- [ ] Modo landscape para tablets
- [ ] Tests unitarios y UI tests
- [ ] CI/CD con GitHub Actions

## 📚 Documentación Adicional

- [ARCHITECTURE.md](ARCHITECTURE.md) - Documentación detallada de arquitectura
- [CHANGELOG.md](CHANGELOG.md) - Historial de cambios del proyecto

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

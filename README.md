# Liga 1 - App iOS

Aplicación iOS para seguir en tiempo real la Liga 1 de Fútbol Profesional del Perú. Consulta partidos, resultados, tabla de posiciones y noticias del torneo peruano.

## 📱 Características

- **Partidos en Vivo**: Visualiza los partidos por jornada con resultados en tiempo real
- **Tabla de Posiciones**: Consulta las tablas de Apertura y Clausura con estadísticas detalladas
- **Favoritos**: Marca tus partidos favoritos para seguimiento rápido
- **Noticias**: Mantente informado con las últimas noticias del fútbol peruano
- **Autenticación**: Ingresa con Google o correo electrónico para sincronizar tus favoritos
- **Modo Offline**: Los datos se cachean localmente para acceso sin conexión

## 🛠 Tecnologías y Frameworks

### Lenguaje
- **Swift 5.0+**
- **UIKit** - Framework nativo de Apple para construcción de interfaces

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
- **MVC (Model-View-Controller)**: Arquitectura principal del proyecto
  - **Models**: Estructuras `Codable` para sincronización con Firestore
  - **Views**: UIKit components (UIViewController, UITableView, Custom Cells)
  - **Controllers**: ViewControllers para lógica de negocio

### Estructura de Navegación
- **UITabBarController**: Navegación principal con 4 pestañas
  - Home (Partidos)
  - Favoritos
  - Tabla de Posiciones
  - Noticias

### Estructura del Proyecto

```
liga1/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Model/
│   ├── Match.swift          # Modelo de partido
│   ├── Jornada.swift        # Modelo de jornada
│   ├── Team.swift           # Modelo de equipo
│   ├── News.swift           # Modelo de noticia
│   └── User.swift           # Modelo de usuario
├── View/
│   ├── Home/
│   │   ├── HomeViewController.swift
│   │   └── HomeViewController+TableView.swift
│   ├── Favoritos/
│   │   └── FavoritosViewController.swift
│   ├── Tabla/
│   │   ├── TorneoViewController.swift
│   │   └── TorneoViewController+TableView.swift
│   ├── Noticias/
│   │   └── NewsViewController.swift
│   ├── Login/
│   │   └── LoginViewController.swift
│   ├── Profile/
│   │   └── ProfileViewController.swift
│   └── TabBar/
│       └── MainTabBarController.swift
├── Cell/
│   ├── MatchTableViewCell.swift
│   ├── EquipoTableViewCell.swift
│   ├── NewsTableViewCell.swift
│   └── HeaderView.swift
├── Manager/
│   └── FavoritesManager.swift
├── Extensions/
│   ├── Color+Extension.swift
│   └── Date+Extension.swift
└── Resources/
    ├── Assets.xcassets
    ├── GoogleService-Info.plist
    └── Info.plist
```

## 🗄 Estructura de Datos en Firestore

### Colección: `jornadas`
```
jornadas/
├── {jornadaId}              # Ejemplo: "apertura_01"
│   ├── mostrar: Bool        # Si se muestra en el home
│   ├── fechaInicio: Date    # Fecha de inicio de la jornada
│   └── matches/             # Subcolección de partidos
│       └── {matchId}        # Ejemplo: "adt_utc"
│           ├── fecha: Timestamp
│           ├── golesEquipoLocal: Int
│           ├── golesEquipoVisitante: Int
│           ├── estado: String  # pendiente, enJuego, finalizado
│           └── suspendido: Bool
```

### Colección: `users`
```
users/
└── {userId}/
    └── favorites/
        └── {matchId}: Bool  # Ejemplo: "apertura_01_adt_utc"
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

- **Diseño Adaptativo**: Soporte para modo claro y oscuro
- **Animaciones**: Transiciones suaves entre pantallas
- **Pull-to-Refresh**: Actualización manual de datos
- **Loading States**: Indicadores de carga para mejor experiencia
- **Error Handling**: Mensajes informativos para errores de red

## 🚀 Instalación y Configuración

### Requisitos Previos
- Xcode 14.0+
- iOS 15.0+
- Cuenta de Firebase
- Cuenta de desarrollador de Google (para Google Sign-In)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/liga1.git
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
   - Selecciona un simulador o dispositivo
   - Presiona `Cmd + R` para compilar y ejecutar

## 📊 Estrategia de Caché

La aplicación implementa una estrategia de **Cache-First** con actualización en background:

1. **Primera carga**: Lee desde caché de Firestore (offline) → Respuesta instantánea
2. **Segunda carga**: Actualiza desde servidor en background
3. **Persistencia**: Los datos se mantienen disponibles offline

```swift
// Ejemplo de implementación
db.collection("jornadas")
    .getDocuments(source: .cache) { snapshot, error in
        // Carga rápida desde caché
    }

db.collection("jornadas")
    .getDocuments(source: .server) { snapshot, error in
        // Actualización en background
    }
```

## 🔐 Autenticación

### Métodos Soportados
1. **Google Sign-In**: OAuth 2.0 con Firebase
2. **Email/Password**: Autenticación tradicional con Firebase Auth

### Flujo de Autenticación
1. Usuario selecciona método de login
2. Firebase Auth valida credenciales
3. Se crea/obtiene UID del usuario
4. Se sincroniza colección de favoritos
5. Navegación a pantalla principal

## 🎯 Roadmap

- [ ] Push Notifications para partidos en vivo
- [ ] Widget de iOS para próximos partidos
- [ ] Compartir resultados en redes sociales
- [ ] Estadísticas detalladas por jugador
- [ ] Modo landscape para tablets
- [ ] Soporte para watchOS

## 👥 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📧 Contacto

Miguel Tomairo - [@rapser](https://github.com/rapser)

Project Link: [https://github.com/rapser/liga1](https://github.com/rapser/liga1)

---

**Hecho con ❤️ para los fanáticos del fútbol peruano**

//
//  AppKit+Examples.swift
//  liga1
//
//  Created by AppKit
//  Ejemplos de uso de AppKit v2
//

import UIKit

/*

# AppKit v2 - UI Programática Simplificada

AppKit es una librería interna que proporciona helpers y builders para construir
UI programática de manera rápida y legible.

## Estructura

```
AppKit/
├── Theme/
│   ├── AppTheme.swift          - Typography, corner radius, heights, shadows
│   └── AppColors.swift         - Colores semánticos + marca Liga 1
├── Components/
│   ├── ContainerView.swift     - Container entre nav bar y tab bar
│   ├── DividerView.swift       - Divider con texto central
│   ├── HeaderViews.swift       - Headers pre-construidos
│   ├── NavigationBar+Builder.swift - Configurador de nav bar
│   ├── TableView+Builder.swift     - Builder para UITableView
│   ├── CollectionView+Builder.swift - Builder para UICollectionView
│   ├── CompositionalLayout+Presets.swift - Layouts pre-armados
│   ├── ScrollView+Builder.swift    - ScrollView + ScrollableStackView
│   └── FormBuilder.swift           - Constructor de formularios
├── Extensions/
│   ├── UIView+Layout.swift         - Layout system + ConstraintGroup
│   ├── UIStackView+Builder.swift   - Stack views + ViewBuilder
│   ├── UIViewController+Alert.swift - Alertas
│   └── UIControl+Builder.swift     - Switch, Segment, Slider
└── Presets/
    └── ComponentPresets.swift      - Factories de componentes
```

---

## 1. Layout Básico

```swift
// Agregar vista y posicionar
label.addTo(containerView)
    .pinTop(constant: 16)
    .pinLeading(constant: 16)
    .pinTrailing(constant: 16)

// Llenar superview
tableView.addTo(containerView).fillSuperview()

// Con safe area
view.fillSuperviewSafeArea()

// Centrar
loadingIndicator.addTo(view).centerInSuperview()

// Tamaño
imageView.square(48)
button.height(52)
avatar.size(width: 80, height: 80)

// Con prioridad
label.height(44, priority: .defaultHigh)
view.width(200, priority: .defaultLow)

// Min/Max
textView.minHeight(100)
container.maxWidth(600)
```

## 2. Builder Pattern para Vistas

```swift
// Label
let titleLabel = UILabel()
    .text("Liga 1 2024")
    .font(AppTheme.title2)
    .textColor(.label)
    .alignment(.center)
    .lines(0)

// Button
let saveButton = UIButton()
    .title("Guardar")
    .titleColor(.white)
    .background(.appTint)
    .corner(AppTheme.CornerRadius.medium)

// ImageView
let logo = UIImageView()
    .image(UIImage(named: "liga1"))
    .contentMode(.scaleAspectFit)
    .tintColor(.liga1Red)

// TextField
let emailField = UITextField()
    .placeholder("Correo electrónico")
    .font(AppTheme.body)
    .textColor(.label)
    .borderStyle(.none)
    .leftPadding(16)
```

## 3. Stack Views con @resultBuilder

```swift
// Vertical stack declarativo
let formStack = UIStackView.vStack(spacing: Spacing.medium) {
    titleLabel
    emailField
    passwordField
    loginButton
}

// Horizontal stack
let scoreRow = UIStackView.hStack(spacing: Spacing.small, alignment: .center) {
    teamLogo
    teamName
    Spacer()
    scoreLabel
}

// Con padding
formStack.padding(Spacing.standard)
```

## 4. Navigation Bar

```swift
// Configuración básica
setupNavigationBar()
    .title("Inicio")
    .prefersLargeTitles(true)
    .tintColor(.liga1Red)

// Con botones
setupNavigationBar()
    .title("Perfil")
    .rightBarButton(systemImage: "gear", target: self, action: #selector(openSettings))

// Personalizar appearance (ya no hay bug de sobreescritura)
setupNavigationBar()
    .backgroundColor(.white)
    .titleColor(.black)
    .tintColor(.liga1Red)
```

## 5. TableView

```swift
// Configurar con builder
let tableView = UITableView()
    .delegate(self)
    .dataSource(self)
    .registerCell(MatchTableViewCell.self)
    .registerCell(TeamTableViewCell.self)
    .separatorStyle(.none)
    .enableAutomaticDimensions()
    .removeEmptyCellSeparators()

// Dequeue type-safe (sin guard let, sin identifier strings)
let cell = tableView.dequeueReusableCell(MatchTableViewCell.self, for: indexPath)
cell.configure(with: match, logoLocal: logo1, logoVisitante: logo2)
```

## 6. CollectionView

```swift
// Configurar con builder
let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: .grid(columns: 2)
)
    .delegate(self)
    .dataSource(self)
    .registerCell(TeamGridCell.self)
    .registerHeader(SectionHeader.self)
    .showsVerticalScrollIndicator(false)

// Dequeue type-safe
let cell = collectionView.dequeueReusableCell(TeamGridCell.self, for: indexPath)
let header = collectionView.dequeueReusableHeader(SectionHeader.self, for: indexPath)
```

## 7. Compositional Layout Presets

```swift
// Lista vertical (reemplaza UITableView)
let layout = UICollectionViewCompositionalLayout.list(appearance: .plain)

// Grid de 3 columnas
let layout = UICollectionViewCompositionalLayout.grid(columns: 3, itemSpacing: 8)

// Carrusel horizontal
let layout = UICollectionViewCompositionalLayout.carousel(itemWidth: 200, itemHeight: 120)

// Lista con self-sizing
let layout = UICollectionViewCompositionalLayout.verticalList(estimatedHeight: 80)
```

## 8. Container View

```swift
// Crear container entre navigation bar y tab bar
let containerView = ContainerView()
containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

// Agregar contenido dentro del container
tableView.addTo(containerView).fillSuperview()
```

## 9. ScrollableStackView (para formularios)

```swift
let scrollableForm = ScrollableStackView(spacing: Spacing.standard)
scrollableForm
    .addTo(containerView)
    .fillSuperview()

scrollableForm
    .addContent(titleLabel)
    .addContent(emailTextField)
    .addContent(passwordTextField)
    .addSpace(Spacing.large)
    .addContent(loginButton)
```

## 10. FormBuilder (secciones de formulario)

```swift
let section = FormSection(title: "Cuenta")

let emailField = section.addTextField(
    label: "Correo",
    placeholder: "tu@email.com",
    keyboardType: .emailAddress
)

let notificationsSwitch = section.addSwitch(label: "Notificaciones", isOn: true)

section.addSeparator()
section.addInfoLabel(text: "Las notificaciones te mantienen al día con los resultados.")

let deleteButton = section.addButton(title: "Eliminar cuenta", style: .destructive)
```

## 11. UIControl Builders

```swift
// Switch
let toggle = UISwitch()
    .isOn(true)
    .onTintColor(.liga1Red)
    .onValueChanged(self, action: #selector(toggleChanged))

// SegmentedControl
let segment = UISegmentedControl(items: ["Partidos", "Equipos"])
    .selectedIndex(0)
    .selectedTintColor(.liga1Red)
    .onValueChanged(self, action: #selector(segmentChanged))

// Button con target
let button = UIButton()
    .title("Guardar")
    .onTap(self, action: #selector(saveTapped))
```

## 12. ConstraintGroup (layouts adaptativos)

```swift
let compactConstraints = ConstraintGroup()
    .add(view.heightAnchor.constraint(equalToConstant: 44))
    .add(view.widthAnchor.constraint(equalTo: superview.widthAnchor))

let expandedConstraints = ConstraintGroup()
    .add(view.heightAnchor.constraint(equalToConstant: 200))
    .add(view.widthAnchor.constraint(equalToConstant: 300))

// Activar un grupo
compactConstraints.activate()

// Alternar con animación
compactConstraints.replace(with: expandedConstraints)
UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
```

## 13. Theme System

```swift
// Typography
label.font = AppTheme.title1       // 24pt bold
label.font = AppTheme.headline     // 16pt semibold
label.font = AppTheme.body         // 16pt regular
label.font = AppTheme.caption1     // 12pt regular

// Corner Radius
view.corner(AppTheme.CornerRadius.medium)  // 12pt

// Heights
button.height(AppTheme.Heights.button)     // 52pt

// Shadows
cardView.shadow(.light)
cardView.shadow(.medium)

// Colores semánticos
view.background(.appBackground)
label.textColor(.appTint)
button.background(.appDestructive)
```

## 14. Component Presets (factories)

```swift
// Botón primario pre-configurado
let loginButton = ComponentPresets.primaryButton(title: "Iniciar Sesión")

// TextField estilizado
let emailField = ComponentPresets.styledTextField(placeholder: "Correo")

// Label de título
let title = ComponentPresets.titleLabel(text: "Bienvenido", fontSize: 28)

// Loading overlay
let (overlay, indicator) = ComponentPresets.loadingOverlay(in: view)

// Divider
let divider = ComponentPresets.dividerView(text: "o continuar con")
```

## 15. Header Views

```swift
// Date Header
let dateHeader = DateHeaderView()
dateHeader.configure(with: Date())       // "Hoy", "Mañana", "Lunes, 3 de marzo"

// Jornada Header
let jornadaHeader = JornadaHeaderView()
jornadaHeader.configure(jornada: "Jornada 10", torneo: "Apertura 2024")

// Title Header
let titleHeader = TitleHeaderView()
titleHeader.configure(title: "Tabla de Posiciones")

// Empty State
let emptyState = EmptyStateView()
emptyState.configure(
    systemImage: "star.slash",
    title: "Sin favoritos",
    message: "Agrega equipos a tus favoritos"
)
```

## 16. Ejemplo Completo: ViewController

```swift
class ExampleViewController: UIViewController {

    private let containerView = ContainerView()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar
        setupNavigationBar()
            .title("Ejemplo")
            .prefersLargeTitles(true)
            .tintColor(.liga1Red)

        // UI
        view.backgroundColor = .appBackground
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        tableView
            .addTo(containerView)
            .fillSuperview()
            .delegate(self)
            .dataSource(self)
            .registerCell(MatchTableViewCell.self)
            .separatorStyle(.none)
            .enableAutomaticDimensions()
    }
}
```

## Mejores Prácticas

1. **Builder pattern**: Encadenar métodos para configurar vistas
2. **Type-safe dequeue**: Usar `registerCell()` y `dequeueReusableCell(Cell.self, for:)`
3. **Container views**: Usar para separar concerns entre navigation/tab bar
4. **Stack views**: Preferir stack views sobre constraints manuales
5. **Spacing constants**: Usar `Spacing.small`, `.medium`, `.standard` en vez de números
6. **Theme system**: Usar `AppTheme` para fonts y `AppColors` para colores
7. **ConstraintGroup**: Para layouts que cambian dinámicamente

*/

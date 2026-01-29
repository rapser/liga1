//
//  AppKit+Examples.swift
//  liga1
//
//  Created by AppKit
//  Ejemplos de uso de AppKit
//

import UIKit

/*

# AppKit - UI Programática Simplificada

AppKit es una librería interna que proporciona helpers y builders para construir
UI programática de manera rápida y legible, similar a SnapKit pero más simple.

## Ejemplos de Uso

### 1. Constraints Básicos

```swift
// Llenar completamente el superview
view.fillSuperview()

// Llenar con padding
view.fillSuperview(padding: 16)
view.fillSuperview(padding: .init(top: 0, left: 16, bottom: 0, right: 16))

// Llenar respetando safe area
view.fillSuperviewSafeArea()

// Anchors manuales
view.anchor(
    top: containerView.topAnchor,
    leading: containerView.leadingAnchor,
    bottom: containerView.bottomAnchor,
    trailing: containerView.trailingAnchor,
    padding: .init(top: 16, left: 16, bottom: 16, right: 16)
)

// Centrar en superview
view.centerInSuperview()
view.centerXInSuperview()
view.centerYInSuperview()

// Tamaño
view.size(CGSize(width: 200, height: 100))
view.width(200)
view.height(100)

// Aspect ratio
imageView.aspectRatio(16/9)
```

### 2. Builder Pattern para Vistas

```swift
// Label
let titleLabel = UILabel()
    .text("Título")
    .font(.boldSystemFont(ofSize: 18))
    .textColor(.liga1Red)
    .textAlignment(.center)
    .numberOfLines(0)

// Button
let button = UIButton()
    .title("Guardar")
    .titleColor(.white)
    .backgroundColor(.liga1Red)
    .cornerRadius(8)
    .addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

// ImageView
let imageView = UIImageView()
    .image(UIImage(systemName: "star.fill"))
    .contentMode(.scaleAspectFit)
    .tintColor(.liga1Red)
```

### 3. Navigation Bar

```swift
// En viewDidLoad
setupNavigationBar()
    .title("Inicio")
    .prefersLargeTitles(true)
    .largeTitleDisplayMode(.always)
    .tintColor(.liga1Red)

// Con botones
setupNavigationBar()
    .title("Configuración")
    .rightBarButton(
        systemImage: "gear",
        target: self,
        action: #selector(settingsTapped)
    )
    .leftBarButton(
        systemImage: "arrow.left",
        target: self,
        action: #selector(backTapped)
    )

// Background personalizado
setupNavigationBar()
    .backgroundColor(.white)
    .titleColor(.black)

// Transparente
setupNavigationBar()
    .transparent()
```

### 4. TableView

```swift
let tableView = UITableView()
    .delegate(self)
    .dataSource(self)
    .registerCell(MatchTableViewCell.self)
    .registerCell(NewsTableViewCell.self)
    .separatorStyle(.none)
    .enableAutomaticDimensions()
    .removeEmptyCellSeparators()

// Dequeue type-safe
let cell = tableView.dequeueReusableCell(MatchTableViewCell.self, for: indexPath)
```

### 5. Container View

```swift
// Crear container entre navigation bar y tab bar
let containerView = view.addContainerViewBetweenBars(hasTabBar: true)
containerView.backgroundColor(.systemBackground)

// O manualmente
let containerView = ContainerView()
    .attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)
    .backgroundColor(.white)

// Añadir tableView dentro del container
containerView.addSubview(tableView)
tableView.fillSuperview()
```

### 6. Stack Views

```swift
// Vertical stack
let vStack = StackViewFactory.vStack(
    spacing: 12,
    alignment: .fill,
    distribution: .fill,
    views: [titleLabel, subtitleLabel, button]
)

// Horizontal stack
let hStack = StackViewFactory.hStack(
    spacing: 8,
    views: [iconView, label]
)

// Con builders
let stack = UIStackView(axis: .vertical, spacing: 12)
    .alignment(.center)
    .distribution(.fillEqually)
    .padding(16)
    .addArrangedSubviews(view1, view2, view3)

// Añadir spacers
stack.addFlexibleSpacer()
```

### 7. Header Views

```swift
// Date Header
let dateHeader = DateHeaderView()
dateHeader.configure(with: Date())
// O con texto personalizado
dateHeader.configure(with: "Hoy")

// Jornada Header
let jornadaHeader = JornadaHeaderView()
jornadaHeader.configure(jornada: "Jornada 10", torneo: "Torneo Apertura 2024")

// Title Header
let titleHeader = TitleHeaderView()
titleHeader.configure(title: "Apertura")

// Empty State
let emptyState = EmptyStateView()
emptyState.configure(
    systemImage: "heart.slash",
    title: "No hay favoritos",
    message: "Agrega equipos o partidos a tus favoritos"
)
```

### 8. Ejemplo Completo: Vista con TableView

```swift
class HomeViewController: UIViewController {

    private let containerView = ContainerView()
    private let tableView = UITableView()
    private let dateHeader = DateHeaderView()
    private let jornadaHeader = JornadaHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }

    private func setupNavigationBar() {
        setupNavigationBar()
            .title("Inicio")
            .prefersLargeTitles(true)
            .largeTitleDisplayMode(.always)
            .tintColor(.liga1Red)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Container entre navigation y tab bar
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        // TableView dentro del container
        containerView.addSubview(tableView)
        tableView.fillSuperview()

        // Configurar tableView
        tableView
            .delegate(self)
            .dataSource(self)
            .registerCell(MatchCell.self)
            .separatorStyle(.none)
            .enableAutomaticDimensions()
            .removeEmptyCellSeparators()

        // Headers
        dateHeader.configure(with: Date())
        dateHeader.height(50)

        jornadaHeader.configure(jornada: "Jornada 1", torneo: "Apertura 2024")
        jornadaHeader.height(60)

        tableView.tableHeaderView = createHeaderStack()
    }

    private func createHeaderStack() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 110)

        let stack = StackViewFactory.vStack(
            spacing: 0,
            views: [dateHeader, jornadaHeader]
        )

        container.addSubview(stack)
        stack.fillSuperview()

        return container
    }
}
```

### 9. Ejemplo: Vista con Label y Constraints

```swift
class TablaViewController: UIViewController {

    private let containerView = ContainerView()
    private let titleLabel = UILabel()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }

    private func setupNavigationBar() {
        setupNavigationBar()
            .title("Tabla de Posiciones")
            .prefersLargeTitles(true)
            .largeTitleDisplayMode(.always)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Container
        containerView.attachBetweenNavigationAndTabBar(in: view, hasTabBar: true)

        // Label de torneo (dentro del container, no del navbar)
        containerView.addSubview(titleLabel)
        titleLabel
            .text("Apertura")
            .font(.boldSystemFont(ofSize: 18))
            .textColor(.label)
            .textAlignment(.center)

        // Constraints del label
        titleLabel.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            trailing: containerView.trailingAnchor,
            padding: .init(top: 16, left: 16, bottom: 0, right: 16)
        )
        titleLabel.height(30)

        // TableView
        containerView.addSubview(tableView)
        tableView.anchor(
            top: titleLabel.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            padding: .init(top: 12, left: 0, bottom: 0, right: 0)
        )

        tableView
            .delegate(self)
            .dataSource(self)
            .registerCell(PositionCell.self)
            .separatorStyle(.singleLine)
            .enableAutomaticDimensions()
    }
}
```

## Mejores Prácticas

1. **Siempre usar prepareForAutoLayout()**: Se llama automáticamente en los helpers
2. **Encadenar métodos**: Aprovechar el builder pattern
3. **Type-safe dequeue**: Usar los métodos helper para dequeue
4. **Container views**: Usar para separar concerns entre navigation/tab bar
5. **Stack views**: Preferir stack views sobre constraints complejos
6. **Reutilizar headers**: Usar las clases de header proporcionadas

## Ventajas

- ✅ Código más limpio y legible
- ✅ Menos boilerplate
- ✅ Type-safe
- ✅ Consistencia visual
- ✅ Fácil mantenimiento
- ✅ Performance optimizado

*/

//
//  LayoutExamples.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//
//  Este archivo contiene ejemplos de cómo usar las utilidades de layout
//  NO es código de producción, solo documentación y ejemplos

import UIKit

/*

 EJEMPLOS DE USO DE LAS UTILIDADES DE LAYOUT
 ===========================================

 ## 1. UIView+Layout - Construcción declarativa de constraints

 ### Ejemplo 1: TableView que llena toda la pantalla
 ```swift
 let tableView = UITableView()
 tableView
     .addTo(view)
     .fillSuperviewSafeArea()
     .background(.systemBackground)
 ```

 ### Ejemplo 2: Label centrado con padding
 ```swift
 let emptyLabel = UILabel()
 emptyLabel
     .addTo(view)
     .centerInSuperview()
     .pinHorizontal(padding: 40)
     .text("No hay datos")
     .alignment(.center)
     .lines(0)
     .textColor(.secondaryLabel)
 ```

 ### Ejemplo 3: Botón al final de la pantalla
 ```swift
 let button = UIButton()
 button
     .addTo(view)
     .pinBottom(constant: 20, useSafeArea: true)
     .pinHorizontal(padding: Spacing.standard)
     .height(52)
     .background(.systemBlue)
     .corner(12)
     .title("Continuar", for: .normal)
     .titleColor(.white, for: .normal)
 ```

 ### Ejemplo 4: ImageView cuadrada
 ```swift
 let logoView = UIImageView()
 logoView
     .addTo(view)
     .square(100)
     .centerX()
     .pinTop(constant: 40, useSafeArea: true)
     .contentMode(.scaleAspectFit)
     .corner(50)
     .clip()
 ```

 ### Ejemplo 5: TextField con estilo
 ```swift
 let emailField = UITextField()
 emailField
     .addTo(view)
     .pinHorizontal(padding: Spacing.large)
     .height(52)
     .background(.secondarySystemBackground)
     .corner(12)
     .placeholder("Email")
     .leftPadding(16)
 ```

 ## 2. UIStackView+Builder - Construcción de Stacks

 ### Ejemplo 1: HStack simple
 ```swift
 let hStack = UIStackView.hStack(spacing: 8) {
     [logoImageView, titleLabel, scoreLabel]
 }
 hStack.addTo(view).fillSuperview()
 ```

 ### Ejemplo 2: VStack con padding interno
 ```swift
 let vStack = UIStackView.vStack(spacing: 12, alignment: .leading) {
     [
         titleLabel,
         subtitleLabel,
         descriptionLabel
     ]
 }
 .padding(16)  // Padding interno

 vStack.addTo(view).fillSuperviewSafeArea()
 ```

 ### Ejemplo 3: Stack complejo con configuración encadenada
 ```swift
 let stack = UIStackView()
     .addTo(view)
     .axis(.vertical)
     .spacing(Spacing.medium)
     .alignment(.fill)
     .padding(Spacing.standard)
     .addArranged([view1, view2, view3])

 stack.fillSuperview()
 ```

 ### Ejemplo 4: Spacer flexible
 ```swift
 let hStack = UIStackView.hStack {
     [
         leftLabel,
         Spacer(),  // Empuja los elementos a los lados
         rightLabel
     ]
 }
 ```

 ## 3. LayoutPresets - Presets predefinidos

 ### Ejemplo 1: TableView estándar
 ```swift
 let tableView = UITableView()
 LayoutPresets.configureTableView(
     tableView,
     in: view,
     delegate: self,
     dataSource: self
 )
 ```

 ### Ejemplo 2: TableView debajo de un SegmentedControl
 ```swift
 let segmentedControl = UISegmentedControl(items: ["Tab 1", "Tab 2"])
 LayoutPresets.configureSegmentedControl(segmentedControl, in: view)

 let tableView = UITableView()
 LayoutPresets.configureTableViewBelow(
     tableView,
     topView: segmentedControl,
     in: view,
     delegate: self,
     dataSource: self
 )
 ```

 ### Ejemplo 3: TextField estilizado
 ```swift
 let emailField = LayoutPresets.styledTextField(placeholder: "Email")
 emailField.addTo(view)
     .pinTop(constant: 100, useSafeArea: true)
     .pinHorizontal(padding: Spacing.large)
 ```

 ### Ejemplo 4: Botones primarios y secundarios
 ```swift
 let loginButton = LayoutPresets.primaryButton(
     title: "Iniciar Sesión",
     backgroundColor: .systemBlue
 )

 let signupButton = LayoutPresets.secondaryButton(
     title: "Crear Cuenta"
 )

 let stack = UIStackView.vStack(spacing: 12) {
     [loginButton, signupButton]
 }
 stack.addTo(view)
     .pinBottom(constant: 20, useSafeArea: true)
     .pinHorizontal(padding: Spacing.standard)
 ```

 ### Ejemplo 5: Labels con estilos predefinidos
 ```swift
 let titleLabel = LayoutPresets.titleLabel(text: "Bienvenido")
 let subtitleLabel = LayoutPresets.subtitleLabel(text: "Por favor inicia sesión")

 let stack = UIStackView.vStack(spacing: 8) {
     [titleLabel, subtitleLabel]
 }
 stack.addTo(view)
     .centerInSuperview()
     .pinHorizontal(padding: 40)
 ```

 ### Ejemplo 6: Empty State
 ```swift
 let emptyLabel = LayoutPresets.emptyStateLabel(
     text: "No tienes partidos favoritos\nToca la estrella para agregar uno"
 )
 LayoutPresets.setupEmptyState(label: emptyLabel, in: view)
 ```

 ### Ejemplo 7: Loading Overlay
 ```swift
 let (overlay, indicator) = LayoutPresets.loadingOverlay(in: view)

 // Mostrar loading
 overlay.isHidden = false
 indicator.startAnimating()

 // Ocultar loading
 indicator.stopAnimating()
 overlay.isHidden = true
 ```

 ## 4. Spacing - Valores consistentes

 ```swift
 // En lugar de hardcodear valores:
 label.pinTop(constant: 16)  ❌

 // Usa las constantes de Spacing:
 label.pinTop(constant: Spacing.standard)  ✅

 // Valores disponibles:
 Spacing.tiny        // 4
 Spacing.small       // 8
 Spacing.medium      // 12
 Spacing.standard    // 16
 Spacing.large       // 24
 Spacing.extraLarge  // 32
 ```

 ## 5. Ejemplo Completo: Vista de Login

 ```swift
 class MyLoginViewController: UIViewController {

     private let logoImageView = UIImageView()
     private let titleLabel = LayoutPresets.titleLabel(text: "Bienvenido")
     private let emailField = LayoutPresets.styledTextField(placeholder: "Email")
     private let passwordField = LayoutPresets.styledTextField(placeholder: "Contraseña")
     private let loginButton = LayoutPresets.primaryButton(title: "Iniciar Sesión")

     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .systemBackground
         setupUI()
     }

     private func setupUI() {
         // Logo
         logoImageView
             .addTo(view)
             .square(100)
             .centerX()
             .pinTop(constant: 60, useSafeArea: true)
             .contentMode(.scaleAspectFit)

         // Título
         titleLabel
             .addTo(view)
             .centerX()
             .pinTop(to: logoImageView.bottomAnchor, constant: Spacing.large)

         // Form Stack
         let formStack = UIStackView.vStack(spacing: Spacing.standard) {
             [emailField, passwordField, loginButton]
         }
         formStack
             .addTo(view)
             .pinTop(to: titleLabel.bottomAnchor, constant: Spacing.extraLarge)
             .pinHorizontal(padding: Spacing.large)
     }
 }
 ```

 ## 6. Migración de código existente

 ### Antes:
 ```swift
 let label = UILabel()
 label.translatesAutoresizingMaskIntoConstraints = false
 view.addSubview(label)

 NSLayoutConstraint.activate([
     label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
     label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
     label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
 ])

 label.text = "Hola"
 label.textAlignment = .center
 label.numberOfLines = 0
 ```

 ### Después:
 ```swift
 let label = UILabel()
 label
     .addTo(view)
     .pinTop(constant: Spacing.standard, useSafeArea: true)
     .pinHorizontal(padding: Spacing.standard)
     .text("Hola")
     .alignment(.center)
     .lines(0)
 ```

 REDUCCIÓN: 14 líneas → 7 líneas (50% menos código)

 */

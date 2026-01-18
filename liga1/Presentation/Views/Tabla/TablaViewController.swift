//
//  ViewController.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import UIKit
import Combine

class TablaViewController: UIViewController {

    // MARK: - Properties
    private let tableView = UITableView()
    
    // MARK: - Segmented Control (Comentado temporalmente - mostrar solo al concluir apertura)
    // let segmentedControl = UISegmentedControl(items: ["Apertura", "Clausura", "Acumulado"])
    
    // Rectángulo rojo que reemplaza al segmented control mostrando "Apertura"
    private let aperturaLabelView = UIView()
    private let aperturaLabel = UILabel()
    
    let viewModel: TorneoViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: TorneoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // configureSegmentedControl() // Comentado temporalmente
        configureAperturaLabelView() // Nuevo: mostrar rectángulo rojo con "Apertura"
        configureTableView()
        bindViewModel()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recargar datos cada vez que se entra a esta tab
        viewModel.reloadTeams(for: .apertura)
    }

    // MARK: - Private methods

    private func loadInitialData() {
        // segmentedControl.selectedSegmentIndex = 0 // Comentado temporalmente
        viewModel.loadTeams(for: .apertura)
    }

    private func bindViewModel() {
        viewModel.$displayedTeams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }

    // MARK: - Segmented Control Configuration (Comentado temporalmente)
    /*
    private func configureSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        LayoutPresets.configureSegmentedControl(segmentedControl, in: view)
    }
    */
    
    // MARK: - Apertura Label View Configuration
    private func configureAperturaLabelView() {
        aperturaLabelView.backgroundColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0) // Rojo
        aperturaLabelView.layer.cornerRadius = 5.0
        aperturaLabelView.prepareForAutoLayout()
        
        aperturaLabel.text = "Apertura"
        aperturaLabel.textColor = .white
        aperturaLabel.font = .systemFont(ofSize: 14, weight: .bold)
        aperturaLabel.textAlignment = .center
        aperturaLabel.prepareForAutoLayout()
        
        aperturaLabelView.addSubview(aperturaLabel)
        view.addSubview(aperturaLabelView)
        
        NSLayoutConstraint.activate([
            // Posicionar el rectángulo donde estaría el segmented control
            aperturaLabelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.standard),
            aperturaLabelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.standard),
            aperturaLabelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.standard),
            aperturaLabelView.heightAnchor.constraint(equalToConstant: 30), // Mismo height que el segmented control
            
            // Centrar el label dentro del rectángulo
            aperturaLabel.centerXAnchor.constraint(equalTo: aperturaLabelView.centerXAnchor),
            aperturaLabel.centerYAnchor.constraint(equalTo: aperturaLabelView.centerYAnchor)
        ])
    }

    private func configureTableView() {
        tableView.register(EquipoTableViewCell.self, forCellReuseIdentifier: "EquipoCell")
        tableView.allowsSelection = false
        // LayoutPresets.configureTableViewBelow(
        //     tableView,
        //     topView: segmentedControl, // Comentado temporalmente
        //     in: view,
        //     delegate: self,
        //     dataSource: self
        // )
        
        // Configurar tabla usando el aperturaLabelView como topView
        LayoutPresets.configureTableViewBelow(
            tableView,
            topView: aperturaLabelView,
            in: view,
            delegate: self,
            dataSource: self
        )
    }

    // MARK: - Segmented Control Action (Comentado temporalmente)
    /*
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.loadTeams(for: .apertura)
        case 1:
            viewModel.loadTeams(for: .clausura)
        case 2:
            viewModel.loadTeams(for: .acumulado)
        default:
            break
        }
    }
    */
}

//
//  MatchCell.swift
//  liga1
//
//  Created by miguel tomairo on 14/09/25.
//

import UIKit

protocol MatchCellDelegate: AnyObject {
    func didTapIniciar(match: Match)
    func didTapActualizar(match: Match)
    func didTapFinalizar(match: Match)
    func didUpdateScore(match: Match, local: Int, visita: Int)
}

class MatchCell: UITableViewCell {
    weak var delegate: MatchCellDelegate?
    private var match: Match?

    // MARK: - UI
    private let logoLocal = UIImageView()
    private let logoVisita = UIImageView()
    private let nombreLocal = UILabel()
    private let nombreVisita = UILabel()
    private let marcadorLocal = UILabel()
    private let marcadorVisita = UILabel()

    private let stepperLocal = UIStepper()
    private let stepperVisita = UIStepper()

    private let btnIniciar = UIButton(type: .system)
    private let btnActualizar = UIButton(type: .system)
    private let btnFinalizar = UIButton(type: .system)

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none

        [nombreLocal, nombreVisita].forEach {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .label
            $0.textAlignment = .left
        }

        [marcadorLocal, marcadorVisita].forEach {
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .center
            $0.widthAnchor.constraint(equalToConstant: 28).isActive = true
        }

        stepperLocal.minimumValue = 0
        stepperLocal.maximumValue = 20
        stepperLocal.stepValue = 1

        stepperVisita.minimumValue = 0
        stepperVisita.maximumValue = 20
        stepperVisita.stepValue = 1

        btnIniciar.setTitle("Iniciar", for: .normal)
        btnActualizar.setTitle("Actualizar", for: .normal)
        btnFinalizar.setTitle("Finalizar", for: .normal)

        [btnIniciar, btnActualizar, btnFinalizar].forEach {
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        }

        logoLocal.contentMode = .scaleAspectFit
        logoVisita.contentMode = .scaleAspectFit
        logoLocal.widthAnchor.constraint(equalToConstant: 24).isActive = true
        logoLocal.heightAnchor.constraint(equalToConstant: 24).isActive = true
        logoVisita.widthAnchor.constraint(equalToConstant: 24).isActive = true
        logoVisita.heightAnchor.constraint(equalToConstant: 24).isActive = true

        // 🔹 Local row
        let localInfo = UIStackView(arrangedSubviews: [logoLocal, nombreLocal])
        localInfo.axis = .horizontal
        localInfo.spacing = 16
        localInfo.alignment = .center

        let localScore = UIStackView(arrangedSubviews: [marcadorLocal, stepperLocal])
        localScore.axis = .horizontal
        localScore.spacing = 8
        localScore.alignment = .center

        let localRow = UIStackView(arrangedSubviews: [localInfo, localScore])
        localRow.axis = .horizontal
        localRow.alignment = .center
        localRow.distribution = .equalSpacing

        // 🔹 Visit row
        let visitaInfo = UIStackView(arrangedSubviews: [logoVisita, nombreVisita])
        visitaInfo.axis = .horizontal
        visitaInfo.spacing = 16
        visitaInfo.alignment = .center

        let visitaScore = UIStackView(arrangedSubviews: [marcadorVisita, stepperVisita])
        visitaScore.axis = .horizontal
        visitaScore.spacing = 8
        visitaScore.alignment = .center

        let visitaRow = UIStackView(arrangedSubviews: [visitaInfo, visitaScore])
        visitaRow.axis = .horizontal
        visitaRow.alignment = .center
        visitaRow.distribution = .equalSpacing

        // 🔹 Botones de control alineados a la derecha
        let actionsRow = UIStackView(arrangedSubviews: [btnIniciar, btnActualizar, btnFinalizar])
        actionsRow.axis = .horizontal
        actionsRow.spacing = 12
        actionsRow.alignment = .center
        actionsRow.distribution = .equalSpacing

        let actionsContainer = UIStackView(arrangedSubviews: [UIView(), actionsRow])
        actionsContainer.axis = .horizontal
        actionsContainer.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [localRow, visitaRow, actionsContainer])
        mainStack.axis = .vertical
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    private func setupActions() {
        btnIniciar.addTarget(self, action: #selector(iniciarTapped), for: .touchUpInside)
        btnActualizar.addTarget(self, action: #selector(actualizarTapped), for: .touchUpInside)
        btnFinalizar.addTarget(self, action: #selector(finalizarTapped), for: .touchUpInside)

        stepperLocal.addTarget(self, action: #selector(localStepperChanged(_:)), for: .valueChanged)
        stepperVisita.addTarget(self, action: #selector(visitaStepperChanged(_:)), for: .valueChanged)
    }

    // MARK: - Configure
    func configure(with match: Match, localTeam: Team, visitaTeam: Team) {
        self.match = match

        nombreLocal.text = localTeam.nombre
        nombreVisita.text = visitaTeam.nombre
        marcadorLocal.text = "\(match.golesEquipoLocal)"
        marcadorVisita.text = "\(match.golesEquipoVisitante)"

        logoLocal.image = UIImage(named: localTeam.logo)
        logoVisita.image = UIImage(named: visitaTeam.logo)

        stepperLocal.value = Double(match.golesEquipoLocal)
        stepperVisita.value = Double(match.golesEquipoVisitante)

        switch match.estado {
        case .pendiente:
            btnIniciar.isEnabled = true
            btnActualizar.isEnabled = false
            btnFinalizar.isEnabled = false
        case .enJuego:
            btnIniciar.isEnabled = false
            btnActualizar.isEnabled = true
            btnFinalizar.isEnabled = true
        case .finalizado, .anulado, .suspendido:
            btnIniciar.isEnabled = false
            btnActualizar.isEnabled = false
            btnFinalizar.isEnabled = false
        }
    }

    // MARK: - Actions
    @objc private func iniciarTapped() {
        guard let match = match else { return }
        delegate?.didTapIniciar(match: match)
    }

    @objc private func actualizarTapped() {
        guard let match = match else { return }
        delegate?.didTapActualizar(match: match)
    }

    @objc private func finalizarTapped() {
        guard let match = match else { return }
        delegate?.didTapFinalizar(match: match)
    }

    @objc private func localStepperChanged(_ sender: UIStepper) {
        guard var match = match else { return }
        match.golesEquipoLocal = Int(sender.value)
        marcadorLocal.text = "\(match.golesEquipoLocal)"
        delegate?.didUpdateScore(match: match,
                                 local: match.golesEquipoLocal,
                                 visita: match.golesEquipoVisitante)
    }

    @objc private func visitaStepperChanged(_ sender: UIStepper) {
        guard var match = match else { return }
        match.golesEquipoVisitante = Int(sender.value)
        marcadorVisita.text = "\(match.golesEquipoVisitante)"
        delegate?.didUpdateScore(match: match,
                                 local: match.golesEquipoLocal,
                                 visita: match.golesEquipoVisitante)
    }
}

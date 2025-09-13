//
//  EquipoOldTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit

class EquipoOldTableViewCell: UITableViewCell {

    let nombreLabel = UILabel()
    
    let partidosJugadosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let partidosGanadosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let partidosEmpatadosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let partidosPerdidosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let golesFavorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let golesContraLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let puntosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addConstraints(to: nombreLabel, leading: 10, top: 10, width: 150)
        contentView.addConstraints(to: partidosJugadosLabel, leading: 170, top: 10, width: 20)
        contentView.addConstraints(to: partidosGanadosLabel, leading: 200, top: 10, width: 20)
        contentView.addConstraints(to: partidosEmpatadosLabel, leading: 230, top: 10, width: 20)
        contentView.addConstraints(to: partidosPerdidosLabel, leading: 260, top: 10, width: 20)
        contentView.addConstraints(to: puntosLabel, leading: 290, top: 10, width: 20)
        contentView.addConstraints(to: golesFavorLabel, leading: 320, top: 10, width: 20)
        contentView.addConstraints(to: golesContraLabel, top: 10, trailing: 10, width: 30)

    }

    func configurarCon(equipo: Match) {
        nombreLabel.text = equipo.nombre
        partidosJugadosLabel.text = "\(equipo.partidosJugados)"
        partidosGanadosLabel.text = "\(equipo.partidosGanados)"
        partidosEmpatadosLabel.text = "\(equipo.partidosEmpatados)"
        partidosPerdidosLabel.text = "\(equipo.partidosPerdidos)"
        golesFavorLabel.text = "\(equipo.golesFavor)"
        golesContraLabel.text = "\(equipo.golesContra)"
        puntosLabel.text = "\(equipo.puntos)"
    }
}

//
//  TeamTableViewCell.swift
//  liga1
//
//  Created by miguel tomairo on 17/01/26.
//

import UIKit

protocol TeamTableViewCellDelegate: AnyObject {
    func didTapFavorite(cell: TeamTableViewCell)
}

class TeamTableViewCell: UITableViewCell {

    static let identifier = "TeamTableViewCell"

    weak var delegate: TeamTableViewCellDelegate?

    // MARK: - UI Components

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        button.setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "star.fill", withConfiguration: config), for: .selected)
        button.tintColor = .systemYellow
        return button
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground

        contentView.addSubview(logoImageView)
        contentView.addSubview(teamNameLabel)
        contentView.addSubview(favoriteButton)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Logo
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),

            // Team Name
            teamNameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            teamNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            teamNameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),

            // Favorite Button
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }

    // MARK: - Configuration

    func configure(with team: TeamUI, logo: UIImage?) {
        teamNameLabel.text = team.nombre
        logoImageView.image = logo ?? UIImage(systemName: "shield.fill")
        favoriteButton.isSelected = team.isFavorite
    }

    // MARK: - Actions

    @objc private func favoriteTapped() {
        delegate?.didTapFavorite(cell: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        teamNameLabel.text = nil
        favoriteButton.isSelected = false
    }
}

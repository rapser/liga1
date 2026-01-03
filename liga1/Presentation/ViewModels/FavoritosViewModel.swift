//
//  FavoritosViewModel.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import Combine
import FirebaseFirestore

class FavoritosViewModel {

    // MARK: - Published Properties

    @Published private(set) var matches: [Match] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var favoriteMatchIds: Set<String> = []

    // MARK: - Dependencies

    private let matchesRepository: MatchesRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()

    // MARK: - Initialization

    init(
        matchesRepository: MatchesRepositoryProtocol = MatchesRepository(),
        favoritesService: FavoritesServiceProtocol = FavoritesService()
    ) {
        self.matchesRepository = matchesRepository
        self.favoritesService = favoritesService

        observeFavorites()
    }

    // MARK: - Public Methods

    func toggleFavorite(matchId: String) {
        favoritesService.toggleFavorite(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to toggle favorite for match: \(matchId)", error: error)
                }
            } receiveValue: { _ in
                Logger.shared.debug("Favorite toggled successfully for match: \(matchId)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func observeFavorites() {
        favoritesService.observeFavorites()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteIds in
                self?.favoriteMatchIds = favoriteIds
                self?.fetchFavoriteMatches()
            }
            .store(in: &cancellables)
    }

    private func fetchFavoriteMatches() {
        guard !favoriteMatchIds.isEmpty else {
            self.matches = []
            return
        }

        isLoading = true

        db.collection("matches")
            .whereField(FieldPath.documentID(), in: Array(favoriteMatchIds))
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.error = error
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.matches = []
                        return
                    }

                    var fetchedMatches = documents.compactMap { doc -> Match? in
                        var match = try? doc.data(as: Match.self)
                        match?.isFavorite = true
                        return match
                    }

                    fetchedMatches.sort { $0.fecha < $1.fecha }
                    self.matches = fetchedMatches
                }
            }
    }
}

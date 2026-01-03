//
//  DIContainer.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Dependency Injection Container
/// Responsable de crear y proveer todas las dependencias de la app
class DIContainer {

    // MARK: - Singleton

    static let shared = DIContainer()

    private init() {}

    // MARK: - Repositories

    func makeJornadasRepository() -> JornadasRepositoryProtocol {
        return JornadasRepository()
    }

    func makeMatchesRepository() -> MatchesRepositoryProtocol {
        return MatchesRepository()
    }

    func makeTeamsRepository() -> TeamsRepositoryProtocol {
        return TeamsRepository()
    }

    func makeNewsRepository() -> NewsRepositoryProtocol {
        return NewsRepository()
    }

    // MARK: - Services

    func makeAuthService() -> AuthServiceProtocol {
        return AuthService()
    }

    func makeFavoritesService() -> FavoritesServiceProtocol {
        return FavoritesService()
    }

    // MARK: - Use Cases - Jornadas

    func makeFetchActiveJornadasUseCase() -> FetchActiveJornadasUseCaseProtocol {
        return FetchActiveJornadasUseCase(
            repository: makeJornadasRepository()
        )
    }

    // MARK: - Use Cases - Matches

    func makeFetchMatchesUseCase() -> FetchMatchesUseCaseProtocol {
        return FetchMatchesUseCase(
            repository: makeMatchesRepository()
        )
    }

    // MARK: - Use Cases - Teams

    func makeFetchTeamsUseCase() -> FetchTeamsUseCaseProtocol {
        return FetchTeamsUseCase(
            repository: makeTeamsRepository()
        )
    }

    // MARK: - Use Cases - News

    func makeFetchNewsUseCase() -> FetchNewsUseCaseProtocol {
        return FetchNewsUseCase(
            repository: makeNewsRepository()
        )
    }

    // MARK: - Use Cases - Favorites

    func makeToggleFavoriteUseCase() -> ToggleFavoriteUseCaseProtocol {
        return ToggleFavoriteUseCase(
            service: makeFavoritesService()
        )
    }

    func makeObserveFavoritesUseCase() -> ObserveFavoritesUseCaseProtocol {
        return ObserveFavoritesUseCase(
            service: makeFavoritesService()
        )
    }

    // MARK: - Use Cases - Auth

    func makeLoginUseCase() -> LoginUseCaseProtocol {
        return LoginUseCase(
            authService: makeAuthService()
        )
    }

    func makeLogoutUseCase() -> LogoutUseCaseProtocol {
        return LogoutUseCase(
            authService: makeAuthService()
        )
    }

    // MARK: - ViewModels

    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            jornadasRepository: makeJornadasRepository(),
            matchesRepository: makeMatchesRepository(),
            favoritesService: makeFavoritesService()
        )
    }

    func makeNewsViewModel() -> NewsViewModel {
        return NewsViewModel(
            newsRepository: makeNewsRepository()
        )
    }

    func makeTorneoViewModel() -> TorneoViewModel {
        return TorneoViewModel(
            teamsRepository: makeTeamsRepository()
        )
    }

    func makeFavoritosViewModel() -> FavoritosViewModel {
        return FavoritosViewModel(
            jornadasRepository: makeJornadasRepository(),
            matchesRepository: makeMatchesRepository(),
            favoritesService: makeFavoritesService()
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(
            authService: makeAuthService()
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            authService: makeAuthService()
        )
    }
}

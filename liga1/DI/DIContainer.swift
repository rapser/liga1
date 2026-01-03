//
//  DIContainer.swift
//  liga1
//
//  Created by Claude Code on 02/01/26.
//

import Foundation

/// Dependency Injection Container
/// Responsable de crear y proveer todas las dependencias de la app
final class DIContainer {

    // MARK: - Singleton

    static let shared = DIContainer()

    private init() {}

    // MARK: - Database

    private func makeDatabase() -> DatabaseProtocol {
        return FirestoreManager.shared
    }

    // MARK: - Repositories

    func makeJornadasRepository() -> JornadasRepositoryProtocol {
        return JornadasRepository(database: makeDatabase())
    }

    func makeMatchesRepository() -> MatchesRepositoryProtocol {
        return MatchesRepository(database: makeDatabase())
    }

    func makeTeamsRepository() -> TeamsRepositoryProtocol {
        return TeamsRepository(database: makeDatabase())
    }

    func makeNewsRepository() -> NewsRepositoryProtocol {
        return NewsRepository(database: makeDatabase())
    }

    func makeAdminMatchRepository() -> AdminMatchRepositoryProtocol {
        return AdminMatchRepository(database: makeDatabase())
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

    func makeFetchFavoriteMatchesUseCase() -> FetchFavoriteMatchesUseCaseProtocol {
        return FetchFavoriteMatchesUseCase(
            matchesRepository: makeMatchesRepository()
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

    // MARK: - Use Cases - Admin

    func makeRegisterMatchesUseCase() -> RegisterMatchesUseCaseProtocol {
        return RegisterMatchesUseCase(
            adminMatchRepository: makeAdminMatchRepository()
        )
    }

    // MARK: - ViewModels

    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            fetchActiveJornadasUseCase: makeFetchActiveJornadasUseCase(),
            fetchMatchesUseCase: makeFetchMatchesUseCase(),
            toggleFavoriteUseCase: makeToggleFavoriteUseCase(),
            observeFavoritesUseCase: makeObserveFavoritesUseCase()
        )
    }

    func makeNewsViewModel() -> NewsViewModel {
        return NewsViewModel(
            fetchNewsUseCase: makeFetchNewsUseCase()
        )
    }

    func makeTorneoViewModel() -> TorneoViewModel {
        return TorneoViewModel(
            fetchTeamsUseCase: makeFetchTeamsUseCase()
        )
    }

    func makeFavoritosViewModel() -> FavoritosViewModel {
        return FavoritosViewModel(
            fetchFavoriteMatchesUseCase: makeFetchFavoriteMatchesUseCase(),
            toggleFavoriteUseCase: makeToggleFavoriteUseCase(),
            observeFavoritesUseCase: makeObserveFavoritesUseCase()
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(
            logoutUseCase: makeLogoutUseCase()
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            loginUseCase: makeLoginUseCase()
        )
    }

    func makeRegistrarPartidosViewModel() -> RegistrarPartidosViewModel {
        return RegistrarPartidosViewModel(
            registerMatchesUseCase: makeRegisterMatchesUseCase()
        )
    }
}

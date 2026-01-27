//
//  DIContainer.swift
//  liga1
//
//  Created by miguel tomairo on 02/01/26.
//

import Foundation
import UIKit

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
        let authService = makeAuthService() as! AuthService
        return FavoritesService(database: makeDatabase(), authProvider: authService)
    }

    private lazy var notificationService: NotificationServiceProtocol = {
        return NotificationService()
    }()

    func makeNotificationService() -> NotificationServiceProtocol {
        return notificationService
    }

    func makeUserPreferencesService() -> UserPreferencesServiceProtocol {
        let authService = makeAuthService() as! AuthService
        return UserPreferencesService(database: makeDatabase(), authProvider: authService)
    }

    private lazy var notificationTopicManager: NotificationTopicManagerProtocol = {
        return NotificationTopicManager(
            notificationService: makeNotificationService(),
            favoritesService: makeFavoritesService(),
            userPreferencesService: makeUserPreferencesService()
        )
    }()

    func makeNotificationTopicManager() -> NotificationTopicManagerProtocol {
        return notificationTopicManager
    }

    // MARK: - Use Cases - Jornadas

    func makeFetchActiveJornadasUseCase() -> FetchActiveJornadasUseCaseProtocol {
        return FetchActiveJornadasUseCase(
            repository: makeJornadasRepository()
        )
    }

    func makeObserveActiveJornadasUseCase() -> ObserveActiveJornadasUseCaseProtocol {
        return ObserveActiveJornadasUseCase(
            repository: makeJornadasRepository()
        )
    }

    // MARK: - Use Cases - Matches

    func makeFetchMatchesUseCase() -> FetchMatchesUseCaseProtocol {
        return FetchMatchesUseCase(
            repository: makeMatchesRepository()
        )
    }

    func makeObserveMatchesUseCase() -> ObserveMatchesUseCaseProtocol {
        return ObserveMatchesUseCase(
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

    func makeToggleFavoriteTeamUseCase() -> ToggleFavoriteTeamUseCaseProtocol {
        return ToggleFavoriteTeamUseCase(
            service: makeFavoritesService()
        )
    }

    func makeObserveFavoriteTeamsUseCase() -> ObserveFavoriteTeamsUseCaseProtocol {
        return ObserveFavoriteTeamsUseCase(
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

    // MARK: - Use Cases - Admin

    func makeRegisterMatchesUseCase() -> RegisterMatchesUseCaseProtocol {
        return RegisterMatchesUseCase(
            adminMatchRepository: makeAdminMatchRepository()
        )
    }

    // MARK: - Use Cases - Notifications

    func makeUpdatePushNotificationsEnabledUseCase() -> UpdatePushNotificationsEnabledUseCaseProtocol {
        return UpdatePushNotificationsEnabledUseCase(
            userPreferencesService: makeUserPreferencesService(),
            notificationTopicManager: makeNotificationTopicManager()
        )
    }

    func makeObserveUserPreferencesUseCase() -> ObserveUserPreferencesUseCaseProtocol {
        return ObserveUserPreferencesUseCase(
            userPreferencesService: makeUserPreferencesService()
        )
    }

    // MARK: - ViewModels

    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            fetchActiveJornadasUseCase: makeFetchActiveJornadasUseCase(),
            observeActiveJornadasUseCase: makeObserveActiveJornadasUseCase(),
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
            observeFavoritesUseCase: makeObserveFavoritesUseCase(),
            fetchTeamsUseCase: makeFetchTeamsUseCase(),
            toggleFavoriteTeamUseCase: makeToggleFavoriteTeamUseCase(),
            observeFavoriteTeamsUseCase: makeObserveFavoriteTeamsUseCase()
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

    func makeNotificationSettingsViewModel() -> NotificationSettingsViewModel {
        return NotificationSettingsViewModel(
            updatePushNotificationsEnabledUseCase: makeUpdatePushNotificationsEnabledUseCase(),
            observeUserPreferencesUseCase: makeObserveUserPreferencesUseCase()
        )
    }

    // MARK: - ViewControllers

    func makeHomeViewController() -> HomeViewController {
        return HomeViewController(viewModel: makeHomeViewModel())
    }

    func makeTablaViewController() -> TablaViewController {
        return TablaViewController(viewModel: makeTorneoViewModel())
    }

    func makeFavoritosViewController() -> FavoritosViewController {
        return FavoritosViewController(viewModel: makeFavoritosViewModel())
    }

    func makeNewsViewController() -> NewsViewController {
        return NewsViewController(viewModel: makeNewsViewModel())
    }

    func makeProfileViewController() -> ProfileViewController {
        return ProfileViewController(viewModel: makeProfileViewModel(), container: self)
    }

    func makeLoginViewController() -> LoginViewController {
        return LoginViewController(viewModel: makeLoginViewModel())
    }

    func makeRegistrarPartidosViewController() -> RegistrarPartidosViewController {
        return RegistrarPartidosViewController(viewModel: makeRegistrarPartidosViewModel())
    }

    // MARK: - Coordinators

    func makeAppCoordinator(window: UIWindow) -> AppCoordinator {
        return AppCoordinator(window: window, container: self)
    }

    func makeLoginCoordinator(navigationController: UINavigationController) -> LoginCoordinator {
        return LoginCoordinator(navigationController: navigationController, container: self)
    }
}

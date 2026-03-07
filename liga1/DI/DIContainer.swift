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
        return JornadasRepository(database: makeDatabase(), logger: makeLogger())
    }

    func makeMatchesRepository() -> MatchesRepositoryProtocol {
        return MatchesRepository(database: makeDatabase(), logger: makeLogger())
    }

    func makeTeamsRepository() -> TeamsRepositoryProtocol {
        return TeamsRepository(database: makeDatabase())
    }

    func makeNewsRepository() -> NewsRepositoryProtocol {
        return NewsRepository(database: makeDatabase(), logger: makeLogger())
    }

    // MARK: - Services

    // MARK: - Services

    private lazy var favoritesService: FavoritesServiceProtocol = {
        return FavoritesService(database: makeDatabase(), logger: makeLogger())
    }()

    func makeFavoritesService() -> FavoritesServiceProtocol {
        return favoritesService
    }

    private lazy var notificationService: NotificationServiceProtocol = {
        return NotificationService()
    }()

    func makeNotificationService() -> NotificationServiceProtocol {
        return notificationService
    }

    private lazy var userPreferencesService: UserPreferencesServiceProtocol = {
        return UserPreferencesService(
            database: makeDatabase(),
            logger: makeLogger()
        )
    }()

    func makeUserPreferencesService() -> UserPreferencesServiceProtocol {
        return userPreferencesService
    }

    private lazy var notificationTopicManager: NotificationTopicManagerProtocol = {
        return NotificationTopicManager(
            notificationService: makeNotificationService(),
            favoritesService: makeFavoritesService(),
            userPreferencesService: makeUserPreferencesService(),
            logger: makeLogger()
        )
    }()

    func makeNotificationTopicManager() -> NotificationTopicManagerProtocol {
        return notificationTopicManager
    }

    // MARK: - Notification Deduplicator

    private lazy var notificationDeduplicator: NotificationDeduplicatorProtocol = {
        return NotificationDeduplicator()
    }()

    func makeNotificationDeduplicator() -> NotificationDeduplicatorProtocol {
        return notificationDeduplicator
    }

    // MARK: - Logging

    func makeLogger() -> LoggerProtocol {
        return Logger.shared
    }

    // MARK: - EventBus

    private lazy var appEventBus: AppEventBusProtocol = {
        return AppEventBus()
    }()

    func makeAppEventBus() -> AppEventBusProtocol {
        return appEventBus
    }

    // MARK: - Use Cases - Jornadas

    func makeFetchActiveJornadasUseCase() -> FetchActiveJornadasUseCaseProtocol {
        return FetchActiveJornadasUseCase(
            repository: makeJornadasRepository(),
            logger: makeLogger()
        )
    }

    func makeObserveActiveJornadasUseCase() -> ObserveActiveJornadasUseCaseProtocol {
        return ObserveActiveJornadasUseCase(
            repository: makeJornadasRepository()
        )
    }

    func makeGetJornadaToDisplayUseCase() -> GetJornadaToDisplayUseCaseProtocol {
        return GetJornadaToDisplayUseCase(
            fetchActiveJornadasUseCase: makeFetchActiveJornadasUseCase(),
            observeActiveJornadasUseCase: makeObserveActiveJornadasUseCase()
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
    // AuthKit ahora se usa directamente vía AuthManager.shared
    // No se necesitan UseCases separados

    // MARK: - Use Cases - Notifications

    func makeUpdatePushNotificationsEnabledUseCase() -> UpdatePushNotificationsEnabledUseCaseProtocol {
        return UpdatePushNotificationsEnabledUseCase(
            userPreferencesService: makeUserPreferencesService(),
            notificationTopicManager: makeNotificationTopicManager(),
            logger: makeLogger()
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
            getJornadaToDisplayUseCase: makeGetJornadaToDisplayUseCase(),
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
            observeFavoriteTeamsUseCase: makeObserveFavoriteTeamsUseCase(),
            notificationTopicManager: makeNotificationTopicManager()
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel()
    }

    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            logger: makeLogger()
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

    func makeProfileViewController(eventBus: AppEventBusProtocol? = nil) -> ProfileViewController {
        return ProfileViewController(
            viewModel: makeProfileViewModel(),
            container: self,
            eventBus: eventBus ?? makeAppEventBus()
        )
    }

    func makeLoginViewController(presentingViewController: UIViewController) -> LoginViewController {
        let viewModel = makeLoginViewModel()
        let googleCredentialProvider = GoogleCredentialProviderImpl(
            presentingViewController: presentingViewController
        )
        return LoginViewController(
            viewModel: viewModel,
            googleCredentialProvider: googleCredentialProvider
        )
    }

    func makeNotificationHistoryViewController() -> NotificationHistoryViewController {
        return NotificationHistoryViewController()
    }

    // MARK: - Coordinators

    func makeAppCoordinator(window: UIWindow) -> AppCoordinator {
        return AppCoordinator(
            window: window,
            container: self,
            eventBus: makeAppEventBus(),
            logger: makeLogger()
        )
    }

    func makeLoginCoordinator(navigationController: UINavigationController) -> LoginCoordinator {
        return LoginCoordinator(
            navigationController: navigationController,
            container: self,
            eventBus: makeAppEventBus()
        )
    }

    func makeMainTabBarController(eventBus: AppEventBusProtocol) -> MainTabBarController {
        return MainTabBarController(container: self, eventBus: eventBus)
    }
}

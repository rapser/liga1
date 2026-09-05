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

    // MARK: - Auth

    func makeAuthService() -> AuthServiceProtocol {
        return AuthManager.shared
    }

    // MARK: - Repositories

    func makeJornadasRepository() -> JornadasRepositoryProtocol {
        return JornadasRepository(database: makeDatabase(), logger: makeLogger())
    }

    func makeMatchesRepository() -> MatchesRepositoryProtocol {
        return MatchesRepository(database: makeDatabase(), logger: makeLogger())
    }

    private lazy var teamsRepository: TeamsRepositoryProtocol = {
        return CachingTeamsRepository(wrapping: TeamsRepository(database: makeDatabase()))
    }()

    func makeTeamsRepository() -> TeamsRepositoryProtocol {
        return teamsRepository
    }

    func makeNewsRepository() -> NewsRepositoryProtocol {
        return NewsRepository(database: makeDatabase(), logger: makeLogger())
    }

    func makeStadiumRepository() -> StadiumRepositoryProtocol {
        return StadiumRepository(database: makeDatabase(), logger: makeLogger())
    }

    func makeRefereeRepository() -> RefereeRepositoryProtocol {
        return RefereeRepository(database: makeDatabase(), logger: makeLogger())
    }

    func makeWeatherRepository() -> WeatherRepositoryProtocol {
        return WeatherRepository(database: makeDatabase(), logger: makeLogger())
    }

    func makePollRepository() -> PollRepositoryProtocol {
        return PollRepository(database: makeDatabase(), logger: makeLogger())
    }

    // MARK: - Services

    private lazy var favoritesService: FavoritesServiceProtocol = {
        return FavoritesService(database: makeDatabase(), logger: makeLogger(), authService: makeAuthService())
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

    func makeTournamentConfigRepository() -> TournamentConfigRepositoryProtocol {
        return FirebaseTournamentConfigRepository()
    }

    private lazy var userPreferencesService: UserPreferencesServiceProtocol = {
        return UserPreferencesService(
            database: makeDatabase(),
            logger: makeLogger(),
            authService: makeAuthService()
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

    func makeGetTournamentAvailabilityUseCase() -> GetTournamentAvailabilityUseCaseProtocol {
        return GetTournamentAvailabilityUseCase(
            repository: makeTournamentConfigRepository()
        )
    }

    func makeCalculateAccumulatedStandingsUseCase() -> CalculateAccumulatedStandingsUseCaseProtocol {
        return CalculateAccumulatedStandingsUseCase()
    }

    // MARK: - Use Cases - Simulador de tabla / descenso

    func makeFetchRemainingFixturesUseCase() -> FetchRemainingFixturesUseCaseProtocol {
        return FetchRemainingFixturesUseCase(
            jornadasRepository: makeJornadasRepository(),
            matchesRepository: makeMatchesRepository()
        )
    }

    func makeSimulateStandingsUseCase() -> SimulateStandingsUseCaseProtocol {
        return SimulateStandingsUseCase()
    }

    func makeProjectQualificationUseCase() -> ProjectQualificationUseCaseProtocol {
        return ProjectQualificationUseCase()
    }

    // MARK: - Use Cases - Match Context (Sabor Local)

    func makeGetStadiumForTeamUseCase() -> GetStadiumForTeamUseCaseProtocol {
        return GetStadiumForTeamUseCase(repository: makeStadiumRepository())
    }

    func makeGetRefereeProfileUseCase() -> GetRefereeProfileUseCaseProtocol {
        return GetRefereeProfileUseCase(repository: makeRefereeRepository())
    }

    func makeGetMatchWeatherUseCase() -> GetMatchWeatherUseCaseProtocol {
        return GetMatchWeatherUseCase(repository: makeWeatherRepository())
    }

    func makeObserveRefereePollUseCase() -> ObserveRefereePollUseCaseProtocol {
        return ObserveRefereePollUseCase(repository: makePollRepository())
    }

    func makeObservePollResultUseCase() -> ObservePollResultUseCaseProtocol {
        return ObservePollResultUseCase(repository: makePollRepository(), authService: makeAuthService())
    }

    func makeSubmitRefereePollVoteUseCase() -> SubmitRefereePollVoteUseCaseProtocol {
        return SubmitRefereePollVoteUseCase(repository: makePollRepository(), authService: makeAuthService())
    }

    // MARK: - Use Cases - News

    func makeFetchNewsUseCase() -> FetchNewsUseCaseProtocol {
        return FetchNewsUseCase(
            repository: makeNewsRepository()
        )
    }

    // MARK: - Use Cases - Favorites

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

    func makeLoginWithEmailUseCase() -> LoginWithEmailUseCaseProtocol {
        return LoginWithEmailUseCase(authService: makeAuthService())
    }

    func makeLoginWithGoogleUseCase() -> LoginWithGoogleUseCaseProtocol {
        return LoginWithGoogleUseCase(authService: makeAuthService())
    }

    func makeObserveAuthStateUseCase() -> ObserveAuthStateUseCaseProtocol {
        return ObserveAuthStateUseCase(authService: makeAuthService())
    }

    func makeLogoutUseCase() -> LogoutUseCaseProtocol {
        return LogoutUseCase(authService: makeAuthService())
    }

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
            fetchMatchesUseCase: makeFetchMatchesUseCase()
        )
    }

    func makeNewsViewModel() -> NewsViewModel {
        return NewsViewModel(
            fetchNewsUseCase: makeFetchNewsUseCase()
        )
    }

    func makeTorneoViewModel() -> TorneoViewModel {
        return TorneoViewModel(
            fetchTeamsUseCase: makeFetchTeamsUseCase(),
            tournamentAvailabilityUseCase: makeGetTournamentAvailabilityUseCase(),
            calculateAccumulatedStandingsUseCase: makeCalculateAccumulatedStandingsUseCase()
        )
    }

    func makeFavoritosViewModel() -> FavoritosViewModel {
        return FavoritosViewModel(
            fetchTeamsUseCase: makeFetchTeamsUseCase(),
            toggleFavoriteTeamUseCase: makeToggleFavoriteTeamUseCase(),
            observeFavoriteTeamsUseCase: makeObserveFavoriteTeamsUseCase(),
            notificationTopicManager: makeNotificationTopicManager()
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(
            authService: makeAuthService(),
            logoutUseCase: makeLogoutUseCase()
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            authService: makeAuthService(),
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
        return HomeViewController(viewModel: makeHomeViewModel(), container: self)
    }

    func makeMatchDetailViewModel(context: MatchDetailContext) -> MatchDetailViewModel {
        return MatchDetailViewModel(
            context: context,
            getStadiumUseCase: makeGetStadiumForTeamUseCase(),
            getRefereeProfileUseCase: makeGetRefereeProfileUseCase(),
            getMatchWeatherUseCase: makeGetMatchWeatherUseCase(),
            observeRefereePollUseCase: makeObserveRefereePollUseCase(),
            observePollResultUseCase: makeObservePollResultUseCase(),
            submitRefereePollVoteUseCase: makeSubmitRefereePollVoteUseCase()
        )
    }

    func makeMatchDetailViewController(context: MatchDetailContext) -> MatchDetailViewController {
        return MatchDetailViewController(viewModel: makeMatchDetailViewModel(context: context))
    }

    func makeTablaViewController() -> TablaViewController {
        return TablaViewController(viewModel: makeTorneoViewModel())
    }

    func makeStandingsSimulatorViewModel() -> StandingsSimulatorViewModel {
        return StandingsSimulatorViewModel(
            fetchTeamsUseCase: makeFetchTeamsUseCase(),
            calculateAccumulatedUseCase: makeCalculateAccumulatedStandingsUseCase(),
            fetchRemainingFixturesUseCase: makeFetchRemainingFixturesUseCase(),
            simulateStandingsUseCase: makeSimulateStandingsUseCase(),
            projectQualificationUseCase: makeProjectQualificationUseCase()
        )
    }

    func makeStandingsSimulatorViewController(torneo: TorneoType) -> StandingsSimulatorViewController {
        return StandingsSimulatorViewController(viewModel: makeStandingsSimulatorViewModel(), torneo: torneo)
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
            authService: makeAuthService(),
            logoutUseCase: makeLogoutUseCase(),
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

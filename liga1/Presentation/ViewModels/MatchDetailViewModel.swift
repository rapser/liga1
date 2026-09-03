//
//  MatchDetailViewModel.swift
//  liga1
//

import Foundation
import Combine

struct MatchDetailContext {
    let jornadaId: String
    let jornadaNumero: Int
    let torneo: String
    let match: MatchUI
}

struct MatchDetailStatRow: Equatable {
    let title: String
    let localDisplay: String
    let visitanteDisplay: String
    /// Magnitud numérica para la barra comparativa (local vs visitante).
    let localMagnitude: Double
    let visitanteMagnitude: Double
    /// Línea secundaria bajo el valor (ej. pases 231/275).
    let localSubtitle: String?
    let visitanteSubtitle: String?

    init(
        title: String,
        localDisplay: String,
        visitanteDisplay: String,
        localMagnitude: Double,
        visitanteMagnitude: Double,
        localSubtitle: String? = nil,
        visitanteSubtitle: String? = nil
    ) {
        self.title = title
        self.localDisplay = localDisplay
        self.visitanteDisplay = visitanteDisplay
        self.localMagnitude = localMagnitude
        self.visitanteMagnitude = visitanteMagnitude
        self.localSubtitle = localSubtitle
        self.visitanteSubtitle = visitanteSubtitle
    }

    init(title: String, local: Int, visitante: Int) {
        self.init(
            title: title,
            localDisplay: "\(local)",
            visitanteDisplay: "\(visitante)",
            localMagnitude: Double(local),
            visitanteMagnitude: Double(visitante),
            localSubtitle: nil,
            visitanteSubtitle: nil
        )
    }

    init(title: String, local: Double, visitante: Double, localDisplay: String, visitanteDisplay: String) {
        self.init(
            title: title,
            localDisplay: localDisplay,
            visitanteDisplay: visitanteDisplay,
            localMagnitude: local,
            visitanteMagnitude: visitante,
            localSubtitle: nil,
            visitanteSubtitle: nil
        )
    }

    /// Goles esperados con formato local (coma decimal, 2 cifras como en vivo).
    static func expectedGoalsRow(local: Double, visitante: Double) -> MatchDetailStatRow {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "es_PE")
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        let ls = nf.string(from: NSNumber(value: local)) ?? String(format: "%.2f", local)
        let vs = nf.string(from: NSNumber(value: visitante)) ?? String(format: "%.2f", visitante)
        return MatchDetailStatRow(
            title: "Goles esperados (xG)",
            local: local,
            visitante: visitante,
            localDisplay: ls,
            visitanteDisplay: vs
        )
    }

    /// Pases: porcentaje principal y fracción completados/intentos debajo.
    static func passesRow(
        localPct: Int,
        localCompleted: Int,
        localAttempts: Int,
        visitPct: Int,
        visitCompleted: Int,
        visitAttempts: Int
    ) -> MatchDetailStatRow {
        MatchDetailStatRow(
            title: "Pases",
            localDisplay: "\(localPct)%",
            visitanteDisplay: "\(visitPct)%",
            localMagnitude: Double(localPct),
            visitanteMagnitude: Double(visitPct),
            localSubtitle: "\(localCompleted)/\(localAttempts)",
            visitanteSubtitle: "\(visitCompleted)/\(visitAttempts)"
        )
    }
}

final class MatchDetailViewModel {

    // MARK: - Published Properties

    /// Estadio local del partido (Sabor Local). `nil` hasta que carga o si no está catalogado.
    @Published private(set) var stadium: Stadium?
    /// Ficha del árbitro designado (Termómetro Arbitral). `nil` si no está catalogado.
    @Published private(set) var referee: RefereeProfile?
    /// Clima estimado de la sede (Sabor Local). `nil` hasta que carga o si el Admin no lo generó.
    @Published private(set) var weather: MatchWeather?

    // MARK: - Termómetro Arbitral (encuesta en vivo)

    /// Encuesta arbitral abierta del partido. `nil` si no hay ninguna.
    @Published private(set) var refereePoll: RefereePoll?
    /// Conteo por opción (suma de shards), en vivo.
    @Published private(set) var pollTally: [String: Int] = [:]
    /// Opción que votó el usuario; se siembra de Firestore y se fija tras votar.
    @Published private(set) var myPollVote: String?
    @Published private(set) var pollVoteInFlight = false
    @Published private(set) var pollVoteError: String?

    // MARK: - Dependencies

    let context: MatchDetailContext
    private let getStadiumUseCase: GetStadiumForTeamUseCaseProtocol
    private let getRefereeProfileUseCase: GetRefereeProfileUseCaseProtocol
    private let getMatchWeatherUseCase: GetMatchWeatherUseCaseProtocol
    private let observeRefereePollUseCase: ObserveRefereePollUseCaseProtocol
    private let observePollResultUseCase: ObservePollResultUseCaseProtocol
    private let submitRefereePollVoteUseCase: SubmitRefereePollVoteUseCaseProtocol
    /// Suscripción al resultado; se reemplaza cuando cambia la encuesta activa.
    private var pollResultCancellable: AnyCancellable?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        context: MatchDetailContext,
        getStadiumUseCase: GetStadiumForTeamUseCaseProtocol,
        getRefereeProfileUseCase: GetRefereeProfileUseCaseProtocol,
        getMatchWeatherUseCase: GetMatchWeatherUseCaseProtocol,
        observeRefereePollUseCase: ObserveRefereePollUseCaseProtocol,
        observePollResultUseCase: ObservePollResultUseCaseProtocol,
        submitRefereePollVoteUseCase: SubmitRefereePollVoteUseCaseProtocol
    ) {
        self.context = context
        self.getStadiumUseCase = getStadiumUseCase
        self.getRefereeProfileUseCase = getRefereeProfileUseCase
        self.getMatchWeatherUseCase = getMatchWeatherUseCase
        self.observeRefereePollUseCase = observeRefereePollUseCase
        self.observePollResultUseCase = observePollResultUseCase
        self.submitRefereePollVoteUseCase = submitRefereePollVoteUseCase
    }

    private var match: MatchUI { context.match }

    // MARK: - Public Methods

    /// Carga los datos remotos de "Sabor Local" (estadio + árbitro). Idempotente.
    func load() {
        if stadium == nil, let localId = match.equipoLocalId, !localId.isEmpty {
            getStadiumUseCase.execute(homeTeamCode: localId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in self?.stadium = $0 })
                .store(in: &cancellables)
        }
        if referee == nil, let name = arbitroSiExiste {
            getRefereeProfileUseCase.execute(refereeName: name)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in self?.referee = $0 })
                .store(in: &cancellables)
        }
        if weather == nil {
            getMatchWeatherUseCase.execute(jornadaId: context.jornadaId, matchId: match.id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in self?.weather = $0 })
                .store(in: &cancellables)
        }

        observeRefereePollUseCase.execute(matchId: match.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in self?.handleRefereePoll($0) })
            .store(in: &cancellables)
    }

    // MARK: - Termómetro Arbitral

    private func handleRefereePoll(_ poll: RefereePoll?) {
        let changed = poll?.id != refereePoll?.id
        refereePoll = poll

        guard let poll else {
            pollResultCancellable = nil
            pollTally = [:]
            myPollVote = nil
            return
        }

        guard changed else { return }
        pollTally = [:]
        myPollVote = nil
        pollVoteError = nil
        pollResultCancellable = observePollResultUseCase.execute(pollId: poll.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] result in
                guard let self else { return }
                self.pollTally = result.tally
                if self.myPollVote == nil, let seeded = result.myVote {
                    self.myPollVote = seeded
                }
            })
    }

    /// Registra el voto del usuario en la encuesta activa.
    func voteRefereePoll(optionId: String) {
        guard let poll = refereePoll, puedeVotarRefereePoll else { return }
        pollVoteInFlight = true
        pollVoteError = nil
        submitRefereePollVoteUseCase.execute(poll: poll, optionId: optionId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.pollVoteInFlight = false
                if case .failure(let error) = completion {
                    self?.pollVoteError = error.localizedDescription
                }
            }, receiveValue: { [weak self] votedOption in
                self?.myPollVote = votedOption
            })
            .store(in: &cancellables)
    }

    var refereePollDisponible: Bool { refereePoll != nil }
    var refereePollPregunta: String? { refereePoll?.pregunta }
    var refereePollAbierta: Bool { refereePoll?.isOpen() ?? false }
    var refereePollYaVote: Bool { myPollVote != nil }
    var puedeVotarRefereePoll: Bool {
        refereePollAbierta && !refereePollYaVote && !pollVoteInFlight
    }

    var refereePollTotalDisplay: String {
        let total = pollTally.values.reduce(0, +)
        return total == 1 ? "1 voto" : "\(total) votos"
    }

    var refereePollEstadoDisplay: String {
        refereePollAbierta ? "En vivo" : "Cerrada"
    }

    struct RefereePollOptionVM: Equatable {
        let id: String
        let texto: String
        let votos: Int
        let porcentaje: Int
        let esMiVoto: Bool
    }

    var refereePollOpciones: [RefereePollOptionVM] {
        guard let poll = refereePoll else { return [] }
        let result = PollResult(tally: pollTally, myVote: myPollVote)
        return poll.opciones.map { opt in
            RefereePollOptionVM(
                id: opt.id,
                texto: opt.texto,
                votos: result.votos(for: opt.id),
                porcentaje: result.percent(for: opt.id),
                esMiVoto: myPollVote == opt.id
            )
        }
    }

    var competitionLine: String {
        let torneo = context.torneo.capitalized
        return "PERÚ · LIGA 1 · \(torneo) · JORNADA \(context.jornadaNumero)"
    }

    var localTeamName: String {
        EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoLocalId ?? "")
    }

    var visitTeamName: String {
        EquipoPeruano.obtenerNombreCompleto(paraId: match.equipoVisitanteId ?? "")
    }

    var scoreDisplay: String {
        switch match.estado {
        case .pendiente:
            return "—  :  —"
        default:
            return "\(match.golesEquipoLocal) - \(match.golesEquipoVisitante)"
        }
    }

    var dateTimeLine: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_PE")
        df.dateFormat = "dd.MM.yyyy  hh:mm a"
        return df.string(from: match.fecha)
    }

    var statusLine: String {
        if match.suspendido { return "Suspendido" }
        return match.estadoTexto
    }

    /// Lista completa tipo “estadísticas principales” (dummy, alineada a referencia visual).
    private var estadisticasTabFullDummy: [MatchDetailStatRow] {
        [
            .expectedGoalsRow(local: 0.13, visitante: 0.71),
            MatchDetailStatRow(
                title: "Posesión",
                localDisplay: "53%",
                visitanteDisplay: "47%",
                localMagnitude: 53,
                visitanteMagnitude: 47
            ),
            MatchDetailStatRow(title: "Remates totales", local: 3, visitante: 7),
            MatchDetailStatRow(title: "Remates a puerta", local: 0, visitante: 3),
            MatchDetailStatRow(title: "Grandes ocasiones", local: 0, visitante: 1),
            MatchDetailStatRow(title: "Córneres", local: 1, visitante: 0),
            .passesRow(
                localPct: 84,
                localCompleted: 231,
                localAttempts: 275,
                visitPct: 78,
                visitCompleted: 197,
                visitAttempts: 251
            ),
            MatchDetailStatRow(title: "Tarjetas amarillas", local: 0, visitante: 1),
            MatchDetailStatRow(title: "Tarjetas rojas", local: 1, visitante: 0)
        ]
    }

    /// En Resumen solo las tres primeras métricas (mismos valores que abren la pestaña).
    var resumenStatRows: [MatchDetailStatRow] {
        Array(estadisticasTabFullDummy.prefix(3))
    }

    var estadisticasTabRows: [MatchDetailStatRow] { estadisticasTabFullDummy }

    /// Canal de transmisión fijo para todos los partidos (Liga 1).
    var tvChannels: [String] { ["L1 Max"] }

    func displayOrConfirm(_ value: String?) -> String {
        guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else {
            return "Por confirmar"
        }
        return v
    }

    /// Nombre a mostrar si el documento trae dato; `nil` en jornadas sin campo o vacío.
    var arbitroSiExiste: String? {
        guard let a = match.arbitro else { return nil }
        let t = a.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    var arbitroDisplay: String { displayOrConfirm(match.arbitro) }

    /// Prioridad: dato del partido (Firestore) → catálogo `stadiums` → catálogo local bundled.
    var estadioDisplay: String {
        if let s = nonEmptyString(match.estadio) { return s }
        if let s = nonEmptyString(stadium?.name) { return s }
        if let s = TeamVenueCatalog.info(forLocalTeamId: match.equipoLocalId)?.estadio { return s }
        return "Por confirmar"
    }

    var capacidadDisplay: String {
        if let s = nonEmptyString(match.capacidad) { return s }
        if let cap = stadium?.capacity, cap > 0 { return Self.milesFormatter.string(from: NSNumber(value: cap)) ?? "\(cap)" }
        if let s = TeamVenueCatalog.info(forLocalTeamId: match.equipoLocalId)?.capacidadTexto { return s }
        return "Por confirmar"
    }

    private func nonEmptyString(_ value: String?) -> String? {
        guard let t = value?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }

    // MARK: - Sabor Local (estadio: altura / geografía / dato histórico)

    private static let milesFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "es_PE")
        return nf
    }()

    /// Hay estadio catalogado con datos geográficos que mostrar.
    var saborLocalDisponible: Bool { (stadium?.altitudeMsnm ?? 0) > 0 }

    var ciudadDisplay: String? {
        guard let s = stadium else { return nil }
        let region = s.region.isEmpty || s.region == s.city ? "" : ", \(s.region)"
        let ciudad = s.city.isEmpty ? "" : "\(s.city)\(region)"
        return ciudad.isEmpty ? nil : ciudad
    }

    var altitudDisplay: String? {
        guard let msnm = stadium?.altitudeMsnm, msnm > 0 else { return nil }
        let n = Self.milesFormatter.string(from: NSNumber(value: msnm)) ?? "\(msnm)"
        return "\(n) msnm"
    }

    var esDeAltura: Bool { stadium?.esDeAltura ?? false }

    /// Etiqueta corta del factor geográfico para el partido.
    var factorGeograficoDisplay: String? {
        guard let s = stadium, s.altitudeMsnm > 0 else { return nil }
        if s.altitudeMsnm >= 3000 { return "Altura extrema" }
        if s.esDeAltura { return "Factor altura" }
        if s.altitudeMsnm <= 200 { return "Nivel del mar" }
        return "Media altura"
    }

    var datoHistorico: String? {
        guard let d = stadium?.dato?.trimmingCharacters(in: .whitespacesAndNewlines), !d.isEmpty else { return nil }
        return d
    }

    // MARK: - Termómetro Arbitral

    /// Hay ficha ampliada del árbitro (más allá del nombre).
    var refereeFichaDisponible: Bool { referee != nil }

    var refereeNombreDisplay: String? {
        referee?.fullName ?? arbitroSiExiste
    }

    var refereeNacionalidadDisplay: String? {
        guard let n = referee?.nationality, !n.isEmpty else { return nil }
        return n
    }

    var refereePenalesPorPartidoDisplay: String? {
        guard let c = referee?.career, c.matches > 0 else { return nil }
        return String(format: "%.2f", c.penaltiesPerGame)
    }

    var refereeTarjetasPorPartidoDisplay: String? {
        guard let c = referee?.career, c.matches > 0 else { return nil }
        return String(format: "%.1f amarillas · %.2f rojas", c.yellowPerGame, c.redPerGame)
    }

    // MARK: - Sabor Local (clima de la sede)

    /// Hay clima estimado que mostrar.
    var climaDisponible: Bool { weather != nil }

    /// SF Symbol para el ícono del clima.
    var climaIconoSF: String? { weather?.symbol }

    /// Titular corto: "Nublado · 18°".
    var climaResumenDisplay: String? {
        guard let w = weather else { return nil }
        return "\(w.condition.displayName) · \(w.roundedTemperature)°"
    }

    /// Sensación térmica solo cuando difiere de la temperatura real ("15°C").
    var climaSensacionDisplay: String? {
        guard let w = weather, w.sensationDiffers else { return nil }
        return "\(Int(w.feelsLikeC.rounded()))°C"
    }

    var climaVientoDisplay: String? {
        guard let w = weather else { return nil }
        return "\(Int(w.windKmh.rounded())) km/h"
    }

    var climaHumedadDisplay: String? {
        guard let w = weather else { return nil }
        return "\(w.humidityPct)%"
    }

    /// Solo aporta si hay probabilidad apreciable de lluvia.
    var climaPrecipitacionDisplay: String? {
        guard let w = weather, w.precipitationProbPct >= 10 else { return nil }
        return "\(w.precipitationProbPct)%"
    }

    /// "actualizado hoy 14:30" — contexto de frescura del dato.
    var climaActualizadoDisplay: String? {
        guard let date = weather?.updatedAt else { return nil }
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_PE")
        df.doesRelativeDateFormatting = true
        df.dateStyle = .short
        df.timeStyle = .short
        return "actualizado \(df.string(from: date))"
    }

    var shareText: String {
        "\(localTeamName) vs \(visitTeamName) · \(scoreDisplay) · \(dateTimeLine)"
    }

    // MARK: - Alineaciones (dummy; `FootballFormation` admite 4-4-2, 3-5-2, etc.)

    var lineupTabModel: MatchLineupTabModel {
        let visitFormation = FootballFormation.parseCode("3-4-2-1")!
        let localFormation = FootballFormation.parseCode("4-2-3-1")!

        let visitPlayers: [LineupPlayerUIData] = [
            LineupPlayerUIData(number: 1, shortName: "Duarte", rating: 6.2),
            LineupPlayerUIData(number: 2, shortName: "Ibarra", rating: 6.4),
            LineupPlayerUIData(number: 4, shortName: "Rodríguez", rating: 6.5),
            LineupPlayerUIData(number: 15, shortName: "Soto", rating: 6.1),
            LineupPlayerUIData(number: 8, shortName: "Fernández", rating: 6.6),
            LineupPlayerUIData(number: 16, shortName: "Castro", rating: 6.3),
            LineupPlayerUIData(number: 21, shortName: "Vera", rating: 6.7),
            LineupPlayerUIData(number: 11, shortName: "López", rating: 7.0),
            LineupPlayerUIData(number: 10, shortName: "Ramírez", rating: 6.8),
            LineupPlayerUIData(number: 7, shortName: "Díaz", rating: 7.1),
            LineupPlayerUIData(number: 9, shortName: "Giménez", rating: 7.2, scoredGoal: true)
        ]

        let localPlayers: [LineupPlayerUIData] = [
            LineupPlayerUIData(number: 12, shortName: "García", rating: 6.5),
            LineupPlayerUIData(number: 3, shortName: "Paredes", rating: 6.4),
            LineupPlayerUIData(number: 5, shortName: "Mendoza", rating: 6.6),
            LineupPlayerUIData(number: 6, shortName: "Torres", rating: 6.2),
            LineupPlayerUIData(number: 14, shortName: "Ríos", rating: 6.3),
            LineupPlayerUIData(number: 18, shortName: "Salas", rating: 6.7),
            LineupPlayerUIData(number: 19, shortName: "Flores", rating: 6.5),
            LineupPlayerUIData(number: 22, shortName: "Hurtado", rating: 6.8),
            LineupPlayerUIData(number: 17, shortName: "Cruz", rating: 7.0),
            LineupPlayerUIData(number: 20, shortName: "Peña", rating: 6.9),
            LineupPlayerUIData(number: 11, shortName: "Reyna", rating: 6.6)
        ]

        return MatchLineupTabModel(
            visitTop: TeamLineupSideModel(
                teamName: visitTeamName,
                formation: visitFormation,
                players: visitPlayers,
                averageRating: 6.4
            )!,
            localBottom: TeamLineupSideModel(
                teamName: localTeamName,
                formation: localFormation,
                players: localPlayers,
                averageRating: 6.7
            )!
        )
    }
}

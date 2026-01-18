//
//  NewsViewModel.swift
//  liga1
//
//  Created by miguel tomairo on 01/01/26.
//  Refactored on 03/01/26.
//

import Foundation
import Combine

class NewsViewModel {

    // MARK: - Published Properties

    @Published private(set) var featuredNews: [NewsItem] = []
    @Published private(set) var groupedNews: [NewsCategory: [NewsItem]] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    // MARK: - Dependencies

    private let fetchNewsUseCase: FetchNewsUseCaseProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(fetchNewsUseCase: FetchNewsUseCaseProtocol) {
        self.fetchNewsUseCase = fetchNewsUseCase
    }

    // MARK: - Public Methods

    func fetchNews() {
        isLoading = true
        error = nil

        fetchNewsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    Logger.shared.error("Failed to fetch news", error: error)
                    self?.error = error
                }
            } receiveValue: { [weak self] newsItems in
                guard let self = self else { return }
                
                // Ordenar todas las noticias por fecha descendente (más reciente primero)
                // Esto asegura que las noticias más frescas aparezcan de arriba hacia abajo
                let sortedNewsItems = newsItems.sorted { $0.publishedDate > $1.publishedDate }
                
                // Filtrar noticias destacadas (ya están ordenadas por fecha descendente)
                self.featuredNews = sortedNewsItems.filter { $0.featured }
                
                // Filtrar noticias regulares y agrupar por categoría
                let regularNews = sortedNewsItems.filter { !$0.featured }
                
                // Agrupar por categoría (cada grupo ya está ordenado por fecha descendente)
                let grouped = Dictionary(grouping: regularNews, by: { $0.category })
                self.groupedNews = grouped
            }
            .store(in: &cancellables)
    }
}

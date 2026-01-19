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

    @Published private(set) var groupedNews: [NewsCategory: [NewsItem]] = [:]
    @Published private(set) var sortedCategories: [NewsCategory] = []
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
                
                // Agrupar todas las noticias por categoría (incluye destacadas y normales)
                let grouped = Dictionary(grouping: newsItems, by: { $0.category })
                
                // Para cada categoría, ordenar noticias: primero destacadas, luego normales
                // Ambas sub-listas ordenadas por fecha descendente (más reciente primero)
                var organizedGroupedNews: [NewsCategory: [NewsItem]] = [:]
                
                for (category, categoryNews) in grouped {
                    // Separar destacadas y normales
                    let featuredNews = categoryNews.filter { $0.featured }
                        .sorted { $0.publishedDate > $1.publishedDate }
                    let regularNews = categoryNews.filter { !$0.featured }
                        .sorted { $0.publishedDate > $1.publishedDate }
                    
                    // Combinar: primero destacadas, luego normales
                    organizedGroupedNews[category] = featuredNews + regularNews
                }
                
                self.groupedNews = organizedGroupedNews
                
                // Ordenar categorías por fecha de noticia destacada más reciente
                // Si una categoría no tiene destacadas, usar la fecha de su noticia normal más reciente
                self.sortedCategories = organizedGroupedNews.keys.sorted { category1, category2 in
                    let news1 = organizedGroupedNews[category1] ?? []
                    let news2 = organizedGroupedNews[category2] ?? []
                    
                    // Obtener la fecha de la noticia destacada más reciente, o si no hay destacada, la normal más reciente
                    let featuredNews1 = news1.filter { $0.featured }
                    let featuredNews2 = news2.filter { $0.featured }
                    
                    let date1 = featuredNews1.first?.publishedDate ?? news1.first?.publishedDate ?? Date.distantPast
                    let date2 = featuredNews2.first?.publishedDate ?? news2.first?.publishedDate ?? Date.distantPast
                    
                    // Ordenar por fecha descendente (más reciente primero)
                    return date1 > date2
                }
            }
            .store(in: &cancellables)
    }
}

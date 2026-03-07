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

    @Published private(set) var groupedNews: [NewsCategory: [NewsItemUI]] = [:]
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
                    self?.error = error
                }
            } receiveValue: { [weak self] newsItems in
                guard let self = self else { return }
                let newsItemsUI = NewsItemUIMapper.toUI(from: newsItems)
                let grouped = Dictionary(grouping: newsItemsUI, by: { $0.category })
                var organizedGroupedNews: [NewsCategory: [NewsItemUI]] = [:]
                for (category, categoryNews) in grouped {
                    let sortedNews = categoryNews.sorted { $0.publishedDate > $1.publishedDate }
                    organizedGroupedNews[category] = sortedNews
                }
                self.groupedNews = organizedGroupedNews
                // Destacado siempre primero; el resto ordenado por fecha (más reciente primero)
                self.sortedCategories = organizedGroupedNews.keys.sorted { category1, category2 in
                    if category1 == .destacado { return true }
                    if category2 == .destacado { return false }
                    let news1 = organizedGroupedNews[category1] ?? []
                    let news2 = organizedGroupedNews[category2] ?? []
                    let date1 = news1.first?.publishedDate ?? Date.distantPast
                    let date2 = news2.first?.publishedDate ?? Date.distantPast
                    return date1 > date2
                }
            }
            .store(in: &cancellables)
    }
}

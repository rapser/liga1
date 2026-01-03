//
//  NewsViewModel.swift
//  liga1
//
//  Created by Claude Code on 01/01/26.
//

import Foundation
import Combine

class NewsViewModel {

    // MARK: - Published Properties

    @Published private(set) var featuredNews: [NewsItem] = []
    @Published private(set) var groupedNews: [String: [NewsItem]] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    // MARK: - Dependencies

    private let newsRepository: NewsRepositoryProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(newsRepository: NewsRepositoryProtocol = NewsRepository()) {
        self.newsRepository = newsRepository
    }

    // MARK: - Public Methods

    func fetchNews() {
        isLoading = true
        error = nil

        newsRepository.fetchNews()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] newsItems in
                guard let self = self else { return }
                self.featuredNews = newsItems.filter { $0.destacada }
                let regularNews = newsItems.filter { !$0.destacada }
                self.groupedNews = Dictionary(grouping: regularNews, by: { $0.categoria })
            }
            .store(in: &cancellables)
    }
}

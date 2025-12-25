//
//  NewsViewController.swift
//  liga1
//
//  Created by miguel tomairo on 13/09/25.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class NewsViewController: UIViewController {

    private var news: [NewsItem] = []
    var featuredNews: [NewsItem] = []
    var groupedNews: [String: [NewsItem]] = [:]

    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Noticias"

        setupTableView()
        fetchNews()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(NewsCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.register(FeaturedNewsContentCell.self, forCellReuseIdentifier: FeaturedNewsContentCell.reuseIdentifier)
        tableView.register(FeaturedNewsTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: FeaturedNewsTitleHeaderView.reuseIdentifier)
        tableView.register(CategoryHeaderView.self, forHeaderFooterViewReuseIdentifier: CategoryHeaderView.reuseIdentifier)
        tableView.estimatedSectionHeaderHeight = 40
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    private func fetchNews() {
        let db = Firestore.firestore()
        db.collection("news").order(by: "fecha", descending: true).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let snapshot = snapshot {
                let items = snapshot.documents.compactMap { NewsItem(from: $0.data()) }
                self.featuredNews = items.filter { $0.destacada }
                self.news = items.filter { !$0.destacada }
                self.groupNews()
                self.tableView.reloadData()
            }
        }
    }

    private func groupNews() {
        groupedNews = Dictionary(grouping: news, by: { $0.categoria })
    }
}

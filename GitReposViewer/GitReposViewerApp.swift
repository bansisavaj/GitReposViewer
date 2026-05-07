//
//  GitReposViewerApp.swift
//  GitReposViewer
//
//  Created by bansi savaj on 04/05/26.
//

import SwiftUI

@main
struct GitReposViewerApp: App {

    let repoService = RepositoryRequest()
    let languageService = LanguageRequest()

    @StateObject private var favoritesManager = FavoritesManager()
    let rateLimiter = RateLimitHandler.shared

    var body: some Scene {
        WindowGroup {
            RepoListView(
                repoService: repoService,
                favoritesManager: favoritesManager,
                rateLimiter: rateLimiter,
                languageService: languageService
            )
        }
    }
}

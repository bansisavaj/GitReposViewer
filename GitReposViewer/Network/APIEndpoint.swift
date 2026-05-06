import Foundation

let authToken: String? = nil //"<YOUR_TOKEN_HERE>"

enum APIEndpoint {

    case repositories(page: String?)
    case languages(url: String)

    var url: URL? {

        switch self {

            case .repositories(let page):
                let base = "https://api.github.com/repositories"
                return URL(string: page ?? base)

            case .languages(let url):
                return URL(string: url)
        }
    }
}

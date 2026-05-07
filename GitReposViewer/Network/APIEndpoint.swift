import Foundation

let authToken: String? = nil //"<YOUR_TOKEN_HERE>"

enum APIEndpoint {

    case repositories
    case details(owner: String, repo: String)

    var path: String {
        switch self {

            case .repositories:
                return "/repositories"

            case .details(let owner, let repo):
                return "/repos/\(owner)/\(repo)"

        }
    }

    var url: URL {
        URL(string: APIConstants.baseURL + path)!
    }
}

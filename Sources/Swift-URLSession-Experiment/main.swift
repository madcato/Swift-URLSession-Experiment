import Foundation

let sem = DispatchSemaphore(value: 0)

enum Http {

enum Result<Response> {
    case success(Response)
    case error(Int, String)
}

enum Method {
    case get
    case post
    case put
    case patch
    case delete
}

// MARK: - Http Endpoint

typealias Parameters = [String: Any]
typealias Path = String

final class Endpoint<Response> {
    let method: Method
    let path: Path
    let parameters: Parameters?
    let decode: (Data) throws -> Response

    init(method: Method,
         path: Path,
         parameters: Parameters? = nil,
         decode: @escaping (Data) throws -> Response) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.decode = decode
    }
}

}  // Http

// MARK: - Endpoint extensions

extension Http.Endpoint where Response: Swift.Decodable {
    convenience init(method: Http.Method,
                     path: Http.Path,
                     parameters: Http.Parameters? = nil) {
        self.init(method: method, path: path, parameters: parameters) {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"  // Rails default format
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            return try decoder.decode(Response.self, from: $0)
        }
    }
}

extension Http.Endpoint where Response == Void {
    convenience init(method: Http.Method,
                     path: Http.Path,
                     parameters: Http.Parameters? = nil) {
        self.init(
            method: method,
            path: path,
            parameters: parameters) { _ in () }
    }
}

extension Http {
class Client {
    private let session: URLSession!
    private let baseURL: URL!
    private let queue = DispatchQueue(label: "ClientHttpQueue")
    private var dataTask: URLSessionDataTask?

    init(baseURL: String, basePath: String, defaultHeaders: [AnyHashable: Any]? = nil) {
        guard let url = URL(string: baseURL)?.appendingPathComponent(basePath) else {
            fatalError("Invalid url or base path: \(baseURL) - \(basePath)")
        }
        self.baseURL = url
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        self.session = URLSession(configuration: configuration)
    }

    /// request data. This is a GET HTTPrequest
    /// - param endpoint: url of the endpoint and the type of the response.
    ///               The response will be decoded to this format
    /// - param completion: this block will be called at the end of the processing, with the resul or the error
    ///
    func request<Response>(_ endpoint: Http.Endpoint<Response>,
                           completion: @escaping (Http.Result<Response>) -> Void) {
        guard dataTask == nil else {
            fatalError("Trying to launch a data task before finising previous.")
        }
        guard endpoint.method == .get else {
            fatalError("This method only handle GET")
        }
        let url = url(path: endpoint.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let parameters: [String: String?] = endpoint.parameters as? [String: String?] {
            components?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        if let finalQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B") {
            components?.percentEncodedQuery = finalQuery
        }
        let urlRequest = URLRequest(url: components?.url ?? url)
        dataTask = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            if let error = error {
                let httpResponse = response as? HTTPURLResponse
                // DispatchQueue.main.async {
                completion(Http.Result.error(httpResponse?.statusCode ?? 0, error.localizedDescription))
                // }
            } else if let data = data,
                      let response = response as? HTTPURLResponse,
                      (response.statusCode >= 200 && response.statusCode < 300) {
                do {
                    let responseData = try endpoint.decode(data)
                    // DispatchQueue.main.async {
                    completion(Http.Result.success(responseData))
                    // }
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            } else {
                fatalError("Invalid status code")
            }
        }
        dataTask?.resume()
    }

    private func url(path: Http.Path) -> URL {
        baseURL.appendingPathComponent(path)
    }
}
}

enum SwiftRoRAPI {
static func todos() -> Http.Endpoint<[SwiftRoR.TodoDto]> {
    Http.Endpoint(
        method: .get,
        path: "/todos.json"
    )
}
}  // SwiftRoRAPI

enum SwiftRoR {
struct TodoDto: Decodable {
    let title: String
    let created_by: String
    let created_at: Date
    let updated_at: Date?
}
}  // SwiftRoR

class SwiftRoRService {
    private var swiftAPIClient = Http.Client(baseURL: "http://localhost:3000",
                                             basePath: "",
                                             defaultHeaders: ["Accept": "application/json"])

    func listTodos(_ onFinish: @escaping (Http.Result<[SwiftRoR.TodoDto]>) -> Void) {
        swiftAPIClient.request(SwiftRoRAPI.todos()) { result in
            defer { sem.signal() }
            onFinish(result)
        }
    }
}

SwiftRoRService().listTodos { result in
    switch result {
    case let .success(response):
        // onFinish(Http.Result.success(array))
        print("Received: \(response)")
    case let .error(id, description):
        // onFinish(Http.Result<[SwiftRoR.TodoDto]>.error(id, description))
        print("Error: \(description)")
    }
    print("fin")
}

sem.wait()

import Foundation

enum APIClient {
    static let baseURL = "https://api.juicevault.xyz"

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    static func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue("JuiceVault-iOS/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 60
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(T.self, from: data)
    }

    static func fetchSongs(_ path: String) async throws -> [Song] {
        let res: SongListResponse = try await get(path)
        return res.songs
    }

    static func search(_ query: String) async throws -> [Song] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let res: SearchResponse = try await get("/music/search?q=\(encoded)")
        return res.results
    }

    static func stats() async throws -> StatsResponse {
        try await get("/stats")
    }

    static func radioNowPlaying() async throws -> RadioCurrent? {
        let res: RadioNowPlaying = try await get("/radio/now-playing")
        return res.data?.current
    }
}

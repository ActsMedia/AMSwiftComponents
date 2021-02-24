//
//  MultipartNetworkingProvider.swift
//  
//
//  Created by PJ Fechner on 2/22/21.
//

import Foundation
import Connectivity

public protocol MultipartNetworkingProvider: NetworkingProvider {
    var boundary: String { get }
    var components: [MultipartComponent] { get }
    var defaultHeaders: [String:String] { get }

    func makeMultipartData() -> Data
}

public struct MultipartComponent {
    public let contentDisposition: String
    public let name: String
    public let fileName: String
    public let contentType: String
    public let dataSource: DataSource

    public init(contentDisposition: String, name: String, fileName: String, contentType: String, dataSource: DataSource) {
        self.contentDisposition = contentDisposition
        self.name = name
        self.fileName = fileName
        self.contentType = contentType
        self.dataSource = dataSource
    }

    public enum DataSource {
        case url(URL)
        case data(Data)

        func makeData() -> Data? {
            switch self {
            case .data(let data): return data
            case .url(let url):
                do {
                    return try Data(contentsOf: url)
                } catch {
                    print(error)
                    return nil
                }
            }
        }
    }
}

public extension MultipartNetworkingProvider {

    var defaultHeaders: [String : String] {
        [
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
    }

    func enqueueRequest<Response>(_ request: URLRequest, decoder: JSONDecoder, completion: @escaping (Result<Response, Error>) -> ()) where Response : Decodable {

        var mutableRequest = request
        defaultHeaders.forEach {
            mutableRequest.addValue($1, forHTTPHeaderField: $0)
        }

        checkConnection { (isConnected) in
            guard isConnected else {
                completion(.failure(NetworkError.notConnected))
                return
            }
            self.startUploadTask(mutableRequest, data: self.makeMultipartData(), decoder: decoder, completion: completion)
        }
    }

    func makeMultipartData() -> Data {
        var data = Data()

        components.forEach {
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)


            data.append("Content-Disposition: \($0.contentDisposition); name=\"\($0.name)\"; filename=\"\($0.fileName)\"; ".data(using: .utf8)!)
            data.append("Content-Type: \"\($0.contentType)\"\r\n\r\n".data(using: .utf8)!)

            print(String(data: data, encoding: .utf8)!)
            $0.dataSource.makeData().map { data.append($0) }

            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        }
        return data
    }
}


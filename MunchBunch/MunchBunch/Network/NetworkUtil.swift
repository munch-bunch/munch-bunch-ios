//
//  NetworkUtil.swift
//  MunchBunch
//
//  Created by Kevin Nguyen on 2/23/18.
//  Copyright © 2018 munch-bunch-app. All rights reserved.
//

import Foundation
import Alamofire
import Moya

enum Service {
    // Auth endpoints
    case authenticate(username: String, password: String)
    case register(username: String, hashed_password: String,
        first_name: String, last_name: String, email: String)
    
    // Bookmark endpoints
    case getAllBookmarks(id: Int)
    case addBookmark(userId: Int, truckId: Int)
    case deleteBookmark(userId: Int, truckId: Int)
    
    // Truck endpoints
    case getAllTrucks
    case getTruck(id: Int)
    
    // User endpoints
    case getAllUsers
    case getUser(id: Int)
    case deleteUser(id: Int)
}

extension Service: TargetType {
    var baseURL: URL { return URL(string: SERVER_URL)! }
    
    var path: String {
        switch self {
        case .authenticate:
            return AUTHENTICATE
        case .register:
            return REGISTER
        case .getAllBookmarks(let id):
            return "\(BOOKMARKS)/\(id)"
        case .addBookmark, .deleteBookmark:
            return BOOKMARKS
        case .getAllTrucks:
            return TRUCKS
        case .getTruck(let id):
            return "\(TRUCKS)/\(id)"
        case .getAllUsers:
            return USERS
        case .getUser(let id), .deleteUser(let id):
            return "\(USERS)/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .authenticate, .register, .addBookmark:
            return .post
        case .getAllBookmarks, .getAllTrucks, .getAllUsers, .getTruck, .getUser:
            return .get
        case .deleteBookmark, .deleteUser:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .authenticate(let username, let password):
            return .requestParameters(parameters: ["username": username,
                "password": password], encoding: JSONEncoding.default)
            
        case .register(let username, let hashed_password, let first_name, let last_name, let email):
            return .requestParameters(parameters: ["username": username,
                "hashed_password": hashed_password, "first_name": first_name,
                "last_name": last_name, "email": email], encoding: JSONEncoding.default)
        
        case .addBookmark(let userId, let truckId):
            return .requestParameters(parameters: ["user_id": userId,
                "truck_id": truckId], encoding: JSONEncoding.default)
            
        case .deleteBookmark(let userId, let truckId):
            return .requestParameters(parameters: ["user_id": userId,
                "truck_id": truckId], encoding: JSONEncoding.default)
            
        case .getAllBookmarks, .getAllTrucks, .getTruck, .getAllUsers, .getUser, .deleteUser:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        switch self {
        case .authenticate(_, _):
            return AUTHENTICATE_SAMPLE.utf8Encoded
        case .register(_, _, _, _, _):
            return REGISTER_SAMPLE.utf8Encoded
        case .getAllBookmarks(_):
            return GET_ALL_BOOKMARKS_SAMPLE.utf8Encoded
        case .addBookmark(_, _):
            return ADD_BOOKMARK_SAMPLE.utf8Encoded
        case .deleteBookmark(_, _):
            return DELETE_BOOKMARK_SAMPLE.utf8Encoded
        case .getAllTrucks:
            return GET_ALL_TRUCKS_SAMPLE.utf8Encoded
        case .getTruck(_):
            return GET_TRUCK_SAMPLE.utf8Encoded
        case .getAllUsers:
            return GET_ALL_USERS_SAMPLE.utf8Encoded
        case .getUser(_):
            return GET_USER_SAMPLE.utf8Encoded
        case .deleteUser(_):
            return DELETE_USER_SAMPLE.utf8Encoded
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

// MARK: Plugin for adding auth header with JWT
// USAGE: let provider = MoyaProvider<Target>(plugins: [AuthPlugin(token: "eyeAm.AJsoN.weBTOKen")])
struct AuthPlugin: PluginType {
    let token: String
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue(token, forHTTPHeaderField: "x-access-token")
        return request
    }
}
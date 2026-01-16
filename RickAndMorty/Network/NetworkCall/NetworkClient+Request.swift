//
//  NetworkClient+Request.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

extension NetworkClient {
    func get(route: String, param: Param) -> NetworkingRequest {
        request(httpVerb: .get, route: route, param: param)
    }

    func post(route: String, param: Param) -> NetworkingRequest {
        request(httpVerb: .post, route: route, param: param)

        // need to send encoding data in case of post request
        // omitting that part as its not required for this implementation.
    }

    func request( httpVerb: HTTPVerb, route: String, param: Param) -> NetworkingRequest {
        let networkRequest = NetworkingRequest()
        networkRequest.baseURL = baseURL
        networkRequest.header = headers
        networkRequest.httpVerb = httpVerb
        networkRequest.timeInterval = timeInterval
        networkRequest.param = param
        networkRequest.route = route

        return networkRequest
    }
}

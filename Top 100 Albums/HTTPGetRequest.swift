//
//  HTTPGetRequest.swift
//  Top 100 Albums
//
//  Created by David Lindsay on 8/25/19.
//  Copyright © 2019 Tapinfuse, LLC. All rights reserved.
//

import Foundation

class HTTPGetRequest : URLSession {
    var session: URLSession? = nil
    var request: NSMutableURLRequest? = nil
    var url: URL? = nil
    
    init(httpEndPointString: String) {
        
        if let encoded = httpEndPointString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded)
        {
            self.url = url
            self.request = NSMutableURLRequest(url: url)
            self.request?.httpMethod = "GET"
            let config = URLSessionConfiguration.default
            self.session = URLSession(configuration: config)
        }
    }
}

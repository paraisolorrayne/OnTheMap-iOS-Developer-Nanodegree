//
//  LoginService.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import UIKit

class LoginService: GenericService {
    
    func requestSession(username:String, password:String, completion: @escaping (ResultType<LoginResponse>) -> Void) {
        let parameters = ["udacity":["username":username,"password":password]]
        requestData(type: LoginResponse.self, url: UdacityUtils.shared.sessionURL, method: .post, parameters: parameters){ completionHandler in
            completion(completionHandler)
            
        }
    }
    
    func getLocation(completion: @escaping (ResultType<StudentsInformations>) -> Void) {
        requestData(type: StudentsInformations.self, url: UdacityUtils.shared.parseURL, method: .get, parameters: nil,hasHTTPHeader:false, isParseRequest: true) { (completionHandler) in
            completion(completionHandler)
        }
    }
    
    func deleteSession(completion: @escaping (ResultType<LoginResponse>) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                completion(ResultType.Failure(e: error!))
                return
            }
            guard let data = data else {
                completion(ResultType.Failure(e: error!))
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            print(json ?? "")
            do {
                let jsonFromData =  try JSONDecoder().decode(LoginResponse.self, from: newData)
                completion(ResultType.Success(jsonFromData))
                
            } catch {
                if let errorFromData =  try? JSONDecoder().decode(ServiceError.self, from: newData) {
                    completion(ResultType.Failure(e:errorFromData))
                } else {
                    self.parseJsonFromData(LoginResponse.self, from: newData, completion: {completionHandler in
                        completion(completionHandler)
                    })
                }
            }
        }
        task.resume()
    }
}


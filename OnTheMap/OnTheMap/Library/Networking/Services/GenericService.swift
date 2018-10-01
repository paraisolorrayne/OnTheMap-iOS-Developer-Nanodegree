//
//  GenericService.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import Foundation

// swift result type https://www.cocoawithlove.com/blog/2016/08/21/result-types-part-one.html#the-result-type
enum ResultType<T> {
    case Success(T)
    case Failure(e: Error)
}

// Error for unknown case
enum JSONDecodingError: Error, LocalizedError {
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .unknownError:
            return NSLocalizedString("Unknown Error occured", comment: "")
        }
    }
}

class GenericService {
    
    private func request(url:URL,method:ServiceMethods,parameters:[String:Any]? = nil,hasHTTPHeader:Bool? = true, isParseRequest:Bool? = false, handler: @escaping (_ response: URLResponse?, _ data:Data?,_ error: Error?) -> Void) {
        
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = method.rawValue
        if hasHTTPHeader! {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if isParseRequest! {
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(
                withJSONObject: parameters,
                options: [])
            let theJSONText = String(data: request.httpBody!,
                                     encoding: .ascii)
            print("\n\nJSON string = \(theJSONText!)\n\n")//JSONSerialization.data(withJSONObject: parameters, options:JSONSerialization.WritingOptions.prettyPrinted)
        }
        print( request as URLRequest)
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let data = data {
                let range = Range(5..<data.count)
                let newData = !(isParseRequest!) ? data.subdata(in: range) : data
                handler(response,newData,error)
            } else {
                handler(response,data,error)
            }
            }.resume()
    }
    
    func requestData<T>(type: T.Type, url:URL,method:ServiceMethods,parameters:[String:Any]? = nil,hasHTTPHeader:Bool? = true,isParseRequest:Bool? = false, completion: @escaping (ResultType<T>) -> Void) where T : Decodable  {
        request(url: url, method: method, parameters: parameters,hasHTTPHeader:hasHTTPHeader,isParseRequest: isParseRequest) { (response, data, error) in
            guard error == nil else {
                completion(ResultType.Failure(e: error!))
                return
            }
            
            guard let data = data else {
                completion(ResultType.Failure(e: error!))
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            print(json ?? "")
            do {
                let jsonFromData =  try JSONDecoder().decode(type.self, from: data)
                completion(ResultType.Success(jsonFromData))
                
            } catch {
                if let errorFromData =  try? JSONDecoder().decode(ServiceError.self, from: data) {
                    completion(ResultType.Failure(e:errorFromData))
                } else {
                    self.parseJsonFromData(type, from: data, completion: {completionHandler in
                        completion(completionHandler)
                    })
                }
            }
        }
    }
    
    func parseJsonFromData<T>(_ type: T.Type, from data: Data,completion: @escaping (ResultType<T>) -> Void) where T : Decodable {
        do {
            let jsonFromData =  try JSONDecoder().decode(type.self, from: data)
            completion(ResultType.Success(jsonFromData))
        } catch DecodingError.dataCorrupted(let context) {
            completion(ResultType.Failure(e: DecodingError.dataCorrupted(context)))
        } catch DecodingError.keyNotFound(let key, let context) {
            completion(ResultType.Failure(e: DecodingError.keyNotFound(key, context)))
        } catch DecodingError.typeMismatch(let type, let context) {
            completion(ResultType.Failure(e: DecodingError.typeMismatch(type, context)))
        } catch DecodingError.valueNotFound(let value, let context) {
            completion(ResultType.Failure(e: DecodingError.valueNotFound(value, context)))
        } catch {
            completion(ResultType.Failure(e:JSONDecodingError.unknownError))
        }
    }
    
}

// MARK: Extension

// Extension on Decoding Error to provide better and concise debug description
extension DecodingError: LocalizedError {
    
    public var errorDescription: String? {
        switch  self {
        case .dataCorrupted(let context):
            return NSLocalizedString(context.debugDescription, comment: "")
        case .keyNotFound(_, let context):
            return NSLocalizedString("\(context.debugDescription)", comment: "")
        case .typeMismatch(_, let context):
            return NSLocalizedString("\(context.debugDescription)", comment: "")
        case .valueNotFound(_, let context):
            return NSLocalizedString("\(context.debugDescription)", comment: "")
        }
    }
}

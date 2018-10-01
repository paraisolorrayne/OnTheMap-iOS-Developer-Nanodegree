//
//  StudentService.swift
//  OnTheMap
//
//  Created by Lorrayne Paraiso  on 30/09/18.
//  Copyright © 2018 Lorrayne Paraiso. All rights reserved.
//

import Foundation

class StudentService: GenericService {
    
    func postStudentLocation(student: StudentInformation, completion: @escaping (ResultType<PostStudentResponse>) -> Void) {

        guard let uniqueKey:String = student.uniqueKey, let firstName:String = student.firstName, let lastName:String = student.lastName,let mapString:String = student.mapString,let mediaURL:String = student.mediaURL, let latitude:Float = student.latitude, let longitude = student.longitude else {
            return completion(ResultType.Failure(e:ServiceError(error: "unwrapping error happened", status: 500, code: 500)))
        }
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
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
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            print(json ?? "")
            do {
                let jsonFromData =  try JSONDecoder().decode(PostStudentResponse.self, from: data)
                completion(ResultType.Success(jsonFromData))
                
            } catch {
                if let errorFromData =  try? JSONDecoder().decode(ServiceError.self, from: data) {
                    completion(ResultType.Failure(e:errorFromData))
                } else {
                    self.parseJsonFromData(PostStudentResponse.self, from: data, completion: {completionHandler in
                        completion(completionHandler)
                    })
                }
            }
        }
        task.resume()
    }
    
    func getStudentLocation(student:StudentInformation, completion: @escaping (ResultType<StudentsInformations>) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22AER234%22%7D")!)
        request.httpMethod = "GET"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            print(json ?? "")
            do {
                let jsonFromData =  try JSONDecoder().decode(StudentsInformations.self, from: data)
                completion(ResultType.Success(jsonFromData))
                
            } catch {
                if let errorFromData =  try? JSONDecoder().decode(ServiceError.self, from: data) {
                    completion(ResultType.Failure(e:errorFromData))
                } else {
                    self.parseJsonFromData(StudentsInformations.self, from: data, completion: {completionHandler in
                        completion(completionHandler)
                    })
                }
            }
        }
        task.resume()
    }
    
    func putStudentLocation(student:StudentInformation, completion: @escaping (ResultType<PostStudentResponse>) -> Void) {
        
        guard let objectId = student.objectId ,let uniqueKey:String = student.uniqueKey, let firstName:String = student.firstName, let lastName:String = student.lastName,let mapString:String = student.mapString,let mediaURL:String = student.mediaURL, let latitude:Float = student.latitude, let longitude = student.longitude else {
            return completion(ResultType.Failure(e:ServiceError(error: "unwrapping error happened", status: 500, code: 500)))
        }
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
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
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            print(json ?? "")
            do {
                let jsonFromData =  try JSONDecoder().decode(PostStudentResponse.self, from: data)
                completion(ResultType.Success(jsonFromData))
                
            } catch {
                if let errorFromData =  try? JSONDecoder().decode(ServiceError.self, from: data) {
                    completion(ResultType.Failure(e:errorFromData))
                } else {
                    self.parseJsonFromData(PostStudentResponse.self, from: data, completion: {completionHandler in
                        completion(completionHandler)
                    })
                }
            }
        }
        task.resume()
    }
}

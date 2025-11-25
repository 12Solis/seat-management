//
//  AuthenticationService.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import Foundation
import FirebaseAuth
import Combine
import Firebase


class AuthenticationService : ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    
    init(){
        self.checkAuth()
    }
    
    func checkAuth(){
        if let user = Auth.auth().currentUser{
            self.user = user
            self.isAuthenticated = true
        }else{
            self.isAuthenticated = false
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User,Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password:password){ result, error in
            if let error = error{
                completion(.failure(error))
                return
            }
            if let user = result?.user{
                self.user = user
                self.isAuthenticated = true
                completion(.success(user))
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User,Error>) -> Void){
        Auth.auth().createUser(withEmail: email, password:password){ result, error in
            if let error = error{
                completion(.failure(error))
                return
            }
            if let user = result?.user{
                self.user = user
                self.isAuthenticated = true
                completion(.success(user))
            }
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        }catch{
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

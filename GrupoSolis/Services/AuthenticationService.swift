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

enum CodeValidationStatus {
    case valid
    case notFound
    case alreadyUsed
    case error
}

class AuthenticationService : ObservableObject {
    private let db = Firestore.firestore()
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    private var isAccessCodeValid = false
    
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
    
    func checkAccessCode(code: String, completion: @escaping (CodeValidationStatus) -> Void){
        let docRef = db.collection("account-codes").document(code)
        docRef.getDocument() { (document, error) in
            
            if error != nil {
                completion(.error)
            }
            
            if let document = document, document.exists {
                
                let isUsed = document.data()?["isUsed"] as? Bool ?? false
                if isUsed{
                    completion(.alreadyUsed)
                }else{
                    completion(.valid)
                }
                
            }else{
                completion(.notFound)
            }
        }
    }
    
    func signUp(email: String, password: String,accessCode: String, completion: @escaping (Result<FirebaseAuth.User,Error>) -> Void){
        
        checkAccessCode(code: accessCode){status in
            switch status{
            case .valid:
                Auth.auth().createUser(withEmail: email, password:password){ result, error in
                    if let error = error{
                        completion(.failure(error))
                        return
                    }
                    if let user = result?.user{
                        let codeRef = self.db.collection("account-codes").document(accessCode)
                        codeRef.updateData(["isUsed":true, "usedBy": email])
                        
                        self.user = user
                        do{
                            try Auth.auth().signOut()
                        }catch{
                            print("Error signing out: \(error.localizedDescription)")
                        }
                        completion(.success(user))
                    }
                }
                
            case .alreadyUsed:
                let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "El código de acceso ya se ha utilizado"])
                completion(.failure(error))
                
            case .notFound:
                let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "El código de acceso no es válido"])
                completion(.failure(error))
                
            case .error:
                let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error al validar el código de acceso"])
                completion(.failure(error))
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

//
//  FirebaseService.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import Foundation
import FirebaseFirestore

class FirebaseService {
    let db = Firestore.firestore()
    
    func testConnection() {
        
        db.collection("test").document("connection").setData([
            "connected": true,
            "timestamp": Date()
        ]) { error in
            if let error = error {
                print("❌ Error de conexión: \(error)")
            } else {
                print("✅ ¡Conectado a Firebase correctamente!")
            }
        }
    }
}

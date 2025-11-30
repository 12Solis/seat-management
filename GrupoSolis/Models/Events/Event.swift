//
//  Event.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 19/11/25.
//

import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let date: Date
    let place: String
    
    init(name: String, date: Date, place: String) {
        self.name = name
        self.date = date
        self.place = place
    }
}

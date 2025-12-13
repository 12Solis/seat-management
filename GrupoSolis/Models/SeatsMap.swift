//
//  SeatsMap.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 19/11/25.
//

import Foundation
import FirebaseFirestore

struct SeatsMap: Codable, Identifiable {
    @DocumentID var id: String?
    let eventId: String
    let name: String
    let layoutData: LayoutData
    
    init(id: String? = nil, eventId: String, name: String, layoutData: LayoutData) {
        self.id = id
        self.eventId = eventId
        self.name = name
        self.layoutData = layoutData
    }
}

struct LayoutData: Codable {
    let sections: [SeatSection]
    
}


struct SeatSection: Codable {
    let name : String
    let rows: [SeatRow]
}

struct SeatRow: Codable {
    let name : String
    let seatsCount: Int
    let startPosX: Int
    let startPosY: Int
}

struct VisualElement: Codable, Identifiable{
    var id = UUID().uuidString
    let positionX: Int
    let positionY: Int
    let width: Int
    let height: Int
    let label: String
}


struct SeatMapTemplate: Codable, Identifiable{
    @DocumentID var id: String?
    let name: String
    let description: String
    let layoutData: LayoutData
    let stageData: StageData?
    let createdAt: Date
    
    init(name:String,description:String, layoutData: LayoutData, stageData: StageData? = nil){
        self.name = name
        self.description = description
        self.layoutData = layoutData
        self.stageData = stageData
        self.createdAt = Date()
    }
}

struct StageData: Codable{
    let width: Int
    let height: Int
    let positionX: Int
    let positionY: Int
    let label: String
    
}

//
//  EventListElement.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 01/12/25.
//

import SwiftUI

struct EventListElement: View {
    let event: Event
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.name)
                .font(.headline)
            Text("Lugar: \(event.place)")
                .font(.subheadline)
            Text("Fecha: \(event.date, style: .date)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    } 
}

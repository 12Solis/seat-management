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
        ZStack(alignment: .leading){
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.principalBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(.black).opacity(0.4))
                    .frame(width: 80, height: 80)
                VStack{
                    Text(event.date.formatted(.dateTime.month(.abbreviated)))
                        .foregroundStyle(.accentGray)
                        .font(.title3)
                    Text(event.date.formatted(.dateTime.day(.defaultDigits)))
                        .foregroundStyle(.accentGray)
                        .font(.title)
                }
                .frame(width: 80)
            }
            VStack(alignment: .leading) {
                Text(event.name)
                    .foregroundStyle(.accentGray)
                    .font(.title)
                Text(event.place)
                    .foregroundStyle(.accentGray)
                    .font(.subheadline)
            }
            .padding(.leading, 100)
        }
    } 
}
#Preview {
    EventListElement(event: Event(name: "Prueba de Evento", date: Date(), place: "Lugar de prueba"))
}

//
//  CreateEventFormView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 30/11/25.
//

import SwiftUI

struct CreateEventFormView: View {
    let templateName: String
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var date: Date
    @Binding var location: String
    var body: some View {
        NavigationStack {
            List{
                Section("Nombre del evento"){
                    TextField("Ingresa el nombre",text: $name)
                }
                Section("Fecha"){
                    DatePicker("Selecciona la fecha", selection:$date,in: Date.now... ,displayedComponents: .date)
                        .labelsHidden()
                }
                Section("Lugar"){
                    TextField("Ingresa el lugar",text: $name)
                }
                
            }
            .navigationTitle(templateName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar{
                ToolbarItem(placement: .confirmationAction){
                    Button("Ok"){
                        isPresented.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateEventFormView(templateName:"Plaza de toros Scc" ,isPresented: .constant(true), name: .constant(""), date: .constant(Date()), location: .constant(""))
}

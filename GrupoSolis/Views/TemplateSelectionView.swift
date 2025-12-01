//
//  TemplateSelectionView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 24/11/25.
//

import SwiftUI

struct TemplateSelectionView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TemplateViewModel()
    @StateObject private var eventVM = EventViewModel()
    @State private var isCreatingEvent = false
    @State private var errorMessage = ""
    
    @State private var isFormPresented = false
    @State private var eventName = ""
    @State private var eventDate = Date()
    @State private var eventPlace = ""
    
    var body: some View {
        NavigationView{
            VStack{
                
                if !viewModel.templates.isEmpty {
                    Text("Selecciona una plantilla")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                if viewModel.isLoading && viewModel.templates.isEmpty {
                    ProgressView("Cargando plantillas...")
                }
                if isCreatingEvent{
                    ProgressView("Creando evento...")
                }
                if !errorMessage.isEmpty{
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                }
                if viewModel.templates.isEmpty && !viewModel.isLoading {
                    Text("No hay plantillas disponibles")
                        .foregroundStyle(.gray)
                        .padding()
                }
                
                List(viewModel.templates){template in
                    VStack(alignment:.leading,spacing: 8){
                        Text(template.name)
                            .font(.headline)
                        
                        Text(template.description)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        Text("\(countTotalSeats(in: template.layoutData)) asientos")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical,4)
                    .onTapGesture {
                        print("Plantilla seleccionada: \(template.name)")
                        createEventFromTemplate(template)
                    }
                }
                Button("template"){
                    isFormPresented.toggle()
                }
                
            }
            .navigationTitle("Seleccionar plantilla")
            .navigationBarItems(trailing: Button("Cerrar"){
                dismiss()
            })
            .onAppear{
                print("TemplateSelectionView apareció")
                if viewModel.templates.isEmpty && !viewModel.isLoading {
                    viewModel.loadTemplates()
                }
            }
            .sheet(isPresented: $isFormPresented){
                CreateEventFormView(templateName: "Plaza de toros", isPresented: $isFormPresented, name: $eventName, date: $eventDate, location: $eventPlace)
            }
            
        }
        
        
    }
    
    private func createEventFromTemplate(_ template: SeatMapTemplate) {
        isCreatingEvent = true
        errorMessage = ""
        
        let newEvent = Event(
            name: template.name,
            date: Date().addingTimeInterval(86400),
            place: "Lugar por definir"
        )
        print("Creando evento desde plantilla...")
        
        eventVM.createEvent(newEvent) { result in
            switch result {
            case .success(let eventId):
                print("Evento creado con ID: \(eventId)")
                
                self.viewModel.createFromTemplate(template: template, eventId: eventId) { seatMapResult in
                    DispatchQueue.main.async {
                        self.isCreatingEvent = false
                        
                        switch seatMapResult {
                        case .success(let seatMapId):
                            print("Mapa creado con ID: \(seatMapId)")
                            
                            self.dismiss()
                            
                        case .failure(let error):
                            self.errorMessage = "Error creando mapa: \(error.localizedDescription)"
                            print("Error creando mapa: \(error)")
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isCreatingEvent = false
                    self.errorMessage = "Error creando evento: \(error.localizedDescription)"
                    print("Error creando evento: \(error)")
                }
            }
        }
    }
    
    private func countTotalSeats(in layoutData: LayoutData) -> Int{
        return layoutData.sections.reduce(0){total, section in
            total + section.rows.reduce(0){rowTotal, row in
                rowTotal + row.seatsCount
            }
        }
    }
    
}

#Preview {
    TemplateSelectionView()
}

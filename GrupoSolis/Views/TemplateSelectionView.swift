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
    
    var body: some View {
        NavigationView{
            VStack{
                
                VStack{
                    Text("DEBUG:\(viewModel.templates.count) plantillas cargadas: ")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    if !viewModel.templates.isEmpty {
                        Text("Selecciona una plantilla")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
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
                        print("🎯 Plantilla seleccionada: \(template.name)")
                        createEventFromTemplate(template)
                    }
                }
                
            }
            .navigationTitle("Seleccionar plantilla")
            .navigationBarItems(trailing: Button("Cerrar"){
                dismiss()
            })
            .onAppear{
                print("👀 TemplateSelectionView apareció")
                if viewModel.templates.isEmpty && !viewModel.isLoading {
                    viewModel.loadTemplates()
                }
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
        
        eventVM.createEvent(newEvent) { result in  // ✅ QUITAR [weak self]
            switch result {
            case .success(let eventId):
                print("✅ Evento creado con ID: \(eventId)")
                
                // 2. Luego crear el mapa de asientos para este evento
                self.viewModel.createFromTemplate(template: template, eventId: eventId) { seatMapResult in
                    DispatchQueue.main.async {
                        self.isCreatingEvent = false  // ✅ Cambiar a self.
                        
                        switch seatMapResult {
                        case .success(let seatMapId):
                            print("✅ Mapa creado con ID: \(seatMapId)")
                            // Guardar ambos IDs para usarlos después
                            UserDefaults.standard.set(eventId, forKey: "lastCreatedEventId")
                            UserDefaults.standard.set(seatMapId, forKey: "seatMapId_\(eventId)")
                            
                            // Cerrar la vista
                            self.dismiss()  // ✅ Cambiar a self.
                            
                        case .failure(let error):
                            self.errorMessage = "Error creando mapa: \(error.localizedDescription)"  // ✅ Cambiar a self.
                            print("❌ Error creando mapa: \(error)")
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isCreatingEvent = false  // ✅ Cambiar a self.
                    self.errorMessage = "Error creando evento: \(error.localizedDescription)"  // ✅ Cambiar a self.
                    print("❌ Error creando evento: \(error)")
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

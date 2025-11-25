//
//  TemplateSelectionView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 24/11/25.
//

import SwiftUI

struct TemplateSelectionView: View {
    let eventId: String
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TemplateViewModel()
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView{
            VStack{
                
                VStack{
                    Text("DEBUG:\(viewModel.templates.count) plantillas cargadas: ")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    if !viewModel.templates.isEmpty {
                        Text("Primera plantilla: \(viewModel.templates[0].name)")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                if viewModel.isLoading && viewModel.templates.isEmpty {
                    ProgressView("Cargando plantillas...")
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
                        createFromTemplate(template)
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
    
    private func createFromTemplate(_ template: SeatMapTemplate){
        print("🔄 Creando mapa desde plantilla: \(template.name)")
        viewModel.createFromTemplate(template: template, eventId: eventId){ result in
            switch result{
            case .success(let seatMapId):
                print("✅ Mapa creado con ID: \(seatMapId)")
                UserDefaults.standard.set(seatMapId, forKey: "seatMapId_\(eventId)")
                dismiss()
            case .failure(let error):
                errorMessage = "Error creando mapa: \(error.localizedDescription)"
                print("❌ Error creando mapa: \(error)")
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
    TemplateSelectionView(eventId: "")
}

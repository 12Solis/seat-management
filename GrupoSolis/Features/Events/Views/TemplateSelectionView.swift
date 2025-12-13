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
    @State private var isCreatingEvent = false
    @State private var errorMessage = ""
    @Binding var sheetPresented: Bool
    
    @State private var isFormPresented = false
    @State private var eventName = ""
    @State private var eventDate = Date()
    @State private var eventPlace = ""
    @State private var templateName = ""
    @State private var selectedTemplate: SeatMapTemplate?
    
    var body: some View {
        VStack{
            
            if !viewModel.templates.isEmpty {
                Text("Selecciona una plantilla")
                    .font(.caption)
                    .foregroundStyle(.green)
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
                NavigationLink(destination:CreateEventFormView(viewModel: viewModel, selectedTemplate: template,isPresented: $sheetPresented)) {
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
                    
                }
                .padding(.vertical,4)
            }
            
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Seleccionar plantilla")
        .toolbar{
            ToolbarItem(placement:.cancellationAction){
                Button("Cerrar"){
                    dismiss()
                }
            }
        }
        .onAppear{
            print("TemplateSelectionView apareció")
            if viewModel.templates.isEmpty && !viewModel.isLoading {
                viewModel.loadTemplates()
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
    TemplateSelectionView(sheetPresented: .constant(true))
}

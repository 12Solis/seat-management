//
//  SeatMap.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI
import FirebaseAuth

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color)
                .frame(width: 15, height: 15)
                .cornerRadius(3)
            Text(text)
                .font(.system(size: 10))
        }
    }
}
 

struct SeatMapView: View {
    let seatMapId: String
    @StateObject private var viewModel = SeatMapViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @State private var stageData: StageData? = nil
    
    private func loadStageData() {
        
        self.stageData = StageData(
            width: 680,
            height: 680,
            positionX: 500,
            positionY: 400,
            label: "ESCENARIO"
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Mapa de Asientos")
                            .font(.title2)
                            .bold()
                        Text("\(viewModel.seats.count) asientos • \(numberOfSections) secciones")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    LegendItem(color: .green, text: "Disponible")
                    LegendItem(color: .red, text: "Vendido")
                    LegendItem(color: .orange, text: "Reservado")
                    LegendItem(color: .blue, text: "Sección A")
                    LegendItem(color: .purple, text: "Sección B")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
            
            ZoomableScrollView() {
                ZStack {
                    if let stageData = stageData {
                        StageView(stageData: stageData)
                            .position(
                                x: CGFloat(stageData.positionX),
                                y: CGFloat(stageData.positionY)
                            )
                            .offset(x:150,y: 300)
                    }
 
                    PlazaSccMapView(viewModel: viewModel, stageData: stageData)
                        .offset(x:150, y:300)
                }
                .frame(width: 1500, height: 1600)
                .contentShape(Rectangle())
            }
            
            
            if viewModel.isLoading {
                ProgressView("Sincronizando asientos...")
                    .padding()
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
        .navigationTitle("Mapa de Asientos")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadSeatsForMap(seatMapId: seatMapId)
            loadStageData()
        }
        .onDisappear{
            viewModel.stopListening()
        }
    }
    
    private var numberOfSections: Int {
        let sections = Set(viewModel.seats.map { $0.section })
        return sections.count
    }
}

#Preview {
    SeatMapView(seatMapId:" ")
    
}

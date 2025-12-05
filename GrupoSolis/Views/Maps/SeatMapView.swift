//
//  SeatMap.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI
import FirebaseAuth

struct SeatMapView: View {
    @StateObject private var viewModel = SeatMapViewModel()
    @StateObject private var eventService = EventService()
    @EnvironmentObject private var authService: AuthenticationService
    
    let seatMapId: String
    let eventName: String
    let eventDate: Date
    
    @State private var selectedSeats: [Seat] = []
    @State private var stageData: StageData? = nil
    
    @State private var errorMessage = ""
    
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
                HStack{
                    Spacer()
                    VStack(alignment: .center,spacing: 10){
                        Text(eventName)
                            .font(.title)
                            .bold()
                        Text(eventDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day(.twoDigits).hour().minute().locale(Locale(identifier: "es_MX"))))
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    LegendItem(color: .green, text: "Disponible")
                    LegendItem(color: .red, text: "Vendido")
                    LegendItem(color: .orange, text: "Reservado")
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
 
                    PlazaSccMapView(viewModel: viewModel, stageData: stageData,selectedSeats: $selectedSeats)
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
        .toolbar(){
            ToolbarItem(placement:.confirmationAction){
                Button("Guardar"){
                    updateSelectedSeats()
                }
                .disabled(selectedSeats.isEmpty)
            }
        }
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
    private func updateSelectedSeats(){
        guard let userId = authService.user?.uid else { return }
            
            // Llamamos a la nueva función de batch
            eventService.updateSelectedSeats(seats: selectedSeats, userId: userId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Todos los asientos guardados en una sola operación")
                        self.selectedSeats.removeAll()
                        // Opcional: Mostrar alerta de éxito
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
}

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

#Preview {
    SeatMapView(seatMapId:" ",eventName:"Prueba", eventDate: Date())
    
}

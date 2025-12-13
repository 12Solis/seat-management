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
    let event: Event
    let mapCanvasSize = CGSize(width: 1500, height: 1600)
    
    @State private var selectedSeats: [Seat] = []
    @State private var stageData: StageData? = nil
    
    @State private var errorMessage = ""
    @State private var isSheetPresented = false
    
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
                        Text(event.name)
                            .font(.title)
                            .bold()
                        Text((event.date).formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day(.twoDigits).hour().minute().locale(Locale(identifier: "es_MX"))))
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                HStack(spacing: 15) {
                    LegendItem(color: .blue, text: "Seleccionado")
                    LegendItem(color: .green, text: "Disponible")
                    LegendItem(color: .red, text: "Vendido")
                    LegendItem(color: .orange, text: "Reservado")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
            
            ZoomableScrollView(mapSize: mapCanvasSize) {
                ZStack {
                        if let stageData = stageData {
                            StageView(stageData: stageData)
                                .position(
                                    x: CGFloat(stageData.positionX),
                                    y: CGFloat(stageData.positionY)
                                )
                                .offset(x: 150, y: 300)
                        }

                        PlazaSccMapView(viewModel: viewModel, stageData: stageData, selectedSeats: $selectedSeats)
                            .offset(x: 150, y: 300)
                    }
                    .frame(width: mapCanvasSize.width, height: mapCanvasSize.height)
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
                    isSheetPresented = true
                }
                .disabled(selectedSeats.isEmpty)
            }
        }
        .sheet(isPresented:$isSheetPresented){
            ReserveSeatFormView(event: event,selectedSeats: $selectedSeats, isPresented: $isSheetPresented)
                .presentationDetents([.fraction(0.85)])
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
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .cornerRadius(3)
                .overlay{
                    Circle()
                        .stroke(.black, lineWidth: 0.5)
                }
                .shadow(radius: 2)
            Text(text)
                .font(.system(size: 10))
        }
    }
}

#Preview {
    SeatMapView(seatMapId: "", event: Event(name: "Prueba", date: Date(), place: "Prueba"))
    
}

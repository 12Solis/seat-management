//
//  SeatMap.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI
import FirebaseAuth

struct SectionView: View{
    let section : Int
    let seats : [Seat]
    let onSeatTap: (Seat) -> Void
    
    private var uniqueRows: [Int] {
        let rows = Set(seats.map { $0.row })
        return Array(rows).sorted()
    }
    private func seatsInRow(_ row : Int) -> [Seat] {
        return seats.filter {$0.row == row}.sorted { $0.number < $1.number}
        
    }
    
    var body: some View {
        VStack(alignment:.leading,spacing: 8){
            Text("Sección \(section+1)")
                .font(.system(size: 14,weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal,8)
                .padding(.vertical,4)
                .background(getSectionColor(section))
                .cornerRadius(4)
           
            VStack(alignment:.leading,spacing: 2){
                ForEach(uniqueRows,id: \.self){actualRow in
                    RowView(
                        row: actualRow,
                        seats: seatsInRow(actualRow),
                        onSeatTap: onSeatTap
                    )
                }
            }
        }
    }
    private func getSectionName(_ section: Int) -> String {
        let sectionNames = ["A", "B", "C", "D", "E"]
        return section < sectionNames.count ? sectionNames[section] : "\(section + 1)"
    }
        
    private func getSectionColor(_ section: Int) -> Color {
        let colors: [Color] = [.blue, .purple, .orange, .pink, .indigo]
        return section < colors.count ? colors[section] : .gray
    }
    
}

struct RowView: View {
    let row: Int
    let seats: [Seat]
    let onSeatTap: (Seat) -> Void
    
    var body: some View {
        HStack(spacing: 2){
            Text("Fila \(row)")
                .font(.system(size: 10))
                .frame(width: 35,alignment: .leading)
                .foregroundStyle(.gray)
            ForEach(seats){seat in
                SeatView(seat: seat, onTap: onSeatTap)
            }
            Spacer()
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
 

struct SeatMapView: View {
    let seatMapId: String
    @StateObject private var viewModel = SeatMapViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @State private var stageData: StageData? = nil
    
    private func loadStageData() {
        // Datos del escenario basados en tu plantilla
        self.stageData = StageData(
            width: 180,
            height: 180,
            positionX: 500, // Centro del área ampliada
            positionY: 400,
            label: "RING"
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header mejorado
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Mapa de Asientos")
                            .font(.title2)
                            .bold()
                        Text("\(viewModel.seats.count) asientos • \(numberOfSections) secciones")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    // Controles de zoom
                    HStack(spacing: 15) {
                        Button("Reset") {
                            withAnimation(.spring()) {
                                // Aquí resetearíamos el zoom si usáramos el ZoomableViewModel
                            }
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                    }
                }
                
                // Leyenda
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
            
            // Mapa con zoom y pan
            ZoomableScrollView {
                ZStack {
                    // Escenario en el centro
                    if let stageData = stageData {
                        StageView(stageData: stageData)
                            .position(
                                x: CGFloat(stageData.positionX),
                                y: CGFloat(stageData.positionY)
                            )
                    }
                    
                    // Secciones dispuestas alrededor del escenario
                    ForEach(0..<numberOfSections, id: \.self) { section in
                        SectionContainerView(
                            section: section,
                            seats: viewModel.seatsInSection(section),
                            onSeatTap: { seat in
                                if let userId = authService.user?.uid {
                                    viewModel.toggleSeatStatus(seat, userId: userId)
                                }
                            }
                        )
                        .position(getPositionForSection(section))
                    }
                }
                .frame(width: 1000, height: 800) // Área grande para el zoom
            }
            
            // Estados de carga/error
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
    }
    
    private var numberOfSections: Int {
        let sections = Set(viewModel.seats.map { $0.section })
        return sections.count
    }
    
    // Posiciones mejoradas para evitar amontonamiento
    private func getPositionForSection(_ section: Int) -> CGPoint {
        let centerX: CGFloat = 500
        let centerY: CGFloat = 400
        let baseRadius: CGFloat = 280 // Radio base aumentado
        
        // Ángulos específicos para 5 secciones
        let sectionAngles: [Double] = [
            .pi * 1.25,    // A: Superior izquierda (225°)
            .pi * 1.75,    // B: Superior (270°)
            .pi * 0.25,    // C: Superior derecha (45°)
            .pi * 0.75,    // D: Inferior derecha (135°)
            .pi * 1.5      // E: Inferior izquierda (180°)
        ]
        
        if section < sectionAngles.count {
            let angle = sectionAngles[section]
            let radius = baseRadius + CGFloat(section) * 20 // Espaciado progresivo
            
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            return CGPoint(x: x, y: y)
        } else {
            // Para secciones adicionales
            let angle = Double(section) * (2 * .pi / Double(numberOfSections))
            let x = centerX + baseRadius * cos(angle)
            let y = centerY + baseRadius * sin(angle)
            return CGPoint(x: x, y: y)
        }
    }
}

// Nueva vista contenedora para secciones
struct SectionContainerView: View {
    let section: Int
    let seats: [Seat]
    let onSeatTap: (Seat) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            SectionView(section: section, seats: seats, onSeatTap: onSeatTap)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
    }
}
#Preview {
    SeatMapView(seatMapId:" ")
    
}

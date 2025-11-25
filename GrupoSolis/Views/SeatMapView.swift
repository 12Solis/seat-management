//
//  SeatMap.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI
import FirebaseAuth

struct SeatMapView: View {
    let seatMapId : String
    @StateObject private var viewModel = SeatMapViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    private var numberOfSections: Int {
        let sections = Set(viewModel.seats.map { $0.section })
        print("🔍 Secciones únicas encontradas: \(sections.sorted())")
        return sections.count
    }
    var body: some View {
        VStack{
            HStack{
                VStack(alignment:.leading){
                    Text("Mapa de asientos")
                        .font(.title2)
                        .bold()
                    Text("Asientos: \(viewModel.seats.count)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                Spacer()
                HStack(spacing:15){
                    LegendItem(color: .green, text: "Disponible")
                    LegendItem(color: .red, text: "Vendido")
                    LegendItem(color: .orange, text: "Reservado")
                }
            }
            .padding(.horizontal)
            
            VStack {
                Text("DEBUG: \(viewModel.seats.count) asientos cargados")
                    .font(.caption)
                    .foregroundColor(.blue)
                        
                if !viewModel.seats.isEmpty {
                    Text("Primeros 3 asientos:")
                        .font(.caption)
                    ForEach(viewModel.seats.prefix(3)) { seat in
                        Text("ID: \(seat.id) - Sección: \(seat.section) - Fila: \(seat.row) - Número: \(seat.number) - Status: \(seat.status.rawValue)")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                    }
                } else {
                    Text("No hay asientos para mostrar")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
            
            ScrollView([.horizontal,.vertical],showsIndicators: true){
                VStack(alignment:.leading,spacing: 15){
                    ForEach(0..<numberOfSections,id: \.self){section in
                        SectionView(
                            section: section,
                            seats: viewModel.seatsInSection(section),
                            onSeatTap: { seat in
                                if let userId = authService.user?.uid {
                                viewModel.toggleSeatStatus(seat, userId: userId)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            
            if viewModel.isLoading {
                ProgressView("Sincronizando...")
            }
                    
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
        }
        .navigationTitle("Asientos")
        .onAppear {
            print("🎯 Cargando asientos para seatMapId: \(seatMapId)")
            viewModel.loadSeatsForMap(seatMapId: seatMapId)
        }
    }
}
struct SectionView: View{
    let section : Int
    let seats : [Seat]
    let onSeatTap: (Seat) -> Void
    
    private var uniqueRows: [Int] {
        let rows = Set(seats.map { $0.row })
        return Array(rows).sorted()
    }
    private func seatsInRow(_ row : Int) -> [Seat] {
        let rowSeats = seats.filter {$0.row == row}.sorted { $0.number < $1.number}
        print("🔍 Sección \(section) - Fila \(row) tiene \(rowSeats.count) asientos")
        return rowSeats
        
    }
    
    var body: some View {
        VStack(alignment:.leading,spacing: 8){
            Text("Sección \(section+1)")
                .font(.headline)
                .padding(.leading,5)
           
            ForEach(uniqueRows, id: \.self){actualRow in
                RowView(row:actualRow,seats: seatsInRow(actualRow),onSeatTap: onSeatTap)
            }
        }
    }
    
}

struct RowView: View {
    let row: Int
    let seats: [Seat]
    let onSeatTap: (Seat) -> Void
    
    var body: some View {
        HStack(spacing: 4){
            Text("Fila \(row)")
                .font(.system(size: 10))
                .frame(width: 40,alignment: .leading)
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
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
                .font(.system(size: 10))
        }
    }
}
#Preview {
    SeatMapView(seatMapId:" ")
    
}

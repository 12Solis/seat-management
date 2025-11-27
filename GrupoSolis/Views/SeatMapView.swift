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
        VStack(alignment:.center ,spacing: 8){
            Text("Sección \(getSectionName(section))")
                .font(.system(size: 14,weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal,8)
                .padding(.vertical,4)
                .background(getSectionColor(section))
                .cornerRadius(4)
           
            VStack(alignment:
                    section == 0 ? .trailing:
                    section == 4 ? .leading:
                    .center
                   ,spacing: 2){
                ForEach(uniqueRows.reversed(),id: \.self){actualRow in
                    RowView(
                        row: actualRow,
                        seats: seatsInRow(actualRow),
                        onSeatTap: onSeatTap,
                        sectionName: getSectionName(section)
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
    var sectionName:String
    
    var body: some View {
        HStack(spacing: 2){
            Text("F \(row)")
                .font(.system(size: 10))
                .frame(width: 35,alignment:
                        sectionName == "A" ? .trailing :
                        sectionName == "E" ? .leading :
                        .center)
                .foregroundStyle(.gray)
            ForEach(seats){seat in
                SeatView(seat: seat, onTap: onSeatTap)
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
                    }
                    
                    ForEach(0..<numberOfSections, id: \.self) { section in
                        SectionContainerView(
                            section: section,
                            seats: viewModel.seatsInSection(section),
                            onSeatTap: { seat in
                                if let userId = authService.user?.uid {
                                    viewModel.toggleSeatStatus(seat, userId: userId)
                                }
                            },rotation: getRotationForSection(section)
                        )
                        .position(getPositionForSection(section))
                    }
                }
                .frame(width: 1500, height: 1600)
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
    }
    
    private var numberOfSections: Int {
        let sections = Set(viewModel.seats.map { $0.section })
        return sections.count
    }
    
    private func getPositionForSection(_ section: Int) -> CGPoint {
        guard let stageData = stageData else {
            return CGPoint(x: 400, y: 500)
        }
        
        let centerX = CGFloat(stageData.positionX)
        let centerY = CGFloat(stageData.positionY)
        let stageWidth = CGFloat(stageData.width)
        let stageHeight = CGFloat(stageData.height)
        
        let horizontalDistance: CGFloat = 120
        let verticalDistance: CGFloat = 120
        
        switch section{
        case 0:
            return CGPoint(
                x: centerX + stageWidth / 2 + horizontalDistance + 143,
                y: centerY - 360
            )
        case 1:
            return CGPoint(
                x: centerX,
                y: centerY - stageWidth/2 - verticalDistance - 100
            )
        case 2:
            return CGPoint(
                x: centerX - stageWidth / 2 - horizontalDistance - 143,
                y: centerY - 20
            )
        case 3:
            return CGPoint(
                x: centerX,
                y: centerY + stageWidth/2 + verticalDistance + 100
            )
        case 4:
            return CGPoint(
                x: centerX + stageWidth / 2 + horizontalDistance + 143,
                y: centerY + 330
            )
        default:
            return CGPoint(x: 400, y: 500)
        }
    }
    
    private func getRotationForSection(_ section: Int) -> Angle {
        switch section{
        case 0:
            return .degrees(90)
        case 1:
            return .degrees(0)
        case 2:
            return .degrees(-90)
        case 3:
            return .degrees(180)
        case 4:
            return .degrees(90)
        default:
            return .degrees(0)
        }
    }
}


struct SectionContainerView: View {
    let section: Int
    let seats: [Seat]
    let onSeatTap: (Seat) -> Void
    let rotation: Angle
    
    var body: some View {
        VStack(spacing: 8) {
            SectionView(section: section, seats: seats, onSeatTap: onSeatTap)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .rotationEffect(rotation)
    }
}
#Preview {
    SeatMapView(seatMapId:" ")
    
}

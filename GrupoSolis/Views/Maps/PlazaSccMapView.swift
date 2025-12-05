//
//  PlazaSccMapView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 28/11/25.
//

import SwiftUI
import FirebaseAuth

struct PlazaSccMapView: View {
    @ObservedObject var viewModel: SeatMapViewModel
    @EnvironmentObject private var authService: AuthenticationService
    let stageData: StageData?
    @Binding var selectedSeats: [Seat]
    
    var body: some View {
        ForEach(0..<numberOfSections, id: \.self) { section in
            SectionContainerView(
                section: section,
                seats: viewModel.seatsInSection(section),
                onSeatTap: { seat in
                    guard seat.status == .available else { return }
                            
                    if let index = selectedSeats.firstIndex(where: { $0.id == seat.id }) {
                        selectedSeats.remove(at: index)
                        print("Asiento \(seat.number) deseleccionado (Local)")
                    } else {
                        var seatToSelect = seat
                        seatToSelect.tempStatus = .sold
                        selectedSeats.append(seatToSelect)
                        print("Asiento \(seat.number) seleccionado (Local)")
                    }
                    
                },rotation: getRotationForSection(section),
                selectedSeats: selectedSeats
            )
            .position(getPositionForSection(section))
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


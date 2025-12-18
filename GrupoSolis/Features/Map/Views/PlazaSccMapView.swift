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
    @StateObject var eventService = EventService()
    
    let stageData: StageData?
    @Binding var selectedSeats: [Seat]
    
    @State private var seatToRefund: Seat? = nil
    
    var body: some View {
        ForEach(0..<numberOfSections, id: \.self) { section in
            SectionContainerView(
                section: section,
                seats: viewModel.seatsInSection(section),
                onSeatTap: { seat in
                    handleSeatTap(seat)
                },
                rotation: getRotationForSection(section),
                selectedSeats: selectedSeats,
                seatBeingInspected: seatToRefund,
                onRefund: { seat in
                    refundSeat(seat)
                },
                onDismissBubble: {
                    seatToRefund = nil
                },
                onLiquidate: { seat, method in
                    liquidateSeat(seat, method: method)
                }
            )
            .position(getPositionForSection(section))
        }
    }
    
    
    private func handleSeatTap(_ seat: Seat) {
        if seat.status == .sold || seat.status == .reserved {
            withAnimation {
                if seatToRefund?.id == seat.id {
                    seatToRefund = nil
                } else {
                    seatToRefund = seat
                }
            }
            print("Inspeccionando asiento: \(seat.number) (\(seat.status.rawValue))")
        }

        else if seat.status == .available {
            seatToRefund = nil
            if let index = selectedSeats.firstIndex(where: { $0.id == seat.id }) {
                selectedSeats.remove(at: index)
                print("Asiento \(seat.number) deseleccionado (Local)")
            } else {
                if let first = selectedSeats.first, first.section != seat.section {
                    print("No se puede seleccionar asientos de distnitas secciones")
                    return
                }
                selectedSeats.append(seat)
            }
        }
    }
    
    // MARK: - Operaciones de asientos
    
    private func liquidateSeat(_ seat: Seat, method: PaymentMethods) {
        guard let userId = authService.user?.uid else { return }
        let paid = seat.amountPaid ?? 0.0
        let currentBuyer = seat.buyerName ?? "Cliente"
        let originalPaymentMethod = seat.paymentMethod ?? nil

        eventService.updateSelectedSeats(
            seats: [seat],
            userId: userId,
            newStatus: .sold,
            buyer: currentBuyer,
            amountPaid: paid,
            paymentMethod: originalPaymentMethod,
            liquidateMethod: method
            
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Asiento liquidado correctamente")
                    self.seatToRefund = nil
                case .failure(let error):
                    print("Error al liquidar: \(error.localizedDescription)")
                }
            }
        }
    }

    private func refundSeat(_ seat: Seat) {
        guard let userId = authService.user?.uid else { return }
        
        eventService.updateSelectedSeats(
            seats: [seat],
            userId: userId,
            newStatus: .available,
            buyer: "",
            amountPaid: 0.0,
            paymentMethod: nil,
            liquidateMethod: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Asiento liberado correctamente")
                    self.seatToRefund = nil
                case .failure(let error):
                    print("Error al liberar: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Posición y Datos de Mapa
    
    private var numberOfSections: Int {
        let sections = Set(viewModel.seats.map { $0.section })
        return sections.count
    }
    
    private func getPositionForSection(_ section: Int) -> CGPoint {
        guard let stageData = stageData else { return CGPoint(x: 400, y: 500) }
        
        let centerX = CGFloat(stageData.positionX)
        let centerY = CGFloat(stageData.positionY)
        let stageWidth = CGFloat(stageData.width)
        let horizontalDistance: CGFloat = 120
        let verticalDistance: CGFloat = 120
        
        switch section {
        case 0: return CGPoint(x: centerX + stageWidth / 2 + horizontalDistance + 143, y: centerY - 360)
        case 1: return CGPoint(x: centerX, y: centerY - stageWidth/2 - verticalDistance - 100)
        case 2: return CGPoint(x: centerX - stageWidth / 2 - horizontalDistance - 143, y: centerY - 20)
        case 3: return CGPoint(x: centerX, y: centerY + stageWidth/2 + verticalDistance + 100)
        case 4: return CGPoint(x: centerX + stageWidth / 2 + horizontalDistance + 143, y: centerY + 330)
        default: return CGPoint(x: 400, y: 500)
        }
    }
    
    private func getRotationForSection(_ section: Int) -> Angle {
        switch section {
        case 0: return .degrees(90)
        case 1: return .degrees(0)
        case 2: return .degrees(-90)
        case 3: return .degrees(180)
        case 4: return .degrees(90)
        default: return .degrees(0)
        }
    }
}

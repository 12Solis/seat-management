//
//  SeatView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI

struct SeatView: View {
    let seat: Seat
    let isSelected: Bool
    let seatBeingInspected: Seat?
    let onTap: (Seat) -> Void
    
    let onRefund: (Seat) -> Void
    let onDismissBubble: () -> Void
    let onLiquidate: (Seat) -> Void
    
    var body: some View {
        Circle()
            .fill(seatColor)
            .frame(width: 25,height: 25)
            .overlay(
                Circle()
                    .stroke(.black, lineWidth: 2)
            )
            .overlay(
                Text("\(seat.number)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(textColor)
            )
            .overlay(alignment: .bottom){
                if seatBeingInspected?.id == seat.id {
                    SeatDetailBubble(
                        seat: seat,
                        onDismiss: onDismissBubble,
                        onRefund: {onRefund(seat)},
                        onLiquidate: {onLiquidate(seat)}
                    )
                    .offset(y: -35)
                    .onTapGesture { }
                }
            }
            .zIndex(seatBeingInspected?.id == seat.id ? 100 : 1)
            .onTapGesture {
                onTap(seat)
            }
    }
    
    private var seatColor: Color {
        if isSelected{return .blue}
        
        switch seat.status {
        case .available:
            return .green
        case .sold:
            return .red
        case .reserved:
            return .orange
        }
    }
    private var textColor: Color {
        if isSelected{return .white}
        
        switch seat.status {
        case .available:
            return .black
        case .sold, .reserved:
            return .white
        }
    }
    
}


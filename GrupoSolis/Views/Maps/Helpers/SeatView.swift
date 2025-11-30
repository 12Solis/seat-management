//
//  SeatView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI

struct SeatView: View {
    let seat: Seat
    let onTap: (Seat) -> Void
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
            .onTapGesture {
                onTap(seat)
            }
    }
    
    private var seatColor: Color {
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
        switch seat.status {
        case .available:
            return .black
        case .sold, .reserved:
            return .white
        }
    }
    
}


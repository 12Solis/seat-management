//
//  RowView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 28/11/25.
//

import SwiftUI

struct RowView: View {
    let row: Int
    let seats: [Seat]
    let selectedSeats: [Seat]
    let onSeatTap: (Seat) -> Void
    var sectionName:String
    
    let seatBeingInspected: Seat?
    let onRefund: (Seat) -> Void
    let onDismissBubble: () -> Void
    let onLiquidate: (Seat) -> Void
    
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
                SeatView(seat: seat,
                         isSelected: selectedSeats.contains(where: { $0.id == seat.id }) ,
                         seatBeingInspected:seatBeingInspected ,
                         onTap: onSeatTap,
                         onRefund: onRefund,
                         onDismissBubble: onDismissBubble,
                         onLiquidate: onLiquidate
                )
            }
            
        }
    }
}


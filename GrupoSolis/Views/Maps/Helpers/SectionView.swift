//
//  SectionVIew.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 28/11/25.
//

import SwiftUI

struct SectionView: View {
    let section : Int
    let seats : [Seat]
    let onSeatTap: (Seat) -> Void
    let selectedSeats: [Seat]
    
    let seatBeingInspected: Seat?
    let onRefund: (Seat) -> Void
    let onDismissBubble: () -> Void
    let onLiquidate: (Seat) -> Void
    
    private var uniqueRows: [Int] {
        let rows = Set(seats.map { $0.row })
        return Array(rows).sorted()
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
                        selectedSeats: selectedSeats,
                        onSeatTap: onSeatTap,
                        sectionName: getSectionName(section),
                        seatBeingInspected: seatBeingInspected,
                        onRefund: onRefund,
                        onDismissBubble: onDismissBubble,
                        onLiquidate: onLiquidate
                    )
                }
            }
        }
    }
    
    private func seatsInRow(_ row : Int) -> [Seat] {
        return seats.filter {$0.row == row}.sorted { $0.number < $1.number}
        
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

struct SectionContainerView: View {
    let section: Int
    let seats: [Seat]
    let onSeatTap: (Seat) -> Void
    let rotation: Angle
    let selectedSeats: [Seat]
    
    let seatBeingInspected: Seat?
    let onRefund: (Seat) -> Void
    let onDismissBubble: () -> Void
    let onLiquidate: (Seat) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            SectionView(section: section,
                        seats: seats,
                        onSeatTap: onSeatTap,
                        selectedSeats: selectedSeats,
                        seatBeingInspected: seatBeingInspected,
                        onRefund: onRefund,
                        onDismissBubble: onDismissBubble,
                        onLiquidate: onLiquidate
            )
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

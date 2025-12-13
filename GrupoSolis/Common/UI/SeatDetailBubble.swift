//
//  SeatDetailBubble.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 08/12/25.
//

import SwiftUI

struct SeatDetailBubble: View {
    var seat: Seat
    let onDismiss: () -> Void
    let onRefund: () -> Void
    let onLiquidate: () -> Void
    
    var body: some View {
        VStack(spacing: 8){
            HStack{
                Text("Asiento \(seat.number)")
                    .font(.caption)
                    .bold()
                Spacer()
                Button{
                    onDismiss()
                }label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            Divider()
            
            if let buyer = seat.buyerName {
                Text("Comprador: \(buyer)")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            
            if let date = seat.lastUpdate{
                Text((seat.status == .reserved ? "Reservado el: " : "Comprado el: ") + date.formatted(date: .numeric, time: .shortened))
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            
            if seat.status == .reserved {
                let price = seat.price ?? 0.0
                let paid = seat.amountPaid ?? 0.0
                Text("Saldo restante: \((price - paid).formatted())")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                Button{
                    onLiquidate()
                }label:{
                    Text("Liquidar")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
            }
            
            if let method = (seat.paymentMethod)?.rawValue{
                Text("Metodo de pago: \(method)")
            }
            
            Button(action: onRefund) {
                Text("Liberar Asiento")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .padding(8)
        .frame(width: 140)
        .background(Color(.white))
        .cornerRadius(8)
        .shadow(radius: 4)
        .overlay(alignment: .bottom) {
            Image(systemName: "arrowtriangle.down.fill")
                .foregroundColor(.white)
                .font(.caption)
                .offset(y: 8)
        }
    }
}


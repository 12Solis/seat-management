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
    let onLiquidate: (Seat, PaymentMethods) -> Void
    
    @State private var paymenthMethod : PaymentMethods = .cash
    
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
                
                Picker("Metodo", selection: $paymenthMethod){
                    Text("Efectivo").tag(PaymentMethods.cash)
                    Text("Transf").tag(PaymentMethods.bankWire)
                }
                .pickerStyle(.segmented)
                
                Button{
                    onLiquidate(seat, paymenthMethod)
                }label:{
                    Text("Liquidar")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.rgb(16, 185, 129))
                        .cornerRadius(4)
                }
            }
            
            
            if let method = (seat.paymentMethod)?.rawValue{
                Text("Metodo de pago: \(method)")
                    .font(.system(size: 9, weight: .bold))
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

extension Color {
    static func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color {
        return Color(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
}


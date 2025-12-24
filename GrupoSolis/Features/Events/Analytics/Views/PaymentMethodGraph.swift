//
//  PaymentMethodGraph.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 14/12/25.
//

import SwiftUI

struct PaymentMethodGraph: View {
    let isCash: Bool
    let totalAmount: Int
    let totalInCash: Int
    
    var percentageInCash: Double {
        guard totalAmount > 0 else { return 0 }
        return Double(totalInCash) / Double(totalAmount)
    }
    
    var displayPercentage: Double {
        guard totalAmount > 0 else { return 0 }
            
        return isCash ? percentageInCash : (1.0 - percentageInCash)
    }
    
    @State private var animationProgress: Double = 0.0

    var body: some View {
        VStack {
            Image(systemName: isCash ? "wallet.bifold" : "dollarsign.bank.building")
                .font(.largeTitle)
                .bold()

            Text(isCash ? "Efectivo" : "Transferencia")
                .font(.title2)

            Text(isCash ? "$\(totalInCash)" : "$\(totalAmount - totalInCash)")
                .font(.largeTitle)
                .bold()
            
            GeometryReader { proxy in
                let totalWidth = proxy.size.width

                if totalWidth > 0 {
                    ZStack(alignment: isCash ? .leading : .trailing) {
                        
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)

                        let barWidth = max(20, totalWidth * displayPercentage * animationProgress)
                        
                        Capsule()
                            .fill(Color.green)
                            .frame(width: barWidth, height: 20)
                            .overlay(
                                Text("\(Int(displayPercentage * 100))%")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6),
                                alignment: isCash ? .trailing : .leading
                            )
                    }
                }
            }
            .frame(height: 20)
            .padding(.horizontal,40)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)) {
                    animationProgress = 1
                }
            }
        }
    }
}


#Preview {
    PaymentMethodGraph(
        isCash: true, totalAmount: 300, totalInCash: 100
    )
}

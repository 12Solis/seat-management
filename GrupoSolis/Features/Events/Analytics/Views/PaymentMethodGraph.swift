//
//  PaymentMethodGraph.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 14/12/25.
//

import SwiftUI

struct PaymentMethodGraph: View {
    let isCash: Bool
    let progress: Double = 0.7
    let totalAmount: Int
    let totalInCash: Int
    var percentageInCash: Double {
        Double(totalInCash) / Double(totalAmount)
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

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    if isCash{
                        Capsule()
                            .fill(Color.green)
                            .frame(
                                width: max(20, geo.size.width * percentageInCash * animationProgress),
                                height: 20
                            )
                            .overlay(
                                Text("\(Int(percentageInCash*100))%")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6),
                                alignment: .trailing
                            )
                    }else{
                        Capsule()
                            .fill(Color.green)
                            .frame(
                                width: max(20, geo.size.width * (1.0 - percentageInCash) * animationProgress),
                                height: 20
                            )
                            .overlay(
                                Text("\(Int((1.0 - percentageInCash) * 100))%")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6),
                                alignment: .trailing
                            )
                    }

                }
            }
            .frame(height: 20)
            .padding(.horizontal)
            .onAppear{
                withAnimation(.easeInOut(duration: 1.5)){
                    animationProgress = 1
                }
            }
        }
        .padding(.horizontal)
    }
}


#Preview {
    PaymentMethodGraph(
        isCash: true, totalAmount: 300, totalInCash: 100
    )
}

//
//  DebtGraph.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI

struct DebtGraph: View {
    let total: Int
    var body: some View {
        VStack{
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.largeTitle)
            
            Text("Por Cobrar")
                .font(.title2)
                .bold()
            
            Text("\(total)")
                .foregroundStyle(.red)
                .font(.largeTitle)
                .bold()
            Spacer()
        }
    }
}

#Preview {
    DebtGraph(total: 1500)
}

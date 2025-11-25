//
//  StageView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 24/11/25.
//

import SwiftUI

struct StageView: View {
    let stageData : StageData
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: CGFloat(stageData.width),height: CGFloat(stageData.height))
                .overlay{
                    Rectangle()
                        .stroke(.black,lineWidth: 2)
                }
            Text(stageData.label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
                .rotationEffect(.degrees(-45))
        }
    }
}

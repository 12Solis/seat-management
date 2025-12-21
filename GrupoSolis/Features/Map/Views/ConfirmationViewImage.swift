//
//  ConfirmationViewImage.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 21/12/25.
//

import SwiftUI
import Kingfisher

struct ConfirmationViewImage: View {
    let event: Event
    var body: some View {
        if let imageString = event.image, let url = URL(string: imageString) {

            KFImage(url)
                .placeholder {
                    ProgressView()
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.1))
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .clipShape(UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20)
                ))
                
        } else {
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20))
                .foregroundStyle(.principalBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
        }
    }
}


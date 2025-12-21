//
//  EventListElement.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 01/12/25.
//

import SwiftUI
import Kingfisher

struct EventListElement: View {
    let event: Event
    var body: some View {
        VStack(spacing: 0) {
            KFImage(URL(string: event.image ?? "https://firebasestorage.googleapis.com/v0/b/gruposolisapp.firebasestorage.app/o/Common%2FnoImage.jpg?alt=media&token=d098627e-df23-43cb-81d6-b262444559d0"))
                .placeholder {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.gray.opacity(0.1))
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: UIScreen.main.bounds.width, height: 80)))
                .scaleFactor(UIScreen.main.scale)
                .cacheOriginalImage()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .clipped()

            ZStack(alignment: .leading) {
                Color.principalBlue
                    .frame(height: 80)
                
                HStack(spacing: 0) {
                    ZStack {
                        Color.black.opacity(0.4)
                        
                        VStack {
                            Text(event.date.formatted(.dateTime.month(.abbreviated)))
                                .foregroundStyle(.accentGray)
                                .font(.title3)
                            Text(event.date.formatted(.dateTime.day(.defaultDigits)))
                                .foregroundStyle(.accentGray)
                                .font(.title)
                        }
                    }
                    .frame(width: 80, height: 80)
                    
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .foregroundStyle(.accentGray)
                            .font(.title)
                            .lineLimit(1)
                        Text(event.place)
                            .foregroundStyle(.accentGray)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                }
            }
            .frame(height: 80)
        }
        .background(Color.principalBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))

    }
}
#Preview {
    EventListElement(event: Event(name: "Prueba de Evento", date: Date(), place: "Lugar de prueba", seats:100))
}

//
//  ZoomableScrollView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 25/11/25.
//

import SwiftUI

struct ZoomableScrollView <Content: View> : View {
    let content: Content
    @StateObject private var viewModel = ZoomableViewModel()
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    
    var body: some View {
        GeometryReader{ geometry in
            ScrollView([.horizontal,.vertical],showsIndicators: true){
                ZStack{
                    content
                }
                .frame(
                    width: geometry.size.width * 2,
                    height: geometry.size.height * 2,
                    alignment: .center
                )
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged{value in
                            let delta = value / viewModel.lastScale
                            viewModel.lastScale = value
                            viewModel.updateScale(viewModel.scale * delta)
                        }
                        .onEnded{ _ in
                            viewModel.lastScale = 1.0
                        }
                        
                )
                .gesture(
                    DragGesture()
                        .onChanged{value in
                            viewModel.updateOffset(
                                CGSize(
                                    width: viewModel.lastOffset.width + value.translation.width ,
                                    height: viewModel.lastOffset.height + value.translation.height
                                )
                            )
                        }
                        .onEnded{ value in
                            viewModel.lastOffset = viewModel.offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()){
                        viewModel.reset()
                    }
                }
                
            }
        }
    }
}

//
//  ZoomableViewModel.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 25/11/25.
//

import Foundation
import SwiftUI
import Combine

class ZoomableViewModel: ObservableObject {
    @Published var scale: CGFloat = 1.0
    @Published var lastScale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    
    let minScale: CGFloat = 0.5
    let maxScale: CGFloat = 3.0
    
    func updateScale(_ newScale: CGFloat){
        scale = min(max(newScale, minScale), maxScale)
    }
    func updateOffset(_ newOffset: CGSize){
        offset = newOffset
    }
    func reset(){
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }
}

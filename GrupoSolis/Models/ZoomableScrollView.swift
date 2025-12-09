//
//  ZoomableScrollView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 25/11/25.
//

import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    private var mapSize: CGSize

    init(mapSize: CGSize, @ViewBuilder content: () -> Content) {
        self.mapSize = mapSize
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.1
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = []
        hostedView.backgroundColor = .clear
        
        hostedView.frame = CGRect(origin: .zero, size: mapSize)
        scrollView.contentSize = mapSize
        scrollView.addSubview(hostedView)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content

        if !context.coordinator.hasSetInitialZoom {
            DispatchQueue.main.async {
                let visibleW = uiView.bounds.width
                let visibleH = uiView.bounds.height
                                
                if visibleW > 0 && visibleH > 0 {
                    let scaleToFit = min(visibleW / mapSize.width, visibleH / mapSize.height) * 0.95
                    let startingZoom = min(scaleToFit * 1.8, 5.0)
                    uiView.minimumZoomScale = scaleToFit
                    uiView.setZoomScale(startingZoom, animated: false)
                                    
                    let offsetX = (mapSize.width * startingZoom - visibleW) / 2
                    let offsetY = (mapSize.height * startingZoom - visibleH) / 2
                    uiView.contentOffset = CGPoint(x: max(0, offsetX), y: max(0, offsetY))
                                
                    context.coordinator.hasSetInitialZoom = true
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        var hasSetInitialZoom = false

        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}

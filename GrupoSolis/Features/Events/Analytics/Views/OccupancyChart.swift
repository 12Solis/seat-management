//
//  OccupancyChart.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 14/12/25.
//

import SwiftUI

struct OccupancyChart: View {
    let event: Event
    let soldSeats: Double
    let reservedSeats: Double
    
    @State private var animationProgress = 0.0
    
    var percentageSold: Double {
        soldSeats / Double(event.seats)
    }
    var totalPercentageOccupied: Double {
        percentageSold + reservedSeats / Double(event.seats)
    }
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.7), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: percentageSold *  animationProgress)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(lineWidth: 20,lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))
            
            
            Circle()
                .trim(from:percentageSold * animationProgress, to: totalPercentageOccupied * animationProgress)
                .stroke(
                    Color.orange,
                    style: StrokeStyle(lineWidth: 20, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))
            
            
            VStack {
                RollingText(value: percentageSold * animationProgress)
 
                Text("Ocupado")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .frame(width: 150, height: 150)
        .onAppear{
            withAnimation(.easeInOut(duration: 1.5)){
                animationProgress = 1
            }
        }
    }
    
}

struct RollingText: View, Animatable {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        Text("\(value, format: .percent.precision(.fractionLength(1)))")
            .font(.title)
            .bold()
            .monospacedDigit()
    }
}

#Preview {
    OccupancyChart(
        event:Event(name: "Prueba de Evento", date: Date(), place: "Estadio de pruebas",seats: 100),
        soldSeats: 15, reservedSeats: 15
    )
}

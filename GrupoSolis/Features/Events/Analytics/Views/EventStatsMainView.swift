//
//  EventStats.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 14/12/25.
//

import SwiftUI

struct EventStatsMainView: View {
    @ObservedObject var viewModel : SeatMapViewModel
    let event: Event
    var body: some View {
        ZStack{
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            VStack{
                ZStack {
                    BackgroundRectangle()
                    VStack{
                        Spacer()
                        Text("Ingresos Totales")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Text("$\(viewModel.totalRevenue.formatted())")
                            .font(.largeTitle)
                            .bold()
                        Text("$\(viewModel.totalCash.formatted())")
                        
                        Spacer()
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color(uiColor: .systemGroupedBackground))
                                    .frame(width: 170,height:20)
                                Text("Boletos Vendidos: \(viewModel.soldSeatsCount) / \(event.seats)")
                                    .font(.caption)
                                    .bold()
                            }
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color(uiColor: .systemGroupedBackground))
                                    .frame(width: 170,height:20)
                                Text("Boletos Reservados: \(viewModel.reservedSeatsCount)")
                                    .font(.caption)
                                    .bold()
                            }
                            Spacer()
                        }
                        
                    }
                    .frame(height: 178)
                }
                .padding(.vertical)
                
                ZStack {
                    BackgroundRectangle()
                    HStack{
                        OccupancyChart(event: event, soldSeats: Double(viewModel.soldSeatsCount), reservedSeats: Double(viewModel.reservedSeatsCount))
                            .padding(.trailing)
                        VStack(alignment: .leading){
                            Text("Ocupación")
                                .font(.title3)
                                .bold()
                            ColorLabel(label: "Vendidos", color: .blue)
                            ColorLabel(label: "Reservados", color: .orange)
                            ColorLabel(label: "Disponibles", color: .gray)

                        }
                        .padding(.leading)
                    }
                    .frame(height: 178)
                }
                .padding(.bottom)
                
                HStack{
                    ZStack{
                        BackgroundRectangle()
                        PaymentMethodGraph(isCash: true, totalAmount: viewModel.totalRevenue, totalInCash: viewModel.totalCash)
                    }
                    Spacer()
                    ZStack{
                        BackgroundRectangle()
                        PaymentMethodGraph(isCash: false, totalAmount: viewModel.totalRevenue, totalInCash: viewModel.totalCash)
                    }
                }

            }
        }
    }

}

struct ColorLabel: View {
    var label: String
    var color: Color
    
    var body: some View {
        HStack{
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption)
                .bold()
                .padding(.horizontal,-3)
        }
    }
}

struct BackgroundRectangle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .padding(.horizontal)
            .frame(height: 200)
            .foregroundStyle(.white)
            .shadow(radius: 10)
    }
}

#Preview {
    EventStatsMainView(
        viewModel: SeatMapViewModel() ,
        event:Event(name: "Prueba de Evento", date: Date(), place: "Estadio de pruebas",seats: 100)
    )
}

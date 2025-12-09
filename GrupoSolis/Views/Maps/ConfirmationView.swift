//
//  ConfirmationView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 06/12/25.
//

import SwiftUI

struct ConfirmationView: View {
    let event: Event
    let section: String
    let row: String
    let seats: String
    let pendingPayment: Double
    @Binding var isSheetPresented: Bool
    @State private var navigatingToHome = false
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundStyle(Color(uiColor: .systemGroupedBackground))
                .ignoresSafeArea()
            VStack{
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                    .padding()
                Text("¡Reserva Confirmada!")
                    .font(.title)
                    .bold()
                
                ZStack(alignment:.top) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.white)
                            .frame(width: 300, height: 400)
                        VStack {
                            HStack {
                                Circle()
                                    .trim(from:0.0, to:0.5)
                                    .frame(width: 40)
                                    .rotationEffect(.degrees(-90))
                                    .foregroundStyle(Color(uiColor: .systemGroupedBackground))
                                Spacer()
                                dottedLine()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundStyle(Color.gray.opacity(0.5))
                                    .frame(height: 1)
                                    .padding(.horizontal, 5)
                                Spacer()
                                Circle()
                                    .trim(from:0.0, to:0.5)
                                    .frame(width: 40)
                                    .rotationEffect(.degrees(90))
                                    .foregroundStyle(Color(uiColor: .systemGroupedBackground))
                            }
                            .padding(.top,180)
                        }
                        .frame(width: 340, height: 400)
                        if !(pendingPayment==0) {
                            Text("PENDIENTE")
                                .font(.system(size: 45, weight: .heavy, design: .rounded))
                                .foregroundStyle(.orange.opacity(0.25))
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.orange.opacity(0.25), lineWidth: 4)
                                )
                                .rotationEffect(.degrees(-25))
                                .offset(x: 0, y: -20)
                        }
                    }
                    VStack{
                        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20))
                            .foregroundStyle(.principalBlue)
                            .frame(width: 300, height: 80)
                        Text(event.name)
                            .textCase(.uppercase)
                            .font(.title2)
                            .bold()
                            .padding(.top,3)
                        Text((event.date).formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day(.twoDigits).hour().minute().locale(Locale(identifier: "es_MX"))))
                            .foregroundStyle(.gray)
                            .bold()
                            .padding(1)
                        Text(event.place)
                            .foregroundStyle(.gray)
                            .bold()
                            .padding(.top,-6)
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color(.gray).opacity(0.07))
                                .frame(width: 250,height: 60)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.gray).opacity(0.25), lineWidth: 2)
                                }
                            HStack{
                                Spacer()
                                VStack{
                                    Text("SECCIÓN")
                                        .foregroundStyle(.gray)
                                        .bold()
                                    Text(section)
                                        .font(.title2)
                                        .bold()
                                }
                                Spacer()
                                Divider()
                                Spacer()
                                VStack(){
                                    Text("FILA")
                                        .foregroundStyle(.gray)
                                        .bold()
                                    Text(row)
                                        .font(.title2)
                                        .bold()
                                }
                                Spacer()
                                Divider()
                                Spacer()
                                VStack{
                                    Text("ASIENTOS")
                                        .foregroundStyle(.gray)
                                        .bold()
                                    Text(seats)
                                        .font(.title2)
                                        .bold()
                                }
                                Spacer()
                            }
                            .frame(width:250,height: 60)
                            .padding(.vertical)
                        }
                        Spacer()
                        VStack{
                            if pendingPayment == 0{
                                Text("¡Gracias por tu compra!")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.principalBlue)
                                Spacer()
                                Text("Pregunta por las opciones que tenemos para entregar tus boletos")
                                    .multilineTextAlignment(.center)
                                    .font(.callout)
                                    .bold()
                                .padding(.horizontal,33)
                                Spacer()
                            }else{
                                Spacer()
                                Text("Hemos procesado tu reserva")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.principalBlue)
                                Spacer()
                                Text("Saldo restante: $\(pendingPayment.formatted()) ")
                                    .foregroundStyle(.orange)
                                    .font(.headline)
                                    .bold()
                                .padding(.horizontal,33)
                                Spacer()
                            }
                        }
                        .frame(width: 340,height: 100)
                        
                    }
                    .frame(width: 340, height: 400)
                }
                
            }
        }
        .toolbar{
            ToolbarItem(placement: .confirmationAction){
                Button("Ok"){
                    isSheetPresented = false
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

import SwiftUI

struct dottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

#Preview {
    ConfirmationView(
        event:Event(name: "Prueba de Evento", date: Date(), place: "Estadio de pruebas"),
        section: "A",
        row: "2",
        seats: "1,2",
        pendingPayment: 100,
        isSheetPresented: .constant(true)
    )
}

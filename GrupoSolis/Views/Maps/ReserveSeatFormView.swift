//
//  ReserveSeatFormView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 05/12/25.
//

import SwiftUI
import FirebaseAuth

struct ReserveSeatFormView: View {
    @StateObject private var eventService = EventService()
    @EnvironmentObject private var authService: AuthenticationService
    let event: Event
    
    @Binding var selectedSeats: [Seat]
    @Binding var isPresented: Bool
    @State private var buyerName = ""
    @State private var fullyPaid = false
    @State private var amountPaid: Double = 0.0
    @State private var paymentMethod: PaymentMethods = .cash
    @State private var newStatus: SeatStatus = .reserved
    
    @State private var confirmedSection = ""
    @State private var confirmedRow = ""
    @State private var confirmedSeats = ""
    @State private var confirmedPendingPayment = 0.0
    
    @FocusState private var isFocused: Bool
    @State private var errorMessage = ""
    @State private var isAlertVisible = false
    @State private var isNavigatingToConfirmation = false
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 18)
                        .foregroundColor(.white)
                        .frame(width: 330, height: 220)
                        .shadow(color: Color.black.opacity(0.8), radius: 10)
                    VStack{
                        HStack{
                            Spacer()
                            VStack{
                                Text("SECCIÓN")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text(getSection())
                                    .font(.title2)
                                    .bold()
                            }
                            Spacer()
                            Divider()
                            Spacer()
                            VStack{
                                Text("FILA")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text(getRowText())
                                    .font(.title2)
                                    .bold()
                            }
                            Spacer()
                            Divider()
                            Spacer()
                            VStack{
                                Text(selectedSeats.count > 1 ? "ASIENTOS" : "ASIENTO")
                                    .foregroundStyle(.gray)
                                    .bold()
                                Text(getSeatNumber())
                                    .font(.title2)
                                    .bold()
                            }
                            Spacer()
                        }
                        .frame(height: 80)
                        Divider()
                        
                        Text("Boletos(x\(selectedSeats.count)): ")
                        Text("TOTAL: $\(getTotalPrice().formatted())")
                            .font(.title)
                            .bold()
                    }
                }
                .frame(width: 330,height: 220)
                .padding(.bottom,20)
                VStack(alignment: .leading) {
                    Text("Nombre del comprador:")
                        .font(.headline)
                    TextField("Juan Perez",text: $buyerName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom,20)
                    
                    Text("Cantidad pagada")
                        .font(.headline)
                    Picker("", selection: $fullyPaid){
                        Text("Pago Completo").tag(true)
                        Text("Anticipo").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: fullyPaid) {
                        if fullyPaid {
                            amountPaid = getTotalPrice()
                        } else {
                            amountPaid = 0.0
                            isFocused = true
                        }
                    }
                    
                    TextField("Monto", value:$amountPaid, format: .currency(code:("MXN")))
                        .disabled(fullyPaid)
                        .foregroundStyle(fullyPaid ? Color(.gray).opacity(0.7) : .black)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .toolbar {
                            if isFocused {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Listo") {
                                        isFocused = false
                                    }
                                }
                            }
                        }
                        .padding(.bottom,20)
                    
                    Text("Método de pago:")
                        .font(.headline)
                    Picker("Método de pago", selection: $paymentMethod) {
                        ForEach(PaymentMethods.allCases){method in
                            Text(method.rawValue)
                                .tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom,20)
                }
                Button{
                    if fullyPaid{amountPaid = getTotalPrice()}
                    if amountPaid > getTotalPrice(){
                        errorMessage = "La cantidad pagada no debe ser mayor a la del total"
                        isAlertVisible = true
                    } else {
                        if amountPaid == getTotalPrice(){
                            newStatus = .sold
                            updateSelectedSeats()
                        }else{
                            newStatus = .reserved
                            updateSelectedSeats()
                        }
                    }
                    
                }label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 300, height: 50)
                        Text("Reservar")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                .padding(.bottom, -10)
            }
            .frame(width: 330)
            .alert("",isPresented: $isAlertVisible){
                
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(isPresented: $isNavigatingToConfirmation){
                ConfirmationView(
                    event: event,
                    section: confirmedSection,
                    row: confirmedRow,
                    seats: confirmedSeats,
                    pendingPayment: confirmedPendingPayment,
                    isSheetPresented: $isPresented
                )
            }
        }
    }
    
    private func updateSelectedSeats(){
        guard let userId = authService.user?.uid else { return }
            
        eventService.updateSelectedSeats(seats: selectedSeats, userId: userId, newStatus: newStatus, buyer: buyerName, amountPaid: amountPaid/Double(selectedSeats.count)) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Asientos guarados")
                        self.confirmedSection = getSection()
                        self.confirmedRow = getRowText()
                        self.confirmedSeats = getSeatNumber()
                        self.confirmedPendingPayment = getTotalPrice() - amountPaid
                        
                        self.selectedSeats.removeAll()
                        isNavigatingToConfirmation = true
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
    
    private func getSection() -> String {
        guard let firstSeat = selectedSeats.first else { return "-" }
        
        let allSameSection = selectedSeats.allSatisfy{$0.section == firstSeat.section}
        if !allSameSection { return "Varios" }
        
        var sectionName = ""
        switch firstSeat.section {
        case 0:
            sectionName = "A"
        case 1:
            sectionName = "B"
        case 2:
            sectionName = "C"
        case 3:
            sectionName = "D"
        case 4:
            sectionName = "E"
        default:
            sectionName = "N/A"
        }
        return sectionName
    }
    
    private func getRowText() -> String {
        guard let firstSeat = selectedSeats.first else { return "-" }
        
        let allSameRow = selectedSeats.allSatisfy { $0.row == firstSeat.row }
        if !allSameRow {
            return "Var"
        } else {
            return "\(firstSeat.row)"
        }
    }
    
    private func getSeatNumber() -> String {
        if selectedSeats.count > 3 {
            let primero = selectedSeats.first?.number ?? 0
            let ultimo = selectedSeats.last?.number ?? 0
            return "\(primero)...\(ultimo)"
        }else{
            return selectedSeats
                .map { "\($0.number)" }
                .joined(separator: ", ")
        }
    }
    
    private func getTotalPrice() -> Double {
        var totalPrice = 0.0
        for seat in selectedSeats {
            totalPrice += seat.price ?? 0.0
        }
        return totalPrice
    }
}


#Preview {
    ReserveSeatFormView(
        event:Event(name: "Prueba", date: Date(), place: "Prueba") ,
        selectedSeats: .constant([
            Seat(seatMapId: "", section: 1, row: 1, number: 1, status: .available,lastUpdatedBy: "", price: 200),
            Seat(seatMapId: "", section: 1, row: 1, number: 2, status: .available, lastUpdatedBy: "", price: 200),]),
        isPresented: .constant(true))
}

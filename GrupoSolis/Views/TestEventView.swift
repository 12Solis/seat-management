//
//  TestEventView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI

struct TestEventsView: View {
    @StateObject private var eventVM = EventViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @State private var selectedEventId: String? = nil
    @State private var isShowingTemplateSelection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Gestor de Eventos")
                    .font(.title)
                    .bold()
                
                Button("Crear Nuevo Evento desde Plantilla") {
                    isShowingTemplateSelection = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(eventVM.isLoading)
                
                if let eventId = selectedEventId ?? eventVM.events.first?.id {
                    NavigationLink("Ver Mapa de Asientos del Evento Seleccionado") {
                        SeatMapView(seatMapId: getSeatMapIdForEvent(eventId: eventId))
                            .environmentObject(authService)
                    }
                    .buttonStyle(.bordered)
                }
                
               
                if eventVM.isLoading {
                    ProgressView("Cargando...")
                }
                
                if !eventVM.errorMessage.isEmpty {
                    Text(eventVM.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                
                VStack(alignment: .leading) {
                    Text("Eventos Existentes (\(eventVM.events.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List(eventVM.events) { event in
                        VStack(alignment: .leading) {
                            Text(event.name)
                                .font(.headline)
                            Text("Lugar: \(event.place)")
                                .font(.subheadline)
                            Text("Fecha: \(event.date, style: .date)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .onTapGesture {
                            selectedEventId = event.id
                            print("Evento seleccionado: \(event.name) - ID: \(event.id ?? "nil")")
                        }
                        .background(selectedEventId == event.id ? Color.blue.opacity(0.1) : Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationBarItems(leading: Button("Logout"){authService.signOut()})
            .padding()
            .onAppear {
                eventVM.fetchEvents()
            }
            .sheet(isPresented: $isShowingTemplateSelection) {
                TemplateSelectionView()
                    .onDisappear {
                        
                        eventVM.fetchEvents()
                    }
                
            }
        }
    }
    
    private func getSeatMapIdForEvent(eventId: String) -> String {
        return UserDefaults.standard.string(forKey: "seatMapId_\(eventId)") ?? "test-map"
    }
}

#Preview {
    TestEventsView()
        .environmentObject(AuthenticationService())
}

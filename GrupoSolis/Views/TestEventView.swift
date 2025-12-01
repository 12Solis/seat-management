//
//  TestEventView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 20/11/25.
//

import SwiftUI

struct TestEventsView: View {
    @StateObject private var eventVM = EventViewModel()
    @State private var eventService = EventService()
    @EnvironmentObject private var authService: AuthenticationService
    
    @State private var selectedEventId: String? = nil
    @State private var selectedSeatMapId: String? = nil
    @State private var isShowingTemplateSelection = false
    @State private var isNavigatingToSeatMap = false
    @State private var isLoadingMap = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Gestor de Eventos")
                    .font(.title)
                    .bold()
                
                Button("Crear Nuevo Evento desde Plantilla") {
                    isShowingTemplateSelection = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(eventVM.isLoading)
                
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            fetchAndOpenMap(for: event)
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
            .navigationDestination(isPresented: $isNavigatingToSeatMap) {
                if let mapId = selectedSeatMapId {
                    SeatMapView(seatMapId: mapId)
                        .environmentObject(authService)
                } else {
                    Text("Error: No se encontró el ID del mapa")
                }
            }
            .sheet(isPresented: $isShowingTemplateSelection) {
                TemplateSelectionView()
                    .onDisappear {
                        
                        eventVM.fetchEvents()
                    }
            }
            
        }
        .onAppear {
            eventVM.fetchEvents()
        }
    }
    
    private func fetchAndOpenMap(for event: Event) {
        guard let eventId = event.id else { return }
        isLoadingMap = true
        
        eventService.fetchSeatMaps(forEventId: eventId){ result in
            DispatchQueue.main.async {
                self.isLoadingMap = false
                switch result{
                case .success(let maps):
                    if let firstMap = maps.first, let mapId = firstMap.id {
                        print("Mapa encontrado en la nube: \(mapId)")
                        self.selectedSeatMapId = mapId
                        self.isNavigatingToSeatMap = true
                    } else {
                        print("Mapa no encontrado en Firebase")
                    }
                case .failure(let error):
                    print("Error al obtener mapas: \(error)")
                }
            }
        }
    }
}

#Preview {
    TestEventsView()
        .environmentObject(AuthenticationService())
}

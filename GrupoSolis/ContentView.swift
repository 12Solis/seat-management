//
//  ContentView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @StateObject private var eventVM = EventViewModel()
    @State private var eventService = EventService()
    @EnvironmentObject private var authService: AuthenticationService
    
    @State private var selectedEvent: Event? = nil
    @State private var selectedSeatMapId: String? = nil
    @State private var isShowingTemplateSelection = false
    @State private var isNavigatingToSeatMap = false
    @State private var isLoadingMap = false
    
    @State private var showDeleteAlert = false
    @State private var eventToDelete: Event? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Proximos Eventos")
                    .foregroundStyle(.principalBlue)
                    .font(.title)
                    .bold()
                
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
                    
                    List {
                        ForEach(eventVM.events){event in
                            
                            EventListElement(event: event)
                                .shadow(radius: 10)
                                .onTapGesture {
                                    selectedEvent = event
                                    fetchAndOpenMap(for: event)
                                    print("Evento seleccionado: \(event.name) - ID: \(event.id ?? "nil")")
                                }
                        }
                        .onDelete(perform: askForDeletion)
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        eventVM.fetchEvents()
                    }
                }
                
                Spacer()
            }
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cerrar Sesión"){authService.signOut()}
                }
                ToolbarItem(placement: .confirmationAction){
                    Button{
                        isShowingTemplateSelection = true
                    }label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.principalBlue)
                            .disabled(eventVM.isLoading)
                    }
                }
            }
            .padding()
            .navigationDestination(isPresented: $isNavigatingToSeatMap) {
                if let mapId = selectedSeatMapId {
                    SeatMapView(seatMapId: mapId,event: selectedEvent!)
                        .environmentObject(authService)
                } else {
                    Text("Error: No se encontró el ID del mapa")
                }
            }
            .sheet(isPresented: $isShowingTemplateSelection,onDismiss:{eventVM.fetchEvents()}) {
                NavigationStack {
                    TemplateSelectionView(sheetPresented: $isShowingTemplateSelection)
                        .onDisappear {
                            eventVM.fetchEvents()
                        }
                }
            }
            .alert("Eliminar evento",isPresented:$showDeleteAlert){
                Button("Cancelar",role: .cancel){
                    eventToDelete = nil
                }
                Button("Eliminar", role: .destructive){
                    if let event = eventToDelete {
                        deleteEvent(event)
                    }
                }
            }message: {
                Text("¿Estás seguro? Esta acción borrará el evento, su mapa y todos sus asientos. Esta acción no se puede deshacer.")
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
    
    private func askForDeletion(at offsets: IndexSet) {
        if let index = offsets.first {
            let event = eventVM.events[index]
            self.eventToDelete = event
            self.showDeleteAlert = true
        }
    }
    
    private func deleteEvent(_ event: Event) {
        guard let eventId = event.id else { return }
        
        eventService.deleteEvent(eventId: eventId) { result in
            DispatchQueue.main.async {
                switch result{
                case .success:
                    print("Evento eliminado")
                    self.eventToDelete = nil
                    eventVM.fetchEvents()
                case .failure:
                    print("Error eliminando el evento")
                }
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(AuthenticationService())
}

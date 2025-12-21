//
//  CreateEventFormView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 30/11/25.
//

import SwiftUI
import PhotosUI

struct CreateEventFormView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var eventVM = EventViewModel()
    @State private var eventService = EventService()
    var viewModel: TemplateViewModel
    
    let selectedTemplate: SeatMapTemplate?
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var date = Date()
    @State private var location = ""
    let totalSeats: Int
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var isCreatingEvent = false
    
    @State private var isPriceActive = false
    @State private var pricingConfigs: [SectionPricingConfig] = []
    
    var body: some View {
        VStack{
            if isCreatingEvent{
                ProgressView("Creando evento...")
            }
            
            Text(selectedTemplate?.name ?? "")
                .font(.title)
                .bold()
            List{
                Section("Datos generales"){
                    TextField("Nombre del evento",text: $name)
                    DatePicker("Selecciona la fecha", selection:$date,in: Date.now... ,displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                    TextField("Lugar",text: $location)
                    HStack {
                        Text("Imagen (Portada)")
                        Spacer()
                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                                            
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text(selectedImage == nil ? "Seleccionar" : "Cambiar")
                        }
                    }
                    .onChange(of: selectedItem) { _ ,newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                            let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
                    }
                }
                Section("Configuración de precios"){
                    Toggle("Activar precios", isOn: $isPriceActive)
                    
                    if isPriceActive{
                        ForEach($pricingConfigs){$sectionConfig in
                            VStack(alignment:.leading, spacing: 10){
                                Text("Sección: \(sectionConfig.sectionName)")
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                                Toggle("Precio unico para toda la sección", isOn:$sectionConfig.appliesToAllRows)
                                if sectionConfig.appliesToAllRows{
                                    HStack{
                                        Text("Precio General:")
                                        Spacer()
                                        TextField("0.0", value:$sectionConfig.unifiedPrice, format:.currency(code:"MXN"))
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 100)
                                    }
                                }else{
                                    DisclosureGroup("Configurar filas individualmente"){
                                        ForEach($sectionConfig.rows){$rowConfig in
                                            HStack{
                                                Text(rowConfig.label)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Spacer()
                                                TextField("0.0", value:$rowConfig.price, format: .currency(code:"MXN"))
                                                    .keyboardType(.decimalPad)
                                                    .multilineTextAlignment(.trailing)
                                                    .textFieldStyle(.roundedBorder)
                                                    .frame(width:100)
                                            }
                                        }
                                    }
                                }
                                
                            }
                            .padding(.vertical,4)
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
            
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Creación de evento")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar{
            ToolbarItem(placement: .confirmationAction){
                Button("Ok"){
                    if isFornmValid() {
                        createEventFromTemplate(selectedTemplate!)
                    } else {
                        errorMessage = "Por favor llena todos los campos"
                        showAlert = true
                    }
                }
            }
            ToolbarItem(placement:.cancellationAction){
                Button("Cancelar"){
                    dismiss()
                }
            }
        }
        .onAppear{
            initPricing()
        }
        .alert("",isPresented: $showAlert) {
        }message: {
            Text(errorMessage)
        }
        .scrollDismissesKeyboard(.interactively)

        
    }
    
    private func isFornmValid() -> Bool {
        return !name.isEmpty && !location.isEmpty && date > Date()
    }
    
    private func initPricing() {
        guard let template = selectedTemplate else { return }
        self.pricingConfigs = template.layoutData.sections.enumerated().map{ (secIndex, sectionData) in
            let rowConfigs = sectionData.rows.map{ rowData in
                let rIndex = Int(rowData.name) ?? 0
                return RowPricingConfig(rowIndex: rIndex, label: "Fila: \(rowData.name)")
            }
            let secName = ["A", "B", "C", "D", "E"][secIndex]
            return SectionPricingConfig(sectionIndex: secIndex, sectionName: secName, appliesToAllRows: true,unifiedPrice: 0.0 ,rows: rowConfigs)
        }
    }
    
    private func createEventFromTemplate(_ template: SeatMapTemplate) {
            isCreatingEvent = true 
            errorMessage = ""
            
            let finalStep: (String?) -> Void = { imageURL in
                
                let newEvent = Event(
                    name: name,
                    date: date,
                    place: location,
                    isPriceActive: isPriceActive,
                    image: imageURL,
                    seats: totalSeats
                )
                
                var compiledPrices: [Int : [Int : Double]] = [:]
                if isPriceActive {
                    for section in pricingConfigs {
                        var rowDict: [Int: Double] = [:]
                        if section.appliesToAllRows {
                            for row in section.rows {
                                rowDict[row.rowIndex] = section.unifiedPrice
                            }
                        } else {
                            for row in section.rows {
                                rowDict[row.rowIndex] = row.price
                            }
                        }
                        compiledPrices[section.sectionIndex] = rowDict
                    }
                }
                
                print("Creando evento en Firestore...")
                
                eventVM.createEvent(newEvent) { result in
                    switch result {
                    case .success(let eventId):
                        print("Evento creado con ID: \(eventId)")
                        
                        self.viewModel.createFromTemplate(template: template, eventId: eventId, prices: compiledPrices) { seatMapResult in
                            DispatchQueue.main.async {
                                self.isCreatingEvent = false
                                
                                switch seatMapResult {
                                case .success(let seatMapId):
                                    print("Mapa creado con ID: \(seatMapId)")
                                    isPresented = false
                                case .failure(let error):
                                    self.errorMessage = "Error creando mapa: \(error.localizedDescription)"
                                }
                            }
                        }
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.isCreatingEvent = false
                            self.errorMessage = "Error creando evento: \(error.localizedDescription)"
                        }
                    }
                }
            }

            if let imageToUpload = selectedImage {
                print("Subiendo imagen...")
                eventService.processAndUploadImage(originalImage: imageToUpload) { url in
                    if let url = url {
                        finalStep(url)
                    } else {
                        DispatchQueue.main.async {
                            self.isCreatingEvent = false
                            self.errorMessage = "Error al subir la imagen. Intenta de nuevo."
                            self.showAlert = true
                        }
                    }
                }
            } else {
                print("Creando evento sin imagen...")
                finalStep(nil)
            }
        }
    
}

#Preview {
    CreateEventFormView(viewModel: TemplateViewModel(), selectedTemplate: nil, isPresented: .constant(true), totalSeats: 200)
}

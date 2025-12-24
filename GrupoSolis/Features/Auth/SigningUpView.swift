//
//  SigningUpView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import SwiftUI

struct SigningUpView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var accessCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var succesfullSigngUp = false
    var authService: AuthenticationService
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    Section(header: Text("Email")){
                        LoginTexfieldElement(label: "email", field: $email)
                            .padding(.vertical,-10)
                    }
                    Section(header: Text("Contraseña")){
                        LoginTexfieldElement(label: "password", field: $password)
                            .padding(.vertical,-10)
                    }
                    Section(header: Text("Confirmar contraseña")){
                        LoginTexfieldElement(label: "password", field: $passwordConfirmation)
                            .padding(.vertical,-10)
                        
                    }
                    Section(header:Text("Código de acceso")){
                        LoginTexfieldElement(label: "Codigo", field: $accessCode)
                            .padding(.vertical,-10)
                    }
                    HStack {
                        Spacer()
                        Button("Registrarse"){
                            if password.isEmpty || password != passwordConfirmation{
                                alertMessage = "Las contraseñas no coinciden"
                                succesfullSigngUp = false
                                showAlert = true
                                return
                            }
                            if accessCode.isEmpty{
                                alertMessage = "Por favor introduce el codigo de acceso proporcionado por el administrador"
                                succesfullSigngUp = false
                                showAlert = true
                                return
                            }
                            
                            authService.signUp(email: email, password: password,accessCode: accessCode){result in
                                DispatchQueue.main.async {
                                    switch result{
                                    case .success:
                                        alertMessage = "Usuario registrado con éxito"
                                        succesfullSigngUp = true
                                        showAlert = true
                                        
                                    case .failure(let error):
                                        alertMessage = "Error: \(error.localizedDescription)"
                                        succesfullSigngUp = false
                                        showAlert = true
                                    }
                                }
                            }

                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.principalBlue)
                        Spacer()
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .alert("",isPresented: $showAlert) {
                Button("OK"){
                    if succesfullSigngUp {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .padding()
            .navigationTitle("Registro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement:.cancellationAction){
                    Button("Cancelar"){
                        dismiss()
                    }
                }
            }
            
        }
        
    }
}

#Preview {
    SigningUpView(authService: AuthenticationService())
}

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
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled()
                    }
                    Section(header: Text("Password")){
                        SecureField("Password",text: $password)
                            .textFieldStyle(.roundedBorder)
                        SecureField("Confirm Password:",text: $passwordConfirmation)
                            .textFieldStyle(.roundedBorder)
                    }
                    Section(header:Text("Código de acceso")){
                        TextField("Código", text: $accessCode)
                            .autocapitalization(.allCharacters)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled()
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
                            /*if !password.isEmpty && password == passwordConfirmation{
                                if !accessCode.isEmpty{
                                    authService.signUp(email: email, password: password,accessCode: accessCode){result in
                                        switch result{
                                        case .success:
                                            alertMessage = "Usuario registrado con éxito"
                                            showAlert.toggle()
                                            succesfullSigngUp = true
                                            
                                        case .failure(let error):
                                            alertMessage = "Error al registrar el usuario: \(error.localizedDescription)"
                                            showAlert.toggle()
                                            succesfullSigngUp = false
                                        }
                                        
                                    }
                                }else{
                                    alertMessage = "Por favor introduce el codigo de acceso proporcionado por el administrador"
                                    showAlert.toggle()
                                    succesfullSigngUp = false
                                }
                                
                            }else{
                               alertMessage = "Las contraseñas no coinciden"
                                showAlert.toggle()
                                succesfullSigngUp = false
                            }*/
                        }
                        .buttonStyle(.borderedProminent)
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
            
        }
        
    }
}

#Preview {
    SigningUpView(authService: AuthenticationService())
}

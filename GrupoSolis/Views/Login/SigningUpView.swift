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
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var succesfullSigngUp = false
    var authService: AuthenticationService
    
    
    var body: some View {
        NavigationView{
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
                    HStack {
                        Spacer()
                        Button("Registrarse"){
                            if !password.isEmpty && password == passwordConfirmation{
                                authService.signUp(email: email, password: password){result in
                                    switch result{
                                    case .success:
                                        alertMessage = "Usuario registrado con éxito"
                                        showAlert.toggle()
                                        succesfullSigngUp = true
                                        
                                    case .failure:
                                        alertMessage = "Error al registrar el usuario: "
                                        showAlert.toggle()
                                        succesfullSigngUp = false
                                    }
                                    
                                }
                                
                            }else{
                               alertMessage = "Las contraseñas no coinciden"
                                showAlert.toggle()
                                succesfullSigngUp = false
                            }
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
                    } else {
                        showAlert.toggle()
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

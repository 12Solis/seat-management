//
//  LoginView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var errorMessage = ""
    @State private var loggedIn = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack{
                    VStack(alignment:.leading) {
                        Text("Email")
                            .font(.headline)
                            .foregroundStyle(.principalBlue)
                            .padding(.horizontal,4)
                            .padding(.bottom,-3)
                        LoginTexfieldElement(label: "email", field: $email)
                    }
                    .padding()
                    
                    VStack(alignment:.leading) {
                        Text("Contraseña")
                            .font(.headline)
                            .foregroundStyle(.principalBlue)
                            .padding(.horizontal,4)
                            .padding(.bottom,-3)
                        LoginTexfieldElement(label: "password", field: $password)
                    }
                    .padding()
                        
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    
                    Button{
                        authService.signIn(email: email, password: password){ result in
                            switch result {
                            case .success:
                                errorMessage = ""
                                print("Login exitoso")
                                loggedIn = true
                            case .failure(let error):
                                errorMessage = "Error: \(error.localizedDescription)"
                            }
                        }
                    }label: {
                        HStack {
                            Text("Iniciar Sesión")
                                .foregroundStyle(.white)
                                .font(.title3)
                        }
                        .frame(width: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.principalBlue)
                    .padding(.vertical)
                    
                    Button{
                        isSigningUp = true
                    } label: {
                        Text("Registro")
                            .font(.headline)
                            .foregroundStyle(.principalBlue)
                            .underline()
                    }
                    
                }
                .sheet(isPresented: $isSigningUp){
                    SigningUpView(authService: authService)
                }
                .navigationDestination(isPresented: $loggedIn){
                    ContentView()
                }
                .navigationBarBackButtonHidden()
                Spacer()
            }
            .background(.white)
        }
        
        
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationService())
}

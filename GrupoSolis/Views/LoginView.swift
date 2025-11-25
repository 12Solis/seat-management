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
            VStack{
                TextField("email:",text: $email)
                    .padding()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                SecureField("password:",text: $password)
                    .padding()
                    .autocapitalization(.none)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                
                Button("Login"){
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
                }
                .buttonStyle(.borderedProminent)
                Button("Sign Up"){
                    isSigningUp = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $isSigningUp){
                SigningUpView(authService: authService)
            }
            .navigationDestination(isPresented: $loggedIn){
                ContentView()
            }
            .navigationBarBackButtonHidden()
        }
        
        
    }
}

#Preview {
    LoginView()
}

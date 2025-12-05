//
//  ContentView.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    let firebaseService = FirebaseService()
    @StateObject private var authService = AuthenticationService()
    @State private var loggedOut = false
    @State private var isPresented = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Test"){
                firebaseService.testConnection()
            }
            Button("Logout"){
                authService.signOut()
                loggedOut = true
            }
            Button("Sheet"){
                isPresented = true
            }
        }
        .padding()
        .navigationDestination(isPresented: $loggedOut){
            LoginView()
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $isPresented){
            SheetView()
                .interactiveDismissDisabled()
                .presentationDetents([.medium,.large])
                .presentationDragIndicator(.hidden)
                
        }
        
        
    }
}

struct SheetView: View {
    var body: some View {
        VStack{
            Text("Hello")
            Text("Pedro")
                .padding()
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
}

#Preview {
    ContentView()
}

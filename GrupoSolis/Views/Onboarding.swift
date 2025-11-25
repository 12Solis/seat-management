//
//  Onboarding.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import SwiftUI

struct Onboarding: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    var body: some View {
        Group{
            if authService.isAuthenticated {
               // ContentView()
                TestEventsView()
                
            }else{
                LoginView()
            }
        }
        
        
    }
}

#Preview {
    Onboarding()
}

//
//  GrupoSolisApp.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 12/11/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct GrupoSolisApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthenticationService()
    
    var body: some Scene {
        WindowGroup {
            Onboarding()
                .environmentObject(authService)
        }
    }
}

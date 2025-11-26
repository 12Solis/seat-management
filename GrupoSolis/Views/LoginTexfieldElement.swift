//
//  LoginTexfieldElement.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 25/11/25.
//

import SwiftUI

struct LoginTexfieldElement: View {
    @State private var text = ""
    var label: String
    @Binding var field:String

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            
            if label == "email" {
                TextField(label, text: $field)
                    .keyboardType(.emailAddress)
                    .padding()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
            } else{
                SecureField(label,text: $field)
                    .padding()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
            }
                
                
        }
    }
}

#Preview {
    LoginTexfieldElement(label: "password",field: .constant("") )
}

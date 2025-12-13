//
//  LoginTexfieldElement.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 25/11/25.
//

import SwiftUI

struct LoginTexfieldElement: View {
    var label: String
    @Binding var field:String
    
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible = false

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16)
                .fill(.principalBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            
            if label == "email" {
                ZStack(alignment:.leading) {
                    Text(verbatim: "email@example.com")
                        .foregroundStyle(.white)
                        .padding()
                        .opacity(field.isEmpty ? 1 : 0)
                    TextField("", text: $field)
                        .focused($isFocused)
                        .foregroundStyle(.white)
                        .keyboardType(.emailAddress)
                        .padding()
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
            } else{
                HStack{
                    if isPasswordVisible {
                        TextField(label,text: $field)
                            .focused($isFocused)
                            .foregroundStyle(.white)
                            .padding()
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                    } else {
                        SecureField(label,text: $field)
                            .foregroundStyle(.white)
                            .padding()
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                    }
                    Button{
                        isPasswordVisible.toggle()
                    }label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                }
            }
                
                
        }
    }
}

#Preview {
    LoginTexfieldElement(label: "",field: .constant("") )
}

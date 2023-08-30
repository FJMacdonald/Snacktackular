//
//  LoginView.swift
//  Snacktackular
//
//  Created by Francesca MACDONALD on 2023-08-30.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .padding()
            Group {
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                SecureField("Password", text: $password)
                    .submitLabel(.done)
                    .textInputAutocapitalization(.never)
            }
            .textFieldStyle(.roundedBorder)
            //make the border 'pop'
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
            .padding(.horizontal)
            
            HStack {
                Button {
                    register()
                } label: {
                    Text("Sign Up")
                }
                .padding(.trailing)
                Button {
                    login()
                } label: {
                    Text("Log In")
                }
                .padding(.leading)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("SnackColor"))
            .font(.title2)
            .padding(.top)
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }

    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                print("😡 SIGN-UP ERROR: \(error.localizedDescription)")
                alertMessage = ("SIGN-UP ERROR: \(error.localizedDescription)")
                showingAlert = true
            } else {
                print("Registration sucess")
            }
        }
    }
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error {
            print("😡 SIGIN ERROR: \(error.localizedDescription)")
            alertMessage = ("SIGIN ERROR: \(error.localizedDescription)")
            showingAlert = true
        } else {
            print("Login sucess")
        }
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

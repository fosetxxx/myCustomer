//
//  Variables.swift
//  myCustomer
//
//  Created by Semih Karahan on 31.05.2023.
//

import Foundation
import FirebaseAuth

class AuthSection: ObservableObject {
    @Published var user: User?
    @Published var isUserTrue = false
    
    // Kullanıcı oluşturma
    func signUp(emailText: String, passText: String) {
        if emailText == "" && passText == "" {
            Alert().showAlert(title: "Error", message: "Need email or password!")
        } else {
            Auth.auth().createUser(withEmail: emailText, password: passText) { authData, error in
                if error != nil {
                    Alert().showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    Alert().showAlert(title: "Success", message: "Please login")
                }
            }
        }
    }
    
    // Mevcut kullanıcı ile giriş yapma
    func signIn(emailText: String, passText: String) {
        if emailText == "" && passText == "" {
            Alert().showAlert(title: "Error", message: "Need email or password!")
        } else {
            Auth.auth().signIn(withEmail: emailText, password: passText) { authData, error in
                if error != nil {
                    Alert().showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    Alert().showAlert(title: "Success", message: "Successfully logged in")
                }
            }
        }
    }
    
    // Mevcut kullanıcı hesabı açık mı yoksa çıkış yapılmış mı kontrolü
    func checkCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            if (self.user != nil) {
                isUserTrue = true
            }
        }
    }
    
    // Mevcut kullanıcının çıkış yapılması
    func logOut(){
        do {
            try Auth.auth().signOut()
        } catch {
            Alert().showAlert(title: "Error", message: "Error")
        }
    }
    
}

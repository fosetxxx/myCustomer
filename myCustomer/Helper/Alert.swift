//
//  Alert.swift
//  myCustomer
//
//  Created by Semih Karahan on 31.05.2023.
//

import Foundation
import SwiftUI

class Alert {
    func showAlert(title: String, message: String) {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
      alertController.addAction(okAction)

      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(alertController, animated: true, completion: nil)
      }
    }
}

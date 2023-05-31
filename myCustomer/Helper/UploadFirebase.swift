//
//  UploadFirebase.swift
//  myCustomer
//
//  Created by Semih Karahan on 31.05.2023.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

class UploadFirebase: ObservableObject {
    
    // storage kayitlarında dosya adını oluşturan değişkenler
    @Published var currentDay = String()
    @Published var dateUuid = UUID()
    
    // imagepicker için değişkenler
    @Published var selectedImages: [UIImage] = []
    @Published var showImagePicker = false
    
    // activityIndicatoru için kontrol değişkeni
    @Published var isUploading = false
    
    // firestore yüklenen sözlüğün value değişkenleri
    @Published var nameSurname = String()
    @Published var citizenNo = String()
    @Published var phone = String()
    @Published var email = String()
    @Published var shoppingNo = String()
    @Published var productNo = String()
    @Published var adress = String()
    @Published var billingNo = String()
    @Published var cargoFirm = String()
    @Published var cargoTracking = String()
    @Published var note = String()
    


    // textfield verilerini alıp firestore'a yükler.
    func uploadStrings(currentUser: String) {
        // storage için dosya adını belirleyecek değişkenler
        dateUuid = UUID()
        currentDay = "\(Date())"
        
        // firestore yüklenecek sözlük
        let customerInfoArray = ["nameSurname" : nameSurname,
                                 "citizenNo" : citizenNo,
                                 "phone" : phone,
                                 "email" : email]
        let shoppingInfoArray = ["shoppingDate" : currentDay,
                                 "shopingNo" : shoppingNo,
                                 "productNo" : productNo,
                                 "adress" : adress,
                                 "billingNo" : billingNo,
                                 "cargoFirm" : cargoFirm,
                                 "cargoTracking" : cargoTracking,
                                 "note" : note
        ]
        
        // Birinci collection: Admin adı ile oluşturma.
        let db = Firestore.firestore()
        let adminDbRef = db.collection("\(currentUser)").document("lastStatus")
        adminDbRef.setData(["profit":"profit"]) { error in
            if error != nil {
                Alert().showAlert(title: "Hata", message: error?.localizedDescription ?? "Hata (\"Firestore Admin Collection Referance\" bağlantı hatası")
            } else {
                // profit verilerinin ekleneceği yer.
            }
        }
        
        // İkinci collection: "Customers" adı ile oluşturma ve "customerInfoArray" sözlüğün yüklenmesi
        let customerDbRef = adminDbRef.collection("Customers").document("\(nameSurname)")
        customerDbRef.setData(customerInfoArray) { error in
            if error != nil {
                Alert().showAlert(title: "Hata", message: error?.localizedDescription ?? "Hata (\"Firestore Customer Collection Referance\" bağlantı hatası")
            }
            
            // Üçüncü collection: "ShoppingInfo" adı ile oluşturma ve "shoppingInfoArray" sözlüğün yüklenmesi
            let shoppingDbRef = customerDbRef.collection("ShoppingInfo").document("\(self.currentDay)_\(self.dateUuid)")
            shoppingDbRef.setData(shoppingInfoArray) { [self] error in
                if error != nil {
                    Alert().showAlert(title: "Hata", message: error?.localizedDescription ?? "Hata (\"Firestore ShoppingInfo Collection Referance\" bağlantı hatası")
                } else {
                    // storage bağlantısı
                    let storage = Storage.storage()
                    let storageRef = storage.reference()
                    
                    // seçili image var mı yok mu sorgusu
                    if selectedImages.isEmpty {
                        print("No image to upload.")
                        isUploading = false
                        nameSurname = ""
                        citizenNo = ""
                        phone = ""
                        email = ""
                        shoppingNo = ""
                        productNo = ""
                        adress = ""
                        billingNo = ""
                        cargoFirm = ""
                        cargoTracking = ""
                        note = ""
                    } else {
                        for image in selectedImages {
                            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
                            let uuid = UUID().uuidString
                            let imageRef = storageRef.child("\(nameSurname)_\(currentDay)/\(nameSurname)_\(productNo)_\(uuid).jpeg")
                            let metaData = StorageMetadata()
                            metaData.contentType = "images/jpeg"
                            
                            imageRef.putData(imageData, metadata: metaData) { [self] metaData, error in
                                if let error = error {
                                    Alert().showAlert(title: "Hata", message: error.localizedDescription )
                                    return
                                } else {
                                    print("Upload OK!")
                                    isUploading = false
                                    nameSurname = ""
                                    citizenNo = ""
                                    phone = ""
                                    email = ""
                                    shoppingNo = ""
                                    productNo = ""
                                    adress = ""
                                    billingNo = ""
                                    cargoFirm = ""
                                    cargoTracking = ""
                                    note = ""
                                    selectedImages.removeAll()
                                }
                            }
                        }
                    }
                }
            }
  
        }
    }
 
}

// image picker kodu
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

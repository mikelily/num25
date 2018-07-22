//
//  TestViewController.swift
//  num25
//
//  Created by 蒼月喵 on 2018/7/10.
//  Copyright © 2018年 蒼月喵. All rights reserved.
//

import UIKit
import Firebase

class TestViewController: UIViewController {

    var iStream: InputStream? = nil
    var oStream: OutputStream? = nil
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelField: UILabel!
    
    
    @IBAction func socketBtn(_ sender: Any) {
        if let text = textField.text {
            send(text)
        }
    }
    fileprivate struct City {
        
        let name: String
        let state: String?
        let country: String?
        let capital: Bool?
        let population: Int64?
        
        init?(dictionary: [String: Any]) {
            guard let name = dictionary["name"] as? String else { return nil }
            self.name = name
            
            self.state = dictionary["state"] as? String
            self.country = dictionary["country"] as? String
            self.capital = dictionary["capital"] as? Bool
            self.population = dictionary["population"] as? Int64
        }
        
    }

    
    @IBAction func testBtn(_ sender: Any) {
//        print("Button clicked")
        let fbdb = Firestore.firestore()
        let settings = fbdb.settings
        settings.areTimestampsInSnapshotsEnabled = true
        fbdb.settings = settings
        
        fbdb.collection(Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("No error when open doc")
                for document in querySnapshot!.documents {
                    print("\(document.data())")
//                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        
//        let docRef = fbdb.collection("cities").document("SF")
//
//        // Force the SDK to fetch the document from the cache. Could also specify
//        // FirestoreSource.server or FirestoreSource.default.
//        docRef.getDocument(source: .cache) { (document, error) in
//            if let document = document {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Cached document data: \(dataDescription)")
//                print(type(of: dataDescription))
//            } else {
//                print("Document does not exist in cache")
//            }
//        }
        
        let docRef = fbdb.collection("cities").document("SF")
        
        docRef.getDocument { (document, error) in
            if let city = document.flatMap({
                $0.data().flatMap({ (data) in
                    return City(dictionary: data)
                })
            }) {
                print("City: \(city)")
            } else {
                print("Document does not exist")
            }
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let _ = Stream.getStreamsToHost(withName: "localhost", port: 5008, inputStream: &iStream, outputStream: &oStream)
        
        iStream?.open()
        oStream?.open()
        
        DispatchQueue.global().async {
            self.receiveData(available: { (string) in
                DispatchQueue.main.async {
                    self.labelField.text = string
                }
            })
        }
    }
    
    func receiveData(available: (_ string: String?) -> Void) {
        var buf = Array(repeating: UInt8(0), count: 1024)
        
        while true {
            if let n = iStream?.read(&buf, maxLength: 1024) {
                let data = Data(bytes: buf, count: n)
                let string = String(data: data, encoding: .utf8)
                available(string)
            }
        }
    }
    
    func send(_ string: String) {
        var buf = Array(repeating: UInt8(0), count: 1024)
        let data = string.data(using: .utf8)!
        
        data.copyBytes(to: &buf, count: data.count)
        oStream?.write(buf, maxLength: data.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  PasswordForm
//
//  Created by Martin Walsh on 03/04/2017.
//  Copyright © 2017 Auth0. All rights reserved.
//

import UIKit
import Lock
import Auth0

class ViewController: UIViewController {

    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!


    var profile: Profile?
    var credentials: Credentials?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func retrieveProfile() {
        guard let accessToken = self.credentials?.accessToken else { return }
        let auth = authentication()
        auth.userInfo(token: accessToken).start { result in
            switch result {
            case .success(let profile):
                self.profile = profile
                print("Profile retrieved id: \(self.profile?.id)")
                DispatchQueue.main.async {
                    self.submitButton.isEnabled = true
                }
            case .failure(let error):
                print("There was a problem with userInfo: \(error)")
            }
        }

    }

    @IBAction func Login(_ sender: Any) {
        let lock = Lock.classic()
            .withOptions {
                $0.closable = true
            }.onAuth {
                self.credentials = $0
                self.retrieveProfile()
            }.onError { print("There was a problem authenticating: \($0)")
        }

        lock.present(from: self)
    }
    
    @IBAction func submit(_ sender: Any) {
        guard
            let password = self.newPassword.text,
            let confirm = self.confirmPassword.text,
            let current = self.oldPassword.text,
            let profile = self.profile, profile.identities.first?.social == false,
            let url = URL(string: "http://localhost:3000/change-password")
            else { return print("Check submit values") }

        let user: [String: String] = ["id" : profile.id]
        let dict: [String: Any] = [ "password" : password,
                                       "confirm"  : confirm,
                                       "current"  : current,
                                       "user"     : user ]
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return print("Failed to load with error \(error!)")
            }

            guard let response = response as? HTTPURLResponse else {
                return print("Response was not NSHTTURLResponse")
            }

            guard 200...299 ~= response.statusCode else {
                return print("HTTP response was not successful. HTTP \(response.statusCode)")
            }

            guard let data = data else {
                return print("No Data")
            }

            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let dict = jsonData as? [String: Any] else { return print("Check JSON Data") }

            guard dict["error"] == nil else {
                return print("Change password failed with error: \(dict["error"])")
            }

            if dict["success"] as? Bool == true {
                print("Success")
            }

        }
        task.resume()
    }
}


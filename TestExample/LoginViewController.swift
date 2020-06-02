//
//  LoginViewController.swift
//  TestExample
//
//  Created by Japp Tech on 28/05/20.
//  Copyright © 2020 Japp Tech. All rights reserved.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import MSAL


class LoginViewController: UIViewController {
    
   let kClientID = "983e73cb-fad0-439e-a6a0-e98a985206ed"
    let kRedirectUri = "msauth.com.japptech.TestExample://auth"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    
    let kScopes: [String] = ["user.read"]
       
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    
    var currentAccount: MSALAccount?


    let appleProvider = AppleSignInClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        GIDSignIn.sharedInstance().delegate=self
        do {
            try self.initMSAL()
        } catch let error {
        }
        
        //        self.loadCurrentAccount()
        //self.platformViewDidLoadSetup()
    }
            
   
    @IBAction func googleAct(_ sender: Any)
    {
        
        GIDSignIn.sharedInstance().signIn()
       
    }
    
    @IBAction func appleAct(_ sender: ASAuthorizationAppleIDButton ) {
        appleProvider.handleAppleIdRequest(block: { fullName, email, token in
                   // receive data in login class.
                   print(email ?? "")
                   
                   
               })
    }

 
}
extension LoginViewController:GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
    
            let userId = user.userID
             print(userId ?? 0)
            let idToken = user.authentication.idToken
            print(idToken ?? 0)
            let fullName = user.profile.name
             print(fullName ?? 0)
            let givenName = user.profile.givenName
             print(givenName ?? 0)
            let familyName = user.profile.familyName
             print(familyName ?? 0)
            let email = user.profile.email
             print(email ?? 0)
            // ...
            if GIDSignIn.sharedInstance().currentUser.profile.hasImage {
                let dimension = round(100 * UIScreen.main.scale)
                let pic = user.profile.imageURL(withDimension: UInt(dimension))
                print(pic ?? 0)
            }
            
           // let parameters = ["api": "socialLogin", "device": "ios", "version": "1", "data": ["email":email!,"type":"google","token":idToken!,"fcm_token":SingletonClass.sharedInstance.fcmToken,"platform":"ios"]] as [String : Any]
            
           // print(parameters)
            
            //willSendLoginDetailsToDatabase(params: parameters)
        }
    }
    
}
extension LoginViewController {
    
    func initMSAL() throws {
           
           guard let authorityURL = URL(string: kAuthority) else {
               return
           }
           
           let authority = try MSALAADAuthority(url: authorityURL)
           
           let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: nil, authority: authority)
           self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
           self.initWebViewParams()
       }
       
       func initWebViewParams() {
           self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
       }
       @IBAction func callGraphAPI(_ sender: UIButton) {
            
            self.loadCurrentAccount { (account) in
                
                guard let currentAccount = account else {
                    self.acquireTokenInteractively()
                    return
                }
                
                self.acquireTokenSilently(currentAccount)
            }
        }
        
        func acquireTokenInteractively() {
            
            guard let applicationContext = self.applicationContext else { return }
            guard let webViewParameters = self.webViewParamaters else { return }

            let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
            parameters.promptType = .selectAccount
            
            applicationContext.acquireToken(with: parameters) { (result, error) in
                
                if let error = error {
                    return
                }
                
                guard let result = result else {
                    return
                }
                
                self.accessToken = result.accessToken
                self.updateCurrentAccount(account: result.account)
                self.getContentWithToken()
            }
        }
        
        func acquireTokenSilently(_ account : MSALAccount!) {
            
            guard let applicationContext = self.applicationContext else { return }
            
            let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
            
            applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
                
                if let error = error {
                    
                    let nsError = error as NSError
                    if (nsError.domain == MSALErrorDomain) {
                        
                        if (nsError.code == MSALError.interactionRequired.rawValue) {
                            
                            DispatchQueue.main.async {
                                self.acquireTokenInteractively()
                            }
                            return
                        }
                    }
                    return
                }
                
                guard let result = result else {
                    return
                }
                
                self.accessToken = result.accessToken
                self.getContentWithToken()
            }
        }
        
        func getGraphEndpoint() -> String {
            return kGraphEndpoint.hasSuffix("/") ? (kGraphEndpoint + "v1.0/me/") : (kGraphEndpoint + "/v1.0/me/");
        }
        
        /**
         This will invoke the call to the Microsoft Graph API. It uses the
         built in URLSession to create a connection.
         */
        
        func getContentWithToken() {
            
            // Specify the Graph API endpoint
            let graphURI = getGraphEndpoint()
            let url = URL(string: graphURI)
            var request = URLRequest(url: url!)
            
            // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
            request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    return
                }
                
                guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                    return
                }
                /*Do any thing you want with this result saiteja*/
                print(result)
                self.signOut()
                
                }.resume()
        }

}

extension LoginViewController {

typealias AccountCompletion = (MSALAccount?) -> Void

   func loadCurrentAccount(completion: AccountCompletion? = nil) {
       
       guard let applicationContext = self.applicationContext else { return }
       
       let msalParameters = MSALParameters()
       msalParameters.completionBlockQueue = DispatchQueue.main
       applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
           
           if let error = error {
               return
           }
           
           if let currentAccount = currentAccount {
               self.updateCurrentAccount(account: currentAccount)
               
               if let completion = completion {
                   completion(self.currentAccount)
               }
               
               return
           }
           self.accessToken = ""
           self.updateCurrentAccount(account: nil)
           
           if let completion = completion {
               completion(nil)
           }
       })
   }
   


   func signOut() {

       guard let applicationContext = self.applicationContext else { return }
       
       guard let account = self.currentAccount else { return }
       
       do {
           
           let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
           signoutParameters.signoutFromBrowser = false
           
           applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
               
               if let error = error {
                   return
               }
               self.accessToken = ""
               self.updateCurrentAccount(account: nil)
           })
           
       }
   }
   
   func updateCurrentAccount(account: MSALAccount?) {
       self.currentAccount = account
   }
}

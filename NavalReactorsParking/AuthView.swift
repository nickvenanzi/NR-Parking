//
//  AuthView.swift
//  NavalReactorsParking
//
//  Created by Nick Venanzi on 10/26/24.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isLinkSent = false
    @Binding var isComplete: Bool
    
    private let actionCodeSettings = ActionCodeSettings()

    init(isComplete: Binding<Bool>) {
        actionCodeSettings.url = URL(string: "https://nickvenanzi.github.io/")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        if let e = UserDefaults.standard.string(forKey: "email") {
            email = e
        }
        self._isComplete = isComplete
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Image("Background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                        .opacity(0.4)
                        .ignoresSafeArea()
                    
                    // VStack that fits within the screen bounds
                    VStack {
                        HStack {
                            TextField("Enter your PrimeNet email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .multilineTextAlignment(.trailing) // Right-align the text
                            
                            Text("@unnpp.gov")
                        }.padding()

                        Button(action: {
                            sendAuthLink()
                        }) {
                            Text("Send Sign-In Link")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(email.isEmpty)
                        
                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(isLinkSent ? .green : .red)
                                .padding()
                        }
                    }
                    .padding() // Adds padding around the VStack
                    .background(Color.white.opacity(0.3)) // Semi-transparent background for contrast
                    .cornerRadius(16) // Rounded corners
                    .shadow(radius: 10) // Adds a shadow for better separation from the background
                    .frame(width: geometry.size.width * 0.9)
                }
            }
            .preferredColorScheme(.dark)
        }
        
    }
    
    private func sendAuthLink() {
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                isLinkSent = false
                message = "Error using \(email): \(error.localizedDescription)"
                print(error)
            } else {
                isLinkSent = true
                message = "Sign-in link sent to your email.  This page will automatically disappear once the email is verified."
                UserDefaults.standard.set(email, forKey: "email")
            }
        }
    }
}

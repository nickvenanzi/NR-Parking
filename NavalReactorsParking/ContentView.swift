//
//  ContentView.swift
//  NavalReactorsParking
//
//  Created by Nick Venanzi on 10/16/24.
//

import SwiftUI
import FirebaseAuth
import GoogleMobileAds

struct ContentView: View {
    
    @StateObject var garageModel = ParkingModel("parkingGarage")
    @StateObject var bldg104Model = ParkingModel("bldg104")
    @State var tabSelection: Int = 0
    @State var showSignIn: Bool = true
    
    @State private var timer: Timer?

    init() {
        if let _ = Auth.auth().currentUser?.isEmailVerified {
            print("Signed in without making firebase request")
            showSignIn = false
        }
    }
    
    var body: some View {
        if showSignIn {
            AuthView(isComplete: $showSignIn)
                .onAppear {
                    startVerificationTimer()  // Start the timer when AuthView appears
                }
        } else {
            TabView(selection: $tabSelection) {
                
                ParkingView()
                    .environmentObject(garageModel)
                    .tabItem {
                        Text("Garage 28")
                        Image(systemName: "car")
                    }
                    .tag(0)
                
                ParkingView()
                    .environmentObject(bldg104Model)
                    .tabItem {
                        Text("Bldg 104 N/S")
                        Image(systemName: "car")
                    }
                    .tag(1)
                
                //
                //            ReservationView()
                //                .tabItem {
                //                    Text("Reservations")
                //                    Image(systemName: "calendar")
                //                }
                //                .tag(2)
            }
            .tint(.primary)
            .onAppear {
                UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
                garageModel.fetchData()
                bldg104Model.fetchData()
            }
        }
    }
    
    func startVerificationTimer() {
        // Invalidate the timer if it already exists
        timer?.invalidate()
        
        // Create a new timer that calls checkVerification every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkVerification()
        }
    }
    
    func checkVerification() {
        Auth.auth().currentUser?.reload { error in
            if let user = Auth.auth().currentUser {
                showSignIn = !user.isEmailVerified
                // If the user is verified, invalidate the timer
                if user.isEmailVerified {
                    print("Signed in during checkVerification")
                    self.timer?.invalidate()  // Stop the timer
                    self.timer = nil  // Clear the reference to the timer
                }
            }
        }
    }
}

struct BannerView: UIViewRepresentable {
    let adSize: GADAdSize
    
    init(_ adSize: GADAdSize) {
        self.adSize = adSize
    }
    
    func makeUIView(context: Context) -> UIView {
        // Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
        // frame size changes; wrapping in a UIView container insulates the GADBannerView from size
        // changes that impact the view returned from makeUIView.
        let view = UIView()
        view.addSubview(context.coordinator.bannerView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
}

class BannerCoordinator: NSObject, GADBannerViewDelegate {
    
    private(set) lazy var bannerView: GADBannerView = {
        let banner = GADBannerView(adSize: parent.adSize)
        banner.adUnitID = "ca-app-pub-6901401588530297/2047573326"
        banner.load(GADRequest())
        banner.delegate = self
        return banner
    }()
    
    let parent: BannerView
    
    init(_ parent: BannerView) {
        self.parent = parent
    }
}

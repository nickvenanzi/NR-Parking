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
    
    var body: some View {
        
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
            Auth.auth().signInAnonymously { (authResult, error) in
                if let _ = error {
                    return
                }
                guard let _ = authResult?.user else { return }
                garageModel.fetchData()
                bldg104Model.fetchData()
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

//
//  ContentView.swift
//  NavalReactorsParking
//
//  Created by Nick Venanzi on 10/16/24.
//

import SwiftUI
import FirebaseAuth

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

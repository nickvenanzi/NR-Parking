//
//  ParkingView.swift
//  NavalReactorsParking
//
//  Created by Nick Venanzi on 10/19/24.
//
import SwiftUI
import GoogleMobileAds

struct ParkingView: View {
    @EnvironmentObject var viewModel: ParkingModel
    
    @State var nrSpacesPicker = 0
    
    @State private var showAlert = false // Control when to show the alert
    @AppStorage("doNotShowMessageAgain") private var storedDoNotShowAgain = false // Persist the preference
    
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

                        if !viewModel.floors.filter({ floor in
                            floor.statusGeneral != nil
                        }).isEmpty {
                            Picker("RedWhiteSpaces", selection: $nrSpacesPicker) {
                                Text("NR").tag(0)
                                Text("General").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.darkGray)) // Dark grey background
                            )
                        }
                        
                        let full: Bool = nrSpacesPicker == 0 ? viewModel.parkingFullNR : viewModel.parkingFullGeneral
                        let fullStr: String = nrSpacesPicker == 0 ? "NR Spaces Full" : "Garage Full"
                        Text(full ? fullStr : "Spaces Available")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(full ? .red : .green)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.darkGray)) // Dark grey background
                            )
                        
                        parkingGarageView
                        
                    }
                    .padding() // Adds padding around the VStack
                    .background(Color.white.opacity(0.3)) // Semi-transparent background for contrast
                    .cornerRadius(16) // Rounded corners
                    .shadow(radius: 10) // Adds a shadow for better separation from the background
                    .frame(width: geometry.size.width * 0.9)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Warning"),
                            message: Text("If you select OK all users will receive a notification that " + (nrSpacesPicker == 0 ? "all NR designated spaces are full" : "the garage is full")),
                            primaryButton: .default(Text("OK")) {
                                viewModel.showAlertCompletion()
                                storedDoNotShowAgain = true
                            },
                            secondaryButton: .cancel(Text("Cancel")) {
                                storedDoNotShowAgain = true
                            }
                        )
                    }
                }
                Spacer()
                
                let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)

                BannerView(adSize)
                    .frame(height: adSize.size.height)
            }
            .preferredColorScheme(.dark)
        }
        
    }
    
    var parkingGarageView: some View {
        ScrollView { // Ensures content fits within smaller screens
            ForEach(viewModel.floors.filter({ floor in
                let status = nrSpacesPicker == 0 ? floor.statusNR : floor.statusGeneral
                return status != nil
            }).sorted(by: { $0.order < $1.order }), id: \.id) { floor in
                FloorRowView(floor: floor, updateStatus: { status in
                    var willBeFull: Bool = status == .full
                    for otherFloor in viewModel.floors {
                        if otherFloor.floorName == floor.floorName {
                            continue
                        }
                        if let otherStatus = (nrSpacesPicker == 0 ? otherFloor.statusNR : otherFloor.statusGeneral), otherStatus != .full {
                            willBeFull = false
                            break
                        }
                    }
                    if willBeFull && !storedDoNotShowAgain {
                        viewModel.showAlertCompletion = {
                            viewModel.updateFloorStatus(floor: floor, newStatus: status, isNR: nrSpacesPicker == 0)
                        }
                        showAlert = true
                    } else {
                        viewModel.updateFloorStatus(floor: floor, newStatus: status, isNR: nrSpacesPicker == 0)
                    }
                }, isNRStatus: nrSpacesPicker == 0)
            }
        }
        .frame(maxHeight: .infinity) // Prevents content overflow
    }
}

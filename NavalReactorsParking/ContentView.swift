//
//  ContentView.swift
//  NavalReactorsParking
//
//  Created by Nick Venanzi on 10/16/24.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @EnvironmentObject var viewModel: ParkingGarageViewModel
    
    @State var nrSpacesPicker = 0
    
    var body: some View {
        GeometryReader { geometry in
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
                    
                    let full: Bool = nrSpacesPicker == 0 ? viewModel.garageFullNR : viewModel.garageFullGeneral
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
                    
                    ScrollView { // Ensures content fits within smaller screens
                        ForEach(viewModel.floors.filter({ floor in
                            let status = nrSpacesPicker == 0 ? floor.statusNR : floor.statusGeneral
                            return status != nil
                        }).sorted(by: { $0.order < $1.order }), id: \.id) { floor in
                            FloorRowView(floor: floor, updateStatus: { status in
                                viewModel.updateFloorStatus(floor: floor, newStatus: status, isNR: nrSpacesPicker == 0)
                            }, isNRStatus: nrSpacesPicker == 0)
                        }
                    }
                    .frame(maxHeight: .infinity) // Prevents content overflow
                }
                .padding() // Adds padding around the VStack
                .background(Color.white.opacity(0.3)) // Semi-transparent background for contrast
                .cornerRadius(16) // Rounded corners
                .shadow(radius: 10) // Adds a shadow for better separation from the background
                .frame(width: geometry.size.width * 0.9)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.fetchGarageData()
        }
    }
}

struct FloorRowView: View {
    var floor: ParkingFloor
    var updateStatus: (ParkingStatus) -> Void
    var isNRStatus: Bool
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }
    
    var body: some View {
        VStack {
            // Floor Name above the buttons
            HStack {
                Text("\(floor.floorName)")
                    .font(.headline)
                    .minimumScaleFactor(0.5) // Allows text to shrink if needed
                    .lineLimit(1) // Ensures single-line text
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .foregroundColor(.white)
                
                Spacer()
                
                let fillTime = isNRStatus ? floor.fillTimeNR : floor.fillTimeGeneral
                if let time = fillTime, (isNRStatus ? floor.statusNR == .full : floor.statusGeneral == .full) {
                    let timeString = formatter.string(from: time)
                    Text("Filled: \(timeString)")
                        .foregroundColor(.white)
                }
            }
            
            let floorStatus: ParkingStatus? = isNRStatus ? floor.statusNR : floor.statusGeneral
            // Buttons in a horizontal row
            HStack(spacing: 10) {
                // Full Button
                Button(action: { updateStatus(.full) }) {
                    Text("Full")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40) // Expand to fill available width
                        .background(floorStatus == .full ? Color.red : Color.gray)
                        .cornerRadius(8)
                        .scaleEffect(floorStatus == .full ? 1.1 : 1)
                }
                
                // 1-5 Spaces Button
                Button(action: { updateStatus(.fewSpaces) }) {
                    Text("1-5 Spaces")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40) // Expand to fill available width
                        .background(floorStatus == .fewSpaces ? Color.orange : Color.gray)
                        .cornerRadius(8)
                        .scaleEffect(floorStatus == .fewSpaces ? 1.1 : 1)
                }
                
                // 6+ Spaces Button
                Button(action: { updateStatus(.manySpaces) }) {
                    Text("6+ Spaces")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40) // Expand to fill available width
                        .background(floorStatus == .manySpaces ? Color.green : Color.gray)
                        .cornerRadius(8)
                        .scaleEffect(floorStatus == .manySpaces ? 1.1 : 1)
                }
            }
            .frame(maxWidth: .infinity) // Ensure buttons take up full horizontal space
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 5) // Adds some vertical space between rows
    }
}

class ParkingGarageViewModel: ObservableObject {
    @Published var floors = [ParkingFloor]()
    @Published var garageFullNR = false
    @Published var garageFullGeneral = false

    private var db = Firestore.firestore()

    func fetchGarageData() {
        db.collection("parkingGarage").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching garage data: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            
            self.floors = documents.compactMap { document in
                try? document.data(as: ParkingFloor.self)
            }
            
            self.updateGarageFullStatus()
        }
    }

    func updateFloorStatus(floor: ParkingFloor, newStatus: ParkingStatus, isNR: Bool) {
        if let floorID = floor.id {
            if isNR {
                if floor.fillTimeNR == nil && newStatus == .full {
                    db.collection("parkingGarage").document(floorID).updateData([
                        "statusNR": newStatus.rawValue,
                        "fillTimeNR": FieldValue.serverTimestamp()
                    ])
                } else {
                    db.collection("parkingGarage").document(floorID).updateData([
                        "statusNR": newStatus.rawValue
                    ])
                }
            } else {
                if floor.fillTimeGeneral == nil && newStatus == .full {
                    db.collection("parkingGarage").document(floorID).updateData([
                        "statusGeneral": newStatus.rawValue,
                        "fillTimeGeneral": FieldValue.serverTimestamp()
                    ])
                } else {
                    db.collection("parkingGarage").document(floorID).updateData([
                        "statusGeneral": newStatus.rawValue
                    ])
                }
            }

            
        }
    }

    func updateGarageFullStatus() {
        garageFullNR = floors.allSatisfy { $0.statusNR == .full || $0.statusNR == nil }
        garageFullGeneral = floors.allSatisfy { $0.statusGeneral == .full || $0.statusGeneral == nil }
    }
}

struct ParkingFloor: Identifiable, Codable {
    @DocumentID var id: String?
    var floorName: String
    var statusNR: ParkingStatus?
    var statusGeneral: ParkingStatus?
    var order: Int
    var fillTimeNR: Date?
    var fillTimeGeneral: Date?
}

enum ParkingStatus: String, Codable {
    case full = "FULL"
    case fewSpaces = "1-5 Spaces"
    case manySpaces = "6+ Spaces"
}

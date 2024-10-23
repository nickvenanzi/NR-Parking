import SwiftUI

struct ParkingSpot: Identifiable {
    let id = UUID()
    let number: String
    let ownerName: String
    var status: SpotStatus
}

enum SpotStatus {
    case available
    case claimed(claimant: String)
    case claimedByUser
}

struct ParkingLot: Identifiable {
    let id = UUID()
    let name: String
    var spots: [ParkingSpot]
}

struct ReservationView: View {
    
    @State private var selectedDate = Date() // Date selected
    @State private var parkingLots: [ParkingLot] = [
        ParkingLot(name: "Lot A", spots: [
            ParkingSpot(number: "I-28", ownerName: "S. Fisher", status: .available),
            ParkingSpot(number: "I-29", ownerName: "B. Lee", status: .claimed(claimant: "J. Doe")),
            ParkingSpot(number: "I-30", ownerName: "S. Fisher", status: .claimedByUser)
        ]),
        ParkingLot(name: "Lot B", spots: [
            ParkingSpot(number: "B-1", ownerName: "A. Smith", status: .available)
        ])
    ]

    var body: some View {
        VStack {
            // Date selector with buttons to move forward/backward a day
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                }

                Text(selectedDateFormatted())
                    .font(.headline)
                    .padding()

                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            // List of parking lots and their spots
            List {
                ForEach(parkingLots) { lot in
                    Section(header: Text(lot.name)) {
                        ForEach(lot.spots) { spot in
                            HStack {
                                Text(spot.number)
                                Spacer()
                                Text(spot.ownerName)
                                Spacer()
                                spotStatusView(spot)
                            }
                        }
                    }
                }
            }

            // Button to create new reservation
            Button(action: {
                // Show modal for creating new reservation
                print("Create New Reservation")
            }) {
                Text("Create New Reservation")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }

    // Format the selected date
    private func selectedDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: selectedDate)
    }

    // View to display the status of the parking spot
    @ViewBuilder
    private func spotStatusView(_ spot: ParkingSpot) -> some View {
        switch spot.status {
        case .available:
            Button(action: {
                // Claim the spot
                print("Claim \(spot.number)")
            }) {
                Text("Claim")
                    .foregroundColor(.green)
                    .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green, lineWidth: 1))
            }
        case .claimed(let claimant):
            HStack {
                Text("Claimed by \(claimant)")
                    .foregroundColor(.gray)
                if claimant == "Your Name" {
                    Button(action: {
                        // Forfeit your claim
                        print("Forfeit \(spot.number)")
                    }) {
                        Text("Forfeit")
                            .foregroundColor(.red)
                            .padding(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.red, lineWidth: 1))
                    }
                }
            }
        case .claimedByUser:
            HStack {
                Text("Claimed by You")
                    .foregroundColor(.blue)
                Button(action: {
                    // Forfeit the spot
                    print("Forfeit \(spot.number)")
                }) {
                    Text("Forfeit")
                        .foregroundColor(.red)
                        .padding(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.red, lineWidth: 1))
                }
            }
        }
    }
}

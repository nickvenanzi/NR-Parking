//
//  FloorRowView.swift
//  NavalReactorsParking
//
//  Created by Nick Venanzi on 10/19/24.
//

import SwiftUI

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

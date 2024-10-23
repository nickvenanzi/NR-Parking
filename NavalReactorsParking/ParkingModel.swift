//
//  ParkingGarageViewModel.swift
//  NavalReactorsParking
//
//  Created by Nick Venanzi on 10/19/24.
//

import SwiftUI
import FirebaseFirestore

class ParkingModel: ObservableObject {
    @Published var floors = [ParkingFloor]()
    @Published var parkingFullNR = false
    @Published var parkingFullGeneral = false
    
    var collection: String
    
    init(_ collection: String) {
        self.collection = collection
    }

    private var db = Firestore.firestore()
    
    var showAlertCompletion: ()->() = {}

    func fetchData() {
        db.collection(collection).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching garage data: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            
            self.floors = documents.compactMap { document in
                try? document.data(as: ParkingFloor.self)
            }
            
            self.updateParkingFullStatus()
        }
    }

    func updateFloorStatus(floor: ParkingFloor, newStatus: ParkingStatus, isNR: Bool) {
        if let floorID = floor.id {
            if isNR {
                if floor.fillTimeNR == nil && newStatus == .full {
                    db.collection(collection).document(floorID).updateData([
                        "statusNR": newStatus.rawValue,
                        "fillTimeNR": FieldValue.serverTimestamp()
                    ])
                } else {
                    db.collection(collection).document(floorID).updateData([
                        "statusNR": newStatus.rawValue
                    ])
                }
            } else {
                if floor.fillTimeGeneral == nil && newStatus == .full {
                    db.collection(collection).document(floorID).updateData([
                        "statusGeneral": newStatus.rawValue,
                        "fillTimeGeneral": FieldValue.serverTimestamp()
                    ])
                } else {
                    db.collection(collection).document(floorID).updateData([
                        "statusGeneral": newStatus.rawValue
                    ])
                }
            }

            
        }
    }

    func updateParkingFullStatus() {
        parkingFullNR = floors.allSatisfy { $0.statusNR == .full || $0.statusNR == nil }
        parkingFullGeneral = floors.allSatisfy { $0.statusGeneral == .full || $0.statusGeneral == nil }
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

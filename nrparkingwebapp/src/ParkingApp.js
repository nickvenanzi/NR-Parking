import React, { useEffect, useState } from 'react';
import ParkingView from './ParkingView';
import { db, auth } from './firebaseConfig';
import { signInAnonymously } from "firebase/auth";
import { collection, onSnapshot } from "firebase/firestore";

function ParkingApp() {
  const [tabSelection, setTabSelection] = useState(0);
  const [garageModel, setGarageModel] = useState([]);
  const [bldg104Model, setBldg104Model] = useState([]);

  useEffect(() => {
    // Sign in anonymously to Firebase
    signInAnonymously(auth).then(() => {
      fetchParkingData("parkingGarage", setGarageModel);
      fetchParkingData("bldg104", setBldg104Model);
    });
  }, []);

  return (
    <div className="container">
      <div className="tabs">
        <button onClick={() => setTabSelection(0)}
                className={tabSelection === 0 ? 'button selected' : 'button'}>
          Garage 28
        </button>
        <button onClick={() => setTabSelection(1)}
                className={tabSelection === 1 ? 'button selected' : 'button'}>
          Bldg 104 N/S
        </button>
      </div>
      
      {tabSelection === 0 && <ParkingView floors={garageModel} collectionName="parkingGarage"/>}
      {tabSelection === 1 && <ParkingView floors={bldg104Model} collectionName="bldg104"/>}
    </div>
  );
}

 // Example of how you might update your fetchParkingData function
 function fetchParkingData(collectionName, updateFloors) {
  const floorsCollectionRef = collection(db, collectionName);
  
  // Real-time updates using onSnapshot
  onSnapshot(floorsCollectionRef, (querySnapshot) => {
      const floorsData = querySnapshot.docs.map(doc => ({
          ...doc.data(),
          id: doc.id,
      }));

      // Update the state with the floors data
      updateFloors(floorsData);
  }, (error) => {
      console.error("Error fetching parking data:", error);
  });
}

export default ParkingApp;



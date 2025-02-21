<<<<<<< HEAD:nrparkingwebapp/src/ParkingApp.js
import React, { useEffect, useState } from 'react';
import ParkingView from './ParkingView';
import { db, auth } from './firebaseConfig';
import { signInAnonymously } from "firebase/auth";
import { collection, onSnapshot } from "firebase/firestore";

function ParkingApp() {
=======
import React, { useEffect, useState, useCallback } from 'react';
import ParkingView from './ParkingView';
import { db, auth } from './firebaseConfig';
import { signInAnonymously } from "firebase/auth";
import { collection, getDocs, onSnapshot } from "firebase/firestore";

function App() {
>>>>>>> recovered:nrparkingwebapp/src/App.js
  const [tabSelection, setTabSelection] = useState(0);
  const [locations, setLocations] = useState([]);
  const [parkingData, setParkingData] = useState({});

  const fetchLocations = useCallback(async () => {
    const locationsCollectionRef = collection(db, "parkingLocations");
    const querySnapshot = await getDocs(locationsCollectionRef);
    
    const fetchedLocations = querySnapshot.docs.map(doc => ({
      id: doc.id,
      name: doc.data().name,
      collection: doc.data().collection
    }));

    setLocations(fetchedLocations);

    fetchedLocations.forEach(location => {
      fetchParkingData(location.collection, location.id);
    });
  }, []);

  useEffect(() => {
    signInAnonymously(auth).then(() => {
      fetchLocations();
    });
  }, [fetchLocations]); // ✅ Now fetchLocations is stable and won't trigger excessive renders

  const fetchParkingData = (collectionName, locationId) => {
    const floorsCollectionRef = collection(db, collectionName);

    onSnapshot(floorsCollectionRef, (querySnapshot) => {
      const floorsData = querySnapshot.docs.map(doc => ({
        ...doc.data(),
        id: doc.id,
      }));

      setParkingData(prevData => ({
        ...prevData,
        [locationId]: floorsData
      }));
    }, (error) => {
      console.error(`Error fetching data for ${collectionName}:`, error);
    });
  };

  return (
    <div className="container">
      <div className="tabs">
        {locations.map((location, index) => (
          <button key={location.id}
                  onClick={() => setTabSelection(index)}
                  className={tabSelection === index ? 'button selected' : 'button'}>
            {location.name}
          </button>
        ))}
      </div>

      {locations.length > 0 && (
        <ParkingView 
          floors={parkingData[locations[tabSelection]?.id] || []} 
          collectionName={locations[tabSelection]?.collection} 
        />
      )}
    </div>
  );
}

<<<<<<< HEAD:nrparkingwebapp/src/ParkingApp.js
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


=======
export default App;
>>>>>>> recovered:nrparkingwebapp/src/App.js

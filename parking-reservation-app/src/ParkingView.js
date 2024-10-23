import React, { useEffect, useState } from 'react';
import { collection, query, onSnapshot } from "firebase/firestore";
import { db } from './firebaseConfig';
import FloorRowView from './FloorRowView';  // Assuming you have a separate component for each floor

const ParkingView = () => {
    const [floors, setFloors] = useState([]);
    const [statusType, setStatusType] = useState('statusNR'); // Toggle between 'statusNR' and 'statusGeneral'

    useEffect(() => {
        // Fetch floors data from Firestore
        const q = query(collection(db, 'parkingGarage')); // You can adjust collection name as needed
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const fetchedFloors = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setFloors(fetchedFloors);
        });

        return () => unsubscribe(); // Cleanup listener on unmount
    }, []);

    const sortedFloors = [...floors].sort((a, b) => a.order - b.order);

    return (
        <div className="parking-view">
            <div className="toggle-container">
                <button onClick={() => setStatusType('statusNR')}>
                    NR Spaces
                </button>
                <button onClick={() => setStatusType('statusGeneral')}>
                    General Spaces
                </button>
            </div>

            <div className="floor-list">
                {sortedFloors
                    .filter(floor => floor[statusType] !== undefined)
                    .map((floor) => (
                        <FloorRowView
                            key={floor.id}
                            floor={floor}
                            statusType={statusType}
                        />
                    ))}
            </div>
        </div>
    );
};

export default ParkingView;

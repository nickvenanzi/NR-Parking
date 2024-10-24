import React from 'react';
import { doc, updateDoc, serverTimestamp } from "firebase/firestore";
import { db } from './firebaseConfig';
import './FloorRowView.css';

const FloorRowView = ({ floor, statusType, collectionName }) => {

    const formatTime = (timestamp) => {
        if (!timestamp) return "";
        const date = new Date(timestamp.seconds * 1000); // Convert Firestore timestamp to JS Date
        return date.toLocaleTimeString([], { hour: 'numeric', minute: 'numeric', hour12: true });
    };

    const updateStatus = async (newStatus) => {
        const floorDocRef = doc(db, collectionName, floor.id);
        const fillTimeField = statusType === 'statusNR' ? 'fillTimeNR' : 'fillTimeGeneral';
        try {

            const updateData = {
                [statusType]: newStatus,
            };
    
            if (newStatus === 'FULL') {
                updateData[fillTimeField] = serverTimestamp(); // Set the fill time to the server timestamp
            }

            await updateDoc(floorDocRef, updateData);
            console.log("Status updated successfully");
        } catch (error) {
            console.error("Error updating status:", error);
        }
    };

    const currentStatus = floor[statusType];  // This will be either statusNR or statusGeneral

    return (
        <div className="floor-row">
            <div className="floor-info">
                <h3>{floor.floorName}</h3>
                {/* Display fill time based on current status */}
                {statusType === 'statusNR' ? (
                    floor.statusNR === "FULL" && floor.fillTimeNR && (
                        <p>Filled at: {formatTime(floor.fillTimeNR)}</p>
                    )
                ) : (
                    floor.statusGeneral === "FULL" && floor.fillTimeGeneral && (
                        <p>Filled at: {formatTime(floor.fillTimeGeneral)}</p>
                    )
                )}
            </div>
            <div className="status-buttons">
                <button onClick={() => updateStatus('FULL')} style={{ background: currentStatus === 'FULL' ? 'red' : 'gray' }}>
                    Full
                </button>
                <button onClick={() => updateStatus('1-5 Spaces')} style={{ background: currentStatus === '1-5 Spaces' ? 'orange' : 'gray' }}>
                    1-5 Spaces
                </button>
                <button onClick={() => updateStatus('6+ Spaces')} style={{ background: currentStatus === '6+ Spaces' ? 'green' : 'gray' }}>
                    6+ Spaces
                </button>
            </div>
        </div>
    );
};

export default FloorRowView;

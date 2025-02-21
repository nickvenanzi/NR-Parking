import React from 'react';
import { doc, updateDoc, serverTimestamp, getDoc } from "firebase/firestore";
import { db } from './firebaseConfig';
import './FloorRowView.css';

const FloorRowView = ({ floor, collectionName }) => {

    const formatTime = (timestamp) => {
        if (!timestamp) return "";
        const date = new Date(timestamp.seconds * 1000); // Convert Firestore timestamp to JS Date
        return date.toLocaleTimeString([], { hour: 'numeric', minute: 'numeric', hour12: true });
    };

    const updateStatus = async (newStatus) => {
        const floorDocRef = doc(db, collectionName, floor.id);
        try {
            const updateData = {
                statusGeneral: newStatus,
            };

            if (newStatus === 'FULL') {
                updateData.fillTimeGeneral = serverTimestamp(); // Set the fill time to the server timestamp
            }

            await updateDoc(floorDocRef, updateData);
            console.log("Status updated successfully");
        } catch (error) {
            console.error("Error updating status:", error);
        }
    };

    return (
        <div className="floor-row">
            <div className="floor-info">
                <h3>{floor.floorName}</h3>
                {floor.statusGeneral === "FULL" && floor.fillTimeGeneral && (
                    <p>Filled at: {formatTime(floor.fillTimeGeneral)}</p>
                )}
            </div>
            <div className="status-buttons">
                <button onClick={() => updateStatus('FULL')} style={{ background: floor.statusGeneral === 'FULL' ? 'red' : 'gray' }}>
                    Full
                </button>
                <button onClick={() => updateStatus('1-5 Spaces')} style={{ background: floor.statusGeneral === '1-5 Spaces' ? 'orange' : 'gray' }}>
                    1-5 Spaces
                </button>
                <button onClick={() => updateStatus('6+ Spaces')} style={{ background: floor.statusGeneral === '6+ Spaces' ? 'green' : 'gray' }}>
                    6+ Spaces
                </button>
            </div>
        </div>
    );
};

export default FloorRowView;

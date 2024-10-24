import React, { useState } from 'react';
import FloorRowView from './FloorRowView';  // Assuming you have a separate component for each floor
import './ParkingView.css';

const ParkingView = ({ floors, collectionName }) => {
    const [statusType, setStatusType] = useState('statusNR'); // Toggle between 'statusNR' and 'statusGeneral'
    const sortedFloors = [...floors].sort((a, b) => a.order - b.order);

    return (
        <div className="parking-view">
            
            {collectionName === "parkingGarage" && (
                <div className="toggle-container">
                    <button onClick={() => setStatusType('statusNR')}
                            className={statusType === 'statusNR' ? 'button selected' : 'button'}>
                        NR Spaces
                    </button>
                    <button onClick={() => setStatusType('statusGeneral')}
                            className={statusType === 'statusGeneral' ? 'button selected' : 'button'}>
                        General Spaces
                    </button>
                </div>
            )}
            <div className="floor-list">
                {sortedFloors
                    .filter(floor => floor[statusType] !== undefined)
                    .map((floor) => (
                        <FloorRowView
                            key={floor.id}
                            floor={floor}
                            statusType={statusType}
                            collectionName={collectionName}
                        />
                    ))}
            </div>
        </div>
    );
};

export default ParkingView;

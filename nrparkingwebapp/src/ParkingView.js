import React from 'react';
import FloorRowView from './FloorRowView';  // Assuming you have a separate component for each floor
import './ParkingView.css';

const ParkingView = ({ floors, collectionName }) => {
    const sortedFloors = [...floors].sort((a, b) => a.order - b.order);

    return (
        <div className="parking-view">
            <div className="floor-list">
                {sortedFloors
                    .filter(floor => floor.statusGeneral !== undefined)
                    .map((floor) => (
                        <FloorRowView
                            key={floor.id}
                            floor={floor}
                            statusType="statusGeneral"
                            collectionName={collectionName}
                        />
                    ))}
            </div>
        </div>
    );
};

export default ParkingView;

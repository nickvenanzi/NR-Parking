import './App.css';

import React, { useState } from "react";
import InputMask from 'react-input-mask';

function App() {
  const [formData, setFormData] = useState({
      personalCell: '',
      governmentCell: '',
      name: '',
      workEmailPrefix: '' // Changed to store only the prefix
  });

  const [verificationMessage, setVerificationMessage] = useState(''); // New state for verification message

  const handleChange = (e) => {
      const { name, value } = e.target;
      setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Combine prefix with domain for submission
    const workEmail = `${formData.workEmailPrefix}@unnpp.gov`;
    
    // Display verification message
    setVerificationMessage(`Check your email at ${workEmail} to verify your identity.`);
    
    // Prepare data to send to Cloud Run
    const submissionData = { 
      ...formData, 
      workEmail 
    };

    try {
      // Make a POST request to the Cloud Run function
      const response = await fetch('https://verifycredentials-170552670421.us-central1.run.app/submit_form', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(submissionData)
      });

      if (response.ok) {
        const data = await response.json();
      }
    } catch (error) {
      console.error('Request failed:', error);
    }
  };

  return (
    <div className="form-container">
      <form className="form-box" onSubmit={handleSubmit}>
        <h2>Verification Form</h2>

        <label>
          Name <span style={{ color: 'red' }}>*</span> {/* Red asterisk for required field */}
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            placeholder="Name"
            required
          />
        </label>

        <label>
          Personal Cell Number <span style={{ color: 'red' }}>*</span> {/* Red asterisk for required field */}
          <InputMask
            mask="(999) 999-9999"
            value={formData.phoneNumber1}
            onChange={handleChange}
            name="personalCell"
            placeholder="(123) 456-7890"
            required
          >
            {(inputProps) => <input {...inputProps} type="tel" />}
          </InputMask>
        </label>

        <label>
          Government Cell Number {/* Optional field */}
          <InputMask
            mask="(999) 999-9999"
            value={formData.phoneNumber2}
            onChange={handleChange}
            name="governmentCell"
            placeholder="(123) 456-7890"
          >
            {(inputProps) => <input {...inputProps} type="tel" />}
          </InputMask>
        </label>

        <label>
          PrimeNet Email <span style={{ color: 'red' }}>*</span> {/* Red asterisk for required field */}
          <div className="email-container">
            <input
              type="text"
              name="workEmailPrefix"
              value={formData.workEmailPrefix}
              onChange={handleChange}
              placeholder="john.doe"
              required
            />
            <span className="email-suffix">@unnpp.gov</span>
          </div>
        </label>

        <button type="submit">Submit</button>

        {/* Display verification message in red */}
        {verificationMessage && (
          <div style={{ color: 'red', marginTop: '10px' }}>
            {verificationMessage}
          </div>
        )}
      </form>
    </div>
  );
};

export default App;

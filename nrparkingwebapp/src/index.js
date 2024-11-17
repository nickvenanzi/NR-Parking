import React from "react";
import ReactDOM from "react-dom";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import ParkingApp from "./ParkingApp";
import VerificationApp from "./VerificationApp";
import "./index.css";

ReactDOM.render(
  <React.StrictMode>
    <Router>
      <Routes>
        <Route path="/" element={<ParkingApp />} />
        <Route path="/verification" element={<VerificationApp />} />
      </Routes>
    </Router>
  </React.StrictMode>,
  document.getElementById("root")
);

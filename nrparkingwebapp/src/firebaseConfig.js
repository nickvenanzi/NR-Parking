import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyA3RGuZJJkAKFnZrbWzsnrLGFlJfH7njz4",
  authDomain: "navalreactorsparking.firebaseapp.com",
  projectId: "navalreactorsparking",
  storageBucket: "navalreactorsparking.appspot.com",
  messagingSenderId: "170552670421",
  appId: "1:170552670421:web:d7571947f8370497814a5c",
  measurementId: "G-MZPW4CTR0Y"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

export { db, auth };

import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBszjtINQES2wbAJvzibwUfZ4c7TKRBFXM",
  authDomain: "grid-dash-72dd2.firebaseapp.com",
  projectId: "grid-dash-72dd2",
  storageBucket: "grid-dash-72dd2.firebasestorage.app",
  messagingSenderId: "356982730158",
  appId: "1:356982730158:web:a2bbee5a381e6782d8ac3f",
  measurementId: "G-X58J2740GM"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
export const db = getFirestore(app);

export default app;

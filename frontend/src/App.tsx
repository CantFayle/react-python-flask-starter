import React from 'react';
import './App.css';
import { Route, BrowserRouter as Router, Routes, Navigate } from 'react-router-dom';
import LoginPage from "./pages/LoginPage";
import HomePage from "./pages/HomePage";
import ProtectedRoute from "./ProtectedRoute";
import { useAuth } from "./hooks";

function App() {
  const { token } = useAuth();

  return (
    <div className="App App-header">
      <Router>
        <Routes>
          <Route path="/" element={<Navigate replace to="/login" />} />
          <Route
            path="/login"
            element={token
              ? <Navigate replace to="/home" />
              : <LoginPage />
            }
          />
          <Route element={<ProtectedRoute />}>
            <Route
              path="/home"
              element={
                <HomePage />
              }
            />
          </Route>
        </Routes>
      </Router>
    </div>
  );
}

export default App;

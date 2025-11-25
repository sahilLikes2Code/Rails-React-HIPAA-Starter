import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { AuthProvider, useAuth } from "./contexts/AuthContext";
import ErrorBoundary from "./components/ErrorBoundary";
import Login from "./components/Login";
import Register from "./components/Register";
import TwoFactorSetup from "./components/TwoFactorSetup";
import AuditLogs from "./components/AuditLogs";
import AuditDetail from "./components/AuditDetail";
import ProtectedRoute from "./components/ProtectedRoute";
import PublicRoute from "./components/PublicRoute";
import ConsentManager from "./components/ConsentManager";
import DataSubjectRequests from "./components/DataSubjectRequests";

// Application name - customize this for your application
const APP_NAME = "HIPAA Starter";

const App = () => {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <Router>
          <Navigation />
          <Routes>
          <Route path="/" element={<HomePage />} />
          <Route
            path="/users/sign_in"
            element={
              <PublicRoute>
                <Login />
              </PublicRoute>
            }
          />
          <Route
            path="/users/sign_up"
            element={
              <PublicRoute>
                <Register />
              </PublicRoute>
            }
          />
          <Route
            path="/users/two_factor_setup/new"
            element={
              <ProtectedRoute>
                <TwoFactorSetup />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/audits"
            element={
              <ProtectedRoute>
                <AuditLogs />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/audits/phi_access"
            element={
              <ProtectedRoute>
                <AuditLogs />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/audits/:id"
            element={
              <ProtectedRoute>
                <AuditDetail />
              </ProtectedRoute>
            }
          />
          <Route
            path="/privacy/consent"
            element={
              <ProtectedRoute>
                <ConsentManager />
              </ProtectedRoute>
            }
          />
          <Route
            path="/privacy/requests"
            element={
              <ProtectedRoute>
                <DataSubjectRequests />
              </ProtectedRoute>
            }
          />
          </Routes>
        </Router>
      </AuthProvider>
    </ErrorBoundary>
  );
};

const Navigation = () => {
  const { user, logout, isAuthenticated } = useAuth();

  return (
    <nav className="bg-white shadow-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex">
            <div className="flex-shrink-0 flex items-center">
              <Link to="/" className="flex items-center space-x-2">
                <svg className="w-8 h-8 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                </svg>
                <span className="text-xl font-bold text-gray-900">{APP_NAME}</span>
              </Link>
            </div>
            {isAuthenticated && (
              <div className="hidden sm:ml-6 sm:flex sm:space-x-8">
                <Link
                  to="/"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 transition-colors"
                >
                  Dashboard
                </Link>
                <Link
                  to="/users/two_factor_setup/new"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 transition-colors"
                >
                  MFA Setup
                </Link>
                <Link
                  to="/admin/audits"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 transition-colors"
                >
                  Audit Logs
                </Link>
                <Link
                  to="/privacy/consent"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 transition-colors"
                >
                  Consent Center
                </Link>
                <Link
                  to="/privacy/requests"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 transition-colors"
                >
                  Data Requests
                </Link>
              </div>
            )}
          </div>
          <div className="flex items-center space-x-4">
            {isAuthenticated ? (
              <div className="flex items-center space-x-4">
                <span className="text-sm text-gray-700">{user?.email}</span>
                <button
                  onClick={logout}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors"
                >
                  Sign out
                </button>
              </div>
            ) : (
              <>
                <Link
                  to="/users/sign_in"
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-indigo-600 bg-indigo-50 hover:bg-indigo-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors"
                >
                  Sign in
                </Link>
                <Link
                  to="/users/sign_up"
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors"
                >
                  Sign up
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

const HomePage = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Hero Section */}
        <div className="text-center mb-12">
          <div className="flex justify-center mb-6">
            <div className="w-20 h-20 bg-indigo-600 rounded-2xl flex items-center justify-center shadow-lg">
              <svg className="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
              </svg>
            </div>
          </div>
          <h1 className="text-5xl font-extrabold text-gray-900 mb-4">
            {APP_NAME}
          </h1>
          <p className="text-xl text-gray-600 mb-2">
            Your HIPAA-compliant application is ready!
          </p>
          <p className="text-sm text-gray-500">
            Built with encryption, audit logging, and multi-factor authentication
          </p>
        </div>

        {/* Feature Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center mb-4">
              <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Field Encryption</h3>
            <p className="text-sm text-gray-600">
              All PHI fields are encrypted at rest using Lockbox
            </p>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mb-4">
              <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Audit Logging</h3>
            <p className="text-sm text-gray-600">
              Complete audit trail of all PHI access and modifications
            </p>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mb-4">
              <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Multi-Factor Auth</h3>
            <p className="text-sm text-gray-600">
              TOTP-based two-factor authentication for enhanced security
            </p>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-4 text-center">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Link
              to="/users/two_factor_setup/new"
              className="flex items-center justify-center px-6 py-4 border border-transparent text-base font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all shadow-lg hover:shadow-xl"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
              </svg>
              Set Up MFA
            </Link>
            <Link
              to="/admin/audits"
              className="flex items-center justify-center px-6 py-4 border border-gray-300 text-base font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all shadow-lg hover:shadow-xl"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              View Audit Logs
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default App;


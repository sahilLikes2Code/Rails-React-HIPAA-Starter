import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import api from "../utils/api";

const TwoFactorSetup = () => {
  const [qrCodeUrl, setQrCodeUrl] = useState(null);
  const [otpCode, setOtpCode] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    // Fetch QR code on mount
    fetchQRCode();
  }, []);

  const fetchQRCode = async () => {
    try {
      const response = await api.get("users/two_factor_setup/new");
      if (response.data.success) {
        setQrCodeUrl(response.data.data.qr_code_url || null);
      } else {
        setError(response.data.error || "Failed to load QR code");
      }
    } catch (err) {
      setError(err.response?.data?.error || "Failed to load QR code. Please try again.");
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const response = await api.post("users/two_factor_setup", {
        otp_attempt: otpCode,
      });

      if (response.data.success) {
        alert("Two-factor authentication enabled successfully!");
        navigate("/");
      } else {
        setError(response.data.error || "Invalid code. Please try again.");
      }
    } catch (err) {
      setError(
        err.response?.data?.error || "Invalid code. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  const handleDisable = async () => {
    if (!confirm("Are you sure you want to disable two-factor authentication?")) {
      return;
    }

    try {
      const response = await api.delete("users/two_factor_setup");
      if (response.data.success) {
        alert("Two-factor authentication disabled");
        navigate("/");
      } else {
        setError(response.data.error || "Failed to disable MFA");
      }
    } catch (err) {
      setError(err.response?.data?.error || "Failed to disable MFA. Please try again.");
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Set Up Two-Factor Authentication
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Scan the QR code with your authenticator app
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          {error && (
            <div className="rounded-lg bg-red-50 p-4 border border-red-200">
              <div className="flex">
                <div className="flex-shrink-0">
                  <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                  </svg>
                </div>
                <div className="ml-3">
                  <p className="text-sm font-medium text-red-800">{error}</p>
                </div>
              </div>
            </div>
          )}

          <div className="bg-white rounded-xl shadow-lg p-6 space-y-4">
            <div className="flex justify-center">
              {qrCodeUrl ? (
                <img
                  src={qrCodeUrl}
                  alt="QR Code"
                  className="w-64 h-64 border border-gray-300 rounded"
                />
              ) : (
                <div className="w-64 h-64 border border-gray-300 rounded flex items-center justify-center bg-gray-100">
                  <p className="text-gray-500">Loading QR code...</p>
                </div>
              )}
            </div>

            <div>
              <label htmlFor="otp-code" className="sr-only">
                Verification Code
              </label>
              <input
                id="otp-code"
                name="otp_code"
                type="text"
                required
                className="appearance-none relative block w-full px-4 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm transition-all"
                placeholder="Enter 6-digit code from your app"
                value={otpCode}
                onChange={(e) => setOtpCode(e.target.value)}
                maxLength={6}
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              disabled={loading || otpCode.length !== 6}
              className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg hover:shadow-xl"
            >
              {loading ? "Verifying..." : "Enable Two-Factor Authentication"}
            </button>
          </div>

          <div className="text-center">
            <button
              type="button"
              onClick={handleDisable}
              className="text-sm text-red-600 hover:text-red-500"
            >
              Disable MFA
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default TwoFactorSetup;


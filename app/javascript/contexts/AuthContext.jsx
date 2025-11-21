import React, { createContext, useContext, useState, useEffect } from "react";
import api from "../utils/api";

const AuthContext = createContext(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    try {
      const response = await api.get("auth/me");
      if (response.data.success) {
        setUser(response.data.data.user);
      } else {
        setUser(null);
      }
    } catch (error) {
      setUser(null);
      if (sessionStorage.getItem("session_timeout")) {
        sessionStorage.removeItem("session_timeout");
      }
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    try {
      const response = await api.post("auth/sign_in", {
        user: { email, password },
      });
      if (response.data.success) {
        setUser(response.data.data.user);
        return { success: true, user: response.data.data.user };
      }
      if (response.data.requires_mfa) {
        return {
          success: false,
          requiresMfa: true,
          userId: response.data.user_id,
          message: response.data.message || "MFA verification required",
        };
      }
      return { success: false, error: response.data.error };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.error || "Login failed",
      };
    }
  };

  const verifyMfa = async (userId, password, otpCode) => {
    try {
      const response = await api.post("auth/verify_mfa", {
        user_id: userId,
        password: password,
        otp_code: otpCode,
      });
      if (response.data.success) {
        setUser(response.data.data.user);
        return { success: true, user: response.data.data.user };
      }
      return { success: false, error: response.data.error };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.error || "MFA verification failed",
      };
    }
  };

  const register = async (userData) => {
    try {
      const response = await api.post("auth/sign_up", {
        user: userData,
      });
      if (response.data.success) {
        setUser(response.data.data.user);
        return { success: true, user: response.data.data.user };
      }
      return { success: false, errors: response.data.errors };
    } catch (error) {
      return {
        success: false,
        errors: error.response?.data?.errors || [error.response?.data?.error || "Registration failed"],
      };
    }
  };

  const logout = async () => {
    try {
      await api.delete("auth/sign_out");
      setUser(null);
      return { success: true };
    } catch (error) {
      setUser(null);
      return { success: true };
    }
  };

  const value = {
    user,
    loading,
    login,
    register,
    logout,
    verifyMfa,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};


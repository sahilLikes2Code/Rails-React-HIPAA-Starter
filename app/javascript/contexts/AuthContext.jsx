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
    // Check if user is authenticated on mount
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
      // 401 means not authenticated, which is fine
      setUser(null);
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
      return { success: false, error: response.data.error };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.error || "Login failed",
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
      // Even if logout fails, clear local state
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
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};


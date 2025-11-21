// API utility for making authenticated requests
import axios from "axios";

const api = axios.create({
  baseURL: "/api/v1/",
  headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
  },
});

// Add CSRF token to all requests
api.interceptors.request.use((config) => {
  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  if (token) {
    config.headers["X-CSRF-Token"] = token;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Check if this is a session timeout (user was previously authenticated)
      // vs initial login failure
      const isAuthenticatedRequest = error.config?.url !== "auth/sign_in" && 
                                     error.config?.url !== "auth/sign_up";
      
      if (isAuthenticatedRequest && window.location.pathname !== "/users/sign_in") {
        sessionStorage.setItem("session_timeout", "true");
        window.location.href = "/users/sign_in";
      }
    }
    return Promise.reject(error);
  }
);

export default api;


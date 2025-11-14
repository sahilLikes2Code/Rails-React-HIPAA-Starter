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

// Handle response errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Handle authentication errors
    if (error.response?.status === 401) {
      // Redirect to login if not already there
      if (window.location.pathname !== "/users/sign_in") {
        window.location.href = "/users/sign_in";
      }
    }
    return Promise.reject(error);
  }
);

export default api;


import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const queryClient = new QueryClient();

// Simple React mounting for SPA
const rootElement = document.getElementById("react-root");
if (rootElement) {
  const root = createRoot(rootElement);
  root.render(
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  );
}


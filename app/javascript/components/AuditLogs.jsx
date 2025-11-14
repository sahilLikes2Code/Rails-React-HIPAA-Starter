import React, { useState, useEffect } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import api from "../utils/api";

const AuditLogs = () => {
  const [audits, setAudits] = useState([]);
  const [pagination, setPagination] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const location = useLocation();
  const navigate = useNavigate();
  const isPhiAccess = location.pathname.includes("phi_access");
  const [currentPage, setCurrentPage] = useState(1);

  useEffect(() => {
    fetchAudits();
  }, [currentPage, isPhiAccess]);

  const fetchAudits = async () => {
    setLoading(true);
    setError("");
    try {
      const endpoint = isPhiAccess ? "audits/phi_access" : "audits";
      const response = await api.get(endpoint, {
        params: { page: currentPage, per_page: 50 },
      });
      if (response.data.success) {
        setAudits(response.data.data.audits);
        setPagination(response.data.data.pagination);
      } else {
        setError(response.data.error || "Failed to load audit logs");
      }
    } catch (err) {
      console.error("Audit logs error:", err);
      // Handle 401 (unauthorized) - redirect to login
      if (err.response?.status === 401) {
        navigate("/users/sign_in");
        return;
      }
      const errorMessage = err.response?.data?.error || 
                          err.response?.data?.message ||
                          err.message || 
                          "Failed to load audit logs";
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleString();
  };

  const timeAgo = (dateString) => {
    const date = new Date(dateString);
    const seconds = Math.floor((new Date() - date) / 1000);
    if (seconds < 60) return "just now";
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes} minute${minutes !== 1 ? "s" : ""} ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours} hour${hours !== 1 ? "s" : ""} ago`;
    const days = Math.floor(hours / 24);
    return `${days} day${days !== 1 ? "s" : ""} ago`;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            {isPhiAccess ? "PHI Access Logs" : "Audit Logs"}
          </h1>
          <p className="mt-2 text-sm text-gray-600">
            {isPhiAccess
              ? "All access and modifications to Protected Health Information (HIPAA Compliance)"
              : "View all system activity and PHI access logs (HIPAA Compliance)"}
          </p>
        </div>

        <div className="mb-4 flex gap-4">
          <Link
            to="/admin/audits"
            className={`px-4 py-2 rounded-md ${
              !isPhiAccess
                ? "bg-indigo-600 text-white"
                : "bg-white text-gray-700 border border-gray-300"
            }`}
          >
            All Audit Logs
          </Link>
          <Link
            to="/admin/audits/phi_access"
            className={`px-4 py-2 rounded-md ${
              isPhiAccess
                ? "bg-indigo-600 text-white"
                : "bg-white text-gray-700 border border-gray-300"
            }`}
          >
            PHI Access Logs
          </Link>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-50 border border-red-200 p-4">
            <p className="text-sm font-medium text-red-800">{error}</p>
          </div>
        )}

        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          {loading ? (
            <div className="px-4 py-8 text-center text-gray-500">Loading...</div>
          ) : audits.length === 0 ? (
            <div className="px-4 py-8 text-center text-gray-500">No audit logs found.</div>
          ) : (
            <>
              <ul className="divide-y divide-gray-200">
                {audits.map((audit) => (
                  <li key={audit.id}>
                    <div className="px-4 py-4 sm:px-6">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center">
                          <p className="text-sm font-medium text-indigo-600 truncate">
                            {audit.item_type} #{audit.item_id}
                          </p>
                          <p className="ml-2 flex-shrink-0 text-sm text-gray-500">
                            {audit.event}
                          </p>
                        </div>
                        <div className="ml-2 flex-shrink-0 flex">
                          <p className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                            {timeAgo(audit.created_at)}
                          </p>
                        </div>
                      </div>
                      <div className="mt-2 sm:flex sm:justify-between">
                        <div className="sm:flex">
                          <p className="flex items-center text-sm text-gray-500">
                            <svg
                              className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth="2"
                                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                              />
                            </svg>
                            User: {audit.user_email}
                          </p>
                        </div>
                        <div className="mt-2 flex items-center text-sm text-gray-500 sm:mt-0">
                          <svg
                            className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                            />
                          </svg>
                          <p>{formatDate(audit.created_at)}</p>
                        </div>
                      </div>
                      <div className="mt-4 text-right">
                        <Link
                          to={`/admin/audits/${audit.id}`}
                          className="text-indigo-600 hover:text-indigo-500 text-sm font-medium"
                        >
                          View Details
                        </Link>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
              {pagination && pagination.total_pages > 1 && (
                <div className="px-4 py-4 sm:px-6 border-t border-gray-200 flex items-center justify-between">
                  <div className="flex-1 flex justify-between sm:hidden">
                    <button
                      onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                      disabled={currentPage === 1}
                      className="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
                    >
                      Previous
                    </button>
                    <button
                      onClick={() => setCurrentPage(Math.min(pagination.total_pages, currentPage + 1))}
                      disabled={currentPage === pagination.total_pages}
                      className="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
                    >
                      Next
                    </button>
                  </div>
                  <div className="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                    <div>
                      <p className="text-sm text-gray-700">
                        Showing page <span className="font-medium">{pagination.current_page}</span> of{" "}
                        <span className="font-medium">{pagination.total_pages}</span>
                      </p>
                    </div>
                    <div>
                      <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                        <button
                          onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                          disabled={currentPage === 1}
                          className="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50"
                        >
                          Previous
                        </button>
                        <button
                          onClick={() => setCurrentPage(Math.min(pagination.total_pages, currentPage + 1))}
                          disabled={currentPage === pagination.total_pages}
                          className="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50"
                        >
                          Next
                        </button>
                      </nav>
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default AuditLogs;


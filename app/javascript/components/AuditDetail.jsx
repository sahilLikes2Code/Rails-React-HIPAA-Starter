import React, { useState, useEffect } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import api from "../utils/api";

const AuditDetail = () => {
  const { id } = useParams();
  const [audit, setAudit] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetchAudit();
  }, [id]);

  const fetchAudit = async () => {
    setLoading(true);
    setError("");
    try {
      const response = await api.get(`audits/${id}`);
      if (response.data.success) {
        setAudit(response.data.data.audit);
      }
    } catch (err) {
      // Handle 401 (unauthorized) - redirect to login
      if (err.response?.status === 401) {
        navigate("/users/sign_in");
        return;
      }
      setError(err.response?.data?.error || "Failed to load audit log");
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleString();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center text-gray-500">Loading...</div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="rounded-lg bg-red-50 border border-red-200 p-4">
            <p className="text-sm font-medium text-red-800">{error}</p>
          </div>
        </div>
      </div>
    );
  }

  if (!audit) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <Link
            to="/admin/audits"
            className="text-indigo-600 hover:text-indigo-500 mb-4 inline-block"
          >
            ← Back to Audit Logs
          </Link>
          <h1 className="text-3xl font-bold text-gray-900">Audit Log Details</h1>
        </div>

        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="px-4 py-5 sm:px-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900">
              Audit Log Entry #{audit.id}
            </h3>
            <p className="mt-1 max-w-2xl text-sm text-gray-500">
              Detailed information about this system event.
            </p>
          </div>
          <div className="border-t border-gray-200 px-4 py-5 sm:p-0">
            <dl className="sm:divide-y sm:divide-gray-200">
              <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt className="text-sm font-medium text-gray-500">Event</dt>
                <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                  {audit.event}
                </dd>
              </div>
              <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt className="text-sm font-medium text-gray-500">Item Type</dt>
                <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                  {audit.item_type}
                </dd>
              </div>
              <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt className="text-sm font-medium text-gray-500">Item ID</dt>
                <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                  {audit.item_id}
                </dd>
              </div>
              <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt className="text-sm font-medium text-gray-500">Changed By</dt>
                <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                  {audit.user_email}
                </dd>
              </div>
              <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                <dt className="text-sm font-medium text-gray-500">Created At</dt>
                <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                  {formatDate(audit.created_at)}
                </dd>
              </div>
              {audit.object_changes && (
                <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                  <dt className="text-sm font-medium text-gray-500">Object Changes</dt>
                  <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                    <pre className="bg-gray-100 p-3 rounded-md text-xs overflow-x-auto">
                      {JSON.stringify(audit.object_changes, null, 2)}
                    </pre>
                  </dd>
                </div>
              )}
              {audit.object && (
                <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                  <dt className="text-sm font-medium text-gray-500">Full Object</dt>
                  <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                    <pre className="bg-gray-100 p-3 rounded-md text-xs overflow-x-auto">
                      {JSON.stringify(audit.object, null, 2)}
                    </pre>
                  </dd>
                </div>
              )}
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AuditDetail;


import React, { useEffect, useState } from "react";
import { fetchRequests, submitRequest } from "../utils/dataSubjectRequests";

const REQUEST_TYPES = [
  { value: "access", label: "Access – view the data we hold about you" },
  { value: "export", label: "Export – receive a machine-readable export" },
  { value: "erasure", label: "Erasure – delete personal data (where allowed)" },
];

const DataSubjectRequests = () => {
  const [requests, setRequests] = useState([]);
  const [form, setForm] = useState({ request_type: "access", notes: "" });
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const loadRequests = async () => {
    setLoading(true);
    try {
      const response = await fetchRequests();
      setRequests(response);
    } catch (err) {
      setError(err.response?.data?.errors?.join(", ") || "Unable to load data subject requests.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRequests();
  }, []);

  const handleSubmit = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    setError("");
    setSuccess("");

    try {
      await submitRequest(form);
      setForm({ request_type: "access", notes: "" });
      setSuccess("Request submitted successfully. Our team will respond within 30 days.");
      await loadRequests();
    } catch (err) {
      setError(err.response?.data?.errors?.join(", ") || "Unable to submit request.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto mt-10 bg-white shadow rounded-xl p-8">
      <h1 className="text-2xl font-semibold text-gray-900 mb-4">Data Subject Requests</h1>
      <p className="text-sm text-gray-600 mb-6">
        Submit GDPR Article 15/17/20 requests. We'll confirm via email and track fulfillment within statutory timelines.
      </p>

      {error && <div className="mb-4 rounded-md bg-red-50 p-4 text-sm text-red-800">{error}</div>}
      {success && <div className="mb-4 rounded-md bg-green-50 p-4 text-sm text-green-800">{success}</div>}

      <form onSubmit={handleSubmit} className="space-y-4 mb-10">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Request Type</label>
          <select
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            value={form.request_type}
            onChange={(event) => setForm({ ...form, request_type: event.target.value })}
          >
            {REQUEST_TYPES.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Notes (optional)</label>
          <textarea
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            rows="3"
            value={form.notes}
            onChange={(event) => setForm({ ...form, notes: event.target.value })}
          />
        </div>
        <button
          type="submit"
          disabled={submitting}
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        >
          {submitting ? "Submitting…" : "Submit Request"}
        </button>
      </form>

      <h2 className="text-lg font-semibold text-gray-900 mb-3">Your Requests</h2>
      {loading ? (
        <p className="text-sm text-gray-500">Loading history…</p>
      ) : (
        <div className="space-y-3">
          {requests.map((request) => (
            <div key={request.id} className="border border-gray-200 rounded-lg p-4">
              <div className="flex justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-900 capitalize">{request.request_type}</p>
                  <p className="text-xs text-gray-500">
                    Submitted {new Date(request.created_at).toLocaleString()} • Status:{" "}
                    <span className="font-medium">{request.status}</span>
                  </p>
                </div>
                {request.completed_at && (
                  <p className="text-xs text-green-600">Completed {new Date(request.completed_at).toLocaleString()}</p>
                )}
              </div>
              {request.notes && <p className="text-sm text-gray-600 mt-2 whitespace-pre-wrap">{request.notes}</p>}
            </div>
          ))}
          {requests.length === 0 && <p className="text-sm text-gray-500">No requests yet.</p>}
        </div>
      )}
    </div>
  );
};

export default DataSubjectRequests;


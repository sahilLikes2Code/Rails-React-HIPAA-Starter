import React, { useEffect, useState } from "react";
import { fetchConsentRecords, upsertConsent, updateConsent } from "../utils/consent";

const PURPOSES = [
  {
    key: "core_processing",
    label: "Core PHI/PII Processing",
    description: "Required for delivering healthcare services and fulfilling contractual obligations.",
    required: true,
  },
  {
    key: "product_updates",
    label: "Product Announcements",
    description: "Email notifications about new features and improvements.",
  },
  {
    key: "research_analytics",
    label: "Research & Analytics",
    description: "Use of de-identified data for improving product quality.",
  },
];

const ConsentManager = () => {
  const [consents, setConsents] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const loadConsents = async () => {
    setLoading(true);
    try {
      const response = await fetchConsentRecords();
      const mapped = response.reduce((acc, record) => ({ ...acc, [record.purpose]: record }), {});
      setConsents(mapped);
    } catch (err) {
      setError(err.response?.data?.errors?.join(", ") || "Unable to load consent preferences.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadConsents();
  }, []);

  const handleToggle = async (purposeKey, granted) => {
    setError("");
    const existingRecord = consents[purposeKey];

    try {
      const response = existingRecord
        ? await updateConsent(existingRecord.id, { granted })
        : await upsertConsent({ purpose: purposeKey, granted });

      setConsents((prev) => ({ ...prev, [purposeKey]: response }));
    } catch (err) {
      setError(err.response?.data?.errors?.join(", ") || "Unable to update consent preference.");
    }
  };

  if (loading) {
    return <p className="p-4 text-gray-500">Loading consent preferences…</p>;
  }

  return (
    <div className="max-w-3xl mx-auto mt-10 bg-white shadow rounded-xl p-8">
      <h1 className="text-2xl font-semibold text-gray-900 mb-4">Privacy & Consent Center</h1>
      <p className="text-sm text-gray-600 mb-6">
        Manage how we process your data in accordance with GDPR Article 7 and SOC 2 privacy controls. Required consents
        cannot be disabled but are shown for transparency.
      </p>

      {error && <div className="mb-4 rounded-md bg-red-50 p-4 text-sm text-red-800">{error}</div>}

      <div className="space-y-6">
        {PURPOSES.map((purpose) => {
          const record = consents[purpose.key];
          const granted = record ? record.granted && !record.revoked_at : purpose.required;

          return (
            <div key={purpose.key} className="border border-gray-200 rounded-lg p-5 flex justify-between items-start">
              <div>
                <h2 className="text-lg font-medium text-gray-900">{purpose.label}</h2>
                <p className="text-sm text-gray-600 mt-1">{purpose.description}</p>
                {record && (
                  <p className="text-xs text-gray-500 mt-2">
                    Last updated: {new Date(record.updated_at).toLocaleString()} (source: {record.source})
                  </p>
                )}
              </div>

              <label className="inline-flex items-center cursor-pointer">
                <span className="mr-3 text-sm text-gray-600">{granted ? "Enabled" : "Disabled"}</span>
                <input
                  type="checkbox"
                  className="sr-only peer"
                  checked={granted}
                  disabled={purpose.required}
                  onChange={(event) => handleToggle(purpose.key, event.target.checked)}
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-indigo-500 rounded-full peer dark:bg-gray-700 peer-checked:bg-indigo-600 transition-colors"></div>
              </label>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default ConsentManager;


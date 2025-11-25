import api from "./api";

export const fetchConsentRecords = async () => {
  const response = await api.get("consent_records");
  return response.data;
};

export const upsertConsent = async ({ purpose, granted }) => {
  const response = await api.post("consent_records", {
    consent_record: { purpose, granted, source: "self_service_portal", jurisdiction: "EU" },
  });
  return response.data;
};

export const updateConsent = async (id, { granted }) => {
  const response = await api.put(`consent_records/${id}`, {
    consent_record: { granted },
  });
  return response.data;
};


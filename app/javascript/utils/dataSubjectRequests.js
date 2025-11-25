import api from "./api";

export const fetchRequests = async () => {
  const response = await api.get("data_subject_requests");
  return response.data;
};

export const submitRequest = async ({ request_type, notes }) => {
  const response = await api.post("data_subject_requests", {
    data_subject_request: { request_type, notes },
  });
  return response.data;
};


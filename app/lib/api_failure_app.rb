class ApiFailureApp < Devise::FailureApp
  def respond
    if request.path.start_with?("/api/")
      self.status = 401
      self.content_type = "application/json"
      self.response_body = { success: false, error: i18n_message }.to_json
    else
      super
    end
  end
end


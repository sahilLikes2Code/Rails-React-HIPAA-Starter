# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuditPolicy, type: :policy do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:version) { PaperTrail::Version.new }

  describe "#index?" do
    it "allows admins to view audit logs" do
      policy = AuditPolicy.new(admin_user, version)
      expect(policy.index?).to be true
    end

    it "denies non-admins from viewing audit logs" do
      policy = AuditPolicy.new(regular_user, version)
      expect(policy.index?).to be false
    end

    it "denies unauthenticated users" do
      policy = AuditPolicy.new(nil, version)
      expect(policy.index?).to be false
    end
  end

  describe "#show?" do
    it "allows admins to view individual audit logs" do
      policy = AuditPolicy.new(admin_user, version)
      expect(policy.show?).to be true
    end

    it "denies non-admins from viewing individual audit logs" do
      policy = AuditPolicy.new(regular_user, version)
      expect(policy.show?).to be false
    end
  end

  describe "#phi_access?" do
    it "allows admins to view PHI access logs" do
      policy = AuditPolicy.new(admin_user, version)
      expect(policy.phi_access?).to be true
    end

    it "denies non-admins from viewing PHI access logs" do
      policy = AuditPolicy.new(regular_user, version)
      expect(policy.phi_access?).to be false
    end
  end

  describe "Scope" do
    let!(:version1) { PaperTrail::Version.create!(item_type: "User", item_id: SecureRandom.uuid, event: "create") }
    let!(:version2) { PaperTrail::Version.create!(item_type: "User", item_id: SecureRandom.uuid, event: "update") }

    it "returns all versions for admins" do
      scope = AuditPolicy::Scope.new(admin_user, PaperTrail::Version).resolve
      expect(scope).to include(version1, version2)
    end

    it "returns no versions for non-admins" do
      scope = AuditPolicy::Scope.new(regular_user, PaperTrail::Version).resolve
      expect(scope).to be_empty
    end
  end
end


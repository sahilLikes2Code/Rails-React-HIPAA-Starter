# Paper Trail configuration for HIPAA audit logging
# Minimum 6-year retention required for HIPAA compliance

PaperTrail.config.enabled = true
PaperTrail.config.version_limit = nil # Keep all versions (manage retention via scheduled jobs)

# Configure which models should be tracked
# Add has_paper_trail to models containing PHI


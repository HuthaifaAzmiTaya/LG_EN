AiExceptionAnalyzer.configure do |config|
    config.ollama_host = ENV.fetch("AI_EXCEPTION_OLLAMA_HOST", "http://localhost:11434")
    config.model_name = ENV.fetch("AI_EXCEPTION_OLLAMA_MODEL", "qwen2.5-coder:7b")
    config.enabled = ENV.fetch("AI_EXCEPTION_ANALYZER_ENABLED", "true") == "true"

    # Notification settings
    config.slack_webhook_url = ENV["AI_EXCEPTION_ANALYZER_SLACK_WEBHOOK_URL"]
    config.slack_critical_channel = ENV.fetch("AI_EXCEPTION_ANALYZER_SLACK_CRITICAL_CHANNEL", "#critical-exceptions")
    config.slack_high_channel = ENV.fetch("AI_EXCEPTION_ANALYZER_SLACK_HIGH_CHANNEL", "#high-urgency-exceptions")
    config.slack_medium_channel = ENV.fetch("AI_EXCEPTION_ANALYZER_SLACK_MEDIUM_CHANNEL", "#medium-urgency-exceptions")

    # Github Integration settings (optional)
    config.github_enabled = ENV['AI_EXCEPTION_ANALYZER_GITHUB_TOKEN'].present?
    config.github_token = ENV["AI_EXCEPTION_ANALYZER_GITHUB_TOKEN"]
    config.github_repository = ENV["AI_EXCEPTION_ANALYZER_GITHUB_REPOSITORY"]

end
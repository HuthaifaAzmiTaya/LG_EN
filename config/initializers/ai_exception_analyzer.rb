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

    # Analysis settings
    config.analysis_timeout_seconds = ENV.fetch("AI_EXCEPTION_ANALYZER_TIMEOUT_SECONDS", "10").to_i
    config.max_analysis_retries = ENV.fetch("AI_EXCEPTION_ANALYZER_MAX_RETRIES", "3").to_i
    config.max_code_context_lines = ENV.fetch("AI_EXCEPTION_ANALYZER_MAX_CODE_CONTEXT_LINES", "5").to_i
    config.max_stack_trace_depth = ENV.fetch("AI_EXCEPTION_ANALYZER_MAX_STACK_TRACE_DEPTH", "10").to_i

    # Sensitive data patterns to scrub
    config.sensitive_data_patterns = [
        /Authorization:\s*Bearer\s+\S+/i, 
        /api_key=\S+/i, 
        /password=\S+/i, 
        /password/i,
        /token/i,
        /api[_-]?key/i,
        /secret/i,
        /credit[_-]?card/i,
        /ssn/i,
        /(\d{3}[-.]?\d{3}[-.]?\d{4})/,
        /([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/,
    ]
end
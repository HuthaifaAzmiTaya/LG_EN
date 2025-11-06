module AiExceptionAnalyzer
  class Configuration
    attr_accessor :ollama_host, :model_name, :enabled, :slack_webhook_url,
                  :slack_critical_channel, :slack_high_channel, :slack_medium_channel,
                  :github_enabled, :github_token, :github_repository,
                  :max_code_context_lines, :max_stack_trace_depth, :max_analysis_retries,
                  :analysis_timeout_seconds, :sensitive_data_patterns
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def capture(exception, context = {})
      return unless configuration.enabled
      
      AnalysisJob.perform_async(
        exception.class.name,
        exception.message,
        exception.backtrace,
        context
      )
    end
  end
end
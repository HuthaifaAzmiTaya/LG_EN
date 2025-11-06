class AiExceptionAnalyzer::AnalysisJob < ApplicationJob
  include Sidekiq::Job
    sidekiq_options queue: :ai_analysis, retry: ِهAiExceptionAnalyzer.configuration.max_analysis_retries

  def perform(exception_class, message, backtrace, context)
      start_time = Time.current
      
      # Sanitize context
      sanitized_context = DataSanitizer.sanitize(context)
      
      # Determine urgency
      urgency = UrgencyClassifier.classify(exception_class, message, backtrace)
      
      # Extract code context
      code_context = CodeExtractor.extract(backtrace)
      
      # Analyze with AI
      ai_response = OllamaClient.analyze(
        exception_class: exception_class,
        message: message,
        backtrace: backtrace[0..AiExceptionAnalyzer.configuration.max_stack_trace_depth],
        code_context: code_context,
        urgency: urgency
      )
      
      # Save analysis
      analysis = AiExceptionAnalysis.create!(
        exception_class: exception_class,
        exception_message: message,
        backtrace: backtrace.join("\n"),
        sanitized_params: sanitized_context.to_json,
        urgency_level: urgency,
        ai_analysis: ai_response[:analysis],
        suggested_fix: ai_response[:fix],
        analyzed_code: code_context,
        analysis_duration: Time.current - start_time,
        model_used: AiExceptionAnalyzer.configuration.model_name
      )
      
      # Send notifications
      NotificationService.notify(analysis)
      
      # Create GitHub issue if critical
      if urgency == 'critical' && AiExceptionAnalyzer.configuration.github_enabled
        GithubService.create_issue(analysis)
      end
    rescue => e
      Rails.logger.error("AI Exception Analysis failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
end

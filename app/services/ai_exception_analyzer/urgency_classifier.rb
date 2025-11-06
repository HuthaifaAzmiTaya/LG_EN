class AiExceptionAnalyzer::UrgencyClassifier
	CRITICAL_PATTERNS = [
		/ActiveRecord::.*Error/,
		/PG::/,
		/Mysql2::/,
		/payment/i,
		/charge/i,
		/billing/i,
		/authentication/i,
		/authorization/i,
		/SecurityError/,
	].freeze
	
	HIGH_PATTERNS = [
		/ActionController::/,
		/NoMethodError/,
		/ArgumentError/,
		/TypeError/,
		/NameError/,
	].freeze
	
	MEDIUM_PATTERNS = [
		/Sidekiq/,
		/ActiveJob/,
		/HTTP/i,
		/API/i,
	].freeze
	
	LOW_PATTERNS = [
		/ActiveRecord::RecordNotFound/,
		/ActionController::RoutingError/,
		/ActionController::ParameterMissing/,
	].freeze
	
	def self.classify(exception_class, message, backtrace)
		full_context = "#{exception_class} #{message}"
		
		return 'critical' if matches_any?(full_context, CRITICAL_PATTERNS)
		return 'low' if matches_any?(full_context, LOW_PATTERNS)
		return 'high' if matches_any?(full_context, HIGH_PATTERNS)
		return 'medium' if matches_any?(full_context, MEDIUM_PATTERNS)
		
		# Default based on where it occurred
		if backtrace&.first&.include?('app/controllers')
			'high'
		elsif backtrace&.first&.include?('app/jobs')
			'medium'
		else
			'medium'
		end
	end
	
	def self.matches_any?(text, patterns)
		patterns.any? { |pattern| text.match?(pattern) }
	end
end
class AiExceptionAnalyzer::DataSanitizer
	REDACTED = '[REDACTED]'.freeze
	
	def self.sanitize(data)
		case data
		when Hash
			data.transform_values { |v| sanitize(v) }
		when Array
			data.map { |v| sanitize(v) }
		when String
			sanitize_string(data)
		else
			data
		end
	end
	
	def self.sanitize_string(str)
		sanitized = str.dup
		
		AiExceptionAnalyzer.configuration.sensitive_patterns.each do |pattern|
			sanitized.gsub!(pattern, REDACTED)
		end
		
		sanitized
	end
end
class CodeExtractor
	def self.extract(backtrace)
		return {} unless backtrace.present?
		
		# Find the first app file in the stack trace
		app_trace = backtrace.find { |line| line.include?('/app/') }
		return {} unless app_trace
		
		# Parse file path and line number
		match = app_trace.match(/(.+):(\d+):in/)
		return {} unless match
		
		file_path = match[1]
		line_number = match[2].to_i
		
		return {} unless File.exist?(file_path)
		
		# Read the file
		lines = File.readlines(file_path)
		
		# Extract method context
		method_lines = extract_method_context(lines, line_number)
		
		{
			file_path: file_path.sub(Rails.root.to_s, ''),
			line_number: line_number,
			method_code: method_lines.join,
			full_file: extract_full_file_if_small(lines)
		}
	rescue => e
		Rails.logger.error("Code extraction failed: #{e.message}")
		{}
	end
	
	def self.extract_method_context(lines, error_line)
		max_lines = AiExceptionAnalyzer.configuration.max_code_context_lines
		start_idx = [0, error_line - 20].max
		end_idx = [lines.length - 1, error_line + 20].min
		
		lines[start_idx..end_idx]
	end
	
	def self.extract_full_file_if_small(lines)
		if lines.length <= AiExceptionAnalyzer.configuration.max_code_context_lines
			lines.join
		else
			nil
		end
	end
end
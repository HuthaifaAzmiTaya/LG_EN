class AiExceptionAnalyzer::OllamaClient
  include HTTParty
  base_uri AiExceptionAnalyzer.configuration.ollama_host
  
  def self.analyze(exception_class:, message:, backtrace:, code_context:, urgency:)
    prompt = build_prompt(exception_class, message, backtrace, code_context, urgency)
    
    response = post(
      '/api/generate',
      body: {
        model: AiExceptionAnalyzer.configuration.model_name,
        prompt: prompt,
        stream: false,
        options: {
          temperature: 0.3,
          top_p: 0.9,
        }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: AiExceptionAnalyzer.configuration.analysis_timeout
    )
    
    if response.success?
      parse_response(response.parsed_response['response'])
    else
      { analysis: 'AI analysis failed', fix: 'Unable to generate fix' }
    end
  rescue => e
    Rails.logger.error("Ollama API error: #{e.message}")
    { analysis: "Analysis error: #{e.message}", fix: 'Unable to generate fix' }
  end
  
  def self.build_prompt(exception_class, message, backtrace, code_context, urgency)
    <<~PROMPT
      You are an expert Ruby on Rails developer analyzing an exception.
      
      EXCEPTION DETAILS:
      - Class: #{exception_class}
      - Message: #{message}
      - Urgency: #{urgency}
      
      STACK TRACE:
      #{backtrace.first(10).join("\n")}
      
      CODE CONTEXT:
      File: #{code_context[:file_path]}
      Line: #{code_context[:line_number]}
      
      #{code_context[:method_code] || code_context[:full_file]}
      
      Please provide:
      1. ROOT CAUSE: What caused this exception? Be specific.
      2. IMPACT: How does this affect the application?
      3. SUGGESTED FIX: Provide concrete code changes to fix this issue.
      
      Format your response as:
      ROOT CAUSE: [your analysis]
      IMPACT: [impact description]
      SUGGESTED FIX:
      ```ruby
      [code snippet]
      ```
    PROMPT
  end
  
  def self.parse_response(response_text)
    root_cause = response_text[/ROOT CAUSE:(.*?)(?=IMPACT:|$)/m, 1]&.strip
    impact = response_text[/IMPACT:(.*?)(?=SUGGESTED FIX:|$)/m, 1]&.strip
    fix = response_text[/SUGGESTED FIX:(.*)/m, 1]&.strip
    
    {
      analysis: "#{root_cause}\n\nImpact: #{impact}",
      fix: fix
    }
  end
end
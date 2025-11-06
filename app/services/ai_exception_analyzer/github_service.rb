class AiExceptionAnalyzer::GithubService
  def self.create_issue(analysis)
    return unless AiExceptionAnalyzer.configuration.github_enabled
    
    response = HTTParty.post(
      "https://api.github.com/repos/#{AiExceptionAnalyzer.configuration.github_repo}/issues",
      headers: {
        'Authorization' => "token #{AiExceptionAnalyzer.configuration.github_token}",
        'Accept' => 'application/vnd.github.v3+json'
      },
      body: {
        title: "[AI-Detected] #{analysis.exception_class}: #{analysis.exception_message&.truncate(50)}",
        body: build_issue_body(analysis),
        labels: ['bug', 'ai-detected', "urgency:#{analysis.urgency_level}"]
      }.to_json
    )
    
    if response.success?
      issue_url = response.parsed_response['html_url']
      analysis.update(github_issue_created: true, github_issue_url: issue_url)
    end
  rescue => e
    Rails.logger.error("GitHub issue creation failed: #{e.message}")
  end
  
  def self.build_issue_body(analysis)
    <<~BODY
      ## Exception Details
      
      **Class:** `#{analysis.exception_class}`
      **Message:** #{analysis.exception_message}
      **Urgency:** #{analysis.urgency_level.upcase}
      **Occurred At:** #{analysis.created_at}
      
      ## AI Analysis
      
      #{analysis.ai_analysis}
      
      ## Suggested Fix
      
      #{analysis.suggested_fix}
      
      ## Stack Trace
      
      ```
      #{analysis.backtrace&.split("\n")&.first(15)&.join("\n")}
      ```
      
      ---
      *This issue was automatically created by AI Exception Analyzer*
    BODY
  end
end
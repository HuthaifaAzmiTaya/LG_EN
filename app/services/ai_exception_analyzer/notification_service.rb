class AiExceptionAnalyzer::NotificationService
  def self.notify(analysis)
    case analysis.urgency_level
    when 'critical'
      send_slack(analysis, AiExceptionAnalyzer.configuration.slack_critical_channel)
    when 'high'
      send_slack(analysis, AiExceptionAnalyzer.configuration.slack_high_channel)
    when 'medium'
      send_slack(analysis, AiExceptionAnalyzer.configuration.slack_medium_channel)
    when 'low'
      # Log only, no notification
    end
  end
  
  def self.send_slack(analysis, channel)
    return unless AiExceptionAnalyzer.configuration.slack_webhook_url
    
    notifier = Slack::Notifier.new(
      AiExceptionAnalyzer.configuration.slack_webhook_url,
      channel: channel
    )
    
    notifier.ping(
      text: "#{urgency_emoji(analysis.urgency_level)} *#{analysis.exception_class}*",
      attachments: [
        {
          color: urgency_color(analysis.urgency_level),
          fields: [
            { title: 'Message', value: analysis.exception_message, short: false },
            { title: 'AI Analysis', value: truncate(analysis.ai_analysis, 500), short: false },
            { title: 'Suggested Fix', value: "```#{truncate(analysis.suggested_fix, 500)}```", short: false },
            { title: 'Occurred At', value: analysis.created_at.to_s, short: true },
          ]
        }
      ]
    )
  rescue => e
    Rails.logger.error("Slack notification failed: #{e.message}")
  end
  
  def self.urgency_emoji(urgency)
    case urgency
    when 'critical' then '🚨'
    when 'high' then '⚠️'
    when 'medium' then '⚡'
    when 'low' then 'ℹ️'
    end
  end
  
  def self.urgency_color(urgency)
    case urgency
    when 'critical' then 'danger'
    when 'high' then 'warning'
    when 'medium' then '#439FE0'
    when 'low' then 'good'
    end
  end
  
  def self.truncate(text, length)
    return '' if text.blank?
    text.length > length ? "#{text[0...length]}..." : text
  end
end
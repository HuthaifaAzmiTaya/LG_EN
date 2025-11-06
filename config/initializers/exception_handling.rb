Rails.application.config.after_initialize do
  if defined?(AiExceptionAnalyzer) && AiExceptionAnalyzer.configuration.enabled
    # Hook into Rails exception handling
    ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      
      if event.payload[:exception]
        exception_class, message = event.payload[:exception]
        exception = exception_class.constantize.new(message)
        
        context = {
          controller: event.payload[:controller],
          action: event.payload[:action],
          params: event.payload[:params],
          request_id: event.payload[:headers]&.[]('action_dispatch.request_id')
        }
        
        AiExceptionAnalyzer.capture(exception, context)
      end
    end
  end
end
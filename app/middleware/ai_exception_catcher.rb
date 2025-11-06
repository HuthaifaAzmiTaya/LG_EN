module AiExceptionAnalyzer
  class  # TODO - fix the name spacing here
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue => exception
      # Re-raise but also capture for analysis
      context = extract_context(env)
      AiExceptionAnalyzer.capture(exception, context)
      raise exception
    end

    private

    def extract_context(env)
      request = ActionDispatch::Request.new(env)
      {
        path: request.path,
        method: request.method,
        params: request.params,
        remote_ip: request.remote_ip,
        user_agent: request.user_agent
      }
    end
  end
end
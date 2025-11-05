class AiExceptionAnalysis < ApplicationRecord
    URGENCY_LEVELS = %w[critical high medium low].freeze

    validates :exception_class, :urgency_level, presence: true
end

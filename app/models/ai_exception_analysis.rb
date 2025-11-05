class AiExceptionAnalysis < ApplicationRecord
    URGENCY_LEVELS = %w[critical high medium low].freeze

    validates :exception_class, :urgency_level, presence: true
    valdiates :urgency_level, inclusion: { in: URGENCY_LEVELS }

    scope :critical, -> { where(urgency_level: 'critical') }
    scope :high, -> { where(urgency_level: 'high') }
    scope :medium, -> { where(urgency_level: 'medium') }
    scope :low, -> { where(urgency_level: 'low') }
    scope :recent, -> { order(created_at: :desc) }

    def critical?
        urgency_level == 'critical'
    end

    def high?
        urgency_level == 'high'
    end
end

class CreateAiExceptionAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_exception_analyses do |t|
      t.string :exception_class, null: false
      t.text :exception_message
      t.text :backtrace
      t.text :sanitized_params
      t.string :urgency_level, null: false
      t.text :ai_analysis
      t.text :suggested_fix
      t.text :analyzed_code
      t.float :analysis_duration
      t.string :model_used
      t.boolean :github_issue_created, default: false
      t.string :github_issue_url
      t.timestamps
    end

    add_index :ai_exception_analyses, :exception_class
    add_index :ai_exception_analyses, :urgency_level
    add_index :ai_exception_analyses, :created_at
  end
end

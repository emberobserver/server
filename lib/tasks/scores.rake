# frozen_string_literal: true

namespace :scores do
  task history: :environment do
    SaveCsv.write('score-history.csv', ScoreHistory.rows_by_model_version)
  end
end

# frozen_string_literal: true

class SaveCsv
  def self.write(filename, rows)
    require 'csv'
    File.write(filename, rows.map(&:to_csv).join)
  end
end

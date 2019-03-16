# frozen_string_literal: true

class ScoreHistory
  def self.data
    Addon.active.where('score is not null').map(&:historical_score_calculations)
  end

  def self.data_by_model_version
    data = {}
    ScoreCalculation.all.group_by(&:model_version).each do |version, calcs|
      data[version] = calcs.group_by(&:addon_id).map do |_addon_id, addon_calcs|
        calc = addon_calcs.last
        { name: calc.info['addon_name'], score: calc.info['score'], model_version: calc.info['model_version'] }
      end
    end
    data
  end

  def self.rows_by_model_version
    rows = [['Addon']]
    scores_by_addon = Hash.new { |hash, key| hash[key] = [] }
    data_by_model_version.each do |version, calculations|
      rows[0].push("Model #{version}")
      calculations.each { |c| scores_by_addon[c[:name]].push(c[:score]) }
    end

    scores_by_addon.keys.sort.each do |addon_name|
      rows.push([addon_name] + scores_by_addon[addon_name])
    end

    rows
  end
end

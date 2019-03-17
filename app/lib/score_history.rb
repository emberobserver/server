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
    data = data_by_model_version
    # Find all addons that have scores (some addons may not be present in all model_versions)
    addons = []
    data.each do |_version, calculations|
      calculations.each do |c|
        addons << c[:name]
      end
    end
    addons.uniq!

    scores_by_addon = Hash.new { |hash, key| hash[key] = [] }

    rows = [['Addon']]
    data.keys.sort.each do |version|
      rows[0].push("Model #{version}")
      calculations = data[version]
      addons.each do |addon_name|
        # Find calculation for this addon
        calc = calculations.find { |c| c[:name] == addon_name }
        scores_by_addon[addon_name].push (calc ? calc[:score] : nil)
      end
    end

    scores_by_addon.keys.sort.each do |addon_name|
      rows.push([addon_name] + scores_by_addon[addon_name])
    end

    rows
  end
end

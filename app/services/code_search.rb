class CodeSearch
  EXCLUDED_DIRS = %w[node_modules bower_components tmp dist]

  def self.retrieve_source(term, addon_dir)
    self.new.retrieve_source(term, addon_dir)
  end

  def self.retrieve_addons(term)
    self.new.retrieve_addons(term)
  end

  def initialize(search_engine = SearchEngine.new, sed = LineRetrieval.new)
    @search_engine = search_engine
    @sed = sed
  end

  def source_dir
    ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
  end

  def path_filename_line_number_regex
    /(#{source_dir}\/.*?\/(.*?)):(\d+)/
  end

  def addon_name_regex
    /#{source_dir}\/(.*?)\/.*:/
  end

  def should_exclude_file?(file_path)
    EXCLUDED_DIRS.any? { |dir| file_path =~ /\/#{dir}\// }
  end

  def retrieve_addons(term)
    return [] if term.blank?

    raw_result = @search_engine.query(term)
    addon_list = raw_result.map do |line|
      match_data = line.match(addon_name_regex)
      full_path = match_data[0]
      addon_name = match_data[1]
      should_exclude_file?(full_path) ? nil : addon_name
    end.compact

    addon_list.group_by{ |v| v }.map{ |k, v| {addon: k, count: v.size} }
  end

  def retrieve_source(term, addon_dir)
    return [] if term.blank?

    raw_result = @search_engine.query(term, File.join(source_dir, addon_dir))
    raw_result.map { |line| extract_source_context_for_line(line) }.compact
  end

  def extract_source_context_for_line(search_result)
    match_result = search_result.match(path_filename_line_number_regex)
    path_from_source_dir = match_result[1]

    return nil if should_exclude_file?(path_from_source_dir)

    path_from_addon_dir = match_result[2]
    line_number = match_result[3].to_i
    lines = @sed.retrieve_match(path_from_source_dir, line_number)

    json_lines = lines.map { |line| {text: line.first, number: line.last} }
    {line_number: line_number, filename: path_from_addon_dir, lines: json_lines}
  end
end

# frozen_string_literal: true

class CodeSearch
  def self.retrieve_source(term, addon_dir, regex_search = false)
    new.retrieve_source(term, addon_dir, regex_search)
  end

  def self.retrieve_addons(term, regex_search = false)
    new.retrieve_addons(term, regex_search)
  end

  def initialize(search_engine = SearchEngine.new, line_reader = LineReader.new)
    @search_engine = search_engine
    @line_reader = line_reader
  end

  def source_dir
    @source_dir ||= ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
  end

  def path_filename_line_number_regex
    @filename_regex ||= /(#{source_dir}\/.*?\/(.*?)):(\d+)/
  end

  def file_path_regex
    @file_path_regex ||= /#{source_dir}\/(.*?)\/(.*?):/
  end

  def retrieve_addons(term, regex_search)
    return [] if term.blank?

    raw_result = @search_engine.find_all_matches(term, source_dir, regex: regex_search)
    addon_matches = Hash.new { |h, k| h[k] = [] }
    raw_result.each do |line|
      match = line.match(file_path_regex)
      addon_id = match[1]
      file_path = match[2]
      addon_matches[addon_id] << file_path
    end

    addon_matches.map do |addon, files|
      { addon: addon, files: files, count: files.size }
    end
  end

  def retrieve_source(term, addon_dir, regex_search)
    return [] if term.blank?

    raw_result = @search_engine.find_addon_usages(term, File.join(source_dir, addon_dir), regex: regex_search)
    raw_result.map { |line| extract_source_context_for_line(line) }
  end

  def extract_source_context_for_line(search_result)
    match_result = search_result.match(path_filename_line_number_regex)
    path_from_source_dir = match_result[1]
    path_from_addon_dir = match_result[2]
    line_number = match_result[3].to_i

    lines = @line_reader.retrieve_context(path_from_source_dir, line_number)

    json_lines = lines.map { |line| { text: line.first, number: line.last } }
    { line_number: line_number, filename: path_from_addon_dir, lines: json_lines }
  end
end

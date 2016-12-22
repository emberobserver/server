require 'open3'

class SearchEngine

  def find_all_matches(term, source_dir, options)
    search_term = search_term(term, options)
    find_all_usages(search_term, source_dir)
  end

  def find_addon_usages(term, addon_dir, options)
    search_term = search_term(term, options)
    find_single_addon_usages(search_term, addon_dir)
  end

  private

  def search_term(term, options)
    regex_enabled = !!options[:regex]
    regex_enabled ? term : Regexp.escape(term)
  end

  def find_single_addon_usages(search_term, addon_dir)
    result = Open3.capture2('csearch', '-f', "#{addon_dir}#{File::Separator}", '-n', search_term)
    result.last.success? ? result.first.split("\n") : []
  end

  def find_all_usages(search_term, source_dir)
    grouped_addons = addon_directories(source_dir).each_slice(200).to_a

    threads = grouped_addons.map do |addon_group|
      addon_dir_regex = addon_group.join('|')
      Thread.new do
        result = Open3.capture2('csearch', '-f', addon_dir_regex, search_term)
        result.last.success? ? result.first.split("\n") : []
      end
    end

    threads.flat_map do |t|
      t.value
    end
  end

  def addon_directories(source_dir)
    Dir.entries(source_dir).reject { |d| d == '.' || d == '..'}.map { |d| File.join(source_dir, d) + File::Separator }
  end

end

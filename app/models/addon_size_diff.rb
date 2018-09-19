class AddonSizeDiff
  APP_CSS_REGEX = %r{dist/assets/my-app-\w*\.css}
  APP_JS_REGEX = %r{dist/assets/my-app-\w*\.js}
  VENDOR_CSS_REGEX = %r{dist/assets/vendor-\w*\.css}
  VENDOR_JS_REGEX = %r{dist/assets/vendor-\w*\.js}

  attr_reader :app_css, :app_js, :vendor_css, :vendor_js, :other_css, :other_js

  def initialize(old_data, new_data)
    create_diff(old_data, new_data)
  end

  def to_h
    {
      app_css: @app_css,
      app_js: @app_js,
      vendor_css: @vendor_css,
      vendor_js: @vendor_js,
      other_css: @other_css,
      other_js: @other_js,
    }
  end

  private

  def create_diff(old_data, new_data)
    @app_css = diff_for(old_data, new_data, APP_CSS_REGEX)
    @app_js = diff_for(old_data, new_data, APP_JS_REGEX)
    @vendor_css = diff_for(old_data, new_data, VENDOR_CSS_REGEX)
    @vendor_js = diff_for(old_data, new_data, VENDOR_JS_REGEX)
    @other_css = other_css_size(new_data)
    @other_js = other_js_size(new_data)
  end

  def diff_for(old_data, new_data, name_regex)
    app_css_old_size = size(old_data, name_regex)
    app_css_new_size = size(new_data, name_regex)
    app_css_new_size - app_css_old_size
  end

  def other_css_size(data)
    size_data = data['files'].select do |f|
      f['name'] !~ VENDOR_CSS_REGEX && f['name'] !~ APP_CSS_REGEX && f['name'] =~ /css$/
    end
    size_data.sum { |d| d['size'] }
  end

  def other_js_size(data)
    size_data = data['files'].select do |f|
      f['name'] !~ VENDOR_JS_REGEX && f['name'] !~ APP_JS_REGEX && f['name'] =~ /js$/
    end
    size_data.sum { |d| d['size'] }
  end

  def size(data, name_regex)
    size_data = data['files'].select { |f| f['name'] =~ name_regex }
    size_data.sum { |d| d['size'] }
  end
end

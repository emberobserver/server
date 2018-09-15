class AddonSizeDiff
  APP_CSS_NAME = %r{dist/assets/my-app.*.css}
  APP_JS_NAME = %r{dist/assets/my-app.*.js}
  VENDOR_CSS_NAME = %r{dist/assets/vendor.*.css}
  VENDOR_JS_NAME = %r{dist/assets/vendor.*.js}

  attr_reader :app_css, :app_js, :vendor_css, :vendor_js

  def initialize(old_data, new_data)
    create_diff(old_data, new_data)
  end

  def to_h
    {
      app_css: @app_css,
      app_js: @app_js,
      vendor_css: @vendor_css,
      vendor_js: @vendor_js
    }
  end

  private

  def create_diff(old_data, new_data)
    @app_css = diff_for(old_data, new_data, APP_CSS_NAME)
    @app_js = diff_for(old_data, new_data, APP_JS_NAME)
    @vendor_css = diff_for(old_data, new_data, VENDOR_CSS_NAME)
    @vendor_js = diff_for(old_data, new_data, VENDOR_JS_NAME)
  end

  def diff_for(old_data, new_data, name)
    app_css_old_size = size(old_data, name)
    app_css_new_size = size(new_data, name)
    app_css_new_size - app_css_old_size
  end

  def size(data, name)
    size_data = data['files'].find { |f| f['name'] =~ name }
    size_data['size']
  end
end

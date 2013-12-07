require 'lib/helpers/content_helpers'
require 'lib/helpers/biolinux_helpers'

helpers ContentHelpers
helpers BiolinuxHelpers

page "/usersmap.html", :layout => "usersmap_layout"
page "/bioruby.html", :layout => "bioruby_layout"
page "/news.html", :layout => "news_layout"

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

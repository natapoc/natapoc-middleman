require 'net/http'
require 'json'
require "uri"

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

activate :dato, live_reload: true

configure :development do
  activate :livereload
end

activate :external_pipeline,
   name: :webpack,
   command: build? ?
   "./node_modules/webpack/bin/webpack.js --bail -p" :
   "./node_modules/webpack/bin/webpack.js --watch -d --progress --color",
   source: ".tmp/dist",
   latency: 1

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# Fetch Airbnb data
dato_client = Dato::Site::Client.new(ENV['DATO_FULL_ACCESS_API_TOKEN'])
REVIEW_API_KEY = "review"
review_type = dato_client.item_types.all.find { |type| type["api_key"] == REVIEW_API_KEY }

existing_reviews_dates = dato_client.items
  .all({ "filter[type]" => REVIEW_API_KEY, version: 'latest' }, all_pages: true)
  .map { |review| review["timestamp"] }

puts existing_reviews_dates.inspect

url = 'https://api.airbnb.com/v2/reviews?client_id=3092nxybyb0otqw18e8nh5nty&listing_id=9300418&role=all'
uri = URI(url)
response = JSON.parse(Net::HTTP.get(uri), symbolize_names: true)

response[:reviews].each do |review|
  if !existing_reviews_dates.include?(review[:created_at])
    puts "Saving #{ review[:author][:first_name] }"
    puts "*" * 100
    puts review[:created_at]
    puts "*" * 100
    # URL must be escaped and end in a valid file extension
    photo_url = URI.escape(review[:author][:picture_large_url].remove("?aki_policy=profile_large"))
    begin
      dato_client.items.create(
        item_type: review_type["id"],
        guest_name: review[:author][:first_name],
        photo: dato_client.upload_image(photo_url),
        message: review[:comments],
        timestamp: review[:created_at]
      )
    rescue Dato::ApiError => e
      puts "Unable to add review"
      puts e.inspect
    end
  end
end

# @doc = Nokogiri::XML(open("https://tickets.thefair.com/upcomingEventPerformanceXML.asp"))
# @doc.css("Event").each do |event|
#   event.css("Performance").each do |performance|
#     code = performance.css("PerformanceCode").text
#     name = performance.css("PerformanceName").text
#     unless @existing_showare_performance_codes.include?(code)
#       puts "Saving #{ code }"
#       dato_client.items.create(
#         item_type: @showare_performance_type["id"],
#         name: "#{ name } (#{ code })",
#         code: code
#       )
#     end
#   end
# end

# dato.tap do |dato|
#   dato.redirects.each do |redirect|
#     redirect "#{ redirect.origin }index.html", to: "#{ redirect.destination }"
#   end
# end

proxy "_redirects", "netlify-redirects", ignore: true

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end

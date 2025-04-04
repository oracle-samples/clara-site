# Clara site gem file.
source "https://rubygems.org"

require 'json'
require 'open-uri'
versions = JSON.parse(OpenURI.open_uri('https://pages.github.com/versions.json').read)

gem 'github-pages', versions['github-pages']
gem "webrick", "~> 1.8"

require 'rack'
require_relative './src/app/routes'
require_relative './src/app/main'

use Rack::Reloader, 0

run App.new($router)
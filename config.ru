# frozen_string_literal: true

require 'rack'
require_relative './src/app/main'

use Rack::Reloader, 0

run App.new

require 'yaml/store'
require 'date'
require 'digest'
require 'forwardable'
require 'openssl'
require 'securerandom'

require 'base58'

Dir["src/*.rb"].each { |file| require_relative "#{file}" }

cli = CLI.new
command, *data = ARGV
cli.run(command, data)

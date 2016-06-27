require 'schema_plus/core'
require 'its-it'

require_relative 'enums/active_record'
require_relative 'enums/middleware'
require_relative 'enums/version'

SchemaMonkey.register SchemaPlus::Enums

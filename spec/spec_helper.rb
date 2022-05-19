# frozen_string_literal: true

require 'simplecov'
SimpleCov.start unless SimpleCov.running

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'active_record'
require 'schema_plus_enums'
require 'schema_dev/rspec'

SchemaDev::Rspec.setup

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

RSpec::Matchers.define_negated_matcher :not_include, :include

RSpec.configure do |config|
  config.warnings = true

  config.after do
    ActiveRecord::Base.connection.tap do |c|
      c.enums.each do |p, e, _|
        c.drop_enum e, schema: p, cascade: true
      end

      c.tables.each do |t|
        c.drop_table t, cascade: true
      end
    end
  end
end

SimpleCov.command_name "[ruby #{RUBY_VERSION} - ActiveRecord #{::ActiveRecord::VERSION::STRING} - #{ActiveRecord::Base.connection.adapter_name}]"

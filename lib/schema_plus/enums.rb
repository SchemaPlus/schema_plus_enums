require 'schema_plus/core'

require_relative 'enums/version'

# Load any mixins to ActiveRecord modules, such as:
#
#require_relative 'enums/active_record/base'

# Load any middleware, such as:
#
# require_relative 'enums/middleware/model'

SchemaMonkey.register SchemaPlus::Enums

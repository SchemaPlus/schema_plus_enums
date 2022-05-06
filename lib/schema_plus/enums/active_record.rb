# frozen_string_literal: true

module SchemaPlus::Enums
  module ActiveRecord
    module ConnectionAdapters
      module PostgresqlAdapter

        def enums
          result = query(<<-SQL)
            SELECT
              N.nspname AS schema_name,
              T.typname AS enum_name,
              E.enumlabel AS enum_label,
              E.enumsortorder AS enum_sort_order
              --array_agg(E.enumlabel ORDER BY enumsortorder) AS labels
            FROM pg_type T
            JOIN pg_enum E ON E.enumtypid = T.oid
            JOIN pg_namespace N ON N.oid = T.typnamespace
            ORDER BY 1, 2, 4
          SQL

          result.reduce([]) do |res, row|
            last = res.last
            if last && last[0] == row[0] && last[1] == row[1]
              last[2] << row[2]
            else
              res << (row[0..1] << [row[2]])
            end
            res
          end
        end

        def create_enum(name, *values, **options)
          list = values.map { |value| escape_enum_value(value) }

          if options[:force]
            drop_enum(name,
                      cascade:   options[:force] == :cascade,
                      if_exists: true,
                      schema:    options[:schema])
          end

          execute "CREATE TYPE #{enum_name(name, options[:schema])} AS ENUM (#{list.join(',')})"
        end

        def alter_enum(name, value, **options)
          ActiveSupport::Deprecation.warn "alter_enum is deprecated. use add_enum_value instead"

          add_enum_value(name, value, **options)
        end

        def add_enum_value(name, value, **options)
          sql = +"ALTER TYPE #{enum_name(name, options[:schema])} ADD VALUE "
          sql << 'IF NOT EXISTS ' if options[:if_not_exists]
          sql << escape_enum_value(value)
          sql << case
                 when options[:before] then " BEFORE #{escape_enum_value(options[:before])}"
                 when options[:after] then " AFTER #{escape_enum_value(options[:after])}"
                 else
                   ''
                 end
          execute sql
        end

        def remove_enum_value(name, value, **options)
          sql = <<~SQL
            DELETE FROM pg_enum
            WHERE enumlabel=#{escape_enum_value(value)}
            AND enumtypid = (
              SELECT T.oid 
              FROM pg_type T
              JOIN pg_namespace N ON N.oid = T.typnamespace
              WHERE T.typname = #{quote name} AND N.nspname = #{quote schema_name(options[:schema])}
            )
          SQL
          execute sql
        end

        def rename_enum_value(name, value, new_value, **options)
          raise "Renaming enum values is only supported in PostgreSQL 10.0+" unless rename_enum_value_supported?

          sql = <<~SQL
            ALTER TYPE #{enum_name(name, options[:schema])}
            RENAME VALUE #{escape_enum_value(value)}
            TO #{escape_enum_value(new_value)}
          SQL

          execute sql
        end

        def rename_enum(name, new_name, **options)
          execute "ALTER TYPE #{enum_name(name, options[:schema])} RENAME TO #{new_name}"
        end

        def drop_enum(name, **options)
          sql = +'DROP TYPE '
          sql << 'IF EXISTS ' if options[:if_exists]
          sql << enum_name(name, options[:schema])
          sql << ' CASCADE' if options[:cascade]

          execute sql
        end

        private

        def rename_enum_value_supported?
          unless defined? @rename_enum_value_supported
            version                      = select_value("SHOW server_version").match(/(\d+\.\d+)/)[1]
            @rename_enum_value_supported = Gem::Version.new(version) >= Gem::Version.new('10.0')
          end
          @rename_enum_value_supported
        end

        def schema_name(schema)
          schema || 'public'
        end

        def enum_name(name, schema)
          [schema_name(schema), name].map { |s|
            %Q{"#{s}"}
          }.join('.')
        end

        def escape_enum_value(value)
          escaped_value = value.to_s.sub("'", "''")
          "'#{escaped_value}'"
        end
      end
    end
  end
end

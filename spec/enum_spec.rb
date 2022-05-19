# frozen_string_literal: true

require 'spec_helper'

def enum_fields(name, schema = 'public')
  sql = <<-SQL
    SELECT array_to_string(array_agg(E.enumlabel ORDER BY enumsortorder), ' ') AS "values"
    FROM pg_enum E
    JOIN pg_type T ON E.enumtypid = T.oid
    JOIN pg_namespace N ON N.oid = T.typnamespace
    WHERE N.nspname = '#{schema}' AND T.typname = '#{name}'
    GROUP BY T.oid;
  SQL

  data = ActiveRecord::Base.connection.select_all(sql)
  return nil if data.empty?
  data[0]['values'].split(' ')
end

describe 'enum', :postgresql => :only do
  before(:all) do
    ActiveRecord::Migration.verbose = false
  end

  let(:migration) { ActiveRecord::Migration }

  describe 'enums' do
    it 'should return all enums' do
      begin
        migration.execute 'create schema cmyk'
        migration.create_enum 'color', 'red', 'green', 'blue'
        migration.create_enum 'color', 'cyan', 'magenta', 'yellow', 'black', schema: 'cmyk'

        expect(migration.enums).to match_array [['cmyk', 'color', %w|cyan magenta yellow black|], ['public', 'color', %w|red green blue|]]
      ensure
        migration.drop_enum 'color'
        migration.execute 'drop schema cmyk cascade'
      end
    end
  end

  describe 'create_enum' do
    it 'should create enum with given values' do
      begin
        migration.create_enum 'color', *%w|red green blue|
        expect(enum_fields('color')).to eq(%w|red green blue|)
      ensure
        migration.execute 'DROP TYPE IF EXISTS color'
      end
    end

    it 'should create enum using symbols' do
      begin
        migration.create_enum :color, :red, :green, :blue
        expect(enum_fields('color')).to eq(%w|red green blue|)
      ensure
        migration.execute 'DROP TYPE IF EXISTS color'
      end
    end

    it 'should create enum with schema' do
      begin
        migration.execute 'CREATE SCHEMA colors'
        migration.create_enum 'color', *%|red green blue|, schema: 'colors'
        expect(enum_fields('color', 'colors')).to eq(%w|red green blue|)
      ensure
        migration.execute 'DROP SCHEMA IF EXISTS colors CASCADE'
      end
    end

    it 'should escape enum value' do
      begin
        migration.create_enum('names', "O'Neal")
        expect(enum_fields('names')).to eq(["O'Neal"])
      ensure
        migration.execute "DROP TYPE IF EXISTS names"
      end
    end

    it 'should escape scheme name and enum name' do
      begin
        migration.execute 'CREATE SCHEMA "select"'
        migration.create_enum 'where', *%|red green blue|, schema: 'select'
        expect(enum_fields('where', 'select')).to eq(%w|red green blue|)
      ensure
        migration.execute 'DROP SCHEMA IF EXISTS "select" CASCADE'
      end
    end

    context 'when force: true is passed' do
      it 'removes the existing enum' do
        allow(migration.connection).to receive(:drop_enum)

        migration.create_enum 'color', *%w|red green blue|, force: true

        expect(migration.connection).to have_received(:drop_enum).with(
          'color', { cascade: false, if_exists: true, schema: nil }
        )

        migration.execute 'DROP TYPE IF EXISTS color'
      end
    end

    context 'when force: :cascade is passed' do
      it 'removes the existing enum' do
        allow(migration.connection).to receive(:drop_enum)

        migration.create_enum 'color', *%w|red green blue|, force: :cascade

        expect(migration.connection).to have_received(:drop_enum).with(
          'color', { cascade: true, if_exists: true, schema: nil }
        )

        migration.execute 'DROP TYPE IF EXISTS color'
      end
    end

    context 'when force: :cascade is passed with a schema' do
      it 'removes the existing enum' do
        allow(migration.connection).to receive(:drop_enum)

        migration.create_enum 'color', *%w|red green blue|, force: :cascade, schema: 'public'

        expect(migration.connection).to have_received(:drop_enum).with(
          'color', { cascade: true, if_exists: true, schema: 'public' }
        )

        migration.execute 'DROP TYPE IF EXISTS color'
      end
    end
  end

  describe 'alter_enum' do
    before do
      migration.create_enum('color', 'red', 'green', 'blue')
      allow(ActiveSupport::Deprecation).to receive(:warn)
      allow(migration.connection).to receive(:add_enum_value)
    end
    after do
      migration.execute 'DROP TYPE IF EXISTS color'
    end

    it 'calls add_enum_value' do
      migration.alter_enum('color', 'magenta')

      expect(migration.connection).to have_received(:add_enum_value)
    end

    it 'sends a deprecation warning' do
      migration.alter_enum('color', 'magenta')

      expect(ActiveSupport::Deprecation).to have_received(:warn)
    end
  end

  describe 'add_enum_value' do
    before do
      migration.create_enum('color', 'red', 'green', 'blue')
    end
    after do
      migration.execute 'DROP TYPE IF EXISTS color'
    end

    it 'should add new value after all values' do
      migration.add_enum_value('color', 'magenta')
      expect(enum_fields('color')).to eq(%w|red green blue magenta|)
    end

    it 'should add new value after existed' do
      migration.add_enum_value('color', 'magenta', after: 'red')
      expect(enum_fields('color')).to eq(%w|red magenta green blue|)
    end

    it 'should add new value before existed' do
      migration.add_enum_value('color', 'magenta', before: 'green')
      expect(enum_fields('color')).to eq(%w|red magenta green blue|)
    end

    it 'should add new value within given schema' do
      begin
        migration.execute 'CREATE SCHEMA colors'
        migration.create_enum('color', 'red', schema: 'colors')
        migration.add_enum_value('color', 'green', schema: 'colors')

        expect(enum_fields('color', 'colors')).to eq(%w|red green|)
      ensure
        migration.execute 'DROP SCHEMA colors CASCADE'
      end
    end

    context 'without if_not_exists: true' do
      it 'raises a DB error if the value exists' do
        expect {
          migration.add_enum_value('color', 'red')
        }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    context 'with if_not_exists: true' do
      it 'does not raise a DB error if the value exists' do
        expect {
          migration.add_enum_value('color', 'red', if_not_exists: true)
        }.to_not raise_error
      end
    end
  end

  describe 'remove_enum_value' do
    before do
      migration.create_enum('color', 'red', 'green', 'blue')
    end
    after do
      migration.execute 'DROP TYPE IF EXISTS color'
    end

    it 'removes the value' do
      expect {
        migration.remove_enum_value('color', 'green')
      }.to change {
        enum_fields('color')
      }.to(%w[red blue])
    end

    context 'when the enum is in a schema' do
      before do
        migration.execute "CREATE SCHEMA colors; CREATE TYPE colors.color AS ENUM ('red', 'magenta', 'blue')"
      end
      after do
        migration.execute "DROP SCHEMA colors CASCADE"
      end

      it 'should rename the enum within given name and schema' do
        expect {
          migration.remove_enum_value('color', 'blue', schema: 'colors')
        }.to change {
          enum_fields('color', 'colors')
        }.to(%w[red magenta])
      end
    end
  end

  describe 'rename_enum_value' do
    before do
      migration.create_enum('color', 'red', 'green', 'blue')
    end
    after do
      migration.execute 'DROP TYPE IF EXISTS color'
    end

    context 'when postgresql version is >= 10', postgresql: '>= 10.0' do
      it 'renames the value' do
        expect {
          migration.rename_enum_value('color', 'green', 'orange')
        }.to change {
          enum_fields('color')
        }.to(%w[red orange blue])
      end
    end

    context 'when postgresql version is < 10', postgresql: '< 10.0' do
      it 'raises an error' do
        expect {
          migration.rename_enum_value('color', 'green', 'orange')
        }.to raise_error(/Renaming enum values is only supported/)
      end
    end
  end

  describe 'rename_enum' do
    before do
      migration.create_enum('color', 'red', 'green', 'blue')
    end
    after do
      migration.execute 'DROP TYPE IF EXISTS color'
      migration.execute 'DROP TYPE IF EXISTS shade'
    end

    it 'renames the enum' do
      expect {
        migration.rename_enum('color', 'shade')
      }.to change {
        migration.enums.map(&:second)
      }.from(contain_exactly('color')).to(contain_exactly('shade'))
    end

    context 'when the enum is in a schema' do
      before do
        migration.execute "CREATE SCHEMA colors; CREATE TYPE colors.color AS ENUM ('red', 'blue')"
      end
      after do
        migration.execute "DROP SCHEMA colors CASCADE"
      end

      it 'should rename the enum within given name and schema' do
        expect {
          migration.rename_enum('color', 'shade', schema: 'colors')
        }.to change {
          enum_fields('shade', 'colors')
        }.from(nil).to(%w[red blue])
      end
    end
  end

  describe 'drop_enum' do
    it 'should drop enum with given name' do
      migration.execute "CREATE TYPE color AS ENUM ('red', 'blue')"
      expect(enum_fields('color')).to eq(%w|red blue|)
      migration.drop_enum('color')

      expect(enum_fields('color')).to be_nil
    end

    it 'should drop enum within given name and schema' do
      begin
        migration.execute "CREATE SCHEMA colors; CREATE TYPE colors.color AS ENUM ('red', 'blue')"
        expect(enum_fields('color', 'colors')).to eq(%w|red blue|)
        migration.drop_enum('color', schema: 'colors')

        expect(enum_fields('color', 'colors')).to be_nil
      ensure
        migration.execute "DROP SCHEMA colors CASCADE"
      end
    end

    context 'when the enum does not exist' do
      it 'should fail when if_exists: true is not passed' do
        expect {
          migration.drop_enum('color')
        }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it 'should fail silently when if_exists: true is passed' do
        expect {
          migration.drop_enum('color', if_exists: true)
        }.to_not raise_error
      end
    end

    context 'when cascade: true is passed' do
      it 'cascades through and drops columns' do
        migration.create_enum 'color', %w[red blue green]
        migration.create_table :posts do |t|
          t.column :text_color, :color
        end

        expect {
          migration.drop_enum 'color', cascade: true
        }.to change {
          migration.columns('posts').map(&:name)
        }.from(include('text_color')).to not_include('text_color')
      end
    end
  end

  describe 'create_table' do
    before do
      migration.create_enum 'color', *%w|red green blue|, force: true
    end
  end
end

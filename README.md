[![Gem Version](https://badge.fury.io/rb/schema_plus_enums.svg)](http://badge.fury.io/rb/schema_plus_enums)
[![Build Status](https://github.com/SchemaPlus/schema_plus_enums/actions/workflows/pr.yml/badge.svg)](http://github.com/SchemaPlus/schema_plus_enums/actions)
[![Coverage Status](https://coveralls.io/github/SchemaPlus/schema_plus_enums/badge.svg)](https://coveralls.io/github/SchemaPlus/schema_plus_enums)

# SchemaPlus::Enums

SchemaPlus::Enums provides support for enum data types in ActiveRecord.  Currently the support is limited to defining enum data types, for PostgreSQL only.


SchemaPlus::Enums is part of the [SchemaPlus](https://github.com/SchemaPlus/) family of Ruby on Rails ActiveRecord extension gems.

## Installation

<!-- SCHEMA_DEV: TEMPLATE INSTALLATION - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
As usual:

```ruby
gem "schema_plus_enums"                # in a Gemfile
gem.add_dependency "schema_plus_enums" # in a .gemspec
```

<!-- SCHEMA_DEV: TEMPLATE INSTALLATION - end -->

## Compatibility

SchemaPlus::Enums is tested on:

<!-- SCHEMA_DEV: MATRIX - begin -->
<!-- These lines are auto-generated by schema_dev based on schema_dev.yml -->
* ruby **2.5** with activerecord **5.2**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **2.5** with activerecord **6.0**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **2.5** with activerecord **6.1**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **2.7** with activerecord **5.2**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **2.7** with activerecord **6.0**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **2.7** with activerecord **6.1**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **2.7** with activerecord **7.0**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **3.0** with activerecord **6.0**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **3.0** with activerecord **6.1**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **3.0** with activerecord **7.0**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **3.1** with activerecord **6.0**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **3.1** with activerecord **6.1**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**
* ruby **3.1** with activerecord **7.0**, using **postgresql:9.6**, **postgresql:10**, **postgresql:11** or **postgresql:12**

<!-- SCHEMA_DEV: MATRIX - end -->

## Usage

In a migration,
an enum can be created:

```ruby
create_enum :color, 'red', 'green', 'blue' # default schema is 'public'
create_enum :color, 'cyan', 'magenta', 'yellow', 'black', schema: 'cmyk'
```

New values can be added

```ruby
add_enum_value :color, 'black'
add_enum_value :color, 'red', if_not_exists: true
add_enum_value :color, 'purple', after: 'red'
add_enum_value :color, 'pink', before: 'purple'
add_enum_value :color, 'white', schema: 'cmyk'
```
     
Values can be dropped
```ruby
remove_enum_value :color, 'black'
remove_enum_value :color, 'black', schema: 'cmyk'
```

Values can be renamed
```ruby
rename_enum_value :color, 'red', 'orange'
rename_enum_value :color, 'red', 'orange', schema: 'cmyk'
```

The enum can be renamed
```ruby
rename_enum :color, :hue
rename_enum :color, :hue, schema: 'cmyk'
```

And can be dropped:

```ruby
drop_enum :color
drop_enum :color, schema: 'cmyk'
```

## Release Notes

* **1.0.0** - Add AR 6.0, Ruby 3.0, and drop AR < 5.2 and Ruby < 2.5. Also add new functionality
* **0.1.8** - Update dependencies to include AR 5.2.
* **0.1.7** - Update dependencies to include AR 5.1.*  Thanks to [@patleb](https://github.com/patleb)
* **0.1.6** - Update dependencies to include AR 5.1.  Thanks to [@willsoto](https://github.com/willsoto)
* **0.1.5** - Update dependencies to include AR 5.0.  Thanks to [@jimcavoli](https://github.com/jimcavoli)
* **0.1.4** - Missing require
* **0.1.3** - Explicit gem dependencies
* **0.1.2** - Upgrade schema_plus_core dependency
* **0.1.1** - Clean up and sort dumper output.  Thanks to [@pik](https://github.com/pik)
* **0.1.0** - Initial release, pulled from schema_plus 1.x

## Development & Testing

Are you interested in contributing to SchemaPlus::Enums?  Thanks!  Please follow
the standard protocol: fork, feature branch, develop, push, and issue pull
request.

Some things to know about to help you develop and test:

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_DEV - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
* **schema_dev**:  SchemaPlus::Enums uses [schema_dev](https://github.com/SchemaPlus/schema_dev) to
  facilitate running rspec tests on the matrix of ruby, activerecord, and database
  versions that the gem supports, both locally and on
  [github actions](https://github.com/SchemaPlus/schema_plus_enums/actions)

  To to run rspec locally on the full matrix, do:

        $ schema_dev bundle install
        $ schema_dev rspec

  You can also run on just one configuration at a time;  For info, see `schema_dev --help` or the [schema_dev](https://github.com/SchemaPlus/schema_dev) README.

  The matrix of configurations is specified in `schema_dev.yml` in
  the project root.

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_DEV - end -->

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_PLUS_CORE - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
* **schema_plus_core**: SchemaPlus::Enums uses the SchemaPlus::Core API that
  provides middleware callback stacks to make it easy to extend
  ActiveRecord's behavior.  If that API is missing something you need for
  your contribution, please head over to
  [schema_plus_core](https://github.com/SchemaPlus/schema_plus_core) and open
  an issue or pull request.

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_PLUS_CORE - end -->

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_MONKEY - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
* **schema_monkey**: SchemaPlus::Enums is implemented as a
  [schema_monkey](https://github.com/SchemaPlus/schema_monkey) client,
  using [schema_monkey](https://github.com/SchemaPlus/schema_monkey)'s
  convention-based protocols for extending ActiveRecord and using middleware stacks.

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_MONKEY - end -->

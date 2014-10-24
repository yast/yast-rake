# Yast::Rake

[![Travis Build](https://travis-ci.org/yast/yast-rake.svg?branch=master)](https://travis-ci.org/yast/yast-rake)


Rake tasks to help with uniform handling of yast modules. It provides setup for
[packaging tasks](http://github.com/openSUSE/packaging_tasks) and add yast specific tasks.

# Quick Start

Create Rakefile with content:
```
  require "yast/rake"
```
Now lets check what it provides with `rake -T`

# Provided tasks

## version:bump
Update the latest part of version in spec file.

## test:unit
Runs all rspec tests ending with \_spec.rb or \_test.rb.

## run[client]
Runs client with paths leading to git. Usefull to testing module without
installation.

## console
Runs ruby console with paths leading to git and Yast environment.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# License
This package is licensed under
[LGPL-2.1](http://www.gnu.org/licenses/lgpl-2.1.html).

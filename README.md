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
Runs all RSpec tests ending with \_spec.rb or \_test.rb.

## run[client]
Runs client with paths leading to git. Useful to testing module without
installation.

## console
Runs ruby console with paths leading to git and YaST environment.

## pot
Collect translatable strings and create `*.pot` files.

## check:pot
Check for common mistakes in translated texts.

## check:spelling
Checks spelling in `*.md` and `*.html` files. It uses a global custom dictionary
(file `lib/tasks/spell.dict` in this repository) and supports repository specific
dictionary (`spell.dict` file in the repository root directory).

**Note:** The installed aspell English dictionary may differ in different products
(esp. the Ubuntu dictionary used at Travis - a local check may pass, but it may
later fail at Travis, be prepared for this...)

**Note:** You need to explicitly install `aspell-devel`, `aspell-en`, `ruby-devel`
packages and the `raspell` Ruby gem. (The reason is to decrease the dependencies
for the packages which do not use this task.)

These commands should work:

    sudo zypper in aspell-devel aspell-en ruby-devel
    sudo gem install raspell

# Customizing

Yast::Tasks provides a method to change the configuration of the packaging
tasks. As it's just a proxy for `::Packaging.configuration`, the same options
are available.

```ruby
  Yast::Tasks.configuration do |conf|
    conf.obs_api = "https://api.opensuse.org/"
    conf.obs_project = "YaST:openSUSE:42.1"
  end
```

To avoid duplication, Yast::Tasks also provides a method to set the whole
configuration at once, just specifying the name of one of the available
[target definitions](https://github.com/yast/yast-rake/blob/master/data/targets.yml).
For example, if you want to submit to SLE 12 Service Pack 1, you can do:

```
  Yast::Tasks.submit_to(:sle12sp1)
```

This method can receive, as a second parameter, the path to your own
definitions if needed.

If `submit_to` is not explicitly used, it will be read from the environment
variable `YAST_SUBMIT`. If that variable is not set, `:factory` will be used.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# License
This package is licensed under
[LGPL-2.1](http://www.gnu.org/licenses/lgpl-2.1.html).

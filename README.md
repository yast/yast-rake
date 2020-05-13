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

If the `.rspec_parallel` file exists then the tests are executed using the
`parallel_rspec` command which runs the tests in parallel using all available
CPUs, otherwise the standard RSpec is used.

It is possible to override this behavior via the `PARALLEL_TESTS` environment
variable. Set it to `1` to run the tests in parallel or set it to `0`
to use the standard RSpec with a single process.

You can pass additional `parallel_rspec` command options via the
`PARALLEL_TESTS_OPTIONS` environment. E.g. you might choose to use only the
half of the available CPUs with `PARALLEL_TESTS_OPTIONS="-m 0.5"` option
or use just 4 CPUs with the `PARALLEL_TESTS_OPTIONS="-n 4"` option.
See the [parallel_tests documentation](https://github.com/grosser/parallel_tests)
for more details.

## run[client]
Runs client with paths leading to git. Useful to testing module without
installation.

## console
Runs ruby console
([irb](http://ruby-doc.org/stdlib-2.5.0/libdoc/irb/rdoc/IRB.html))
with paths leading to git and YaST environment.

## pot
Collect translatable strings and create `*.pot` files.

## check:pot
Check for common mistakes in translated texts.

## check:rubocop[options]
Runs the Rubocop checker in parallel processes to speed up the check.
The additional parameters to Rubocop can be passed via the `options`
argument, e.g. `rake check:rubocop[-D]`.

## check:rubocop:auto_correct[options]
Similar to `check:rubocop` above, additionally it passes the auto correct
parameter to Rubocop to try fixing the found issues (it is equivalent to
`rake check:rubocop[-a]`).

## check:spelling
Checks spelling in `*.md` and `*.html` files. It uses a global custom dictionary
(file `lib/tasks/spell.dict` in this repository) and supports repository specific
dictionary (`spell.dict` file in the repository root directory).

**Note:** You need to explicitly install `aspell-devel`, `aspell-en`, `ruby-devel`
packages and the `raspell` Ruby gem. (The reason is to decrease the dependencies
for the packages which do not use this task.)

These commands should work:

    sudo zypper in aspell-devel aspell-en ruby-devel
    sudo gem install raspell

## server
Runs a simple web server which provides a dynamically generated tarball with
the source code. The web server is designed to serve the source tarballs for
the [`yupdate`](https://github.com/lslezak/scripts/tree/yupdate_refactoring/yast/yupdate)
script which can easily update the YaST code in the installation system.

That script downloads a source tarball from GitHub, to make it work also with
your local Git checkout we need to implement a compatible HTTP tarball provider.

By default the web server runs on port 8000, if that port is already used
it tries using port 8001 and so on until a free port is found. This allows
starting several servers in parallel easily.

If you need to use a different port you can pass it as an optional argument:

    rake server[9999]

To install the files in a running installation run

    yupdate patch my_machine.example.com:8000

To allow accessing the web server from other machines you need to open the
appropriate port in the firewall configuration. You can open some more spare
ports just in case you need to run several servers in parallel in the future.

- Open ports permanently (activated after reboot):

      firewall-cmd --permanent --zone=public --add-port=8000-8005/tcp

- Open ports (activated immediately):

      firewall-cmd --zone=public --add-port=8000-8005/tcp

*Note: If you want to open the ports now and keep them open also after
reboot you need to run both commands.*

- Checking the current firewall configuration:

      firewall-cmd --list-ports

To stop the server press the Ctrl+C key combination.

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

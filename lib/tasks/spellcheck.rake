#--
# Yast rake
#
# Copyright (C) 2015 Novell, Inc.
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++
#
# Rake task for checking spelling in the documentation files.
# By default checks all *.md and *.html files.
#
# Supports custom dictionaries:
#
#  - global dictionary located in the tasks gem (lib/tasks/.spell.dict)
#  - repository specific dictionary (.spell.dict in the root directory)
#
# The custom dictionaries contains one word per line.
# The lines starting with '#' character are ignored (used for comments),
#

GLOBAL_SPELL_CONFIG_FILE = File.expand_path("../spell.yml", __FILE__)
CUSTOM_SPELL_CONFIG_FILE = ".spell.yml"

def aspell_speller
  # raspell is an optional dependency, handle the missing case nicely
  begin
    require "raspell"
  rescue LoadError
    $stderr.puts "ERROR: Ruby gem \"raspell\" is not installed."
    exit 1
  end

  # initialize aspell
  speller = Aspell.new("en_US")
  speller.suggestion_mode = Aspell::NORMAL
  # ignore the HTML tags in the text
  speller.set_option("mode", "html")

  speller
end

def files_to_check(config)
  files = config["check"].reduce([]) {|acc, glob| acc + Dir[glob]}
  files = config["ignore"].reduce(files) {|acc, glob| acc - Dir[glob]}

  files
end

def read_spell_config(file)
  return {} unless File.exist?(file)

  puts "Loading config file (#{file})..." if verbose == true
  require "yaml"
  YAML.load_file(file)
end

# read the global and the custom spell configs and merge them
def spell_config
  config = read_spell_config(GLOBAL_SPELL_CONFIG_FILE)
  custom_config = read_spell_config(CUSTOM_SPELL_CONFIG_FILE)

  duplicates = config["dictionary"] & custom_config["dictionary"].to_a
  if !duplicates.empty?
    $stderr.puts "Warning: Found dictionary duplicates in the local dictionary " \
      "(#{CUSTOM_SPELL_CONFIG_FILE}):\n"
    duplicates.each {|duplicate| $stderr.puts "  #{duplicate}" }
    $stderr.puts
  end

  custom_config["dictionary"] = config["dictionary"] + custom_config["dictionary"].to_a
  custom_config["dictionary"].uniq!

  # override the global values by the local if present
  config.merge!(custom_config)

  config
end

namespace :check do
  desc "Run spell checker (by default for *.md and *.html files)"
  task :spelling do
    success = true

    config = spell_config
    speller = aspell_speller

    files_to_check(config).each do |file|
      puts "Checking #{file}..." if verbose == true
      # spell check each line separately so we can report error locations properly
      lines = File.read(file).split("\n")

      lines.each_with_index do |text, index|
        misspelled = speller.list_misspelled([text]) - config["dictionary"]

        if !misspelled.empty?
          success = false
          puts "#{file}:#{index + 1}: #{text.inspect}"
          misspelled.each do |word|
            puts "    #{word.inspect} => #{speller.suggest(word)}"
          end
          puts
        end
      end
    end

    if success
      puts "Spelling OK."
    else
      $stderr.puts "Spellcheck failed! (Fix it or add the words to " \
        "'#{CUSTOM_SPELL_CONFIG_FILE}' file if it is OK.)"
      exit 1
    end
  end
end

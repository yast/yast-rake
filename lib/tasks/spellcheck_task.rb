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
#  - global dictionary located in the tasks gem (lib/tasks/spell.yml)
#  - repository specific dictionary (.spell.yml in the root directory)
#
# The custom dictionaries are defined at the "dictionary" key.
#

require "rake"
require "rake/tasklib"

module Yast
  # Defines a spellcheck rake task
  class SpellcheckTask < Rake::TaskLib
    GLOBAL_SPELL_CONFIG_FILE = File.expand_path("../spell.yml", __FILE__)
    CUSTOM_SPELL_CONFIG_FILE = ".spell.yml".freeze

    # define the Rake task in the constructor
    def initialize
      namespace :check do
        desc "Run spell checker (by default for *.md and *.html files)"
        task :spelling do
          run_task
        end
      end
    end

  private

    # optionally colorize the misspelled words if the rainbow gem is present
    # @return [Boolean] true when the colorization support is present
    def colorize?
      return @colorize unless @colorize.nil?

      begin
        require "rainbow"
        @colorize = true
      rescue LoadError
        @colorize = false
      end
    end

    # evaluate the files to check
    # @return [Array<String>] list of files
    def files_to_check
      files = config["check"].reduce([]) { |a, e| a + Dir[e] }
      config["ignore"].reduce(files) { |a, e| a - Dir[e] }
    end

    # read a Yaml config file
    def read_spell_config(file)
      return {} unless File.exist?(file)

      puts "Loading config file (#{file})..." if verbose == true
      require "yaml"
      YAML.load_file(file)
    end

    # print the duplicate dictionary entries
    # @param dict1 [Array<String>] the first dictionary
    # @param dict2 [Array<String>] the second dictionary
    def report_duplicates(dict1, dict2)
      duplicates = dict1 & dict2
      return if duplicates.empty?

      $stderr.puts "Warning: Found dictionary duplicates in the local dictionary " \
        "(#{CUSTOM_SPELL_CONFIG_FILE}):\n"
      duplicates.each { |duplicate| $stderr.puts "  #{duplicate}" }
      $stderr.puts
    end

    # return the merged global and the custom spell configs
    # @return [Hash] the merged configuration to use
    def config
      return @config if @config

      @config = read_spell_config(GLOBAL_SPELL_CONFIG_FILE)
      custom_config = read_spell_config(CUSTOM_SPELL_CONFIG_FILE)

      report_duplicates(config["dictionary"], custom_config["dictionary"].to_a)

      custom_config["dictionary"] = @config["dictionary"] + custom_config["dictionary"].to_a
      custom_config["dictionary"].uniq!

      # override the global values by the local if present
      @config.merge!(custom_config)

      @config
    end

    # check the file using the spellchecker
    # @param file [String] file name
    # @return [Boolean] true on success (no spelling error found)
    def check_file(file)
      puts "Checking #{file}..." if verbose == true
      # spell check each line separately so we can report error locations properly
      lines = File.read(file).split("\n")

      success = true
      lines.each_with_index do |text, index|
        misspelled = misspelled_on_line(text)
        next if misspelled.empty?

        success = false
        print_misspelled(file, misspelled, index, text)
      end

      success
    end

    def print_misspelled(file, list, index, text)
      list.each { |word| text.gsub!(word, Rainbow(word).red) } if colorize?
      puts "#{file}:#{index + 1}: \"#{text}\""
      # FIXME print suggestion using "aspell soundslike" command
      puts "    #{list}\n\n" unless colorize?
    end

    def misspelled_on_line(text)
      switch_block_tag if block_line?(text)
      return [] if inside_block

      require "open3"
      stdout_str, _status = Open3.capture2("aspell -l en list", stdin_data: text)
      unknown = stdout_str.split("\n").uniq
      # ignore the words from the custom dictionary
      unknown -= config["dictionary"]
      # ignore the upcase words, they are usually abbreviations (like UEFI, GPL, ...),
      # adjusting the custom dictionary for each such a word is annoying...
      unknown.reject{|w| w =~ /\A[A-Z]+\z/}
    end

    def block_line?(line)
      line =~ /^\s*```/
    end

    def switch_block_tag
      @inside_block = !@inside_block
    end

    attr_reader :inside_block

    # run the task
    def run_task
      if files_to_check.map{ |file| check_file(file) }.all?
        puts "Spelling OK."
      else
        $stderr.puts "Spellcheck failed! (Fix it or add the words to " \
          "'#{CUSTOM_SPELL_CONFIG_FILE}' file if it is OK.)"
        exit 1
      end
    end
  end
end

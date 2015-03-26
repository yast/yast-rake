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

CUSTOM_DICTIONARY_FILE = "spell.dict"

def read_dictionary_file(file)
  puts "Loading custom dictionary (#{file})..." if verbose == true
  words = File.read(file).split("\n")

  # remove comments
  words.reject! { |word| word.start_with?("#")}
  words.each(&:chomp!)
end

# read the global and the repository custom dictionary
def read_custom_words
  # read the global default custom dictionary
  dict_path = File.expand_path("../#{CUSTOM_DICTIONARY_FILE}", __FILE__)
  custom_words = read_dictionary_file(dict_path)

  # read the custom dictionary from the project directory if present
  dict_path = CUSTOM_DICTIONARY_FILE
  if File.exist?(dict_path)
    local_dict = read_dictionary_file(dict_path)
    duplicates = custom_words & local_dict

    if !duplicates.empty?
      $stderr.puts "Warning: Found duplicates in the local dictionary (#{dict_path}):\n"
      duplicates.each {|duplicate| $stderr.puts "  #{duplicate}" }
      $stderr.puts
    end

    custom_words += local_dict - duplicates
  end

  custom_words
end

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

namespace :check do
  desc "Run spell checker (by default for *.md and *.html files in Git)"
  task :spelling, :regexp do |t, args|
    regexp = args[:regexp] || /\.(md|html)\z/
    success = true

    files = `git ls-files . | grep -v \\.gitignore`.split("\n")
    files.select!{|file| file.match(regexp)}

    custom_words = read_custom_words
    speller = aspell_speller

    files.each do |file|
      puts "Checking #{file}..." if verbose == true
      # spell check each line separately so we can report error locations properly
      lines = File.read(file).split("\n")

      lines.each_with_index do |text, index|
        misspelled = speller.list_misspelled([text]) - custom_words

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
        "'#{CUSTOM_DICTIONARY_FILE}' file if it is OK.)"
      exit 1
    end
  end
end

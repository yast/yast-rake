#--
# Yast rake
#
# Copyright (C) 2014 Novell, Inc.
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

desc "Collect translatable strings and create POT files"
task :pot do
  y2tool = "/usr/bin/y2tool"
  raise "File #{y2tool} is missing, install yast2-devtools" unless File.exist?(y2tool)

  sh "#{y2tool} y2makepot"
end

namespace :check do
  # print failed lines and a hint to STDERR
  def report_pot_errors(lines)
    $stderr.puts "Failed lines:"
    $stderr.puts "-" * 30
    $stderr.puts lines
    $stderr.puts "-" * 30
    $stderr.puts
    $stderr.puts "Note: \#{foo} substitution in translatable strings does" \
      " not work properly, use"
    $stderr.puts "  _(\"foo %{bar} baz\") % { :bar => bar }"
    $stderr.puts "or"
    $stderr.puts "  _(\"foo %s baz\") % bar"
    $stderr.puts
  end

  # remove gettext keywords and extra quotes
  def clean_pot_lines(lines)
    # leave just the text
    lines.each do |line|
      line.sub!(/^msgid \"/, "")
      line.sub!(/^\"/, "")
      line.sub!(/\"$/, "")
    end
  end

  desc "Check translatable strings for common mistakes"
  # depends on the global "pot" task defined above
  task :pot => :"rake:pot" do
    Dir["*.pot"].each do |pot|
      puts "Checking #{pot}..."
      lines = File.readlines(pot)
      # remove comments
      lines.reject!{ |line| line.match(/^#/) }
      # Ruby substitution present?
      lines.select!{ |line| line.include?('#{') }

      clean_pot_lines(lines)

      if !lines.empty?
        report_pot_errors(lines)
        raise "ERROR: Ruby substitution found in a translatable string"
      end
    end
  end
end

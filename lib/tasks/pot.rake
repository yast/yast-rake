# frozen_string_literal: true

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

  def interpolation_message
    <<~MSG
      Note: \#{foo} substitution in translatable strings does
      not work properly, use
        _(\"foo %{bar} baz\") % { :bar => bar }
      or
        _(\"foo %s baz\") % bar
    MSG
  end

  def angle_brackets_message
    <<~MSG
      Note: %<foo> placeholder should not be used in translatable strings
      because GNU Gettext does support any suitable language format for that,
      use %{foo} instead.
    MSG
  end

  # print failed lines and a hint to STDERR
  def report_pot_errors(lines, message)
    return if lines.empty?

    warn "Failed lines:"
    warn "-" * 30
    warn lines
    warn "-" * 30
    warn ""
    warn message
    warn ""
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
  # depends on the global "pot" task defined above,
  # this scans for the #{} interpolations (do not work in translations)
  # and %<> (no compatible language format in Gettext)
  task pot: :"rake:pot" do
    Dir["*.pot"].each do |pot|
      puts "Checking #{pot}..."
      lines = File.readlines(pot)
      # remove comments
      lines.reject! { |line| line.match(/^#/) }
      # Ruby substitution present?
      interpolations = lines.select { |line| line.include?("\#{") }
      angle_brackets = lines.select { |line| line.include?("%<") }

      next if interpolations.empty? && angle_brackets.empty?

      clean_pot_lines(interpolations)
      clean_pot_lines(angle_brackets)

      report_pot_errors(interpolations, interpolation_message)
      report_pot_errors(angle_brackets, angle_brackets_message)

      raise "ERROR: Found invalid or unsupported translatable string"
    end
  end
end

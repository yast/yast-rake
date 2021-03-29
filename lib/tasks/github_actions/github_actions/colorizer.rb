# frozen_string_literal: true

#--
# Yast rake
#
# Copyright (C) 2021 SUSE LLC
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

module GithubActions
  # helper methods for colorizing output, if the "rainbow" colorizing gem
  # is not installed then it prints the original messages without any colorizing
  module Colorizer
    # print an error
    # @param msg [Object] the text to print
    def error(msg)
      print_colored(msg, :red)
    end

    # print a success message
    # @param msg [Object] the text to print
    def success(msg)
      print_colored(msg, :green)
    end

    # print a warning
    # @param msg [Object] the text to print
    def warning(msg)
      print_colored(msg, :magenta)
    end

    # print a message
    # @param msg [Object] the text to print
    def info(msg)
      print_colored(msg, :cyan)
    end

    # print the progress status
    # @param msg [Object] the text to print
    def stage(msg)
      print_colored(msg, :yellow)
    end

  private

    # helper for printing the text
    # @param msg [Object] the text to print
    # @param color [Symbol] the text color
    def print_colored(msg, color)
      puts rainbow? ? Rainbow(msg).color(color) : msg
    end

    # load the Rainbow colorizing library if present
    # see https://github.com/sickill/rainbow
    # @return Boolean `true` if Rainbow was successfully loaded, `false` otherwise
    def rainbow?
      return @rainbow_present unless @rainbow_present.nil?

      begin
        require "rainbow"
        @rainbow_present = true
      rescue LoadError
        @rainbow_present = false
      end

      @rainbow_present
    end
  end
end

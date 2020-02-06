# frozen_string_literal: true

#--
# Yast rake
#
# Copyright (C) 2020, SUSE LLC
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

require "webrick"

module Yast
  # a webrick servlet which dynamically creates a tarball
  # with the content of the current Git checkout
  class TarballServlet < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(_request, response)
      response.status = 200
      response.content_type = "application/gzip"
      response.body = source_archive
    end

  private

    # compress the current sources into a tarball,
    # no caching to ensure we always provide the latest content
    def source_archive
      # pack all Git files (including the non-tracked files (-o),
      # use --ignore-failed-read to not fail for removed files)
      # -z and --null: NUL-delimited
      `git ls-files --cached --others -z | tar --create --ignore-failed-read --null --files-from - | #{gzip}`
    end

    # find which gzip is installed, use the faster parallel gzip ("pigz") if it is available
    # @return [String] "pigz or "gzip"
    def gzip
      return @gzip if @gzip

      # parallel gzip installed?
      @gzip = system("which pigz") ? "pigz" : "gzip"
    end
  end
end

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
  # a webrick servlet which returns a basic HTML info about the server,
  # just to avoid that nasty 404 error page when someone opens the
  # server URL in a web browser
  class IndexServlet < WEBrick::HTTPServlet::AbstractServlet
    INDEX_FILE = File.expand_path("../../data/index.html", __dir__)

    def do_GET(_request, response)
      response.status = 200
      response.content_type = "text/html"
      response.body = File.read(INDEX_FILE)
    end
  end
end

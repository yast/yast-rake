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

require "json"
require "webrick"

module Yast
  # a webrick servlet which lists all rake servers running on this machine
  class ServersServlet < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(_request, response)
      response.status = 200
      response.content_type = "application/json"
      response.body = servers.to_json
    end

  private

    # find the locally running "rake server" processes
    def servers
      output = `pgrep -a -f "rake server \\([0-9]+,.*\\)"`
      output.lines.map do |l|
        l.match(/rake server \(([0-9]+),(.*)\)/)
        {
          port: Regexp.last_match[1],
          dir:  Regexp.last_match[2]
        }
      end
    end
  end
end

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

begin
  require_relative "../yast/tarball_server"
rescue LoadError
  puts "webrick is not available" if verbose == true
end

# load server only if webrick is available
if defined?(Yast::TarballServer)
  # Rake task for running a source code web server,
  # designed for the `yupdate` script.
  desc "Start an HTTP server providing dynamically generated source code tarball"
  task :server, [:port] do |_task, args|
    server = Yast::TarballServer.new(args[:port])

    puts "Starting tarball webserver:"
    server.addresses.each { |a| puts " * #{a}" }
    puts

    server.start
  end
end

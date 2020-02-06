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
require "socket"

require_relative "index_servlet"
require_relative "servers_servlet"
require_relative "tarball_servlet"

module Yast
  # a webrick server which provides the source tarballs
  #
  # the server handles these URL paths:
  #   - "/archive/current.tar.gz" - the generated source code tarball
  #   - "/servers/index.json" - index of the tarball servers running on this machine
  #   - "/" - just a simple index page
  #
  # to stop the server press Ctrl+C
  class TarballServer
    # the default port number
    DEFAULT_HTTP_PORT = 8000

    attr_reader :port

    # create all URLs valid for this machine, use all network interfaces
    # (except the loop backs, the server will be used only from outside)
    # @return [Array<String>] list of URLs
    def addresses
      # ignore the loopback addresses
      hosts = Socket.ip_address_list.reject { |a| a.ipv4_loopback? || a.ipv6_loopback? }
      # IPv6 addresses need to be closed in square brackets in URLs
      hosts.map! { |a| a.ipv6? ? "[#{a.ip_address}]" : a.ip_address.to_s }
      # include also the hostname to make it easier to write
      hostname = Socket.gethostname
      hosts << hostname if !hostname&.empty?
      hosts.map! { |h| "http://#{h}:#{port}" }
    end

    # constructor
    #
    # @param port [Integer,nil] the port number, if nil the port will be found automatically
    #
    def initialize(port = nil)
      @port = port || find_port
    end

    # start the webserver, it can be closed by pressing Ctrl+C or by sending SIGTERM signal
    def start
      dir = File.basename(Dir.pwd)
      # change the process title so we can find the running
      # servers and their ports just by simple grepping the running processes
      Process.setproctitle("rake server (#{port},#{dir})")

      # Use "*" to bind also the IPv6 addresses
      server = WEBrick::HTTPServer.new(Port: port, BindAddress: "*")
      server.mount("/archive/current.tar.gz", TarballServlet)
      server.mount("/servers/index.json", ServersServlet)
      server.mount("/", IndexServlet)

      # stop the server when receiving a signal like Ctrl+C
      # (inspired by the "un.rb" from the Ruby stdlib)
      signals = ["TERM", "QUIT"]
      signals.concat(["HUP", "INT"]) if $stdin.tty?
      signals.each do |s|
        trap(s) { server.shutdown }
      end

      server.start
    end

  private

    # is the local port already taken by some other application?
    # @param port [Integer] the port number
    # @return [Boolean] true if the port is taken, false otherwise
    def port_taken?(port)
      # open the port and close it immediately, if that succeeds
      # some other application is already using it
      TCPSocket.new("localhost", port).close
      true
    rescue Errno::ECONNREFUSED
      false
    end

    # find a free port starting from the default port number
    # @return [Integer] the free port number
    def find_port
      DEFAULT_HTTP_PORT.step.find { |p| !port_taken?(p)}
    end
  end
end

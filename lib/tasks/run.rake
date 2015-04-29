#--
# Yast rake
#
# Copyright (C) 2009-2013 Novell, Inc.
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

def set_y2dir
  ENV["Y2DIR"] = Dir["**/src"].join(":")
end

desc "Run given client"
task :run, :client do |_t, args|
  args.with_defaults = { client: nil }
  client = args[:client]
  if client
    client = Dir["**/src/clients/#{client}.rb"].first
  else
    clients = Dir["**/src/clients/*.rb"]
    client = clients.reduce do |min, n|
      next n if min.nil?
      # use client with shortest name by default
      min.size > n.size ? n : min
    end
  end

  raise "No client found" unless client

  set_y2dir
  sh "/sbin/yast2 #{client}"
end

desc "Runs console with preloaded module directories"
task :console do
  set_y2dir
  sh "irb -ryast"
end

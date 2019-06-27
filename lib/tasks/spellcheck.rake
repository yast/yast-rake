# frozen_string_literal: true

#--
# Yast rake
#
# Copyright (C) 2015 Novell, Inc.
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

require_relative "spellcheck_task"
Yast::SpellcheckTask.new

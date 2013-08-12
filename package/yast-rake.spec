#
# spec file for package yast-rake
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

######################################################################
#
# IMPORTANT: Please do not change spec file in build service directly
#            Use https://github.com/yast/yast-rake-tasks repo
#
######################################################################

Name:           rubygem-yast-rake
Version:        0.0.1
Release:        0
BuildArch:      noarch

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        yast-rake.tar.bz2

Requires:       rubygem-rake
BuildRequires:  rubygem-rake

Summary:        YaST Rake
Group:          System/YaST
License:        GPL-2.0

Url:            https://github.com/yast/yast-rake

%description
Rake tasks and configuration for YaST

%prep
%build
%install
%clean
rm -rf "$RPM_BUILD_ROOT"

%files
%changelog


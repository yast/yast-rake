#
# spec file for package rubygem-yast-rake
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


Name:           rubygem-yast-rake
Version:        0.1.0
Release:        0
%define mod_name yast-rake
%define mod_full_name %{mod_name}-%{version}

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby-macros >= 1
Url:            http://github.org/openSUSE/yast-rake
Source:         http://rubygems.org/gems/%{mod_full_name}.gem
Summary:        Rake tasks providing basic work-flow for Yast development
License:        LGPL v2.1
Group:          Development/Languages/Ruby

%description
Rake tasks that support work-flow of Yast developer. It allows packaging repo,
send it to build service, create submit request to target repo or run client
from git repo.

%package doc
Summary:        RDoc documentation for %{mod_name}
Group:          Development/Languages/Ruby
Requires:       %{name} = %{version}

%description doc
Documentation generated at gem installation time.
Usually in RDoc and RI formats.

%prep
#gem_unpack
#if you need patches, apply them here and replace the # with a % sign in the surrounding lines
#gem_build

%build

%install
%gem_install -f

%files
%defattr(-,root,root,-)
%{_libdir}/ruby/gems/%{rb_ver}/cache/%{mod_full_name}.gem
%{_libdir}/ruby/gems/%{rb_ver}/gems/%{mod_full_name}/
%{_libdir}/ruby/gems/%{rb_ver}/specifications/%{mod_full_name}.gemspec
%doc %{_libdir}/ruby/gems/%{rb_ver}/gems/%{mod_full_name}/COPYING

%files doc
%defattr(-,root,root,-)
%doc %{_libdir}/ruby/gems/%{rb_ver}/doc/%{mod_full_name}/

%changelog

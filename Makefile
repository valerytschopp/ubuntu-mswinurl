#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# RPM packaging
#
name = mswinurl
version = 1.0.0
release = 1

prefix=/

spec_file = fedora/$(name).spec
rpmbuild_dir = $(CURDIR)/rpmbuild
tmp_dir=$(CURDIR)/tmp

clean:
	@echo "Cleaning..."
	rm -rf $(rpmbuild_dir) $(spec_file) *.rpm $(name) $(tmp_dir) *.tar.gz

dist:
	@echo "Package the sources..."
	test ! -d $(tmp_dir) || rm -fr $(tmp_dir)
	mkdir -p $(tmp_dir)/$(name)-$(version)
	cp Makefile README.md $(tmp_dir)/$(name)-$(version)
	cp -r src $(tmp_dir)/$(name)-$(version)
	test ! -f $(name)-$(version).tar.gz || rm $(name)-$(version).tar.gz
	tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz $(name)-$(version)
	rm -fr $(tmp_dir)

spec:
	@echo "Setting version and release in spec file: $(version)-$(release)"
	sed -e 's#@@SPEC_VERSION@@#$(version)#g' -e 's#@@SPEC_RELEASE@@#$(release)#g' $(spec_file).in > $(spec_file)

pre_rpmbuild: spec
	@echo "Preparing for rpmbuild in $(rpmbuild_dir)"
	mkdir -p $(rpmbuild_dir)/BUILD $(rpmbuild_dir)/RPMS $(rpmbuild_dir)/SOURCES $(rpmbuild_dir)/SPECS $(rpmbuild_dir)/SRPMS
	test -f $(rpmbuild_dir)/SOURCES/$(name)-$(version).tar.gz || wget -P $(rpmbuild_dir)/SOURCES $(dist_url)


srpm: pre_rpmbuild
	@echo "Building SRPM in $(rpmbuild_dir)"
	rpmbuild --nodeps -v -bs $(spec_file) --define "_topdir $(rpmbuild_dir)"
	cp $(rpmbuild_dir)/SRPMS/*.src.rpm .


rpm: pre_rpmbuild
	@echo "Building RPM/SRPM in $(rpmbuild_dir)"
	rpmbuild --nodeps -v -ba $(spec_file) --define "_topdir $(rpmbuild_dir)"
	find $(rpmbuild_dir)/RPMS -name "*.rpm" -exec cp '{}' . \;

install:
	echo "Installing in $(DESTDIR)$(prefix)"
	install -d $(DESTDIR)$(prefix)/usr/bin
	install -t $(DESTDIR)$(prefix)/usr/bin src/bin/$(name)
	install -d $(DESTDIR)$(prefix)/usr/share/applications
	install -t $(DESTDIR)$(prefix)/usr/share/applications src/share/applications/$(name).desktop


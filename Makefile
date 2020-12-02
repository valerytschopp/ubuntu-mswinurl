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

name=mswinurl
version=1.0
release=1

prefix=/usr

tmp_dir=$(CURDIR)/tmp
debbuild_dir=$(CURDIR)/debbuild

#all: deb

clean:
	@echo "Cleaning..."
	rm -rf $(debbuild_dir) *.deb $(name)*

dist:
	@echo "Package the sources..."
	test ! -d $(tmp_dir) || rm -fr $(tmp_dir)
	mkdir -p $(tmp_dir)/$(name)-$(version)
	cp Makefile README.md $(tmp_dir)/$(name)-$(version)
	cp -r src $(tmp_dir)/$(name)-$(version)
	test ! -f $(name)-$(version).tar.gz || rm $(name)-$(version).tar.gz
	tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz $(name)-$(version)
	rm -fr $(tmp_dir)

pre_debbuild:
	@echo "Prepare for Debian building in $(debbuild_dir)"
	mkdir -p $(debbuild_dir)
	test -f $(debbuild_dir)/$(name)_$(version).orig.tar.gz || cp $(name)-$(version).tar.gz $(debbuild_dir)/$(name)_$(version).orig.tar.gz
	tar -C $(debbuild_dir) -xzf $(debbuild_dir)/$(name)_$(version).orig.tar.gz
	cp -r debian $(debbuild_dir)/$(name)-$(version)

deb-src: pre_debbuild
	@echo "Building Debian source package in $(debbuild_dir)"
	cd $(debbuild_dir) && dpkg-source -b $(name)-$(version)
	find $(debbuild_dir) -maxdepth 1 -type f -exec cp '{}' . \;

deb: pre_debbuild
	@echo "Building Debian package in $(debbuild_dir)"
	cd $(debbuild_dir)/$(name)-$(version) && debuild -us -uc
	find $(debbuild_dir) -maxdepth 1 -name "*.deb" -exec cp '{}' . \;

install:
	echo "Installing in $(DESTDIR)$(prefix)"
	install -d $(DESTDIR)$(prefix)/bin
	install -t $(DESTDIR)$(prefix)/bin src/bin/$(name)
	install -d $(DESTDIR)$(prefix)/share/applications
	install -t $(DESTDIR)$(prefix)/share/applications src/share/applications/$(name).desktop


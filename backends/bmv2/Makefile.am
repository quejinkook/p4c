# Copyright 2013-present Barefoot Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Makefile for a backend that generates code for the Behavioral Model version 2 (BMv2)
# compiling for the simple_switch target.
# To be included in the main P4C compiler makefile

bin_PROGRAMS += p4c-bm2-ss
p4c_bm2_ss_LDADD = libbackendbmv2.la
p4c_bm2_ss_SOURCES = backends/bmv2/bmv2.cpp
cpplint_FILES += $(p4c_bm2_ss_SOURCES)

libbackendbmv2_la_UNIFIED = \
	backends/bmv2/analyzer.cpp \
	backends/bmv2/action.cpp \
	backends/bmv2/backend.cpp \
	backends/bmv2/control.cpp \
	backends/bmv2/deparser.cpp \
	backends/bmv2/errorcode.cpp \
	backends/bmv2/expression.cpp \
	backends/bmv2/extern.cpp \
	backends/bmv2/header.cpp \
	backends/bmv2/helpers.cpp \
	backends/bmv2/extractArchInfo.cpp \
	backends/bmv2/JsonObjects.cpp \
	backends/bmv2/lower.cpp \
	backends/bmv2/midend.cpp \
	backends/bmv2/metermap.cpp \
	backends/bmv2/parser.cpp \
	backends/bmv2/sharedActionSelectorCheck.cpp \
	backends/bmv2/simpleSwitch.cpp \
	backends/bmv2/portableSwitch.cpp

noinst_HEADERS += \
	backends/bmv2/analyzer.h \
	backends/bmv2/action.h \
	backends/bmv2/backend.h \
	backends/bmv2/control.h \
	backends/bmv2/deparser.h \
	backends/bmv2/errorcode.h \
	backends/bmv2/expression.h \
	backends/bmv2/extern.h \
	backends/bmv2/header.h \
	backends/bmv2/helpers.h \
	backends/bmv2/extractArchInfo.h \
	backends/bmv2/JsonObjects.h \
	backends/bmv2/lower.h \
	backends/bmv2/midend.h \
	backends/bmv2/metermap.h \
	backends/bmv2/options.h \
	backends/bmv2/parser.h \
	backends/bmv2/sharedActionSelectorCheck.h \
	backends/bmv2/simpleSwitch.h \
	backends/bmv2/portableSwitch.h

cpplint_FILES += $(libbackendbmv2_la_UNIFIED) $(libbackendbmv2_la_NONUNIFIED)

ir_DEF_FILES += $(srcdir)/backends/bmv2/bmv2.def

noinst_LTLIBRARIES += libbackendbmv2.la
libbackendbmv2_la_LIBADD = libfrontend.la

# Tests
-include bmv2tests.mk

CLEANFILES += bmv2tests.mk

bmv2tests.mk: $(GENTESTS) $(srcdir)/%reldir%/Makefile.am \
	      $(srcdir)/testdata/p4_16_samples/*-bmv2.p4 \
	      $(srcdir)/testdata/p4_16_bmv_errors/*-bmv2.p4 \
	      $(srcdir)/testdata/p4_14_samples/*.p4 \
	      $(srcdir)/testdata/p4_14_samples/switch_*/switch.p4 \
	      $(srcdir)/testdata/p4_16_samples $(srcdir)/testdata/p4_14_samples
	@$(GENTESTS) $(srcdir) bmv2 $(srcdir)/backends/bmv2/run-bmv2-test.py $^ >$@

gtest_LDADD += libbackendbmv2.la

INSTALL	= /usr/gnat
RUNTIME =
TOOL_PREFIX =
# tell wether the runtime supports the exceptions
SUPPORT_EXCEPTION = yes
# tell wether the runtime supports Ada.Calendar
SUPPORT_CALENDAR = yes

TEST_PROJECT = aunit_tests

ifeq ($(RUNTIME),zfp)
   SUPPORT_EXCEPTION = no
   SUPPORT_CALENDAR = no
   TEST_PROJECT = aunit_tests_zfp
endif

ifeq ($(TOOL_PREFIX),)
   GNATMAKE  = gnatmake
   GNATCLEAN = gnatclean
else
   GNATMAKE  = $(TOOL_PREFIX)-gnatmake
   GNATCLEAN = $(TOOL_PREFIX)-gnatclean
endif

ifeq ($(RUNTIME),)
   ADA_FLAGS =
else
   ADA_FLAGS = --RTS=$(RUNTIME)
endif

# Install directories

I_INC   = $(INSTALL)/include/aunit
I_LIB   = $(INSTALL)/lib/aunit
I_GPR   = $(INSTALL)/lib/gnat
I_TPL   = $(INSTALL)/share/examples/aunit
I_DOC   = $(INSTALL)/share/doc/aunit
I_PLG   = $(INSTALL)/share/gps/plug-ins

GPR_FLAGS_INSTALL = -XINSTALL_DIR=$(INSTALL)

ifneq ($(SUPPORT_EXCEPTION),yes)
   GPR_FLAGS_EXCEPTION = -XSUPPORT_EXCEPTION=no
else
   GPR_FLAGS_EXCEPTION = -XSUPPORT_EXCEPTION=yes
endif

ifneq ($(SUPPORT_CALENDAR),yes)
   GPR_FLAGS_CALENDAR = -XSUPPORT_CALENDAR=no
else
   GPR_FLAGS_CALENDAR := -XSUPPORT_CALENDAR=yes
endif

GPR_FLAGS = $(GPR_FLAGS_INSTALL) $(GPR_FLAGS_EXCEPTION) $(GPR_FLAGS_CALENDAR)

all:
	$(MKDIR) $(I_INC)
	$(MKDIR) $(I_LIB)
	$(MKDIR) $(I_GPR)
	$(MKDIR) aunit/obj
	$(GNATMAKE) $(ADA_FLAGS) -Paunit_build $(GPR_FLAGS)
	$(CP) support/aunit.gpr $(I_GPR)

clean:
	-$(GNATCLEAN) -f -r -Paunit_build $(GPR_FLAGS)
	-$(GNATCLEAN) -f -r -P$(TEST_PROJECT) $(GPR_FLAGS)
	$(RM) -fr $(I_INC)
	$(RM) -fr $(I_LIB)
	$(RM) -f $(I_GPR)/aunit.gpr
	-$(RMDIR) aunit/obj
	-$(RMDIR) obj
	-${MAKE} -C docs clean

install_clean:
	$(RM) -fr $(I_DOC)
	$(RM) -fr $(I_TPL)
	$(RM) -f $(I_PLG)/aunit.xml

install: install_clean all
	$(MKDIR) $(I_DOC)
	$(MKDIR) $(I_TPL)
	$(MKDIR) $(I_PLG)
	-$(CP) docs/*.html docs/*.info docs/*.pdf docs/*.txt $(I_DOC)
	-$(CP) template/*.ad[bs] template/*.gpr $(I_TPL)
	-$(CP) support/aunit.xml $(I_PLG)

doc:
	${MAKE} -C docs

test: all
	-$(MKDIR) obj
	-$(MKDIR) zfp_support/obj
	-$(MKDIR) zfp_support/lib
	GPR_PROJECT_PATH=$(INSTALL)/lib/gnat $(GNATMAKE) $(ADA_FLAGS) -P$(TEST_PROJECT) $(GPR_FLAGS)
	./aunit_harness

RMDIR	= rmdir
MKDIR	= mkdir -p
RM	= rm
CP	= cp -p

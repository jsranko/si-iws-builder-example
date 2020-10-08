LIBRARY:=$(shell jq '.library' -r ./config.json)
LIBRARY_DESC:=$(shell jq '.libraryDesc' -r ./config.json)
DBGVIEW=*SOURCE
DIR_RPG=QRPGLESRC
DIR_BND=QSRVSRC
DIR_IWSS=QIWSSSRC
DIR_CPY=QCPYLESRC
EXT_IWSS=IWSS
EXT_IWSSCONF=iwssconf
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

SRVPGMS:=\
	$(patsubst %.RPGLE,%.srvpgm,$(shell grep -il " nomain" $(DIR_RPG)/*.RPGLE))

SRCFILES_0=\
	$(DIR_RPG) \
	$(DIR_BND) \
	$(DIR_CPY) \
	$(DIR_IWSS) 

SRCFILES=\
	$(SRCFILES_0:=.srcpf)

IWSS=\
	$(patsubst %.$(EXT_IWSS),%.$(EXT_IWSSCONF),$(wildcard $(DIR_IWSS)/*.$(EXT_IWSS)))
	
# Ensure that intermediate files created by rules chains don't get
# automatically deleted
.PRECIOUS: %.srvpgm %.lib

all: build	

build: $(LIBRARY).lib \
		create-srcfiles \
	    build-srvpgms \
	    install-iwss

build-srvpgms: $(SRVPGMS)

create-srcfiles: $(SRCFILES)

install-iwss: $(IWSS)

display-vars: 
	$(info    IWSS is $(IWSS))
	$(info    IWSSCONF is $(IWSSCONF))  
	$(info    SRVPGMS is $(SRVPGMS)) 
	$(info    SRCFILES is $(SRCFILES)) 

%.lib: 
	(system -Kp "CHKOBJ $* *LIB" || system -Kp "CRTLIB $* TEXT('$(LIBRARY_DESC)')") && \
	touch $@

%.srvpgm: %.module
	$(call copy_to_srcpf,$(ROOT_DIR)/$(DIR_BND)/$(notdir $*).BND,$(LIBRARY),$(DIR_BND),$(notdir $*))
	system -Kp "CRTSRVPGM SRVPGM($(LIBRARY)/$(notdir $*)) MODULE($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$(DIR_BND)/$(notdir $*).BND') ACTGRP(*CALLER) OPTION(*DUPPROC) STGMDL(*INHERIT)" && \
	touch $@ 
	system -Kp "DLTMOD MODULE($(LIBRARY)/$(notdir $*))"
	
%.module: %.RPGLE
	$(call copy_to_srcpf,$(ROOT_DIR)/$<,$(LIBRARY),$(DIR_RPG),$(notdir $*))
	system -Kp "CRTRPGMOD MODULE($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$<') DBGVIEW($(DBGVIEW)) REPLACE(*YES) INCDIR('$(ROOT_DIR)') STGMDL(*INHERIT) TGTCCSID(*JOB) OUTPUT(*NONE)"  && \
	touch $@	
	
%.module: %.SQLRPGLE
	$(call copy_to_srcpf,$(ROOT_DIR)/$<,$(LIBRARY),$(DIR_RPG),$(notdir $*))
	system -Kp "CRTSQLRPGI OBJ($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$<') OBJTYPE(*MODULE) RPGPPOPT(*LVL2) DBGVIEW($(DBGVIEW)) REPLACE(*YES) COMPILEOPT('INCDIR(''$(ROOT_DIR)'') OUTPUT(*NONE) TGTCCSID(*JOB) STGMDL(*INHERIT)')" && \
	touch $@

%.srcpf: $(LIBRARY).lib
	system -Kp "CRTSRCPF FILE($(LIBRARY)/$*) RCDLEN(240) MBR(*NONE) TEXT('just for read-only')" && \
	touch $@

%.$(EXT_IWSSCONF): %.$(EXT_IWSS)
	# @echo "$$@=$@ $$%=$% $$<=$< $$?=$? $$^=$^ $$+=$+ $$|=$| $$*=$*"
	$(call substitute,$<,$@) && \
	$(call copy_to_srcpf,$(ROOT_DIR)/$@,$(LIBRARY),$(DIR_IWSS),$(notdir $*))
	java -cp ./si-iws-builder-latest.jar de.sranko_informatik.ibmi.iwsbuilder.App ./$@ 

clean: clean-iwss \
		clean-srcfiles \
		clean-cpysrc \
		clean-srvpgms \
		clean-lib

clean-lib:
	rm -f $(LIBRARY).lib &&\
	system -Kp 'DLTLIB $(LIBRARY)' || :	

clean-srcfiles:
	rm -f *.srcpf

clean-iwss:
	rm -f $(DIR_IWSS)/*.$(EXT_IWSSCONF)

clean-cpysrc:
	rm -f $(DIR_CPY)/*.cpysrc

clean-srvpgms:
	rm -f $(DIR_RPG)/*.srvpgm \
	      $(DIR_RPG)/*.module
clean-lib:
	rm -f $(LIBRARY).lib &&\
	system -Kp 'DLTLIB $(LIBRARY)' || :	

define copy_to_srcpf
	system -Kp "CPYFRMSTMF FROMSTMF('$(1)') TOMBR('/QSYS.LIB/$(2).LIB/$(3).FILE/$(4).MBR') MBROPT(*REPLACE) STMFCCSID(*STMF) DBFCCSID(*FILE) ENDLINFMT(*ALL)" && \
	system -Kp "CHGPFM FILE($(2)/$(3)) MBR($(4)) SRCTYPE($(subst .,,$(suffix $(1)))) TEXT('just for read-only')"
endef

define substitute
	-rm $(2)
	export QIBM_CCSID=$(SHELL_CCSID) && touch $(2) && \
	sed 's/$$(LIBRARY)/$(LIBRARY)/g; s/$$(ROOT_DIR)/$(subst /,\/,$(ROOT_DIR))/g; s/$$(DIR_JAVA)/$(subst /,\/,$(DIR_JAVA))/g' $(1) >> $(2)
endef	
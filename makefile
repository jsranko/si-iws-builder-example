LIBRARY:=$(shell jq '.library' -r ./config.json)
LIBRARY_DESC:=$(shell jq '.libraryDesc' -r ./config.json)
DIR_RPG=QRPGLESRC
DIR_BND=QSRVSRC
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

SRVPGMS:=\
	$(patsubst %.RPGLE,%.srvpgm,$(shell grep -il " nomain" $(DIR_RPG)/*.RPGLE)) \
	$(patsubst %.SQLRPGLE,%.srvpgm,$(shell grep -il " nomain" $(DIR_RPG)/*.SQLRPGLE))
	
# Ensure that intermediate files created by rules chains don't get
# automatically deleted
.PRECIOUS: %.srvpgm %.lib

all: build	

build: $(LIBRARY).lib \
	    build-srvpgms

build-srvpgms: $(SRVPGMS)

%.lib: 
	(system -Kp "CHKOBJ $* *LIB" || system -Kp "CRTLIB $* TEXT($(LIBRARY_DESC))") && \
	touch $@

%.srvpgm: %.module
	$(call copy_to_srcpf,$(ROOT_DIR)/$(DIR_BND)/$(notdir $*).BND,$(LIBRARY),$(DIR_BND),$(notdir $*))
	liblist -a $(LIBRARY);\
	system -Kp "CRTSRVPGM SRVPGM($(LIBRARY)/$(notdir $*)) MODULE($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$(DIR_BND)/$(notdir $*).BND') ACTGRP(*CALLER) OPTION(*DUPPROC) STGMDL(*INHERIT)" && \
	touch $@	
	system -Kp "ADDBNDDIRE BNDDIR($(LIBRARY)/$(LIBRARY)) OBJ(($(LIBRARY)/$(notdir $*) *SRVPGM *IMMED))" && \
	touch $@ 
	system -Kp "DLTMOD MODULE($(LIBRARY)/$(notdir $*))"
	
%.module: %.RPGLE
	$(call copy_to_srcpf,$(ROOT_DIR)/$<,$(LIBRARY),$(DIR_RPG),$(notdir $*))
	liblist -a $(LIBRARY);\
	system -Kp "CRTRPGMOD MODULE($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$<') DBGVIEW($(DBGVIEW)) REPLACE(*YES) INCDIR('$(ROOT_DIR)') STGMDL(*INHERIT) TGTCCSID(*JOB) OUTPUT(*NONE)"  && \
	touch $@	
	
%.module: %.SQLRPGLE
	$(call copy_to_srcpf,$(ROOT_DIR)/$<,$(LIBRARY),$(DIR_RPG),$(notdir $*))
	liblist -a $(LIBRARY);\
	system -Kp "CRTSQLRPGI OBJ($(LIBRARY)/$(notdir $*)) SRCSTMF('$(ROOT_DIR)/$<') OBJTYPE(*MODULE) RPGPPOPT(*LVL2) DBGVIEW($(DBGVIEW)) REPLACE(*YES) COMPILEOPT('INCDIR(''$(ROOT_DIR)'') OUTPUT(*NONE) TGTCCSID(*JOB) STGMDL(*INHERIT)')" && \
	touch $@

clean-lib:
	rm -f $(LIBRARY).lib &&\
	system -Kp 'DLTLIB $(LIBRARY)' || :	

define copy_to_srcpf
	system -Kp "CPYFRMSTMF FROMSTMF('$(1)') TOMBR('/QSYS.LIB/$(2).LIB/$(3).FILE/$(4).MBR') MBROPT(*REPLACE) STMFCCSID(*STMF) DBFCCSID(*FILE) ENDLINFMT(*ALL)" && \
	system -Kp "CHGPFM FILE($(2)/$(3)) MBR($(4)) SRCTYPE($(subst .,,$(suffix $(1)))) TEXT('just for read-only')"
endef	
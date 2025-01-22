# makefile
# Written on Tue Jul 31 15:10:04 CEST 2007
# by Jean-Baptiste Caillau - ENSEEIHT-IRIT, UMR CNRS 5505

PASSWD = /Users/caillau/.passwd/passwd
COUNT1 = /Users/caillau/www/cotcot
USER2  = $(W2USER)
HOST2  = localhost
COUNT2 = $(W2COUNT)/../apo/cotcot
PORT   = $(W2PORT)
EXCL   = $(COUNT1)/.sync-exclude

default: sync

login:
	openssl des3 -d -in $(PASSWD).des -out $(PASSWD)
	chmod -R go-rwx $(PASSWD)

logout:
	rm -f $(PASSWD)

sync:
	chmod -R a+rx *
	rsync -avz --exclude-from=$(EXCL) --delete-excluded --rsh='ssh -p $(PORT)' $(COUNT1)/ $(USER2)@$(HOST2):$(COUNT2)/

logged:
	cat $(PASSWD) | ssh -p $(PORT) $(USER2)@$(HOST2) openssl des3 -d -pass stdin -in $(COUNT2).des -out $(COUNT2).zip
	ssh -p $(PORT) $(USER2)@$(HOST2) unzip $(COUNT2).zip -d /
	ssh -p $(PORT) $(USER2)@$(HOST2) rm -f $(COUNT2).zip $(COUNT2).des
	make sync
	ssh -p $(PORT) $(USER2)@$(HOST2) zip -ry9Tm $(COUNT2).zip $(COUNT2)
	cat $(PASSWD) | ssh -p $(PORT) $(USER2)@$(HOST2) openssl des3 -e -pass stdin -in $(COUNT2).zip -out $(COUNT2).des
	ssh -p $(PORT) $(USER2)@$(HOST2) rm -f $(COUNT2).zip

vault:
	make login
	make logged
	make logout

help:
	@echo "targets: sync (default), logged, vault"

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall

install:
	@mkdir -p $(BINDIR)
	@ln -sf $(CURDIR)/cc-switch $(BINDIR)/cc-switch
	@echo "Installed cc-switch to $(BINDIR)/cc-switch"

uninstall:
	@rm -f $(BINDIR)/cc-switch
	@echo "Uninstalled cc-switch"

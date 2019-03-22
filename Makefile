INSTALL_BIN_DIR ?= ~/.local/bin

all:

install:
	mkdir -p ${INSTALL_BIN_DIR}
	install -m 755 org-imap.sh ${INSTALL_BIN_DIR}/org-imap.sh

uninstall:
	rm ${INSTALL_BIN_DIR}/miyuki 2>/dev/null || :

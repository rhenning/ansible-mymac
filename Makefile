VENV_VERSION = 14.0.6

PYPI_VENV_BASE = https://pypi.python.org/packages/source/v/virtualenv
PYTHON = python
PLAYBOOK = default.yml
BUILD_PATH = build
VENV_PATH = $(BUILD_PATH)/virtualenv
VENV_BIN = $(VENV_PATH)/bin

all: check venv ansible

.PHONY: all clean check venv ansible ansible-galaxy ansible-playbook req

clean:
	rm -rf build/*

check:
	which python

venv: $(VENV_BIN)/activate

ansible: venv ansible-playbook

$(BUILD_PATH)/virtualenv.tar.gz:
	curl \
		--silent \
		--output $@ \
		$(PYPI_VENV_BASE)/virtualenv-$(VENV_VERSION).tar.gz

$(BUILD_PATH)/virtualenv-$(VENV_VERSION): $(BUILD_PATH)/virtualenv.tar.gz
	tar -zxf $(BUILD_PATH)/virtualenv.tar.gz -C $(BUILD_PATH)

$(BUILD_PATH)/virtualenv-$(VENV_VERSION)/virtualenv.py: $(BUILD_PATH)/virtualenv-$(VENV_VERSION)
	$(PYTHON) $(BUILD_PATH)/virtualenv-$(VENV_VERSION)/virtualenv.py $(VENV_PATH)

$(VENV_BIN)/activate: $(BUILD_PATH)/virtualenv-$(VENV_VERSION)/virtualenv.py
	. $@ && pip install --requirement requirements.txt

ansible-galaxy: requirements.yml
	. $(VENV_BIN)/activate && $@ install --role-file requirements.yml

ansible-playbook: ansible-galaxy $(PLAYBOOK)
	. $(VENV_BIN)/activate && $@ $(PLAYBOOK) --inventory 'localhost,' --connection 'local'

req: requirements.txt

requirements.txt: venv requirements.in
	. $(VENV_BIN)/activate && pip install --requirement requirements.in
	. $(VENV_BIN)/activate && pip freeze | tee $@

.PHONY: help setup import validate test test-unit test-integration test-simulation run export-windows export-linux

POWERSHELL ?= powershell
DEV = $(POWERSHELL) -NoProfile -ExecutionPolicy Bypass -File tools/dev.ps1

help:
	$(DEV) help
setup:
	$(DEV) setup
import:
	$(DEV) import
validate:
	$(DEV) validate
test:
	$(DEV) test
test-unit:
	$(DEV) test-unit
test-integration:
	$(DEV) test-integration
test-simulation:
	$(DEV) test-simulation
run:
	$(DEV) run
export-windows:
	$(DEV) export-windows
export-linux:
	$(DEV) export-linux

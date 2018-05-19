#!/bin/bash
PRIVATE_CONFIG=qdata/c/tm.ipc geth --exec "loadScript(\"$1\")" attach ipc:qdata/dd/geth.ipc

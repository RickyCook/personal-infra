#!/bin/bash
THISDIR="$(cd "$(dirname "$0")"; pwd)"
rsync --archive "$THISDIR/root/" /

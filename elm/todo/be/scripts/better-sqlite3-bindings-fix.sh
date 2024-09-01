#!/bin/sh

DIR="$(dirname "$(dirname "$(realpath "$0")")")"

SOURCE_FILE="${DIR}/node_modules/better-sqlite3/build/Release"
TARGET_FILE="${DIR}/Release"

ln -sf "${SOURCE_FILE}" "${TARGET_FILE}"

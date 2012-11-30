#!/usr/bin/env roundup
#
# This file contains the test plan for the `add-authorized-key` command.
#    
#/ usage:  rerun stubbs:test -m ssh -p add-authorized-key [--answers <>]
#

# Helpers
#
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------

describe "add-authorized-key"


it_works_with_a_new_key_and_a_duplicate() {
  # Generate a new key-pair into a temporary directory.
  TMPDIR=$(mktemp -d)
  rerun ssh:keygen --key-file ${TMPDIR}/id_dsa

  # Get the fields from the generated public key file.
  TYPE=$(cut -d' ' -f1 < ${TMPDIR}/id_dsa.pub | cut -d- -f2)
  PUBLIC_KEY=$(cut -d' ' -f2 < ${TMPDIR}/id_dsa.pub)
  COMMENT=$(cut -d' ' -f3- < ${TMPDIR}/id_dsa.pub)

  # Add the key to a new empty authorized_keys file and make sure its the same as the original public key:
  rerun ssh:add-authorized-key --public-key "${PUBLIC_KEY}" --authorized-keys-file ${TMPDIR}/.ssh/authorized_keys --type ${TYPE} --comment ${COMMENT}
  diff ${TMPDIR}/id_dsa.pub ${TMPDIR}/.ssh/authorized_keys

  # Add the key a second time and make sure its the same as the original public key thus proving a duplicate entry was avoided:
  rerun ssh:add-authorized-key --public-key "${PUBLIC_KEY}" --authorized-keys-file ${TMPDIR}/.ssh/authorized_keys --type ${TYPE} --comment ${COMMENT}
  diff ${TMPDIR}/id_dsa.pub ${TMPDIR}/.ssh/authorized_keys

  rm -rf ${TMPDIR}
}

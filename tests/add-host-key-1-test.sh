#!/usr/bin/env roundup
#
# This file contains the test plan for the `add-host-key` command.
#    
#/ usage:  rerun stubbs:test -m ssh -p add-host-key [--answers <>]
#

# Helpers
#
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------

describe "add-host-key"

it_works_with_a_new_key_and_a_duplicate() {
  # Generate a new key-pair into a temporary directory.
  TMPDIR=$(mktemp -d)
  rerun ssh:keygen --key-file ${TMPDIR}/id_dsa

  # Get the fields from the generated public key file.
  TYPE=$(cut -d' ' -f1 < ${TMPDIR}/id_dsa.pub | cut -d- -f2)
  PUBLIC_KEY=$(cut -d' ' -f2 < ${TMPDIR}/id_dsa.pub)
  COMMENT=$(cut -d' ' -f3- < ${TMPDIR}/id_dsa.pub)

  # Add the key to a new empty known hosts file and make sure its the same as the original public key:
  rerun ssh:add-host-key --public-key "${PUBLIC_KEY}" --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname localhost
  echo "localhost ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  # Add the key a second time and make sure its the same as the original public key thus proving a duplicate entry was avoided:
  rerun ssh:add-host-key --public-key "${PUBLIC_KEY}" --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname localhost
  echo "localhost ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  # Add the key a third time with a different hostname proving the existing entry is replaced:
  rerun ssh:add-host-key --public-key "${PUBLIC_KEY}" --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname $HOSTNAME
  echo "$HOSTNAME ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  rm -rf ${TMPDIR}
}


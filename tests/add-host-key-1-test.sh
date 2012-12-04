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

# Tests generating a DSA public host key and adding it to a temporary known hosts file.
it_works_with_a_new_and_duplicate_key() {
  # Generate a new key-pair into a temporary directory.
  TMPDIR=$(mktemp -d)
  rerun ssh:keygen --key-file ${TMPDIR}/id_dsa

  # Get the fields from the generated public key file.
  TYPE=$(cut -d' ' -f1 < ${TMPDIR}/id_dsa.pub | cut -d- -f2)
  PUBLIC_KEY=$(cut -d' ' -f2 < ${TMPDIR}/id_dsa.pub)

  # Add the key to a new empty known hosts file and make sure its the same as the original public key:
  rerun ssh:add-host-key --host-key "${PUBLIC_KEY}" --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname localhost
  echo "localhost ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  # Add the key a second time and make sure its the same as the original public key thus proving a duplicate entry was avoided:
  rerun ssh:add-host-key --host-key "${PUBLIC_KEY}" --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname localhost
  echo "localhost ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  # Add the key a third time with a different hostname proving the existing entry is replaced:
  rerun ssh:add-host-key --host-key "${PUBLIC_KEY}" --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname $HOSTNAME
  echo "$HOSTNAME ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  rm -rf ${TMPDIR}
}

# Tests using ssh-keyscan(1) to get the localhost's DSA public host key and add it to a temporary known hosts file
it_works_when_no_host_key_is_provided() {
  # Generate a new key-pair into a temporary directory.
  TMPDIR=$(mktemp -d)

  # Get the fields from the generated public key file.
  TYPE=dsa
  PUBLIC_KEY=$(ssh-keyscan -t dsa localhost 2>/dev/null | cut  -d' ' -f3)

  # Add the key to a new empty known hosts file and make sure its the same as the original public key:
  rerun ssh:add-host-key --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname localhost
  echo "localhost ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  # Add the key a second time and make sure its the same as the original public key thus proving a duplicate entry was avoided:
  rerun ssh:add-host-key --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname localhost
  echo "localhost ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  # Add the key a third time with a different hostname proving the existing entry is replaced:
  rerun ssh:add-host-key --known-hosts-file ${TMPDIR}/.ssh/known_hosts --type ${TYPE} --hostname $HOSTNAME
  echo "$HOSTNAME ssh-${TYPE} ${PUBLIC_KEY}" > ${TMPDIR}/known_hosts.test
  diff ${TMPDIR}/known_hosts.test ${TMPDIR}/.ssh/known_hosts

  rm -rf ${TMPDIR}
}

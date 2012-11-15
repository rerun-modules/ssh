#!/usr/bin/env roundup
#
# This file contains the test plan for the keygen command.
# Execute the plan by invoking: 
#    
#     rerun stubbs:test -m ssh -p keygen
#

# Helpers
#
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------

describe "keygen"

it_works_without_options() {
    # Backup existing key pair if it exists unless a backup pre-exists.
    [[ -e $HOME/.ssh/id_dsa ]] && [[ ! -e $HOME/.ssh/id_dsa.orig ]] && mv $HOME/.ssh/id_dsa $HOME/.ssh/id_dsa.orig
    [[ -e $HOME/.ssh/id_dsa.pub ]] && [[ ! -e $HOME/.ssh/id_dsa.pub.orig ]] && mv $HOME/.ssh/id_dsa.pub $HOME/.ssh/id_dsa.pub.orig

    # Generate a keypair using the default option values.
    rerun ssh:keygen

    # Remove the generated key pair.
    rm -f $HOME/.ssh/id_dsa $HOME/.ssh/id_dsa.pub

    # Restore key pair if it was backed-up.
    [[ -e $HOME/.ssh/id_dsa.orig ]] && mv $HOME/.ssh/id_dsa.orig $HOME/.ssh/id_dsa
    [[ -e $HOME/.ssh/id_dsa.pub.orig ]] && mv $HOME/.ssh/id_dsa.pub.orig $HOME/.ssh/id_dsa.pub
}

it_fails_without_force_with_existing_key_pair() {
    # Backup existing key pair if it exists unless a backup pre-exists.
    [[ -e $HOME/.ssh/id_dsa ]] && [[ ! -e $HOME/.ssh/id_dsa.orig ]] && mv $HOME/.ssh/id_dsa $HOME/.ssh/id_dsa.orig
    [[ -e $HOME/.ssh/id_dsa.pub ]] && [[ ! -e $HOME/.ssh/id_dsa.pub.orig ]] && mv $HOME/.ssh/id_dsa.pub $HOME/.ssh/id_dsa.pub.orig

    # Generate a keypair using the default option values.
    rerun ssh:keygen

    # Generating a keypair a second time without the force option should fail.
    if ! rerun ssh:keygen
    then
      :
    fi

    # Remove the generated key pair.
    rm -f $HOME/.ssh/id_dsa $HOME/.ssh/id_dsa.pub

    # Restore key pair if it was backed-up.
    [[ -e $HOME/.ssh/id_dsa.orig ]] && mv $HOME/.ssh/id_dsa.orig $HOME/.ssh/id_dsa
    [[ -e $HOME/.ssh/id_dsa.pub.orig ]] && mv $HOME/.ssh/id_dsa.pub.orig $HOME/.ssh/id_dsa.pub
}

it_works_with_force_and_existing_key_pair() {
    # Backup existing key pair if it exists unless a backup pre-exists.
    [[ -e $HOME/.ssh/id_dsa ]] && [[ ! -e $HOME/.ssh/id_dsa.orig ]] && mv $HOME/.ssh/id_dsa $HOME/.ssh/id_dsa.orig
    [[ -e $HOME/.ssh/id_dsa.pub ]] && [[ ! -e $HOME/.ssh/id_dsa.pub.orig ]] && mv $HOME/.ssh/id_dsa.pub $HOME/.ssh/id_dsa.pub.orig

    # Generate a keypair using the default option values.
    rerun ssh:keygen

    # Generating a keypair a second time with the force option should succeed.
    rerun ssh:keygen --force true

    # Remove the generated key pair.
    rm -f $HOME/.ssh/id_dsa $HOME/.ssh/id_dsa.pub

    # Restore key pair if it was backed-up.
    [[ -e $HOME/.ssh/id_dsa.orig ]] && mv $HOME/.ssh/id_dsa.orig $HOME/.ssh/id_dsa
    [[ -e $HOME/.ssh/id_dsa.pub.orig ]] && mv $HOME/.ssh/id_dsa.pub.orig $HOME/.ssh/id_dsa.pub
}

# shellcheck shell=bash

cpanm() {
  \
  ( [[ "${CURRENT_WORD:0:1}" == . ]] || [[ "${CURRENT_WORD:0:1}" == / ]] ) \
    || ${ZCAT_BIN:-zcat} ${CPAN_PACKAGES_DETAILS:-~/.cpanm/sources/http%www.cpan.org/02packages.details.txt.gz} \
    | tail -n +8 \
    | cut -f 1 -d ' ' \
    | grep "^$CURRENT_WORD" \
    | head -${CPAN_MAX_MODULES:-10000}

  true
}

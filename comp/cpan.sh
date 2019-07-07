# shellcheck shell=bash

cpan() {
  \
  ( [[ "${CURRENT_WORD:0:1}" == . ]] || [[ "${CURRENT_WORD:0:1}" == / ]] ) \
    || ${ZCAT_BIN:-zcat} ${CPAN_PACKAGES_DETAILS:-~/.local/share/.cpan/sources/modules/02packages.details.txt.gz} \
    | tail -n +8 \
    | cut -f 1 -d ' ' \
    | grep "^$CURRENT_WORD" \
    | head -${CPAN_MAX_MODULES:-10000}

  true
}

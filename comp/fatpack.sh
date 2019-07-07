# shellcheck shell=bash

fatpack() {
  \
  for incpath in $(perl -wE'say for @INC'); do \
    find $incpath -name "*.pm" -printf "%P\n" \
    | perl -plE's{/}{::}g; s{\.pm}{}' \
    | grep "^$CURRENT_WORD"; \
  done

  true
}

fatpack() {
  \
  for incpath in $(perl -wE'say for @INC'); do \
    find $incpath -name "*.pm" -printf "%P\n" \
    | perl -plE's{/}{::}g; s{\.pm}{}' \
    | grep "^$CURRENT_WORD"; \
  done

  true
}

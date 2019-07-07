# shellcheck shell=bash

prove() {
  find `perl -wE'say for @INC'` | grep '/App/Prove/Plugin/.*.pm$' | perl -plE's{^.*/(App/Prove/Plugin/.*)\.pm$}{$1}; s{/}{::}g'

  true
}

prove() {
  \
  for incpath in $(perl -wE'say for @INC'); do \
    find $incpath -name "*.pm" -printf "%P\n" \
    | perl -plE's{/}{::}g; s{\.pm}{}' \
    | grep "^$CURRENT_WORD"; \
  done

  true
}

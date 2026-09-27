# Audit log

- 27 Sep 2026 — created from Sidewatch's HTTP client: the `.http` block reader moved out of the
  app (and lost a redundant step a mutant proved did nothing), plus curl conversion for paste.
  7 tests; mutants on the header guard, the comment skip and the default scheme each caught.

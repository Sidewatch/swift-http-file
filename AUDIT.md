# Audit log

- 27 Sep 2026 — created from Sidewatch's HTTP client: the `.http` block reader moved out of the
  app (and lost a redundant step a mutant proved did nothing), plus curl conversion for paste.
  7 tests; mutants on the header guard, the comment skip and the default scheme each caught.
- 9 Oct 2026 — security review: `RedirectPolicy` (Support/). Sidewatch's HTTP client used `URLSession.shared`, which follows a redirect carrying every header but `Authorization`; a cross-host `302` delivered the request's `Cookie` and `X-Api-Key`. The pure rule drops every credential-shaped header when the scheme, host or port changes and keeps everything within the origin; `isCredentialShaped(_:)` also gates the client's "Save to Project" warning. `RedirectPolicyTests` (five tests). Mutant: headers always follow — the cross-host test fails.

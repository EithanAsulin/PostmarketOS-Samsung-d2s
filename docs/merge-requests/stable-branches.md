# Stable Branches

This article describes how to make merge requests towards a [stable
release](../releases) branch.

## Relevant Changes

* Fixes backported from `main`.

* Features backported from `main` if the maintainer of the package considers
  them stable enough and important enough for backporting. In general we should
  try to keep these minimal, for users the assumption is that stable branches
  don't change much between releases and are therefore much more reliable than
  edge.

* For packages that have a higher version in `main`: if upstream releases a
  patch-release for an older version that we are using in our stable branch, an
  upgrade MR can directly be sent to the stable branch without the usual
  main-first-then-backport approach described below.

## Workflow

* Merge request authors or other contributors may add a `backport-to-vYY.MM`
  label to pmaports MRs to `main` that shall be backported.

* After the MR is merged to `main`, somebody following up (could be the person
  who merged the MR to be fastest, or the original MR author, or the person
  responsibly for the release, or another community member) creates a MR to
  the release branch.

* Use `git cherry-pick -x ffffffff` (insert commit to cherry pick accordingly)
  for every patch. The `-x` will add a `(cherry picked from commit ffffffff)`
  line to the commit message.

* Put `backport of <link to the original MR>` into the description of the MR
  towards the stable branch.

* For patches that are not related to security, maintainers can choose to delay
  backporting to give them more time in edge. This can be done either by adding
  a visible note in the original MR description that a backport shall wait and
  how long, or by adding a blocking comment in the backport MR that it shall
  not be merged before a specific date.

### Best Practices

* Cherry picked commits shall not be squashed, then it's hard to understand
  which commits were already picked and which were not.

* Avoid cherry-picking multiple patches that touch the same pmaports in the
  wrong order. If there's a conflict, consider additionally cherry-picking a
  dependent patch beforehand if it's non-intrusive.

### Initial Release Branch Bringup

Before the binary repository is built once for the release branch, it is fine
to directly push cherry-picked patches from main to the release branch without
going through a merge request. The reason is that CI doesn't work yet anyway,
and we want to have build fixes applied to the release branch quickly to be
able to finish the initial build of the binary repository.

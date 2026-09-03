# Same-boot verifier system record — 2026-09-03

This record was captured after the final-verification run on 2026-09-03, during
the same boot. It was **not** captured at package launch time and is not evidence
of the approved Apple M1 Pro target. No computer or device name was queried.

`sw_vers` (exit 0):

```text
ProductName:		macOS
ProductVersion:		26.2
BuildVersion:		25C56
```

`sysctl -n kern.boottime` (exit 0):

```text
{ sec = 1787034769, usec = 527313 } Mon Aug 17 23:32:49 2026
```

`uname -m` (exit 0):

```text
arm64
```

The boot timestamp predates the retained 2026-09-03 verification logs, so this
is same-boot corroboration for macOS 26.2 build 25C56 on an arm64 verifier host.
It does not retroactively turn the record into launch-time OS capture.

# USB integration fork — phased development gates

**Status 2026-10-22:** Source fork and mapping permitted and in progress; runtime implementation not authorized by this approval.

The aim is to preserve Atmosphère's original architecture, reuse its documented interfaces where appropriate, and determine what features are **actually possible**. Avoid solving an imaginary problem by grafting unverified functionality into core system modules.

## Phase F0 — Local source fork (now)

- [x] Independent Atmosphère source clone on the desktop, not inside the USB tester or audit repo.
- [x] Pinned Atmosphère 1.12.1 `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8`.
- [x] Dedicated `development/usb-storage-feasibility` branch, official upstream remote.
- [x] Main source, headers, makefiles, fusee, mesosphere, emuMMC and stratosphere preserved.
- [x] Personal hosted GitHub fork `Awetspoon/Atmosphere` created by owner; verified and connected locally as `origin`.
- [x] Documentation-only `development/usb-storage-feasibility` branch published to the hosted fork after explicit approval on 2026-10-22.
- [ ] Unmodified baseline complete compile / regression suite (**not** claimed).

## Phase F1 — Evidence and dependency mapping (current documentation-only stage)

- [x] Identify gamecard consumer API ownership and FS proxy delegation.
- [x] Distinguish `usb:hs` USB host from `usb:ds` device-side service.
- [x] Distinguish SX OS `usbfs`, archived `fsp-usb`, native `fsp-srv` and Atmosphère FS MITM.
- [x] Mark physical gamecard accessors as **queries/consumers**, not constructors.
- [x] Document `nogc`, emuMMC, service permissions and memory constraints.
- [ ] Collect the v0.2 volunteer's real FAT32 test-file read outcome.
- [ ] Audit a prospective feature's dependencies/licences and API version ranges before any code is proposed.

## Phase F2 — Basic USB reliability gate (separate tester, not this fork)

Only once actual hardware testing is approved and conducted: gather firmware, Atmosphère, dock port, USB device and test-file checksum results. Mark USB initialization, enumeration, read, checksum, clean exit, suspend/resume and removal handling as PASS, FAIL, or NOT RUN. No fabricated hardware results.

Current v0.1 test showed app startup but tiny TV text and no controller input. v0.2 builds and passes PC simulations; no physical USB-read result is yet recorded.

**Decision:** If a harmless read-only file cannot be read reliably, stop: do not proceed to more invasive system-level integration.

## Phase F3 — Consider an opt-in USB filesystem service (research proposal only)

Prerequisites before any implementation approval:

- Existing service ACL/memory/session restrictions documented without bypasses.
- Architecture for separate, opt-in clients and ordinary user-created data, not title/gamecard services.
- Timeout, short read, unplug, loss of power, corruption prevention, fail-closed state and controlled shutdown defined.
- Existing modules stay unchanged unless a narrowly justified, explicitly approved integration is necessary.
- Build and licence compatibility with the exact target firmware/toolchain established.
- Bench tests for disk access performed only with spare disposable media and harmless data.
- User approves exact source/header/build paths and the testing and rollback scope.

**No opt-in service code exists in this fork yet.** Historic `fsp-usb` is not drop-in maintainable modern source; libusbhsfs upstream says no direct sysmodule use.

## Phase F4 — Evaluate native gamecard feasibility as a separate question

The public filesystem/gamecard API wrappers inspected here **do not** provide a method to register a USB file as an inserted gamecard, nor prove the relevant proprietary Nintendo backend can be extended.

Before making any decision, a new separate review would have to establish:

- Technical constraints and supported extension contracts **without circumventing security**.
- Firmware compatibility, hardware fallback, resource impact, stability, device lifetime and read errors.
- Distribution obligations and anti-circumvention/rights issues reviewed by qualified advisers where applicable.
- Whether the idea is even technically defensible; a justified outcome may be **NO-GO**.

Do not implement gamecard emulation, XCI launching, keys, rights bypass, filesystem-authentication changes or service interception under the approval for fork/mapping. A source fork itself does not overcome these boundaries.

## Approval and change-review template

For each *future* feature request:

```text
Feature:
Original existing module and file owner:
Exact existing functions/headers:
New files only if necessary and why:
Code/data/build files to modify:
What remains unchanged:
Compatibility assumptions and source links:
Read-only test and rollback:
What has been hardware-verified versus inferred:
Legal/licensing constraints:
Owner approval (specific action):
```

Keep each feature on its own branch and commit in appropriately named source/header/build/test files. After implementation, report actual compiler outcomes and tests, not expectations.

## Non-negotiable release criteria

No release or deployment of a CFW fork simply because it compiles. A development branch must not be treated as production Atmosphère, firmware update package or game loader. Validated rollback and user-approved safe test boundaries are prerequisites.

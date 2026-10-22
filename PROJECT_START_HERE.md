# Atmosphère USB integration — local development fork

**Status:** Local working fork created on 22 October 2026; source/interface mapping under way; no cartridge emulator, system module or game launcher built.

## Read this first

This directory is an **independent local Git clone of the real Atmosphère source tree**, not a collection of copied code snippets and not our separate USB test application. It preserves original module folders, naming, headers, build files and their relationships.

- **Base:** upstream Atmosphère 1.12.1 at commit `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8` (2026-10-16).
- **Working branch:** `development/usb-storage-feasibility`.
- **Fetch remote:** `upstream = https://github.com/Atmosphere-NX/Atmosphere.git`.
- **Personal GitHub fork:** created at https://github.com/Awetspoon/Atmosphere and connected as `origin`. Official Atmosphère remains `upstream`; the development branch is **published to your GitHub fork**, with original source unchanged. See `docs/usb-gamecard/GITHUB_FORK_SETUP.md`.
- **Licence:** preserve Atmosphère's GPLv2 and any separate component notices. Do not publish copies of Nintendo proprietary firmware, game content or keys.

## Project separation

```text
Desktop/
  Atmosphere-USB-Fork/                <- THIS: independent source fork and branch
    fusee/                            <- original, unchanged
    mesosphere/                       <- original, unchanged
    stratosphere/                      <- original, unchanged
    libraries/libstratosphere/        <- original, unchanged
    emummc/                            <- original, unchanged
    docs/usb-gamecard/                <- our evidence and plans
    AGENTS.md                         <- coding rules for future work

  Atmosphere-USB-Feasibility-Audit/   <- PRE-EXISTING research, separate Git repo
    usb-readonly-probe/               <- EXISTING compiled v0.2 test app
    research/upstream/                <- pinned reference clones and history
```

Nothing has been copied over the original project. Neither firmware nor the Switch SD card has been modified.

## Current architectural conclusion

Source review finds API calls for opening an **already recognised** gamecard and its partitions. That is not an interface for registering an arbitrary USB file as a cartridge.

Three distinct kinds of USB services must not be conflated:

- `usb:hs`: lower-level Horizon USB **host** interface used by libnx and USB file-access libraries.
- SX OS `usbfs`: custom file service inferred from third-party **client** shims; original gamecard backend is proprietary and unverified.
- Historic `fsp-usb`: abandoned, opt-in USB filesystem **server**; explicit clients can open USB files, but it does not create a virtual cartridge.

Atmosphère additionally has `fsp-srv` gamecard-related *accessors* and an `ams_mitm` filesystem interception framework. The examined source does **not** establish that either implements an emulated gamecard.

## Work order

1. Preserve and pin upstream baseline (complete locally).
2. Map existing modules to their real responsibilities without guessing (see `docs/usb-gamecard/SOURCE_MAP.md`).
3. Record service and dependency boundaries, unknown APIs, version-specific assumptions and risks (see `docs/usb-gamecard/INTERFACE_BOUNDARIES.md`).
4. Wait for a real USB file-read result from the separate v0.2 app; distinguish app runtime testing from any system-level feasibility.
5. Only after review decide whether an ordinary, non-game USB filesystem opt-in service is a justified separate feature; request explicit approval before making sysmodule or core CFW changes.
6. Gamecard replacement, virtual insertion, DRM/security bypass and XCI launching are **not implemented or assumed deliverable** by this fork setup. Those would be entirely separate high-risk feasibility/legal questions.

## Verification

`tools/verify_fork.ps1` checks the source clone, branch, essential paths and upstream remote without changing anything.

## Key documents

- `AGENTS.md`: repository-wide rules to keep implementation modular and upstream-compatible.
- `docs/usb-gamecard/SOURCE_MAP.md`: grounded file/path/line interface map.
- `docs/usb-gamecard/INTERFACE_BOUNDARIES.md`: evidence-backed architecture sketch.
- `docs/usb-gamecard/IMPLEMENTATION_GATES.md`: decision and test gates, no unsupported promises.
- `docs/usb-gamecard/GITHUB_FORK_SETUP.md`: verified hosted fork, published development branch and future Git sync instructions.
- `docs/usb-gamecard/DECISION_LOG.md`: baseline choices, approvals and limitations.

**No production firmware/gamecard functionality has yet been changed.** That is deliberate: retaining the source's integrity is part of the first phase of a safe fork.

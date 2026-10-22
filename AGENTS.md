# Atmosphère USB integration fork — Codex/agent project rules

Read `PROJECT_START_HERE.md` and all `docs/usb-gamecard/` documents before proposing code. This is a **real, locally forked Atmosphère source repository**. The objective is to map and assess reuse of upstream modules; it is NOT permission to silently implement a gamecard emulator.

## Source integrity and modular structure

- Keep Atmosphère's standard paths, module responsibilities, headers, interfaces, namespaces, build targets, naming conventions and cross-file consistency intact.
- Work on `development/usb-storage-feasibility` or new dedicated topic branches. Do not edit upstream-referencing `git` objects, alter remote URLs without agreement or force-push.
- Preserve upstream original files as the baseline. Prefer the smallest change in the **appropriate existing module** when a later feature is separately approved. New components must have focused responsibilities and corresponding headers/build integration; **never** pack unrelated features into a single custom file.
- Group planning and user-facing change proposals by a single feature, but distribute implementation logically across source, headers, configuration, tests and build scripts.
- No speculative service bindings, fabricated kernel APIs, magic offsets or firmware compatibility promises. Cite exact paths/functions/commits for claims; use `git grep` before assuming a missing feature.
- Do not copy archived `fsp-usb` as-is or depend on libusbhsfs being sysmodule-safe; original upstream explicitly warns against direct sysmodule/MITM reuse.

## Existing responsibilities to respect

- `libraries/libstratosphere/source/fs/fs_game_card.cpp` and header: access gamecards **already recognized** by `fsp-srv`; no virtual-cartridge constructor.
- `libraries/libstratosphere/source/fs/fs_remote_file_system_proxy.hpp` and `fs/impl/fs_remote_device_operator.hpp`: wrappers to native filesystem IPC; these are not standalone backends.
- `libraries/libstratosphere/include/stratosphere/fssrv/`: interface declarations and access control; declarations don't prove every function is implemented.
- `stratosphere/ams_mitm/source/fs_mitm/`: established `fsp-srv` interception functionality for specified filesystem paths. Do not assume this is universal gamecard interception.
- `stratosphere/sm/` and `stratosphere/pm/`: service ACLs and system resource budgets; **never bypass or widen rights** as a shortcut.
- `fusee/`: boot, hardware setup and `nogc` physical gamecard reader protection, not a virtual cartridge.
- `emummc/`: SDMMC/eMMC virtualization for NAND, not evidence of cartridge USB emulation.
- Modern USB **host** I/O lives in external libnx `usb:hs` client code, not Atmosphère's in-tree USB **device-side** `usb:ds` helper.

## Hard scope limits for this first fork iteration

- Allowed now: separate local Git fork, source and dependency mapping, architectural risk review, docs and read-only static checks.
- NOT authorised now: changing retail firmware or live CFW, installing new sysmodules, redirecting service permissions, creating virtual gamecards, spoofing cartridge presence, XCI launch, title-rights/DRM bypass, extracting private keys or protected games, copying proprietary code.
- Do not confuse the separate `Atmosphere-USB-Feasibility-Audit/usb-readonly-probe` v0.2 NRO with this fork. That app remains untouched and awaits real USB-file test feedback.
- Any later code must be confined to a bounded approved feature with expected file-level changes, build/test plan, rollback and an explicitly confirmed runtime environment.

## Mandatory review before any implementation

1. Proposal: which function or file needs to change, which original module owns it and what remains untouched.
2. Interfaces: identify actual callers/callees from pinned source, with header and source references.
3. Service/resource feasibility: legal ACLs, memory, sessions, USB device lifetime and error behavior.
4. Compatibility: Nintendo Horizon/Atmosphère versions, application versus sysmodule context, fallbacks and fail-closed behavior.
5. Testability: no protected content; isolate ordinary harmless data and don't represent PC simulation as a Switch test.
6. Approval gate: ask for explicit approval of the particular code/hardware stage before implementation; do not infer from approval of the fork.

## Commit discipline

Small, reviewable topic commits. Prefer `git diff --check`, include a concise change log, and verify original modules remain unmodified for documentation-only stages. Avoid changes outside this repository, especially upstream reference clones or existing tester/source/firmware.

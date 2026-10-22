# Decision log — Atmosphère USB integration fork

## 2026-10-22 — F0: work inside an independent real source tree

**Decision:** Create `Desktop\Atmosphere-USB-Fork` as an independent Git clone of Atmosphère at `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8`, branch `development/usb-storage-feasibility`, and retain the official upstream remote for later synchronization.

**Reason:** The owner wants any future feature to be built with the existing Atmosphère source skeleton, module responsibilities, naming and correct calls, instead of a separate monolithic patch pretending to replace gamecard behavior.

**Kept untouched:** Original `Atmosphere-USB-Feasibility-Audit` repository and its v0.2 USB tester, the source clone in `research/upstream/`, all actual Switch/SD files, and original Atmosphère C/C++/ASM/build source at this baseline.

**Not done:** Online GitHub fork, firmware build, USB sysmodule, cartridge emulator, XCI loader, rights-bypass work, deployment to any console.

## 2026-10-22 — F1: map existing gamecard interfaces before writing implementation

**Decision:** Document actual source function ownership and call paths under `docs/usb-gamecard/`.

**Verified:** libstratosphere `fs_game_card.cpp` obtains already recognized gamecard handles/partitions and insertion state from existing filesystem-service objects. `stratosphere/ams_mitm` has an `fsp-srv` interception framework, but reviewed source does not provide a USB-backed virtual cartridge. `fusee` `nogc` is protection/disabling of physical reader. `emummc` is NAND/eMMC/SD virtualization. `usb:hs`, `usb:ds`, SX OS `usbfs` and historical `fsp-usb` are distinct interfaces.

**Unverified:** Public extension point for a synthetic gamecard, SX OS proprietary gamecard implementation, service rights for a modern safe USB sysmodule, disk/controller compatibility and virtual-cartridge feasibility. These remain explicitly unresolved.

**Next gate:** Await real USB file-read outcome from the separate v0.2 tester, and review the actual hardware/API/reliability evidence before proposing any separate opt-in USB filesystem experiment.

## Working approach

- Source pin and module map drive changes; no guessing or code placement shortcuts.
- No direct reuse of abandoned `fsp-usb` as if current.
- No modifications to physical gamecard operation in this phase.
- Each later proposal must identify exact original files, affected headers/build targets and unchanged behavior, and obtain specific owner approval.

See `SOURCE_MAP.md`, `INTERFACE_BOUNDARIES.md` and `IMPLEMENTATION_GATES.md`.

## 2026-10-22 — F0b: online fork confirmed and origin configured

**Owner action:** Created GitHub fork `https://github.com/Awetspoon/Atmosphere`.

**Verified:** GitHub reports repository ownership and push privileges for `Awetspoon`; hosted `master` matches upstream pinned Atmosphère 1.12.1 SHA `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8`. Local repository has `origin` pointing to the hosted fork and `upstream` to official Atmosphère. Complete source history remains available, local branch untouched.

**Still outstanding:** Publishing `development/usb-storage-feasibility` to the public hosted fork is a separate operation requiring the owner's approval. No GitHub branch publication, source-code runtime change, or console test was performed by this remote-connection step.

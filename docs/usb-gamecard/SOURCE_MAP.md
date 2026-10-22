# Atmosphère 1.12.1 — module ownership and gamecard API source map

**Pinned upstream baseline:** `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8`.
**Reviewed on:** 2026-10-22.
**Status:** Read-only source evidence, not an implemented virtual gamecard.

The question is whether future work could be integrated into existing Atmosphère components while maintaining their responsibilities and upstream compatibility. **Do not treat existing gamecard accessors as cartridge-emulation constructors.**

## 1. Main verified gamecard call chain

```text
Existing gamecard accessor, Atmosphère libstratosphere
  libraries/libstratosphere/source/fs/fs_game_card.cpp
      |
      +-- GetGameCardHandle()
      |     -> GetFileSystemProxyServiceObject()
      |     -> OpenDeviceOperator()
      |     -> IDeviceOperator::GetGameCardHandle()
      |
      +-- IsGameCardInserted()
      |     -> OpenDeviceOperator()
      |     -> IDeviceOperator::IsGameCardInserted()
      |
      +-- MountGameCardPartition(handle, partition)
            -> IFileSystemProxy::OpenGameCardFileSystem(...)
            -> register returned filesystem on caller mount list
                      |
                      v
Native/remote fs proxy bindings (libnx-facing wrappers)
  libraries/libstratosphere/source/fs/
      fs_remote_file_system_proxy.hpp
      impl/fs_remote_device_operator.hpp
                      |
                      v
Horizon filesystem services (fsp-srv; underlying Nintendo behaviour)
                      |
                      v
Physical gamecard / already recognized card object

This call chain does NOT create a new emulated card.
```

### Source references

| Owned component / file | Evidence | Responsibility | Safe treatment |
| --- | --- | --- | --- |
| `libraries/libstratosphere/include/stratosphere/fs/fs_game_card.hpp:22-93` | `GameCardPartition`, `GameCardHandle`, accessor declarations | Public Atmosphère **consumer** wrapper interface | Reuse in permitted contexts; no synthetic-card API exists here |
| `libraries/libstratosphere/source/fs/fs_game_card.cpp:57-69` | `GetGameCardHandle` obtains a handle through a device operator | Existing card handle | Do not replace with a USB file path |
| `libraries/libstratosphere/source/fs/fs_game_card.cpp:72-97` | `MountGameCardPartition` calls `OpenGameCardFileSystem` on FS proxy | Mount existing card partitions in a caller's namespace | Do not infer this accepts an arbitrary file or implements authentication |
| `libraries/libstratosphere/source/fs/fs_game_card.cpp:103-115` | `IsGameCardInserted` queries device operator | Query existing card insertion status | This is not a set/inject insertion method |
| `libraries/libstratosphere/source/fs/fs_remote_file_system_proxy.hpp:150-158` | `OpenGameCardStorage` is a TODO in this **remote binding**; `OpenGameCardFileSystem` forwards to `fsOpenGameCardFileSystem` | Client-side service-object binding | A TODO here is NOT evidence Nintendo's system lacks card storage |
| `libraries/libstratosphere/source/fs/impl/fs_remote_device_operator.hpp:78-97` | Forwards insertion, handle and identification queries to libnx | Client IPC adapter | Not a hardware driver or virtual insertion engine |
| `libraries/libstratosphere/include/stratosphere/fssrv/sf/fssrv_sf_i_file_system_proxy.hpp:49-50,97` | Declares `OpenGameCardStorage`, `OpenGameCardFileSystem`, `OpenGameCardDetectionEventNotifier` | Service interface contract | Declarations are not proof of a usable emulation backend |
| `libraries/libstratosphere/source/fssrv/fssrv_file_system_proxy_impl.cpp:125-130,278-280` | Some gamecard methods contain TODO/abort placeholders in this in-tree implementation | Incomplete local implementation path | Do not extrapolate to all Nintendo proprietary fsp-srv behavior |
| `libraries/libstratosphere/include/stratosphere/fssrv/impl/fssrv_access_control_bits.hpp:141-143` | Gamecard detection and raw-storage access flags | FS permission policy surface | Respect access checks; no rights bypass |

## 2. Existing Atmosphère modules adjacent to filesystem integration

| Location | Current role shown by source | What not to assume or do |
| --- | --- | --- |
| `stratosphere/fs/source/fs_main.cpp` | Initializes the filesystem proxy library in FS process context | Not a complete editable replacement of native gamecard recognition |
| `stratosphere/fs/fs.json` | FS module permissions and kernel capabilities | Do not widen service/IO rights as an experiment |
| `stratosphere/ams_mitm/source/fs_mitm/fsmitm_module.cpp:29,105` | Registers an `fsp-srv` MITM service | Registration alone does not emulate physical cartridge insertion |
| `stratosphere/ams_mitm/source/fs_mitm/fs_mitm_service.hpp` | Explicit list of intercepted filesystem calls (program data paths, SD, saves and others) | Do not assume all possible fsp-srv commands are covered |
| `stratosphere/ams_mitm/source/fs_mitm/fs_mitm_service.cpp` | Existing file/storage redirection behavior in permitted scope | Keep existing redirection behavior intact; do not mix with USB test code |
| `stratosphere/sm/source/impl/sm_service_manager.cpp:613-625` | Validates process registration and service access rights for non-initial processes | No automatic `usb:hs` access for arbitrary sysmodules |
| `stratosphere/pm/source/impl/pm_spec.cpp:36,65-115,385-393` | Memory/thread/session/event resource pool configuration | Configured budget is not free, measured memory |
| `libraries/libstratosphere/source/usb/usb_device.cpp:36-42` | Calls `usb:ds` = USB **device-side** service | **Not** the `usb:hs` host mass-storage library |
| `fusee/program/source/fusee_setup_horizon.cpp:697-768` and `docs/features/configurations.md:9-18` | `nogc` physical reader protection in specific firmware configurations | Disabling reader ≠ making a virtual cartridge |
| `emummc/README.md` and `emummc/source/emuMMC/` | Replaces SDMMC/eMMC backing for emulated NAND | emuMMC ≠ gamecard emulation, despite both referencing storage hardware |
| `Makefile`, `atmosphere.mk`, module `Makefile`s | Build targets, source integration and toolchain details | Preserve source ownership and build graph; avoid unapproved broad build-system overhaul |

## 3. Source outside this fork, for reference only

The following are separate projects, **not automatically linked to this Atmosphère checkout**:

- **switchbrew/libnx**, pinned `b156b4774fb2df7b93402169509266da7547fc4c` in the separate audit: `nx/source/services/usbhs.c:15-31` obtains Horizon **`usb:hs`**, while `nx/include/switch/services/fs.h:522,703-711` declares functions to access existing gamecard/filesystem service objects.
- **DarkMatterCore/libusbhsfs**, pinned `3b897ed6a79c910aa3f13693f17b80afb802b3b5`: ordinary homebrew USB storage + FAT-family filesystems, and an SX OS-specific `usbfs` **client shim**. Its README explicitly says the library is **not suitable for direct sysmodule/MITM use**.
- **XorTroll/fsp-usb**, archived at `19bc59ce3d6f7cace3a0f4571fa492dd0784e4d3`: historical USB filesystem server `fsp-usb` for explicit clients; no verified gamecard implementation. Its wildcard access rights are not deployment guidance.
- Proprietary SX OS file and virtual-gamecard backend: **source not available/verified** in our audit.

## 4. Call-path questions still open

- What trusted system components actually own complete card insertion, gamecard authentication, content discovery and title lifecycle on the target firmware? Only some clients/interfaces appear in this open tree.
- Are there any documented, supported, authorized extension interfaces for test-only virtual storage distinct from production gamecard paths? None verified in the pinned sources.
- Can an **opt-in non-game USB filesystem** use service resources legally/reliably without modifying title or card paths? Historical prototype exists; modern runtime feasibility unknown.
- How does an application-level USB read behave on the real original Switch dock? Our v0.2 tester still awaits a genuine USB test result.

These are research questions. **No source from this map is an approval to change card verification, bypass game rights or emulate cartridge hardware.**

## 5. Review protocol

When future work is proposed, cite the original header and source, identify caller/callee, explain unchanged behavior, list affected modules, estimate resource/compatibility risk and get explicit approval before touching implementation. Keep branches and commits bounded, and preserve ability to merge future Atmosphère upstream updates.

See `INTERFACE_BOUNDARIES.md`, `IMPLEMENTATION_GATES.md` and `DECISION_LOG.md`.

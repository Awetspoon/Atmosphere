# USB versus gamecard: interface and dependency boundaries

**Fork base:** Atmosphère 1.12.1, commit `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8`.
**Evidence:** Source in this fork plus pinned libnx / libusbhsfs / historical fsp-usb reference clones in the *separate* `Atmosphere-USB-Feasibility-Audit` project.

## 1. Three different responsibilities

```text
             ORDINARY USB HOST PATH (demonstrable source APIs)

Dock USB stick / HDD
       |
       v
Horizon USB host service ("usb:hs")
       |
       v
libnx USB host client [external library]
       |
       +---------------------------+
       |                           |
       v                           v
libusbhsfs application        Historical "fsp-usb"
USB filesystem library        separate opt-in server
       |                           |
       v                           v
files visible to              files accessible to
that homebrew app              clients of "fsp-usb"


          EXISTING PHYSICAL GAMECARD PATH (observed client APIs)

Recognized physical gamecard / native FS services
       |
       v
Horizon "fsp-srv" gamecard objects
       |
       v
libnx and Atmosphère fs accessors:
  insertion query / gamecard handle / partition filesystem
       |
       v
Applications that already have the relevant authorized access


                  SX OS HISTORY (PROPRIETARY BACKEND UNKNOWN)

SX OS file client -> "usbfs" -> [closed-source USB service]
                                               |
                              [UNVERIFIED linkage/implementation]
                                               |
                                               ?
                                               |
                            Historical emulated gamecard behavior

A filesystem object returned by any USB API is NOT automatically
a cartridge, and the checked source supplies no trusted adapter.
```

The diagram distinguishes **verified source-level interfaces** from **unknown implementation**. It is not instructions for intercepting or spoofing the gamecard system.

## 2. Existing wrappers are consumers, not cartridge factories

`libraries/libstratosphere/source/fs/fs_game_card.cpp` obtains an existing gamecard handle through a device operator and delegates partition opening to the filesystem proxy. Its `IsGameCardInserted()` method **reads** the state. It does not expose a method to set insertion state, mount a USB path as a gamecard, or provide a synthetic gamecard device.

`libraries/libstratosphere/source/fs/fs_remote_file_system_proxy.hpp` is a client adapter to libnx; it is not a complete native gamecard backend. Some related in-tree filesystem-proxy methods are declared as TODO, so we must distinguish interface declarations, local incomplete implementations and Nintendo-owned services.

## 3. Existing FS MITM is not the missing cartridge feature

Atmosphère `stratosphere/ams_mitm/source/fs_mitm/fsmitm_module.cpp` registers interception of `fsp-srv`. The `fs_mitm_service.hpp` method list focuses on specific file data, SD, save and BIS operations. A service interception framework alone does **not** establish a working physical-card protocol replacement or legitimate security model.

Forcing a custom file service to pretend to be the gamecard subsystem may affect boot, suspend/resume, existing cartridges, savedata and content lifecycle. None of those compatibility paths have been validated by this project. The current scope does not authorize modifying core filesystem/gamecard service behavior.

## 4. EmuMMC and nogc are separate hardware concerns

The `emummc/README.md` describes an SDMMC driver replacement and eMMC/SD storage redirection. It addresses emulated NAND and SD-backed storage, not arbitrary cartridge emulation from USB.

The `nogc` setting under `fusee` disables the physical reader in certain firmware scenarios to protect card-reader firmware. **Disabling a reader does not create a virtual cartridge**.

## 5. Separate opt-in USB service is the narrower research path

There is genuine historic source for an **opt-in USB filesystem service** (`fsp-usb`, now abandoned), and app-level USB storage libraries remain available. The abandoned project's README and actual IPC command list are not fully identical, it contains broad permission requests, and it has no verified modern firmware support.

The safe, measurable concept to review later is **ordinary user-owned data readable by a consenting homebrew client** — not Nintendo software, not a cartridge, not an XCI title source. Any proposed service must be designed for compatibility with current authorization, resource limits, disconnect handling and explicit read-only capability where applicable. There is no working service in this fork at present.

## 6. Open unknowns and data needed

| Gap | What we have | What is still missing |
| --- | --- | --- |
| USB real-world access on the original Switch | v0.2 ordinary read-only NRO compiles; 10 PC simulation passes; v0.1 app launched | v0.2 physical drive enumeration, fixed-file read and clean exit |
| Modern user service permissions | Atmosphère SM checks allowed service names | Per-process authorization and allowed service hosting for a hypothetical new module |
| System module resource headroom | PM resource group configs; upstream libusbhsfs 1 MiB/device buffer warning | Actual free RAM, sessions, threads and safe lifecycle measured on target firmware |
| Existing-card access APIs | Gamecard handle/partition/insertion query | A documented *supported* extension point for a virtual card; none identified |
| SX OS implementation | Public `usbfs` client and historic feature release notes | Verified proprietary implementation and its legality/compatibility; not acquired |
| Distribution rights | Atmosphère GPLv2 and external libraries with differing licenses | Final license compliance before any later publicly distributed derivative |

## 7. Read-first references

- `SOURCE_MAP.md` (local file/function ownership)
- `IMPLEMENTATION_GATES.md` (what is and is not approved)
- `GITHUB_FORK_SETUP.md` (upstream/personal remote distinction)
- Separate audit `Desktop/Atmosphere-USB-Feasibility-Audit/docs/PHASE7_INTERFACE_COMPARISON.md` when viewed from the Desktop sibling project

**Conclusion:** We can legitimately maintain a fork that stays connected to Atmosphère's real source tree. That enables controlled research and future modular contributions, but **forking does not itself solve native gamecard emulation**.

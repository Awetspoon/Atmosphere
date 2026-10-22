# GitHub fork connection and publishing the development branch

**Status: GitHub fork created and connected locally on 22 October 2026.**

- **Hosted fork:** https://github.com/Awetspoon/Atmosphere
- **Original official project:** https://github.com/Atmosphere-NX/Atmosphere
- **Local source checkout:** `Desktop\Atmosphere-USB-Fork`
- **Local development branch:** `development/usb-storage-feasibility`
- **Local branch currently contains:** project rules and source/interface maps; no original Atmosphère program source changes.
- **Hosted fork's `master`:** verified to match the pinned Atmosphère 1.12.1 base commit `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8`.
- **Development branch on GitHub:** published using the connected GitHub integration on 2026-10-22. GitHub publication commit `7b303603f02a543896896454eb82905723a77704` exactly matches the original local development tree `8f5c5fe1da76ddc77630b7a34d847c5e0605372d` (8 documentation/test-check files).

## Remotes are correctly separated

```text
origin    https://github.com/Awetspoon/Atmosphere.git      YOUR fork
upstream  https://github.com/Atmosphere-NX/Atmosphere.git  OFFICIAL Atmosphère
```

These are distinct repositories. Fetching `upstream` downloads reference updates into Git; it does not modify the work tree, merge changes or publish anything. `origin` is the intended publication destination for your own reviewed commits.

To see the configuration from Windows PowerShell:

```powershell
$git = 'C:\Program Files\Git\cmd\git.exe'
$repo = Join-Path $env:USERPROFILE 'Desktop\Atmosphere-USB-Fork'
& $git -C $repo remote -v
& $git -C $repo status --short --branch
& $git -C $repo log -1 --format='%h %s'
```

## Branch published; future publishing uses explicit approved changes

The owner authorised publication of the documentation-only development branch. The local Windows Git client's credential helper was unable to authenticate in non-interactive mode; the already-connected, authorised GitHub integration published the same eight files directly to `origin`. Their Git blob hashes and complete tree SHA were checked against the desktop copies before publication.

The GitHub commit identity differs from the two local documentation commits because the GitHub API created a new publication commit. The desktop checkout will be synchronized to the published commit using a protected local history backup, leaving source content unchanged. The official `upstream` repository and hosted fork's `master` were not written to.

Future publication of **approved new work** should target `origin` only. GitHub/Windows sign-in may be needed for direct desktop Git pushes. Do not share passwords, access tokens or game files.

To inspect the published branch:

```powershell
$git = 'C:\Program Files\Git\cmd\git.exe'
$repo = Join-Path $env:USERPROFILE 'Desktop\Atmosphere-USB-Fork'
& $git -C $repo remote -v
& $git -C $repo log -1 --oneline
& $git -C $repo status --short --branch
```

## Reviewing official Atmosphère updates

```powershell
$git = 'C:\Program Files\Git\cmd\git.exe'
$repo = Join-Path $env:USERPROFILE 'Desktop\Atmosphere-USB-Fork'
& $git -C $repo fetch upstream
& $git -C $repo log --oneline --max-count=8 upstream/master
& $git -C $repo log --oneline HEAD..upstream/master
```

**Don't automatically merge/rebase** into the development branch. Inspect official changes and version compatibility before integrating anything.

## Source/project separation

The sibling `Desktop\Atmosphere-USB-Feasibility-Audit` research repository still contains the experimental v0.2 ordinary USB test application. That application is **not** this fork, and its hardware USB-read result remains unverified until the tester reports back.

See `PROJECT_START_HERE.md`, `AGENTS.md`, `SOURCE_MAP.md` and `IMPLEMENTATION_GATES.md` before proposing edits to Atmosphère internals.

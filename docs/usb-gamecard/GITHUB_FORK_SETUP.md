# GitHub fork connection and publishing the development branch

**Status: GitHub fork created and connected locally on 22 October 2026.**

- **Hosted fork:** https://github.com/Awetspoon/Atmosphere
- **Original official project:** https://github.com/Atmosphere-NX/Atmosphere
- **Local source checkout:** `Desktop\Atmosphere-USB-Fork`
- **Local development branch:** `development/usb-storage-feasibility`
- **Local branch currently contains:** project rules and source/interface maps; no original Atmosphère program source changes.
- **Hosted fork's `master`:** verified to match the pinned Atmosphère 1.12.1 base commit `6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8`.
- **Development branch on GitHub:** not yet pushed or published as of this document update.

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

## Publication remains a separate action

When you **explicitly approve publishing the local development branch** on your own public GitHub fork, and Git authentication is available in the local Git client, the bounded publication command is:

```powershell
$git = 'C:\Program Files\Git\cmd\git.exe'
$repo = Join-Path $env:USERPROFILE 'Desktop\Atmosphere-USB-Fork'
& $git -C $repo push --set-upstream origin development/usb-storage-feasibility
```

This targets your `origin`, **not** the official upstream. Never issue `git push upstream`, force-push, or publish Nintendo game files, firmware, keys, or private tester data.

If a GitHub sign-in prompt appears during an approved push, complete it on your own trusted computer. Do not share your credentials or a personal access token in chat.

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

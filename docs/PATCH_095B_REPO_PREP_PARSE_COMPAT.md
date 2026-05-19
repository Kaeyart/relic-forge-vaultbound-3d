# 095B — Repo Prep + Parse Compatibility

This is the day-end stabilization patch.

It repairs common parse issues from the recent UI rebuild by adding missing compatibility helpers only if they are absent.

It also installs:

`tools/create_new_github_repo_095b.sh`

Usage:

```bash
cd /home/kaey/Desktop/RelicForgeVaultbound3D
tools/create_new_github_repo_095b.sh relic-forge-vaultbound-3d private
```

The script requires GitHub CLI:

```bash
gh auth status
```

If `origin` already exists, the script stops instead of accidentally pushing to the wrong repo.

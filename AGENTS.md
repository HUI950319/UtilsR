# UtilsR package instructions

These rules apply to work under `UtilsR/` in addition to the repository-root
`AGENTS.md`.

## Function authoring

- Plot functions use positional arguments `data, x, y, group` first.
- Return the ggplot / patchwork object directly.
- Roxygen and code comments are written in English.
- Use `@family`. With the current non-Markdown roxygen configuration, link
  related functions as `\code{\link{FunctionName}()}`; preserve DESCRIPTION's
  configuration instead of enabling Markdown for a local edit.
- Every export has a self-contained `@examples` block using simulated data.
- Check optional dependencies with `requireNamespace()`.
- Add dependencies to DESCRIPTION and new R files to Collate when applicable.
- Add every export to `_pkgdown.yml`.
- Documentation generation and installation follow
  [the shared change workflow](../r-function-dev.md) §5 and
  [execution details](../.claude/docs/r-package-execution-workflow.md).

## Unified plotting parameters

| Concept | Parameter |
|---|---|
| Input and axes | `data`, `x`, `y` |
| Groups | `group`, `group2`, `group_levels` |
| Aesthetics | `colors`, `shapes`, `point_size`, `point_alpha` |
| Labels | `xlab`, `ylab`, `title` |
| Reference / ellipse | `show_refline`, `show_ellipse` |
| Regression | `show_regression`, `reg_method` |
| Correlation | `show_cor`, `cor_method` |
| Annotation | `annot_text`, `annot_size` |
| Marginal plot | `marginal_type` |
| Legend | `legend_pos`, `legend_theme` |
| Theme | `theme_use` |
| Saving (new integrations) | `save = list()` |

Do not introduce alternative names for an existing concept without approval.
For new or changed saving interfaces, follow the shared
[save contract](../r-function-dev.md) §6. Retain existing `filename`, `width`,
`height` and `dpi` interfaces unless their migration is explicitly authorized.

## PlotXxx workflow

Use the seven-step workflow and templates:

- [PlotXxx workflow](../.claude/docs/plotxxx-workflow-detail.md)
- [Tutorial YAML template](../.claude/docs/tutorial-yaml-template.md)

The workflow covers new script-to-function deliveries. Existing-function fixes
use the shared local change workflow; tests cover affected behavior without a
fixed case count. Do not copy templates or tutorial triggers into this file.

Current PlotXxx implementations live under `../test/Plot*/`; inspect the
filesystem rather than maintaining a duplicate inventory here.

## Testing

- Layer, position and scale changes also run their focused tests against the
  minimum versions in DESCRIPTION: ggplot2 3.5.0 with patchwork 1.3.0 in a
  scratchpad library (patchwork 1.3.2 needs a newer ggplot2). A group-only
  jitter-dodge in `fmt_point()` failed only on 3.5.0 (2026-10-17, 0cfc870).
- Code that inspects mapping expressions walks the call structure:
  `rlang::call_name()` returns `NULL` for anonymous and `.env$f()` calls,
  `all.names()` also matches a column named `stage`, and calls such as
  `1 + stage(y)` nest. Test a new check with these cases (2026-10-17
  `fmt_boxplot()`: 7862e14 missed the `NULL` case, fixed in 7945bd6).
- Until a one-time roxygen sync lands, `document()` also reorders `NAMESPACE`,
  rewraps `fmt_boxplot.Rd` and rewrites `@family` links in several Rd files
  (2026-10-18, four sessions). Restore those hunks unless the change is yours.

## CI and pkgdown checklist

Before pushing, follow the root Git rules and stage only task-owned paths or
hunks. Apply the shared change-type exemptions; documentation-only rule changes
do not trigger package builds or pkgdown checks.

When exports, package metadata, examples or site configuration change:

1. Confirm affected exports are listed in `_pkgdown.yml`.
2. Do not use `:::` for exported objects in vignettes.
3. When a package build is required, use a clean location:

```bash
wsl -d Ubuntu-22.04 -- bash -c \
  'cd /tmp && R CMD build /mnt/e/Rpackage/UtilsR --no-build-vignettes'
```

4. For export/index changes, check pkgdown export coverage:

```bash
wsl -d Ubuntu-22.04 -- bash -c \
  'cd /mnt/e/Rpackage/UtilsR &&
   grep "^export(" NAMESPACE | sed "s/export(//;s/)//" | sort > /tmp/exp.txt &&
   grep -E "^\s+-\s+\w" _pkgdown.yml | sed "s/.*- //" | sort > /tmp/listed.txt &&
   comm -23 /tmp/exp.txt /tmp/listed.txt'
```

Empty output means full coverage.

The site is built by `.github/workflows/pkgdown.yaml` on pushes to master.
Dependency resolution uses `dependencies: '"hard"'` and an explicit list of
public example packages, so private `RegR` and `ToyData` Suggests are not
required. Examples using them must check package availability. A workstation
build remains available:

```bash
wsl -d Ubuntu-22.04 -- bash -c \
  'cd /mnt/e/Rpackage/UtilsR && Rscript tools/build-site.R --deploy'
```

Without `--deploy` it only refreshes `docs/`. It needs pkgdown >= 2.2.0 and
stops with install instructions when that is missing.

## Git

Repository identity:

```bash
git config user.name "HUI950319"
git config user.email "ouyanghui950319@gmail.com"
```

Use local `git` and WSL `gh`; never use GitHub MCP write APIs.
Before push, follow the root `AGENTS.md` signature and identity checks.

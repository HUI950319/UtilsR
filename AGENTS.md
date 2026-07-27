# UtilsR package instructions

These rules apply to work under `UtilsR/` in addition to the repository-root
`AGENTS.md`.

## Function authoring

- Plot functions use positional arguments `data, x, y, group` first.
- Return the ggplot / patchwork object directly.
- Roxygen and code comments are written in English.
- Use `@family` and link related functions with `[FunctionName()]`.
- Every export has a self-contained `@examples` block using simulated data.
- Check optional dependencies with `requireNamespace()`.
- Add dependencies to DESCRIPTION and new R files to Collate when applicable.
- Add every export to `_pkgdown.yml`.
- After signature or roxygen changes, run `devtools::document("UtilsR")`.

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
| Output | `filename`, `width`, `height`, `dpi` |

Do not introduce alternative names for an existing concept without approval.

## PlotXxx workflow

Use the seven-step workflow and templates:

- [PlotXxx workflow](../.claude/docs/plotxxx-workflow-detail.md)
- [Tutorial YAML template](../.claude/docs/tutorial-yaml-template.md)

The workflow covers source inspection, `test/PlotXxx/`, implementation, at
least five test cases, WSL testing, Rmd tutorial generation, and PDF rendering.
Do not copy the full templates into this file.

Current PlotXxx implementations live under `../test/Plot*/`; inspect the
filesystem rather than maintaining a duplicate inventory here.

## CI and pkgdown checklist

Before pushing:

1. Stage changed `R/*.R`, `man/*.Rd`, NAMESPACE, DESCRIPTION, and data files.
2. Confirm every export is listed in `_pkgdown.yml`.
3. Do not use `:::` for exported objects in vignettes.
4. Build in a clean location:

```bash
wsl -d Ubuntu-22.04 -- bash -c \
  'cd /tmp && R CMD build /mnt/e/Rpackage/UtilsR --no-build-vignettes'
```

5. Check pkgdown export coverage:

```bash
wsl -d Ubuntu-22.04 -- bash -c \
  'cd /mnt/e/Rpackage/UtilsR &&
   grep "^export(" NAMESPACE | sed "s/export(//;s/)//" | sort > /tmp/exp.txt &&
   grep -E "^\s+-\s+\w" _pkgdown.yml | sed "s/.*- //" | sort > /tmp/listed.txt &&
   comm -23 /tmp/exp.txt /tmp/listed.txt'
```

Empty output means full coverage.

CI installs dependencies but not UtilsR itself. The workflow therefore runs
`R CMD INSTALL --no-build-vignettes .` with `install=FALSE`.

## Git

Repository identity:

```bash
git config user.name "HUI950319"
git config user.email "ouyanghui950319@gmail.com"
```

Use local `git` and WSL `gh`; never use GitHub MCP write APIs.
Before push, follow the root `AGENTS.md` signature and identity checks.

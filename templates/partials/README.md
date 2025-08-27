Template partials

This directory contains modular template fragments (partials) used by the repository's
templates and chezmoi configuration. Put small, reusable pieces of templates here,
organized by subdirectory (platforms, profiles, shell, tools).

Why this directory?
- Previously partials lived under `_partials/`. They were moved to `templates/partials/`
  to make the repo layout clearer and avoid confusion with other top-level directories.

Editing guidance
- Edit files under `templates/partials/` when you want to change shared template
  fragments. Keep fragments small and focused.
- When adding a new partial, place it in the appropriate subfolder and update any
  templates that include it.

Migration note
- If you are upgrading from an older checkout that used `_partials/`, update any
  third-party scripts that reference `_partials` to `templates/partials`.

Automation
- The repository's validation script will fail if any `_partials` references are
  detected to prevent regressions.

Happy templating!

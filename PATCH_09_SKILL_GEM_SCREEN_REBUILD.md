# patch_09_skill_gem_screen_rebuild

Focused UI pass for the Skill Gems screen.

Canonical files replaced:
- `scripts/ui/panels/SkillGemPanel3D.gd`
- `scenes/ui/panels/SkillGemPanel3D.tscn`

Intent:
- Left: active skill slots.
- Center: selected skill, metrics, support sockets, behavior preview.
- Right: compatible supports and spirit reservation.
- Footer: selected skill rules summary.

Rollback is available in `.patch_backups/patch_09_skill_gem_screen_rebuild_*`.

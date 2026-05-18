# Patch 087I — Combat Arena Wall Build Repair

Fixes the 3D combat arena crash caused by reading `.z` from a `MeshInstance3D` while building arena walls.

Also converts arena walls/floor/blockers into StaticBody3D-backed box props where appropriate so the arena foundation is cleaner for future collision/navigation work.

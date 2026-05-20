# Active Runtime Layers — 097B

Runtime layers currently act as compatibility bridges while the game is still moving fast.

## Layer order

1. `VisualFoundationLayer096A`
2. `HubGreyboxPass096B`
3. `CombatArenaGreyboxPass096C`
4. `SkillVFXLayer096D`
5. `EnemyReadabilityLayer096E`
6. `LootPresentationLayer096F`
7. `CombatFeedbackLayer096G`
8. `CombatDirectorLayer097A` if installed

## Strategy

`RuntimeLayerManager3D.gd` is now the consolidation point.

Future target:

- `GameRoot3D.gd` owns core game state and scene routing.
- `RuntimeLayerManager3D.gd` owns temporary runtime visual/system layers.
- Final production scenes gradually replace runtime-generated greybox pieces.

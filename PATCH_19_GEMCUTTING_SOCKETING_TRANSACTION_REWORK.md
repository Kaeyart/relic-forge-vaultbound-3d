# patch_19_gemcutting_socketing_transaction_rework

This patch replaces the previous vague gem buttons with explicit transaction-based gem gameplay.

## Core model
- 9-row equipped gem page.
- 5-slot hotbar binding layer.
- Real uncut active/support/spirit gem items.
- Carving is two-step: select uncut gem, then choose target output.
- Support socketing is UID-based: select active/spirit gem, select support gem, click socket.
- Occupied support sockets can be clicked to unsocket.
- Spirit gems can be toggled and reserve Spirit.
- Active and spirit gems start with 2 support sockets.
- Every 5 gem levels gives +1 support socket.
- Maximum support sockets: 6.
- The old active_skill_slots mirror is still maintained so HUD/combat compatibility survives.

## Test flow
1. Open Skill Gems.
2. Click an Uncut Skill Gem.
3. Click a Carve target, such as Fireball or Ember Mine.
4. Confirm a real gem appears on the equipped gem page or inventory.
5. Click a support gem.
6. Click an empty support socket or Socket Selected Support.
7. Confirm behavior preview changes.
8. Click a spirit gem and Toggle Selected Spirit Gem.
9. Bind a selected active gem to hotbar 1-5.
10. Enter combat and cast the bound hotbar skill.

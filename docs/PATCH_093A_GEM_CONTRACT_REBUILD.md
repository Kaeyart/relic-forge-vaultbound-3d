# 093A — Gem Contract Rebuild

This patch makes gems obey one explicit ARPG contract.

There are exactly three physical inventory gem item types: active, support, and spirit.

Active gems install into active skill slots, keep level/XP/quality/supports, start with 2 support sockets, and unlock +1 socket every 5 gem levels up to 6.

Support gems socket into active gems or spirit gems.

Spirit gems install into spirit slots, reserve spirit when enabled, and can also hold support gems.

Quality is preserved and exposes effect data. Active quality currently grants damage scaling and projectile-style active gems gain extra projectiles at high quality. Spirit quality improves reservation efficiency.

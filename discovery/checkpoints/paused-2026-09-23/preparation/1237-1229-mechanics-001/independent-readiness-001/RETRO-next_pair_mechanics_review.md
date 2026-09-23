# next_pair_mechanics_review retrospective

What worked well: actual consuming `_spray_case` inspection found donor source-ID literals that donor-equality checks intentionally preserved; full source-map rehash found zero drift. The blocker was identified before engine launch.

What did not work well: preparation verified unchanged generic function bodies without isolating target-dependent identity literals. A broad plan print and an attempted spray-controller path lookup added avoidable output; that guessed path was absent and established no evidence. No runtime or timing improvement is claimed.

What to change next time: in the existing readiness diff review, compare every target-dependent callback/decal identity literal against its actual producer, even inside otherwise unchanged donor functions. MAIN LEARNINGS already requires actual consumer/producer comparison; this is a concrete recurrence to fold into that existing lesson at the later authorized documentation checkpoint, without source writes now. Preserve this HOLD and frozen preimage; do not repair or launch after the owner's finish-in-flight-and-stop request.

Round outcome: file readiness HOLD; only READINESS.md and this named RETRO written under independent-readiness-001. Existing sealed discovery/RETRO_LOG.md intentionally remains exact. No engine/build/test/Git/source mutation or child agents.

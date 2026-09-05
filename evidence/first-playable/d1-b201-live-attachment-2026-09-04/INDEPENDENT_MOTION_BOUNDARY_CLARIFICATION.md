# Independent motion-boundary clarification — B201 `w34313545`

Motion-boundary clarification — The immutable motion log contains 360
consecutive grounded, in-boundary, exact-receiver samples over the declared
6.0-second input interval (physics-frame range `131..491`; process/movie range
`65..245`). Its first sample is `51.9999962 m` outward and its 360th sample is
`28.2470646 m` outward; those two sampled positions are `23.7529758 m` apart in
XZ and close `23.7529316 m` along the inward normal. The separately recorded
top-level end position is intentionally a post-input braking endpoint: after
`move_forward` was released, the harness waited 12 additional physics frames,
reaching `28.1209736 m` outward and `23.8790226 m` XZ displacement from the
first sampled position. Therefore `28.121 m / 23.879 m` describe the
post-release endpoint, not the final sample inside the 360-sample/6-second
useful interval.

This boundary correction does not weaken the core continuous player-motion
proof: every one of the 360 interval samples is grounded, in bounds, aimed
first at `building:w34313545:wall`, and camera-basis unchanged, with zero
player/camera transform writes and zero recoveries after input began. All
original sealed evidence and review bytes remain immutable; this separate
clarification narrows their endpoint wording without altering the visual
recognition verdict or `+1` unit decision.

Finding and wording independently approved by `/root/b201_final_audit` on
2026-09-05. This supplemental note was created after the sealed capture and
review; it is not a replacement for either record.

Here's a parameterized, fully unrolled (combinational) version of the logic. Each loop iteration `i` becomes its own `generate` block. That block reads `w[i-1]` and `w[i-Nk]`, which are the outputs of earlier "iterations", and produces `w[i]`. The result is a chain where each word is built from the words computed before it.

(code: see word_expand.sv)

### How the unrolling works

- **All conditions are settled at elaboration time.** `i`, `Nk` and `Nr` are all constants, so `i % Nk == 0` and `Nk > 6 && i % Nk == 4` are decided before synthesis. Each stage only builds the hardware its branch needs:
  - `i % Nk == 0`: a `module2` instance feeding a `module1` instance, then an XOR with `rcon[i/Nk]`.
  - `Nk > 6 && i % Nk == 4`: one `module1` instance.
  - Otherwise: a wire that passes `temp` through unchanged.
- **Each stage feeds the next.** `w[i]` depends on `w[i-1]` (the previous stage) and `w[i-Nk]`. This is the same data flow as the `while` loop, laid out spatially instead of over time.
- **The loop counter disappears.** It turns into the `genvar`, so there's no counter or state machine.

### Assumptions to check against your setup

1. **`module1` and `module2` ports.** I assumed both take a 32-bit word and return a 32-bit word, with ports named `in` and `out`. Rename `.in(...)` and `.out(...)` to match the real port names.
2. **Key byte ordering.** `key[4*i]` goes in the most significant byte of `w[i]`, and `key[4*i+3]` goes in the least significant byte. If your key arrives as one packed vector, say `logic [32*Nk-1:0] key_flat`, you can map it with something like `assign w[i] = key_flat[32*Nk-1-32*i -: 32];`. Swap the order if your convention is the other way round.
3. **`Rcon` is an input.** Its contents weren't specified, so the table comes in as the port `rcon`. Only the indices `Nk/Nk` through `(4*Nr+3)/Nk` are actually used. You can tie it to constants in the parent module or turn it into a `localparam` array if you know the values.
4. **This is purely combinational.** Every word `w[0..4*Nr+3]` is computed at once, which makes for a long logic path at large `Nr`. If timing or area is a problem, the same loop body can be made sequential: keep the last `Nk` words in registers and produce one new `w[i]` per clock with a counter. That needs only one `module1` and one `module2` instance, at the cost of `4*Nr+4-Nk` cycles. I can write that version if you'd like it.

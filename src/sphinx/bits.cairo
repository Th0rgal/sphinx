from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc

namespace Bits:
    func merge{range_check_ptr}(
        a : felt*, a_nb_bits : felt, b : felt*, b_nb_bits : felt
    ) -> (merged : felt*, merged_nb_bits : felt):
        # b must not be null
        alloc_locals
        let (merged) = alloc()
        let (a_full_words, a_rest) = unsigned_div_rem(a_nb_bits, 32)
        memcpy(merged, a, a_full_words)
        let (b_full_words, b_rest) = unsigned_div_rem(b_nb_bits, 32)
        # if a is exactly made of 32-bits words
        if a_rest == 0:
            local exact_len
            # if b is exactly made of 32-bits words
            if b_rest == 0:
                exact_len = b_full_words
            else:
                exact_len = b_full_words + 1
            end
            memcpy(merged + a_full_words, b, exact_len)
            return (merged, a_nb_bits + b_nb_bits)
        end

        # this contains a_rest bits at the left
        let left = a[a_full_words]
        # this contains 32-a_rest bits at the right
        let (right) = erase_last([b], a_rest)
        assert merged[a_full_words] = left + right

        let shift = 32 - a_rest
        extract(b, shift, b_nb_bits - shift, merged + a_full_words + 1)
        return (merged, a_nb_bits + b_nb_bits)
    end

    func extract{range_check_ptr}(
        input : felt*, start : felt, len : felt, output : felt*
    ) -> ():
        # Write len bits from input to output, starting at start.
        #
        # Parameters:
        #    input: The input bits as 32-bit integers
        #    start: The start bit (included)
        #    len: The number of bits to write
        #    output: Where to write the output
        if len == 0:
            return ()
        end
        alloc_locals

        let (test) = is_le(len, 32)
        local to_dump
        if test == TRUE:
            assert to_dump = len
        else:
            assert to_dump = 32
        end

        let (words_len, shift) = unsigned_div_rem(start, 32)
        let (test2) = is_le(to_dump + shift, 32)
        # erase the shift first bits and move to the left
        let (left) = Bits.erase_first(input[words_len], shift)
        local right
        if test2 == FALSE:
            # erase the shift last bits and move to the right
            let (value) = Bits.erase_last(input[words_len + 1], 32 - shift)
            assert right = value
        else:
            assert right = 0
        end
        # erase without shifting
        let (powed) = pow2(32 - to_dump)
        let (erased_and_shifted, _) = unsigned_div_rem(left + right, powed)
        assert [output] = erased_and_shifted * powed
        return extract(input, start + to_dump, len - to_dump, output + 1)
    end

    func erase_last{range_check_ptr}(word : felt, n : felt) -> (
        word : felt
    ):
        # Erase the last n bits of number (and shift to the right).
        #
        # Parameters:
        #    word: A 32-bits word
        #    n: The amount of bits to erase
        #
        # Returns:
        #    word: The word with the last n bits erased.
        let (divisor) = pow2(n)
        let (p, _) = unsigned_div_rem(word, divisor)
        return (p)
    end

    func erase_first{range_check_ptr}(word : felt, n : felt) -> (
        word : felt
    ):
        # Erase the first n bits of number (and shift to the left).
        #
        # Parameters:
        #    word: A 32-bits word
        #    n: The amount of bits to erase
        #
        # Returns:
        #    word: The word with the first n bits erased.
        alloc_locals
        let (divisor) = pow2(32 - n)
        let (_, r) = unsigned_div_rem(word, divisor)
        let (multiplicator) = pow2(n)
        return (multiplicator * r)
    end

    func pow2{range_check_ptr}(exp : felt) -> (res : felt):
        return _pow2(exp, 1)
    end

    func _pow2{range_check_ptr}(exp : felt, acc : felt) -> (
        res : felt
    ):
        if exp == 0:
            return (acc)
        end
        return _pow2(exp - 1, 2 * acc)
    end
end

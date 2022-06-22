from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_le

namespace Bits:
    func extract{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
        input : felt*, output : felt*, start : felt, len : felt
    ) -> ():
        # Write len bits from input to output, starting at start.
        #
        # Parameters:
        #    input: The input bits as 32-bit integers
        #    output: Where to write the output
        #    start: The start bit (included)
        #    len: The number of bits to write

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

        # erase the shift first bits and move to the left
        let (left) = Bits.erase_first(input[words_len], shift)
        local right
        if shift != 0:
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
        return extract(input, output + 1, start + to_dump, len - to_dump)
    end

    func erase_last{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(word : felt, n : felt) -> (
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

    func erase_first{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(word : felt, n : felt) -> (
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
        let (powed) = pow2(32 - n)
        let (erased) = bitwise_and(word, powed - 1)
        let (multiplicator) = pow2(n)
        return (multiplicator * erased)
    end

    func pow2{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(exp : felt) -> (res : felt):
        return _pow2(exp, 1)
    end

    func _pow2{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(exp : felt, acc : felt) -> (
        res : felt
    ):
        if exp == 0:
            return (acc)
        end
        return _pow2(exp - 1, 2 * acc)
    end
end

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.alloc import alloc

func sha256{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(input : felt*, n_bits : felt) -> (output : felt*):
    # Computes SHA256 of 'input'. See https://en.wikipedia.org/wiki/SHA-2
    #
    # Parameters:
    #   input: array of 32-bit words
    #   n_bits: number of bits to consider from input
    #
    # Returns:
    #   output: an array of 8 32-bit words (big endian).

    alloc_locals

    # Initialize hash values
    let (work : felt*) = alloc()
    assert work[0] = 0x6a09e667
    assert work[1] = 0xbb67ae85
    assert work[2] = 0x3c6ef372
    assert work[3] = 0xa54ff53a
    assert work[4] = 0x510e527f
    assert work[5] = 0x9b05688c
    assert work[6] = 0x1f83d9ab
    assert work[7] = 0x5be0cd19

    # Pre-processing (Padding)

    let (len_chunks : felt, chunks : felt**) = create_chunks(input, n_bits, 0)

    return for_all_chunks(work, 0, chunks)
end

func create_chunks{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(input : felt*, n_bits : felt, bits_prefix : felt) -> (len_chunks : felt, chunks : felt**):
    # Creates an array of chunks of length 512 bits (16 32-bit words) from 'input'.
    #
    # Parameters:
    #   input: array of 32-bit words
    #   n_bits: length of input
    #   bits_prefix: number of bits to skip

    alloc_locals

    if n_bits == bits_prefix:
        let (chunks : felt**) = alloc()
        return (0, chunks)
    end

    let (chunk : felt*) = alloc()

    # if that's the last chunk
    # we need to append a single bit and the length as a 64 bit integer
    # so that's 512-65=447 bits free
    let (test) = is_le(n_bits - bits_prefix, 447)
    if test == TRUE:
        let (len_chunks : felt, chunks : felt**) = create_chunks(input, n_bits, n_bits)
        assert chunks[len_chunks] = chunk
        dump_bits(chunk, input, n_bits - bits_prefix, bits_prefix)
        # copy bits from input shifted by bits_prefix (needs to move bits)
        return (len_chunks + 1, chunks)
    end

    # if 448 <= n_bits-bits_prefix <= 511
    let (test) = is_le(n_bits - bits_prefix, 511)
    if test == TRUE:
        let (len_chunks : felt, chunks : felt**) = create_chunks(input, n_bits, n_bits)
        return (len_chunks + 1, chunks)
    end

    # if 512 <= n_bits
    # 512/ 32 = 16
    let (len_chunks : felt, chunks : felt**) = create_chunks(input, n_bits, bits_prefix + 512)
    return (len_chunks + 1, chunks)
end

func dump_bits{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(output : felt*, words : felt*, bits_len : felt, bits_prefix : felt) -> ():
    alloc_locals
    if bits_len == 0:
        return ()
    end

    local to_dump
    let (test) = is_le(bits_len, 32)
    if test == TRUE:
        to_dump = bits_len
    else:
        to_dump = 32
    end
    let (q, r) = unsigned_div_rem(bits_prefix, 32)
    if r == 0:
        let (powed) = pow(2, 32 - to_dump)
        let (erased) = bitwise_and(words[q], (powed - 1) * powed)
        assert [output] = erased / powed
        return dump_bits(output + 1, words, bits_len - to_dump, bits_prefix + to_dump)
    end

    # copy the last 32-r bits of words[q] and r first bits of words[q+1]
    let (_mask) = pow(2, 32 - r)

    let (test) = is_le(to_dump, 32 - r)
    if test == TRUE:
        let (too_much : felt) = pow(2, 32 - r - to_dump)
        let mask1 : felt = _mask - 1 - too_much
        let (alone) = bitwise_and(words[q], mask1)
        let alone_shifted = alone * _mask
        assert [output] = alone_shifted
        return dump_bits(output + 1, words, bits_len - to_dump, bits_prefix + to_dump)
    end
    let mask1 : felt = _mask - 1
    let (left) = bitwise_and(words[q], mask1)
    let left_shifted = left * _mask

    let (right_shifted, _) = unsigned_div_rem(words[q + 1], _mask)

    if to_dump == 32:
        assert [output] = left_shifted + right_shifted
        return dump_bits(output + 1, words, bits_len - 32, bits_prefix + 32)
    end
    let (_mask2) = pow(2, 32 - to_dump)
    let (right) = bitwise_and(right_shifted, _mask2 - 1)
    assert [output] = left_shifted + right
    return dump_bits(output + 1, words, bits_len - 32, bits_prefix + 32)
end

func pow(base : felt, exp : felt) -> (res : felt):
    return _pow(base, exp, 1)
end

func _pow(base : felt, exp : felt, acc : felt) -> (res : felt):
    if exp == 0:
        return (acc)
    end
    return _pow(base, exp - 1, base * acc)
end

func for_all_chunks{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(work : felt*, chunks_len : felt, chunks : felt**) -> (output : felt*):
    if chunks_len == 0:
        return (work)
    end
    let chunk : felt* = [chunks]
    # Initialize array of round constants (it would be cool to reuse it everytime)
    let (updated_work : felt*) = process_chunk(
        work,
        64,
        new (0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2),
    )
    return for_all_chunks(updated_work, chunks_len - 1, chunks + 1)
end

func process_chunk{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(work : felt*, constants_len : felt, constants : felt*) -> (output : felt*):
    if constants_len == 0:
        return (work)
    end

    # todo: update work with [constants]
    return process_chunk(work, constants_len - 1, constants + 1)
end

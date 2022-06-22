%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.alloc import alloc
from src.sphinx.bits import Bits

func sha256{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(input : felt*, n_bits : felt) -> (
    output : felt*
):
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

func create_chunks{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
    input : felt*, n_bits : felt, bits_prefix : felt
) -> (len_chunks : felt, chunks : felt**):
    # Creates an array of chunks of length 512 bits (16 32-bit words) from 'input'.
    #
    # Parameters:
    #   input: array of 32-bit words
    #   n_bits: length of input
    #   bits_prefix: number of bits to skip

    alloc_locals

    # if that's the last chunk
    # we need to append a single bit at 1, zeros and the length as a 64 bit integer
    # so that's 512-65=447 bits free
    let len = n_bits - bits_prefix

    if len == 0:
        let (chunks : felt**) = alloc()
        let (chunk) = alloc()
        assert chunk[15] = n_bits
        assert chunks[0] = chunk
        append_zeros(chunk, 15)
        return (1, chunks)
    end

    # n_bits-bits_prefix <= 511
    let (test) = is_le(len, 511)
    if test == TRUE:
        let (msg : felt*) = alloc()
        Bits.extract(input, bits_prefix, len, msg)

        # one followed by 31 0
        let (one : felt*) = alloc()
        assert [one] = 2147483648

        # we will bind it to get full words
        let (full_words, _) = unsigned_div_rem(len, 32)
        let size = (full_words + 1) * 32 - len
        let (chunk : felt*, new_len : felt) = Bits.merge(msg, len, one, size)
        let words_len = new_len / 32

        let (test) = is_le(len, 447)
        # if that's the last chunk
        # we need to append 447-len '0' and len on 64 bits (2 felt words)
        # so that's 512-65=447 bits free
        if test == TRUE:
            let zero_words = 14 - words_len
            append_zeros(chunk + words_len, zero_words)
            # now chunk is 448 bits long = 14 words
            # todo: support > 32 bits longs size
            # current maximum size = 2^33-1
            # = 8589934591 bits ~= 8.6GB

            assert chunk[14] = 0
            assert chunk[15] = n_bits
            let (chunks : felt**) = alloc()
            assert chunks[0] = chunk
            return (1, chunks)
        else:
            # here we can put 0 until the 512 bits and call it back for the next chunk (empty)
            let zero_words = 16 - words_len
            append_zeros(chunk + words_len, zero_words)
            let (len_chunks : felt, chunks : felt**) = create_chunks(input, n_bits, n_bits)
            assert chunks[len_chunks] = chunk
            return (len_chunks + 1, chunks)
        end
    end

    # if 512 <= n_bits
    # 512/32 = 16
    let (len_chunks : felt, chunks : felt**) = create_chunks(input, n_bits, bits_prefix + 512)

    let (chunk : felt*) = alloc()
    Bits.extract(input, bits_prefix, 512, chunk)
    assert chunks[len_chunks] = chunk

    return (len_chunks + 1, chunks)
end

func append_zeros{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(ptr : felt*, amount : felt):
    if amount == 0:
        return ()
    end
    assert [ptr] = 0
    return append_zeros(ptr + 1, amount - 1)
end

func for_all_chunks{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
    work : felt*, chunks_len : felt, chunks : felt**
) -> (output : felt*):
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

func process_chunk{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
    work : felt*, constants_len : felt, constants : felt*
) -> (output : felt*):
    if constants_len == 0:
        return (work)
    end

    # todo: update work with [constants]
    return process_chunk(work, constants_len - 1, constants + 1)
end

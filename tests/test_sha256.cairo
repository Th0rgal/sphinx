%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from src.sphinx.sha256 import create_chunks, sha256

@view
func test_create_single_chunk{range_check_ptr}():
    alloc_locals
    let (hello_world) = alloc()
    # 01101000 01100101 01101100 01101100
    assert hello_world[0] = 1751477356
    # 01101111 00100000 01110111 01101111
    assert hello_world[1] = 1864398703
    # 01110010 01101100 01100100 ........
    assert hello_world[2] = 1919706112

    let (len_chunks : felt, chunks : felt**) = create_chunks(hello_world, 88, 0)

    assert len_chunks = 1
    let chunk : felt* = chunks[0]
    assert chunk[0] = 1751477356
    assert chunk[1] = 1864398703
    # 01110010 01101100 01100100 1.......
    assert chunk[2] = 1919706240

    # 16-1-3=12
    multiple_asserts(chunk + 3, 12, 0)
    let last = chunk[15]
    assert chunk[15] = 88
    return ()
end

@view
func test_create_two_chunks{range_check_ptr}():
    alloc_locals
    let (phrase) = alloc()

    # 01110100 01101000 01101001 01110011
    assert phrase[0] = 1952999795
    # 00100000 01101001 01110011 00100000
    assert phrase[1] = 543781664
    # 01100001 01101110 00100000 01100101
    assert phrase[2] = 1634607205
    # 01111000 01100001 01101101 01110000
    assert phrase[3] = 2019650928
    # 01101100 01100101 00100000 01101101
    assert phrase[4] = 1818566765
    # 01100101 01110011 01110011 01100001
    assert phrase[5] = 1702064993
    # 01100111 01100101 00100000 01110111
    assert phrase[6] = 1734680695
    # 01101000 01101001 01100011 01101000
    assert phrase[7] = 1751737192
    # 00100000 01110011 01101000 01101111
    assert phrase[8] = 544434287
    # 01110101 01101100 01100100 00100000
    assert phrase[9] = 1970037792
    # 01110100 01100001 01101011 01100101
    assert phrase[10] = 1952541541
    # 00100000 01101101 01110101 01101100
    assert phrase[11] = 544044396
    # 01110100 01101001 01110000 01101100
    assert phrase[12] = 1953067116
    # 01100101 00100000 01100011 01101000
    assert phrase[13] = 1696621416
    # 01110101 01101110 01101011 01110011
    assert phrase[14] = 1970170739

    let (len_chunks : felt, chunks : felt**) = create_chunks(phrase, 480, 0)
    assert len_chunks = 2

    let chunk1 = chunks[len_chunks - 1]
    assert chunk1[0] = phrase[0]
    assert chunk1[13] = phrase[13]
    assert chunk1[14] = phrase[14]
    assert chunk1[15] = 2147483648

    let chunk2 = chunks[len_chunks - 2]
    multiple_asserts(chunk2, 15, 0)
    assert chunk2[15] = 480

    return ()
end

@view
func test_sha256{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
    alloc_locals
    alloc_locals
    let (phrase) = alloc()

    # 01110100 01101000 01101001 01110011
    assert phrase[0] = 1952999795
    # 00100000 01101001 01110011 00100000
    assert phrase[1] = 543781664
    # 01100001 01101110 00100000 01100101
    assert phrase[2] = 1634607205
    # 01111000 01100001 01101101 01110000
    assert phrase[3] = 2019650928
    # 01101100 01100101 00100000 01101101
    assert phrase[4] = 1818566765
    # 01100101 01110011 01110011 01100001
    assert phrase[5] = 1702064993
    # 01100111 01100101 00100000 01110111
    assert phrase[6] = 1734680695
    # 01101000 01101001 01100011 01101000
    assert phrase[7] = 1751737192
    # 00100000 01110011 01101000 01101111
    assert phrase[8] = 544434287
    # 01110101 01101100 01100100 00100000
    assert phrase[9] = 1970037792
    # 01110100 01100001 01101011 01100101
    assert phrase[10] = 1952541541
    # 00100000 01101101 01110101 01101100
    assert phrase[11] = 544044396
    # 01110100 01101001 01110000 01101100
    assert phrase[12] = 1953067116
    # 01100101 00100000 01100011 01101000
    assert phrase[13] = 1696621416
    # 01110101 01101110 01101011 01110011
    assert phrase[14] = 1970170739

    sha256(phrase, 480)
    return ()
end

func multiple_asserts{range_check_ptr}(ptr : felt*, amount : felt, value : felt):
    if amount == 0:
        return ()
    end
    assert [ptr] = value
    return multiple_asserts(ptr + 1, amount - 1, value)
end

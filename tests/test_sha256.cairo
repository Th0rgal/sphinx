%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from src.sphinx.sha256 import create_chunks, sha256

@view
func test_create_single_chunk{range_check_ptr}() {
    alloc_locals;
    let (empty) = alloc();
    let (len_chunks: felt, chunks: felt**) = create_chunks(empty, 0, 0);
    assert len_chunks = 1;
    let chunk: felt* = chunks[0];
    assert chunk[0] = 2147483648;
    multiple_asserts(chunk + 1, 15, 0);

    let (hello_world) = alloc();
    // 01101000 01100101 01101100 01101100
    assert hello_world[0] = 1751477356;
    // 01101111 00100000 01110111 01101111
    assert hello_world[1] = 1864398703;
    // 01110010 01101100 01100100 ........
    assert hello_world[2] = 1919706112;

    let (len_chunks: felt, chunks: felt**) = create_chunks(hello_world, 88, 0);

    assert len_chunks = 1;
    let chunk: felt* = chunks[0];
    assert chunk[0] = 1751477356;
    assert chunk[1] = 1864398703;
    // 01110010 01101100 01100100 1.......
    assert chunk[2] = 1919706240;

    // 16-1-3=12
    multiple_asserts(chunk + 3, 12, 0);
    let last = chunk[15];
    assert chunk[15] = 88;
    return ();
}

@view
func test_create_two_chunks{range_check_ptr}() {
    alloc_locals;
    let (phrase) = alloc();

    // 01110100 01101000 01101001 01110011
    assert phrase[0] = 1952999795;
    // 00100000 01101001 01110011 00100000
    assert phrase[1] = 543781664;
    // 01100001 01101110 00100000 01100101
    assert phrase[2] = 1634607205;
    // 01111000 01100001 01101101 01110000
    assert phrase[3] = 2019650928;
    // 01101100 01100101 00100000 01101101
    assert phrase[4] = 1818566765;
    // 01100101 01110011 01110011 01100001
    assert phrase[5] = 1702064993;
    // 01100111 01100101 00100000 01110111
    assert phrase[6] = 1734680695;
    // 01101000 01101001 01100011 01101000
    assert phrase[7] = 1751737192;
    // 00100000 01110011 01101000 01101111
    assert phrase[8] = 544434287;
    // 01110101 01101100 01100100 00100000
    assert phrase[9] = 1970037792;
    // 01110100 01100001 01101011 01100101
    assert phrase[10] = 1952541541;
    // 00100000 01101101 01110101 01101100
    assert phrase[11] = 544044396;
    // 01110100 01101001 01110000 01101100
    assert phrase[12] = 1953067116;
    // 01100101 00100000 01100011 01101000
    assert phrase[13] = 1696621416;
    // 01110101 01101110 01101011 01110011
    assert phrase[14] = 1970170739;

    let (len_chunks: felt, chunks: felt**) = create_chunks(phrase, 480, 0);
    assert len_chunks = 2;

    let chunk1 = chunks[len_chunks - 1];
    assert chunk1[0] = phrase[0];
    assert chunk1[13] = phrase[13];
    assert chunk1[14] = phrase[14];
    assert chunk1[15] = 2147483648;

    let chunk2 = chunks[len_chunks - 2];
    multiple_asserts(chunk2, 15, 0);
    assert chunk2[15] = 480;

    return ();
}

@view
func test_sha256{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (phrase) = alloc();
    // phrase="this is an example message which should take multiple chunks"
    // 01110100 01101000 01101001 01110011
    assert phrase[0] = 1952999795;
    // 00100000 01101001 01110011 00100000
    assert phrase[1] = 543781664;
    // 01100001 01101110 00100000 01100101
    assert phrase[2] = 1634607205;
    // 01111000 01100001 01101101 01110000
    assert phrase[3] = 2019650928;
    // 01101100 01100101 00100000 01101101
    assert phrase[4] = 1818566765;
    // 01100101 01110011 01110011 01100001
    assert phrase[5] = 1702064993;
    // 01100111 01100101 00100000 01110111
    assert phrase[6] = 1734680695;
    // 01101000 01101001 01100011 01101000
    assert phrase[7] = 1751737192;
    // 00100000 01110011 01101000 01101111
    assert phrase[8] = 544434287;
    // 01110101 01101100 01100100 00100000
    assert phrase[9] = 1970037792;
    // 01110100 01100001 01101011 01100101
    assert phrase[10] = 1952541541;
    // 00100000 01101101 01110101 01101100
    assert phrase[11] = 544044396;
    // 01110100 01101001 01110000 01101100
    assert phrase[12] = 1953067116;
    // 01100101 00100000 01100011 01101000
    assert phrase[13] = 1696621416;
    // 01110101 01101110 01101011 01110011
    assert phrase[14] = 1970170739;

    let (hash) = sha256(phrase, 480);
    let a = hash[0];
    assert a = 3714276112;
    let b = hash[1];
    assert b = 759782134;
    let c = hash[2];
    assert c = 1331117438;
    let d = hash[3];
    assert c = 1331117438;
    let e = hash[4];
    assert e = 699003633;
    let f = hash[5];
    assert f = 2214481798;
    let g = hash[6];
    assert g = 3208491254;
    let h = hash[7];
    assert h = 789740750;

    let (hello_world) = alloc();
    // 01101000 01100101 01101100 01101100
    assert hello_world[0] = 1751477356;
    // 01101111 00100000 01110111 01101111
    assert hello_world[1] = 1864398703;
    // 01110010 01101100 01100100 ........
    assert hello_world[2] = 1919706112;

    let (hash) = sha256(hello_world, 88);
    let a = hash[0];
    assert a = 3108841401;
    let b = hash[1];
    assert b = 2471312904;
    let c = hash[2];
    assert c = 2771276503;
    let d = hash[3];
    assert d = 3665669114;
    let e = hash[4];
    assert e = 3297046499;
    let f = hash[5];
    assert f = 2052292846;
    let g = hash[6];
    assert g = 2424895404;
    let h = hash[7];
    assert h = 3807366633;

    let (empty) = alloc();
    let (hash) = sha256(empty, 0);
    let a = hash[0];
    assert a = 3820012610;
    let b = hash[1];
    assert b = 2566659092;
    let c = hash[2];
    assert c = 2600203464;
    let d = hash[3];
    assert d = 2574235940;
    let e = hash[4];
    assert e = 665731556;
    let f = hash[5];
    assert f = 1687917388;
    let g = hash[6];
    assert g = 2761267483;
    let h = hash[7];
    assert h = 2018687061;

    // let's hash "hey guys"
    let (hash) = sha256(new ('hey ', 'guys'), 64);
    let a = hash[0];
    assert a = 3196269849;
    let b = hash[1];
    assert b = 935960894;
    let c = hash[2];
    assert c = 219027118;
    let d = hash[3];
    assert d = 2548975249;
    let e = hash[4];
    assert e = 1584991481;
    let f = hash[5];
    assert f = 2782224291;
    let g = hash[6];
    assert g = 385959225;
    let h = hash[7];
    assert h = 10428673;

    return ();
}

func multiple_asserts{range_check_ptr}(ptr: felt*, amount: felt, value: felt) {
    if (amount == 0) {
        return ();
    }
    assert [ptr] = value;
    return multiple_asserts(ptr + 1, amount - 1, value);
}

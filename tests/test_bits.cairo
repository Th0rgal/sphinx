%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from src.sphinx.bits import Bits

@view
func test_rightshift{range_check_ptr}() {
    let (test) = Bits.rightshift(127, 3);
    assert test = 15;

    let (test) = Bits.rightshift(127, 4);
    assert test = 7;

    let (test) = Bits.rightshift(378837287, 9);
    assert test = 739916;

    return ();
}

@view
func test_leftshift{range_check_ptr}() {
    let (test) = Bits.leftshift(127, 28);
    assert test = 4026531840;
    return ();
}

@view
func test_rightrotate{range_check_ptr}() {
    let (test) = Bits.rightrotate(3, 1);
    assert test = 2147483649;
    let (test) = Bits.rightrotate(1214606444, 7);
    assert test = 3633367768;
    return ();
}

@view
func test_extract{range_check_ptr}() {
    alloc_locals;
    let (input) = alloc();
    // 01001000011001010110110001101100
    assert input[0] = 1214606444;
    // 01101111001000000111011101101111
    assert input[1] = 1864398703;
    // 01110010011011000110010000000000
    assert input[2] = 1919706112;

    // single word, no shift, custom len
    let (output) = alloc();
    Bits.extract(input, 0, 16, output);
    // 01001000011001010000000000000000
    assert output[0] = 1214578688;

    // single word, shift of 4, custom len
    let (output) = alloc();
    Bits.extract(input, 4, 15, output);
    // 10000110010101100000000000000000
    assert output[0] = 2253783040;

    // two words, no shift, len = two words
    let (output) = alloc();
    Bits.extract(input, 0, 64, output);
    // 01001000011001010110110001101100
    assert output[0] = 1214606444;
    // 01101111001000000111011101101111
    assert output[1] = 1864398703;

    return ();
}

@view
func test_merge{range_check_ptr}() {
    alloc_locals;
    let (a) = alloc();
    // 01101111001000000111011101101111
    assert a[0] = 1864398703;
    // 01110010011011000110010000000000
    assert a[1] = 1919706112;
    // 32+22=54
    let a_nb_bits = 54;

    let (b) = alloc();
    // 01101111001000000111011101101110
    assert b[0] = 1864398702;
    // 31 (last 0 doesn't count)
    let b_nb_bits = 31;

    let (c, c_bits) = Bits.merge(a, a_nb_bits, b, b_nb_bits);

    assert c[0] = 1864398703;
    assert c[1] = 1919706556;
    assert c[2] = 2178791424;

    return ();
}

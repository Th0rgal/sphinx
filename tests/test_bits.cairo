%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from src.sphinx.bits import Bits

@view
func test_erase_last{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
    let (test) = Bits.erase_last(127, 3)
    assert test = 15

    let (test) = Bits.erase_last(127, 4)
    assert test = 7

    let (test) = Bits.erase_last(378837287, 9)
    assert test = 739916

    return ()
end

@view
func test_erase_first{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
    let (test) = Bits.erase_first(127, 28)
    assert test = 4026531840
    return ()
end

@view
func test_extract{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
    alloc_locals
    let (input) = alloc()
    # 01001000011001010110110001101100
    assert input[0] = 1214606444
    # 01101111001000000111011101101111
    assert input[1] = 1864398703
    # 01110010011011000110010000000000
    assert input[2] = 1919706112

    # single word, no shift, custom len
    let (output) = alloc()
    Bits.extract(input, output, 0, 16)
    # 01001000011001010000000000000000
    assert output[0] = 1214578688

    # single word, shift of 4, custom len
    let (output) = alloc()
    Bits.extract(input, output, 4, 15)
    # 10000110010101100000000000000000
    assert output[0] = 2253783040

    # two words, no shift, len = two words
    let (output) = alloc()
    Bits.extract(input, output, 0, 64)
    # 01001000011001010110110001101100
    assert output[0] = 1214606444
    # 01101111001000000111011101101111
    assert output[1] = 1864398703

    return ()
end

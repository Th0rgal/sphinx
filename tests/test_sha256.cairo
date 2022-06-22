%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from src.sphinx.sha256 import dump_bits

@view
func test_dump_bits{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    alloc_locals
    let (arr) = alloc()
    # 01001000011001010110110001101100
    assert arr[0] = 1214606444
    # 01101111001000000111011101101111
    assert arr[1] = 1864398703
    # 01110010011011000110010000000000
    assert arr[2] = 1919706112

    let (output) = alloc()
    dump_bits(output, arr, 16, 0)
    # 0100100001100101
    assert [output] = 18533

    #let (output) = alloc()
    #%{ print("calling") %}
    #dump_bits(output, arr, 31, 0)
    # 0100100001100101011011000110110
    # assert [output] = 0
    #assert [output] = 607303222

    return ()
end

%lang starknet
from src.sphinx.functional import List
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

func sum{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    acc : felt, value : felt
) -> (output : felt):
    return (acc + value)
end

@view
func test_fold_left{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (arr : felt*) = alloc()
    assert arr[0] = 1
    assert arr[1] = 2
    assert arr[2] = 3
    assert arr[3] = 4
    let (result) = List.fold_left(sum, 0, 4, arr)
    assert result = 10
    return ()
end

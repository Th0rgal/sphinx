%lang starknet
from src.sphinx.functional import List
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.alloc import alloc

func sum{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    acc : felt, value : felt
) -> (output : felt):
    return (acc + value)
end

@view
func test_fold_left{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (result) = List.fold_left(sum, 0, 5, new (5, 4, 3, 2, 1))
    assert result = 15
    return ()
end

func is_10{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(item : felt) -> (
    bool : felt
):
    if item == 10:
        return (TRUE)
    end
    return (FALSE)
end

func is_4{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(item : felt) -> (
    bool : felt
):
    if item == 4:
        return (TRUE)
    end
    return (FALSE)
end

@view
func test_exists{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (arr : felt*) = new (5, 4, 3, 2, 1)
    let (result) = List.exists(is_10, 5, arr)
    assert result = FALSE
    let (result) = List.exists(is_4, 5, arr)
    assert result = TRUE
    return ()
end

func is_not_10{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(item : felt) -> (
    bool : felt
):
    if item == 10:
        return (FALSE)
    end
    return (TRUE)
end

@view
func test_for_all{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (arr : felt*) = alloc()
    let (arr : felt*) = new (5, 4, 3, 2, 1)
    let (result) = List.for_all(is_4, 5, arr)
    assert result = FALSE
    let (result) = List.for_all(is_not_10, 5, arr)
    assert result = TRUE
    return ()
end

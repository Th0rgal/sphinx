%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.bool import TRUE, FALSE

namespace List:
    func fold_left{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, acc : felt, arr_len : felt, arr : felt*
    ) -> (acc : felt):
        let (func_pc) = get_label_location(function)
        return _fold_left(func_pc, acc, arr_len, arr)
    end

    func _fold_left{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        func_pc : felt*, acc : felt, arr_len : felt, arr : felt*
    ) -> (acc : felt):
        if arr_len == 0:
            return (acc)
        end
        [ap] = acc; ap++
        [ap] = [arr]; ap++
        call abs func_pc
        return _fold_left(func_pc, [ap - 1], arr_len - 1, arr + 1)
    end

    func exists{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, arr_len : felt, arr : felt*
    ) -> (acc : felt):
        let (func_pc) = get_label_location(function)
        return _exists(func_pc, arr_len, arr)
    end

    func _exists{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        func_pc : felt*, arr_len : felt, arr : felt*
    ) -> (acc : felt):
        if arr_len == 0:
            return (FALSE)
        end
        [ap] = [arr]; ap++
        call abs func_pc
        if [ap - 1] == TRUE:
            return (TRUE)
        end
        return _exists(func_pc, arr_len - 1, arr + 1)
    end

    func for_all{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        function : codeoffset, arr_len : felt, arr : felt*
    ) -> (acc : felt):
        let (func_pc) = get_label_location(function)
        return _for_all(func_pc, arr_len, arr)
    end

    func _for_all{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        func_pc : felt*, arr_len : felt, arr : felt*
    ) -> (acc : felt):
        if arr_len == 0:
            return (TRUE)
        end
        [ap] = [arr]; ap++
        call abs func_pc
        if [ap - 1] == FALSE:
            return (FALSE)
        end
        return _for_all(func_pc, arr_len - 1, arr + 1)
    end
end

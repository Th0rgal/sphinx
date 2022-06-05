%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.serialize import serialize_word

namespace List:
    func fold_left{range_check_ptr}(
        function : codeoffset, acc : felt, args_len : felt, args : felt*
    ) -> (acc : felt):
        let (func_pc) = get_label_location(function)
        return _fold_left(func_pc, acc, args_len, args)
    end

    func _fold_left{range_check_ptr}(func_pc : felt, acc : felt, args_len : felt, args : felt*) -> (
        acc : felt
    ):
        if args_len == 0:
            return (acc)
        end
        [ap] = [args]; ap++
        [ap] = acc; ap++
        call abs func_pc
        return _fold_left(func_pc, [ap - 1], args_len - 1, args + 1)
    end
end

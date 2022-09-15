%lang starknet

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.bool import TRUE, FALSE

namespace List {
    func fold_left(function: codeoffset, acc: felt, arr_len: felt, arr: felt*) -> (acc: felt) {
        let (func_pc) = get_label_location(function);
        return _fold_left(func_pc, acc, arr_len, arr);
    }

    func _fold_left(func_pc: felt*, acc: felt, arr_len: felt, arr: felt*) -> (acc: felt) {
        if (arr_len == 0) {
            return (acc,);
        }
        [ap] = acc, ap++;
        [ap] = [arr], ap++;
        call abs func_pc;
        return _fold_left(func_pc, [ap - 1], arr_len - 1, arr + 1);
    }

    func exists(function: codeoffset, arr_len: felt, arr: felt*) -> (acc: felt) {
        let (func_pc) = get_label_location(function);
        return _exists(func_pc, arr_len, arr);
    }

    func _exists(func_pc: felt*, arr_len: felt, arr: felt*) -> (acc: felt) {
        if (arr_len == 0) {
            return (FALSE,);
        }
        [ap] = [arr], ap++;
        call abs func_pc;
        if ([ap - 1] == TRUE) {
            return (TRUE,);
        }
        return _exists(func_pc, arr_len - 1, arr + 1);
    }

    func for_all(function: codeoffset, arr_len: felt, arr: felt*) -> (acc: felt) {
        let (func_pc) = get_label_location(function);
        return _for_all(func_pc, arr_len, arr);
    }

    func _for_all(func_pc: felt*, arr_len: felt, arr: felt*) -> (acc: felt) {
        if (arr_len == 0) {
            return (TRUE,);
        }
        [ap] = [arr], ap++;
        call abs func_pc;
        if ([ap - 1] == FALSE) {
            return (FALSE,);
        }
        return _for_all(func_pc, arr_len - 1, arr + 1);
    }
}

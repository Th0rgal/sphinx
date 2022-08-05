%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from src.sphinx.sha256 import create_chunks, sha256

@view
func test_create_single_chunk{range_check_ptr}():
    alloc_locals
    let (empty) = alloc()
    let (len_chunks : felt, chunks : felt**) = create_chunks(empty, 0, 0)
    assert len_chunks = 1
    let chunk : felt* = chunks[0]
    assert chunk[0] = 2147483648
    multiple_asserts(chunk + 1, 15, 0)

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
    let (phrase) = alloc()
    # phrase="this is an example message which should take multiple chunks"
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

    let (hash) = sha256(phrase, 480)
    let a = hash[0]
    assert a = 3714276112
    let b = hash[1]
    assert b = 759782134
    let c = hash[2]
    assert c = 1331117438
    let d = hash[3]
    assert c = 1331117438
    let e = hash[4]
    assert e = 699003633
    let f = hash[5]
    assert f = 2214481798
    let g = hash[6]
    assert g = 3208491254
    let h = hash[7]
    assert h = 789740750

    let (hello_world) = alloc()
    # 01101000 01100101 01101100 01101100
    assert hello_world[0] = 1751477356
    # 01101111 00100000 01110111 01101111
    assert hello_world[1] = 1864398703
    # 01110010 01101100 01100100 ........
    assert hello_world[2] = 1919706112

    let (hash) = sha256(hello_world, 88)
    let a = hash[0]
    assert a = 3108841401
    let b = hash[1]
    assert b = 2471312904
    let c = hash[2]
    assert c = 2771276503
    let d = hash[3]
    assert d = 3665669114
    let e = hash[4]
    assert e = 3297046499
    let f = hash[5]
    assert f = 2052292846
    let g = hash[6]
    assert g = 2424895404
    let h = hash[7]
    assert h = 3807366633

    let (empty) = alloc()
    let (hash) = sha256(empty, 0)
    let a = hash[0]
    assert a = 3820012610
    let b = hash[1]
    assert b = 2566659092
    let c = hash[2]
    assert c = 2600203464
    let d = hash[3]
    assert d = 2574235940
    let e = hash[4]
    assert e = 665731556
    let f = hash[5]
    assert f = 1687917388
    let g = hash[6]
    assert g = 2761267483
    let h = hash[7]
    assert h = 2018687061

    # let's hash "hey guys"
    let (hash) = sha256(new ('hey ', 'guys'), 64)
    let a = hash[0]
    assert a = 3196269849
    let b = hash[1]
    assert b = 935960894
    let c = hash[2]
    assert c = 219027118
    let d = hash[3]
    assert d = 2548975249
    let e = hash[4]
    assert e = 1584991481
    let f = hash[5]
    assert f = 2782224291
    let g = hash[6]
    assert g = 385959225
    let h = hash[7]
    assert h = 10428673

    return ()
end

@view
func test_sha256_client_data{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
    alloc_locals

    let (client_data_json) = alloc()
    assert client_data_json[0] = 2065855609
    assert client_data_json[1] = 1885676090
    assert client_data_json[2] = 578250082
    assert client_data_json[3] = 1635087464
    assert client_data_json[4] = 1848534885
    assert client_data_json[5] = 1948396578
    assert client_data_json[6] = 1667785068
    assert client_data_json[7] = 1818586727
    assert client_data_json[8] = 1696741922
    assert client_data_json[9] = 813183028
    assert client_data_json[10] = 879047521
    assert client_data_json[11] = 1684224052
    assert client_data_json[12] = 895825200
    assert client_data_json[13] = 828518449
    assert client_data_json[14] = 1664497968
    assert client_data_json[15] = 878994482
    assert client_data_json[16] = 1647338340
    assert client_data_json[17] = 811872312
    assert client_data_json[18] = 878862896
    assert client_data_json[19] = 825373744
    assert client_data_json[20] = 959854180
    assert client_data_json[21] = 859398963
    assert client_data_json[22] = 825636148
    assert client_data_json[23] = 942761062
    assert client_data_json[24] = 1667327286
    assert client_data_json[25] = 896999980
    assert client_data_json[26] = 577729129
    assert client_data_json[27] = 1734962722
    assert client_data_json[28] = 975333492
    assert client_data_json[29] = 1953526586
    assert client_data_json[30] = 791634799
    assert client_data_json[31] = 1853125231
    assert client_data_json[32] = 1819043186
    assert client_data_json[33] = 761606451
    assert client_data_json[34] = 1886665079
    assert client_data_json[35] = 2004233840
    assert client_data_json[36] = 1919252073
    assert client_data_json[37] = 1702309475
    assert client_data_json[38] = 1634890866
    assert client_data_json[39] = 1768187749
    assert client_data_json[40] = 778528546
    assert client_data_json[41] = 740451186
    assert client_data_json[42] = 1869837135
    assert client_data_json[43] = 1919510377
    assert client_data_json[44] = 1847736934
    assert client_data_json[45] = 1634497381
    assert client_data_json[46] = 2097152000

    let (hash) = sha256(client_data_json, 1504)

    let a = hash[0]
    assert a = 0x08ad1974
    let b = hash[1]
    assert b = 0x216096a7
    let c = hash[2]
    assert c = 0x6ff36a54
    let d = hash[3]
    assert d = 0x159891a3
    let e = hash[4]
    assert e = 0x57d21a90
    let f = hash[5]
    assert f = 0x2c358e6f
    let g = hash[6]
    assert g = 0xeb02f14c
    let h = hash[7]
    assert h = 0xcaf48fcd

    return ()
end

func multiple_asserts{range_check_ptr}(ptr : felt*, amount : felt, value : felt):
    if amount == 0:
        return ()
    end
    assert [ptr] = value
    return multiple_asserts(ptr + 1, amount - 1, value)
end

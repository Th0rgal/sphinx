<h1 align="center">
  <br>
  <img src="/logo.webp?raw=true" alt="Sphinx" width="512">
  <br>
</h1>

<h4 align="center">✨ A collection of useful functions in Cairo</h4>

# Get Sphinx

To install the library through protostar, you can just run the following command:
```console
protostar install https://github.com/Th0rgal/sphinx
```

Otherwise, you can just copy the files that you need.  You can do whatever you want with the code and you don't have to give me credit for it, it's MIT licensed.

# Features

## Functional
Some functions applying operations from other functions passed in parameter. They are inspired by the standard OCAML library.

### List.fold_left
Takes a function, an accumulator and a list. It will apply the function to the accumulator and an element of the list to get the new accumulator until reaching the end.

```cairo
# a sum which adds two elements
func sum{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    acc : felt, value : felt
) -> (output : felt):
    return (acc + value)
end

# a sum which adds all elements from a list using fold_left and sum
@view
func test_fold_left{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (result) = List.fold_left(sum, 0, 5, new (5, 4, 3, 2, 1))
    assert result = 15
    return ()
end
```
### List.exists / List.for_all
These functions are equivalent to quantifiers ``for_all`` and ``exists`` in mathematics. Given a list of elements, ``for_all`` will return true if and only if all these elements respect a property given in parameter while ``exists`` will return true if there is at least one element respecting the property.

```cairo
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
    let (result) = List.exists(is_4, 5, arr)
    assert result = TRUE
    return ()
end
```
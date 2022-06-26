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

> note: new(x, y, z, ...) will create an array, [link to the docs](https://cairo-lang.org/docs/how_cairo_works/object_allocation.html#the-new-operator)

### List.fold_left
Takes a function, an accumulator and a list. It will apply the function to the accumulator and an element of the list to get the new accumulator until reaching the end.

```cairo
# a sum which adds two elements
func sum(
    acc : felt, value : felt
) -> (output : felt):
    return (acc + value)
end

# a sum which adds all elements from a list using fold_left and sum
@view
func test_fold_left():
    let (result) = List.fold_left(sum, 0, 5, new (5, 4, 3, 2, 1))
    assert result = 15
    return ()
end
```

### List.exists / List.for_all
These functions are equivalent to quantifiers ``for_all`` and ``exists`` in mathematics. Given a list of elements, ``for_all`` will return true if and only if all these elements respect a property given in parameter while ``exists`` will return true if there is at least one element respecting the property.

```cairo
func is_4(item : felt) -> (
    bool : felt
):
    if item == 4:
        return (TRUE)
    end
    return (FALSE)
end

@view
func test_exists():
    alloc_locals
    let (arr : felt*) = new (5, 4, 3, 2, 1)
    let (result) = List.exists(is_4, 5, arr)
    assert result = TRUE
    return ()
end

@view
func test_for_all():
    alloc_locals
    let (arr : felt*) = alloc()
    assert arr[0] = 5
    assert arr[1] = 4
    assert arr[2] = 3
    assert arr[3] = 2
    assert arr[4] = 1
    let (result) = List.for_all(is_4, 5, arr)
    assert result = FALSE
    let (result) = List.for_all(is_not_10, 5, arr)
    assert result = TRUE
    return ()
end
```

## Storage
Write to a storage_variable from its address. 

### Storage.write, Storage.read

```cairo
@storage_var
func my_var(x : felt, y : felt) -> (a : felt):
end

@view
func test_my_var{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (inputs) = alloc()
    assert inputs[0] = 7
    assert inputs[1] = 6
    Storage.write(my_var.addr, 2, inputs, 'hello')

    let (result) = my_var.read(7, 6)
    assert result = 'hello'

    let (storage_result) = Storage.read(my_var.addr, 2, inputs)
    assert storage_result = 'hello'
    return ()
end
```
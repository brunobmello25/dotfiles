import gdb
import re

# Set it to true if you're using Microsoft's vscode plugin for c/c++.
# This works around the fact that it doesn't handle "map" display hints properly.
enable_msft_workarounds = False


class OdinAnyPrinter(gdb.ValuePrinter):
    "Pretty print Odin any."

    def __init__(self, val):
        self.__val = val

    def display_hint(self):
        if enable_msft_workarounds:
            return None
        return "map"

    def to_string(self):
        return int(self.__val['id'])

    def children(self):
        yield ('id', self.__val['id'])
        yield ('data', self.__val['data'])


def any_lookup_function(val):
    if val.type.tag is None:
        return None
    if val.type.code != gdb.TYPE_CODE_STRUCT:
        return None
    if val.type.tag != "any":
        return None
    return OdinAnyPrinter(val)


gdb.pretty_printers.append(any_lookup_function)


class OdinTypeidPrinter(gdb.ValuePrinter):
    "Pretty print Odin typeids."

    def __init__(self, val):
        self.__val = val

    def display_hint(self):
        if enable_msft_workarounds:
            return None
        return "map"

    def to_string(self):
        return int(self.__val)

    def children(self):
        id = int(self.__val)
        mask = (1 << (8 * self.__val.type.sizeof - 8)) - 1
        n = (id & mask)
        sym = gdb.lookup_static_symbol("type_table")
        type_table = sym.value()
        yield ("type_info", (type_table['data'] + (id & mask)).dereference().dereference())


def typeid_lookup_function(val):
    if val.type.name != "typeid":
        return None
    return OdinTypeidPrinter(val)


gdb.pretty_printers.append(typeid_lookup_function)


class OdinRunePrinter(gdb.ValuePrinter):
    "Pretty print Odin runes."

    def __init__(self, val):
        self.__val = val

    def to_string(self):
        return f"{int(self.__val)} '{str(chr(int(self.__val)))}'"


def rune_lookup_function(val):
    if val.type.name != "rune":
        return None
    return OdinRunePrinter(val)


gdb.pretty_printers.append(rune_lookup_function)


class OdinStringPrinter(gdb.ValuePrinter):
    "Pretty print Odin strings."

    def __init__(self, val):
        self.__val = val

    def display_hint(self):
        return "string"

    def to_string(self):
        return self.__val["data"].string("utf-8", "ignore", int(self.__val["len"]))


def string_lookup_function(val):
    if val.type.tag is None:
        return None
    if val.type.code != gdb.TYPE_CODE_STRUCT:
        return None
    if val.type.tag != "string":
        return None
    return OdinStringPrinter(val)


gdb.pretty_printers.append(string_lookup_function)


class OdinUnionPrinter(gdb.ValuePrinter):
    "Pretty print Odin unions."

    def __init__(self, val):
        self.__val = val
        self.__tag = int(val["tag"])

    def display_hint(self):
        if enable_msft_workarounds:
            return None
        return "map"

    def to_string(self):
        if self.__tag == 0:
            return "<nil>"
        return self.__val[f"v{self.__tag}"]

    def children(self):
        if self.__tag != 0:
            yield ("value", self.__val[f"v{self.__tag}"])


def union_lookup_function(val):
    if val.type.code != gdb.TYPE_CODE_UNION:
        return None
    has_tag = False
    for f in val.type.fields():
        if f.name == 'tag':
            has_tag = True
        elif not f.name.startswith('v'):
            return None
    if not has_tag:
        return None
    return OdinUnionPrinter(val)


gdb.pretty_printers.append(union_lookup_function)


class OdinSlicePrinter(gdb.ValuePrinter):
    "Pretty print Odin slices."

    def __init__(self, val):
        self.__val = val
        self.__len = int(self.__val["len"])
        self.__data = self.__val["data"]

    def display_hint(self):
        return "array"

    def to_string(self):
        name = str(self.__val.type)
        name = name[len("struct "):]
        return f"{name} len = {self.__len}, data = 0x{int(self.__data):x}"

    def child(self, i):
        if i > self.__len:
            return None
        return (self.__data + i).dereference()

    def num_children(self):
        return self.__len

    def children(self):
        if self.__data.type.target().sizeof == 0:
            return
        for i in range(int(self.__len)):
            yield (f"[{i}]", (self.__data + i).dereference())


def slice_lookup_function(val):
    if val.type.tag is None:
        return None
    if val.type.code != gdb.TYPE_CODE_STRUCT:
        return None
    if not val.type.tag.startswith("[]"):
        return None
    return OdinSlicePrinter(val)


gdb.pretty_printers.append(slice_lookup_function)


class OdinSoaSlicePrinter(gdb.ValuePrinter):
    "Pretty print Odin #soa slices."

    def __init__(self, val):
        self.__val = val
        self.__len = int(self.__val["__$len"])

    def display_hint(self):
        if enable_msft_workarounds:
            return None
        return "map"

    def to_string(self):
        name = str(self.__val.type)
        name = name[len("struct "):]
        return f"{name} len = {self.__len}"

    def num_children(self):
        return len(self.__val.type.fields())

    def children(self):
        yield ("__$len", self.__len)
        for field in self.__val.type.fields():
            if field.name == "__$len":
                continue
            yield (field.name, self.__val[field.name].cast(field.type.target().array(self.__len - 1).pointer()).dereference())


def soa_slice_lookup_function(val):
    if val.type.tag is None:
        return None
    if val.type.code != gdb.TYPE_CODE_STRUCT:
        return None
    if not val.type.tag.startswith("#soa[]"):
        return None
    return OdinSoaSlicePrinter(val)


gdb.pretty_printers.append(soa_slice_lookup_function)


class OdinDynamicArrayPrinter(gdb.ValuePrinter):
    "Pretty print Odin dynamic arrays."

    def __init__(self, val):
        self.__val = val
        self.__len = int(self.__val["len"])
        self.__cap = int(self.__val["cap"])
        self.__data = self.__val["data"]

    def display_hint(self):
        if enable_msft_workarounds:
            return None
        return "map"

    def to_string(self):
        name = str(self.__val.type)
        name = name[len("struct "):]
        return f"{name} len = {self.__len}, cap = {self.__cap}"

    def num_children(self):
        return 4

    def children(self):
        yield ("data", self.__data.cast(self.__data.type.target().array(self.__len - 1).pointer()).dereference())
        yield ("len", self.__len)
        yield ("cap", self.__cap)
        yield ("allocator", self.__val["allocator"])


def soa_dynamic_array_lookup_function(val):
    if val.type.tag is None:
        return None
    if val.type.code != gdb.TYPE_CODE_STRUCT:
        return None
    if not val.type.tag.startswith("[dynamic]"):
        return None
    return OdinDynamicArrayPrinter(val)


gdb.pretty_printers.append(soa_dynamic_array_lookup_function)


class OdinSoaDynamicArrayPrinter(gdb.ValuePrinter):
    "Pretty print Odin #soa dynamic arrays."

    def __init__(self, val):
        self.__val = val
        self.__len = int(self.__val["__$len"])
        self.__cap = int(self.__val["__$cap"])

    def display_hint(self):
        if enable_msft_workarounds:
            return None
        return "map"

    def to_string(self):
        name = str(self.__val.type)
        name = name[len("struct "):]
        return f"{name} len = {self.__len}, cap = {self.__cap}"

    def num_children(self):
        return len(self.__val.type.fields())

    def children(self):
        for field in self.__val.type.fields():
            if field.name == "__$len" or field.name == "__$cap" or field.name == "allocator":
                continue
            yield (field.name, self.__val[field.name].cast(field.type.target().array(self.__len - 1).pointer()).dereference())

        yield ("__$len", self.__len)
        yield ("__$cap", self.__cap)
        yield ("allocator", self.__val["allocator"])


def soa_soa_dynamic_array_lookup_function(val):
    if val.type.tag is None:
        return None
    if val.type.code != gdb.TYPE_CODE_STRUCT:
        return None
    if not val.type.tag.startswith("#soa[dynamic]"):
        return None
    return OdinSoaDynamicArrayPrinter(val)


gdb.pretty_printers.append(soa_soa_dynamic_array_lookup_function)


class OdinMapPrinter(gdb.ValuePrinter):
    "Pretty print Odin maps."

    def __init__(self, val):
        self.__val = val
        self.__len = val["len"]
        self.__base_addr = int(val["data"].dereference().address) & ~63

        cap_log2 = int(val["data"].dereference().address) & 63
        self.__cap = 0 if cap_log2 <= 0 else 1 << cap_log2

        self.__key_type = val["data"]["key"].type
        self.__key_cell_type = val["data"]["key_cell"].type
        self.__key_base_addr = self.__base_addr

        self.__value_type = val["data"]["value"].type
        self.__value_cell_type = val["data"]["value_cell"].type
        self.__value_base_addr = self.__key_base_addr + \
            self.map_cell_offset(
                self.__key_type, self.__key_cell_type, self.__cap)

        self.__hash_type = val["data"]["hash"].type
        self.__tombstone_mask = 1 << (self.__hash_type.sizeof * 8 - 1)
        hash_addr = self.__value_base_addr + \
            self.map_cell_offset(
                self.__value_type, self.__value_cell_type, self.__cap)
        self.__hashes = gdb.Value(hash_addr).cast(self.__hash_type.pointer())

    def display_hint(self):
        if self.__value_type.sizeof == 0:
            return "array"
        if enable_msft_workarounds:
            return None
        return "map"

    def num_children(self):
        return self.__len

    def children(self):
        for i in range(self.__cap):
            hash = (self.__hashes + i).dereference()
            if hash == 0 or (hash & self.__tombstone_mask) != 0:
                continue

            key_ptr = self.__key_base_addr + \
                self.map_cell_offset(self.__key_type, self.__key_cell_type, i)
            key = gdb.Value(key_ptr).cast(
                self.__key_type.pointer()).dereference()
            if self.__value_type.sizeof == 0:
                yield (f"{i}", key)
            else:
                value_ptr = self.__value_base_addr + \
                    self.map_cell_offset(
                        self.__value_type, self.__value_cell_type, i)
                value = gdb.Value(value_ptr).cast(
                    self.__value_type.pointer()).dereference()
                yield (f"{key}", value)

    def map_cell_offset(self, elem_type, elem_cell_type, index):
        if elem_type.sizeof == 0:
            return 0
        elems_per_cell = elem_cell_type.sizeof // elem_type.sizeof
        cell_index = index // elems_per_cell
        data_index = index % elems_per_cell
        return (cell_index * elem_cell_type.sizeof) + (data_index * elem_type.sizeof)


def map_lookup_function(val):
    if val.type.tag is None:
        return None
    if val.type.code != gdb.TYPE_CODE_STRUCT:
        return None
    if not val.type.tag.startswith("map["):
        return None
    return OdinMapPrinter(val)


gdb.pretty_printers.append(map_lookup_function)

import math, re

class Opcode:

    def __init__(self, id, name, params, types):
        
        self.id     = bin(id).lstrip('0b').rjust(6, '0')
        self.name   = name
        self.params = params
        self.types  = types
    
    def size(self):
        total = 6
        for p in self.params:
            total += self.types[p]
        byte = math.ceil(total / 8) 
        return byte


def read_language(filename='is'):
    TYPES = {}
    OPCODES = {}
    with open(filename, 'r') as fin:
        ntypes = int(fin.readline())
        for _ in range(ntypes):
            new_type = fin.readline().strip()
            type_name, type_size_bit = new_type.split()
            TYPES[type_name] = int(type_size_bit)

        nopcodes = int(fin.readline())
        for _ in range(nopcodes):
            new_opcode = fin.readline().strip()
            new_opcode = new_opcode.split()
            op_id       = new_opcode[0]
            op_name     = new_opcode[1]
            op_params   = new_opcode[2:]

            for p_type in op_params:
                if p_type not in TYPES.keys():
                    raise Exception("Not allowed param")

            opcode = Opcode(int(op_id), op_name, op_params, TYPES)
            OPCODES[op_name] = opcode
    
    return (TYPES, OPCODES)

TYPES, OPCODES = read_language()

REG = {
    "A": 0,
    "B": 1,
    "X": 2,
    "Y": 3
}

def get_size(lines):
    total = 0
    for l in lines:
        token = l.split()
        istr = token[0].lower()
        if istr.startswith("."):
            continue
        try:
            bytelen = OPCODES[istr].size()
        except:
            raise Exception("Istruction not valid")
        total += bytelen
    return total
    

def convert(procedure):
    address = procedure[0]
    lines = procedure[1]
    labels = {}
    count = 0
    ret = []

    for l in lines:
        token = l.split(" ")
        print
        istr = token.pop(0).lower()
        # label
        if istr.startswith("."):
            label = istr.lstrip(".").rstrip(":")
            regex_label = r"^[a-zA-Z0-9_]+$"
            if re.match(regex_label, label):
                labels[label] = count
                bytelen = 0
            else:
                raise Exception("Label name not valid")
        # classic opcode
        else:
            try:
                opcode = OPCODES[istr]
            except:
                raise Exception("Istruction not valid")

            assert(len(token) == len(opcode.params))
            final = opcode.id
            if len(token) and opcode.params[0] != "REG" or not len(token):
                final += "00"
            params = ""
            for ptype in opcode.params:
                val = token.pop(0)
                

                if ptype == "REG":
                    try:
                        intval = REG[val]
                    except:
                        raise Exception("Not a valid register")
                    params += bin(intval).lstrip('0b').rjust(TYPES[ptype], '0')

                elif ptype == "BYTE":
                    intval = int(val)
                    params += bin(intval).lstrip('0b').rjust(TYPES[ptype], '0')

                elif ptype == "ADDR":
                    intval = int(val)
                    params += bin(intval).lstrip('0b').rjust(TYPES[ptype], '0')

                elif ptype == "LABEL":
                    try:
                        intval = labels[val]
                    except:
                        raise Exception("No label found")
                    addr = address + intval
                    params += bin(addr).lstrip('0b').rjust(TYPES[ptype], '0')
                    # indirizzi little-endian

                else:
                    raise Exception("Opcode not implemented")
            final += params
            count += opcode.size()
            ret.append(final)
    return (ret, labels)


def clean_code(lines):
    lines = lines.split("\n")
    lines = filter(lambda r: r.strip() != '', lines)
    lines = list(map(lambda r: r.strip(), lines))
    return lines

def splitfile(filename='test.in'):
    with open(filename, 'r') as fin:
        content = fin.read()
    
    procedures, main = content.split("main:")
    procedures = procedures.split("procedure")
    procedures = list(filter(lambda r: r.strip() != '', procedures))

    main = clean_code(main)
    counter = get_size(main)
    
    clean = {}
    clean["main"] = (0, main)
    
    for p in procedures:
        lines = clean_code(p)
        name = lines.pop(0).rstrip(":")
        clean[name] = (counter, lines)
        counter += get_size(lines)

    return clean

procedures = splitfile()
for p in procedures:
    cv = convert(procedures[p])
    print("PROCEDURE " + p)
    print("address " + str(procedures[p][0]))
    print(cv)
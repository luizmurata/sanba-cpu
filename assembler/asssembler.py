import math, re

# GLOBAL SHIT
SYMBOL_TABLE = {
    "REG": {
        "a": 0,
        "b": 1,
        "x": 2,
        "y": 3
    },
    "PROCEDURE": {}
}
TYPES = {}
OPCODES = {}
ENTRYPOINT = 'main'

def convert_to_int(val):
    regex_bin = r"^0b[0-1]+$"
    regex_hex = r"^0x[0-9a-fA-F]+$"
    regex_int = r"^[0-9]+$"
    isint = False
    
    if re.match(regex_bin, val):
        intval = int(val, 2)
    elif re.match(regex_hex, val):
        intval = int(val, 16)
    elif re.match(regex_int, val):
        intval = int(val)
        isint = True
    else:
        raise Exception("No format available")
    
    return (intval, isint)

class Procedure:

    labels = {}

    def __init__(self, name, code,):
        self.name       = name
        self.raw_code   = code
        
        self.recognize_label(code)
    
    @staticmethod
    def size(code):
        total = 0
        for tokens in code:
            istr = tokens[0].lower()
            if istr.startswith("."):
                continue
            try:
                bytelen = OPCODES[istr].size()
            except:
                raise Exception("Istruction not valid")
            total += bytelen
        return total

    def recognize_label(self, code):
        regex_label = r"^\.[a-zA-Z0-9_]+:$"

        self.code = []
        address = 0

        for line in self.raw_code:
            tokens = line.split(" ")
            istr = tokens.pop(0).lower().strip()
            
            if re.match(regex_label, istr):
                label = istr.rstrip(":")
                self.labels[label] = address
            else:
                try:
                    opcode = OPCODES[istr]
                except:
                    raise Exception("Istruction not valid")

                assert(len(tokens) == len(opcode.params))

                if len(tokens) > 1:
                    assert(tokens[0].endswith(","))
                    tokens[0] = tokens[0].rstrip(",")
                elif len(tokens) == 1:
                    assert(not tokens[0].endswith(","))

                address += opcode.size()
                
                tokens.insert(0, istr)
                self.code.append(tokens)
            

    def assemble(self):
        binary = []
        for tokens in self.code:
            istr = tokens.pop(0).lower()

            opcode = OPCODES[istr]
            final = opcode.id
            if len(tokens) and opcode.params[0] != "REG" or not len(tokens):
                final += "00"

            params = ""
            for ptype in opcode.params:
                val = tokens.pop(0)                

                if ptype == "REG":
                    try:
                        intval = SYMBOL_TABLE["REG"][val]
                    except:
                        raise Exception("Not a valid register")
                    params += bin(intval).lstrip('0b').rjust(TYPES[ptype], '0')

                elif ptype == "BYTE":
                    negative = False
                    if val.startswith("-"):
                        negative = True
                        val = val.lstrip("-")
                    
                    intval, isint = convert_to_int(val)

                    if isint and (intval > 2 ** (TYPES[ptype] - 1) or intval < (- 2 ** (TYPES[ptype] - 1) + 1)):
                        raise Exception("Out of limit for a byte")

                    toadd = bin(intval).lstrip('0b').rjust(TYPES[ptype], '0')
                    if len(toadd) > TYPES[ptype]:
                        raise Exception("Too big")
                        
                    if negative:
                        toadd = ''.join('1' if x == '0' else '0' for x in toadd)
                    params += toadd

                elif ptype == "ADDRESS":
                    intval, _ = convert_to_int(val)

                    if intval > 2 ** TYPES[ptype] or intval < 0:
                        raise Exception("Out of limit for an address")

                    params += bin(intval).lstrip('0b').rjust(TYPES[ptype], '0')

                elif ptype == "LABEL":
                    try:
                        intval = self.labels[val]
                        addr = SYMBOL_TABLE['PROCEDURE'][self.name] + intval
                        toadd = bin(addr).lstrip('0b').rjust(TYPES[ptype], '0')
                        toadd = toadd[8:] + toadd[8] # little-endian
                        params += toadd
                    except:
                        raise Exception("No label found")

                elif ptype == "PROCEDURE":
                    try:
                        addr = SYMBOL_TABLE['PROCEDURE'][val]
                        toadd = bin(addr).lstrip('0b').rjust(TYPES[ptype], '0')
                        toadd = toadd[8:] + toadd[8] # little-endian
                        params += toadd
                    except:
                        raise Exception("No procedure found")

                else:
                    raise Exception("Opcode not implemented")

            final += params
            binary.append(final)

        self.binary = ''.join(binary)


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

read_language()


def splitprocedures(filetext):
    splitregex = r"^[a-zA-Z0-9]+:"
    reg = re.compile(splitregex)
    procedures = []
    code = []
    previous = None
    for l in filetext:
        l = l.strip()
        if reg.match(l):
            if previous:
                proc = Procedure(previous, code.copy())
                procedures.append(proc)
            previous = l.rstrip(":")
            code.clear()
        else:
            if l != '':
                code.append(l)

    proc = Procedure(previous, code.copy())
    procedures.append(proc)

    return procedures

def parse(filename='test.in'):
    with open(filename, 'r') as fin:
        content = fin.readlines()
    
    procedures_list = splitprocedures(content)
    procedures_dict = {}
    for p in procedures_list:
        procedures_dict[p.name] = p
    return procedures_dict

def create_st(procedures_dict):

    procedures_name = list(procedures_dict.keys())
    assert(ENTRYPOINT in procedures_name)
    procedures_name.remove(ENTRYPOINT)
    procedures_name.insert(0, ENTRYPOINT)

    address = 0
    
    for name in procedures_name:
        name
        proc = procedures_dict[name]
        size = Procedure.size(proc.code)
        SYMBOL_TABLE['PROCEDURE'][name] = address
        address += size

if __name__ == "__main__":
    procedures = parse()
    create_st(procedures)

    output = ""
    for p in procedures:
        proc = procedures[p]
        proc.assemble()
        output += ''.join(proc.binary)

    with open("test.out", "w") as fout:
        for pos in range(int(len(output) / 8)):
            s = output[pos * 8 : (pos + 1) * 8]
            r = hex(int(s, 2)).lstrip("0x").rjust(2, '0')
            fout.write(r + "\n")
        fout.write("00\n" * int((2 ** 16 - len(output)) / 8))
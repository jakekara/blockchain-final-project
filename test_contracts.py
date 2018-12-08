""" Test that the contracts compile """

from taxblock.source_code import SourceManager
from taxblock.source_code import SourcePart
from taxblock.contract_interface import ContractInterface

import os
source_dir = "taxblock_solidity"

contractName = lambda x: x[5:-4]

source = SourceManager()

for fname in sorted(os.listdir(source_dir)):
    if not fname.startswith("0") or not fname.endswith(".sol"): continue
    fpath = os.path.join(source_dir, fname)
    name = contractName(fname)
    print ("Loading contract '%s'" % name)
    source.add_part(SourcePart.Contract, name, open(fpath).read())

# print()
# print ("Here's the source code:")
# print (source.to_string())

print ()
print ("Compiling...")
interface = ContractInterface(source.to_string())
print("Success!")

fh = open("dump.sol","w")
fh.write(source.to_string());
fh.close();

def pragma_string(version="^0.4.24"):
    return '''pragma solidity %s;''' % version

def make_source_code(pieces, pragma=pragma_string()):
    
    """
        pieces - array of strings in order that they should
                  be concatenated form source code
        pragma - optional pragma string     
    """
    
    return "\n".join([pragma] + [x for x in pieces])

def get_line_no(source_code, line_no):
    
    """ Get a range of line numbers for debugging purposes """
    try:
        return source_code.split("\n")[line_no]
    except:
        pass

def print_line_nos(source_code, start, stop=None):
    
    if stop is None:
        stop = start
    
    for line_no in range(start, stop + 1):
        line = get_line_no(source_code, line_no)
        if line is None: break
        print ("%5d: %s" % (line_no, line))
        
from enum import Enum
class SourcePart(Enum):
    Pragma = 0
    Contract = 1
    Library = 2

class SourceManager:

    def __init__(self, version="^0.4.24"):
        self.code_parts = {}
        self.add_part(SourcePart.Pragma, "pragma", pragma_string(version))
    
    def add_part(self, part, key, val):
        self.code_parts[key] = val
        
    def to_string(self):
        return "\n".join([self.code_parts[x] for x in self.code_parts.keys()])
            
    def print_lines(self, start, stop):
        print_line_nos(self.to_string(), start, stop)
      
    def print_line(self, n):
        self.print_lines(n, n)
        

        
        
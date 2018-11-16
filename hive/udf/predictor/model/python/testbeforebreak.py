import sys
import datetime
for line in sys.stdin:
    line = line.strip()
    textit = line.split('\t')
    l_text = textit[0].lower()
    print '\t'.join([ str(l_text)])
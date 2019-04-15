import random
import time
import sys
import getopt
import os
from setproctitle import setproctitle, getproctitle
import psutil



if __name__ == '__main__':

    opts, args = getopt.getopt(sys.argv[1:], "hd:f:s:n:p:")
    filepath = ""
    filename = ""
    seconds = 30
    procnum = ""
    procname = ""
    for op, value in opts:
        if op == '-d':
            filepath = value
        elif op == '-f':
            filename = value
        elif op == '-s':
            seconds = int(value)
        elif op == '-n':
            procnum = value
        elif op == '-p':
            procname = value
        else:
            print("confirm the parameters [-d] [-f] [-s] [-n] [-p]")
            sys.exit()
    p = psutil.Process(os.getpid())
    name = os.path.splitext(os.path.basename(__file__))[0]
    print(name)
    if procname:
        print(procname +procnum)
        setproctitle(procname + procnum)
    else:
        setproctitle(name + procnum)
    t1 = time.time()

    file1 = filepath + filename
    f = open(file1, 'a')
    while True:
        f.write(str(random.randint(0, 100)) + '\n')
        f.flush()
        time.sleep(1)
        t2 = time.time()
        if t2-t1 >= seconds:
            break

    f.write('\n')
    f.close()

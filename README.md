## asm_disks

* list mpath disks used by asm diskroups 
```
$ asm_disks list
BCKVOL001 = mpathai (360050.........................de) dm-32 500G
BCKVOL002 = mpathaj (360050.........................dc) dm-33 500G
CRSVOL001 = mpathc (3600014.........................1b) dm-0 6.0G
CRSVOL002 = mpathf (3600014.........................28) dm-3 6.0G
CRSVOL003 = mpathg (3600014.........................35) dm-4 6.0G
DATAVOL001 = mpathd (3600014.........................42) dm-1 500G
DATAVOL002 = mpathe (3600014.........................4f) dm-2 500G
```

* list mpath disks not used by asm
```
$ asm_disks unused
mpathe (3600014.........................4f) dm-2 500G
```

create tablespace spreadeasy_tbs datafile '+DATA'
size 32m autoextend on next 32m maxsize unlimited
logging
online
extent management local autoallocate
segment space management auto
flashback on;
--line feed, carriage return, tab, quotes in that order
REPLACE(REPLACE(REPLACE(REPLACE(u.Name, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''), '"', '') as Name
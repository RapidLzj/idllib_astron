function r_strint, s
    ; check is s a number, valid char is only 0-9, +, -, ., and leading and tail space
    ss = strtrim(s, 2)
    l = strlen(ss)
    ok = 1
    for i = 0, l-1 do begin
        c = strmid(ss, i, 1)
        if strpos('+-0123456789.', c) eq -1 then begin
            ok = 0
            break
        endif
    endfor
    return, ok
end
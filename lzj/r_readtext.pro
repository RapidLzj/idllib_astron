function r_ReadText, textfile, linecount=linecount, silent=silent
    if ~ file_test(textfile) then begin
        message, 'File ' + textfile + ' NOT exists.', /cont
        return, ''
    endif

    line = ''
    lines = [line]
    openr, lun, textfile, /get_lun
    while ~ eof(lun) do begin
        readf, lun, line
        lines = [lines, line]
    endwhile
    close, lun
    free_lun, lun

    linecount = n_elements(lines) - 1
    if linecount gt 0 then begin
        lines = lines[1:*]
    endif else begin
        message, 'Empty file', /cont
    endelse

    if ~ keyword_set(silent) then $
        message, strn(linecount) + ' line(s) read', /cont

    return, lines
end
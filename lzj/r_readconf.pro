function r_readconf, configfile
    ; read configure file and make a result structure

    ; first field: configure_filename
    res = {configure_filename: configfile}

    openr, lun, configfile, /get_lun

    line = ''
    readf, lun, line
    while ~ eof(lun) do begin
        ; remove comment, starting with #, no # allowed in key and value
        p = strpos(line, '#')
        if p gt -1 then line = strtrim(strmid(line, 0, p-1), 2)
        ; split by =, if empty line, or not valid "key = value", will skip
        part = strsplit(line, '=', /extract, count=npart)
        if npart ge 2 then begin
            k = strtrim(part[0], 2)
            v = strtrim(part[1], 2)
            res = create_struct(res, k, v)
        endif

        readf, lun, line
    endwhile

    close, lun
    free_lun, lun

    return, res
end
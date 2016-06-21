function r_complist, rvalue, rlist
    ; check whether value in the list, return list index
    ; use where
    return, (where(rvalue eq rlist))[0];
end
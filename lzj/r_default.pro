pro r_default, x, v
    if ~ keyword_set(x) then if keyword_set(v) then x = v else x = 0
end

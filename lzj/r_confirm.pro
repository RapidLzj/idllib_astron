function r_confirm, prompt
  ans = ''
  read, prompt=prompt, ans, format='(a)'
  return, strlowcase(strmid(ans,0,1))
end
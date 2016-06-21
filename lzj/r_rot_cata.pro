function r_rot_cata, x, y, ang

  case (ang mod 8) of
    1: begin ; CW 90 deg
        rx = +y
        ry = -x
      end
    2: begin ; 180 deg
        rx = -x
        ry = -y
      end
    3: begin ; CW 270 deg (CCW 90 deg)
        rx = -y
        ry = +x
      end
    4: begin ; mirror leftup - rightdown
        rx = +y
        ry = +x
      end
    5: begin ; mirror x
        rx = -x
        ry = +y
      end
    6: begin ; mirror leftdown - rightup
        rx = -y
        ry = -x
      end
    7: begin ; mirror y
        rx = +x
        ry = -y
      end
    else: begin
        rx = +x
        ry = +y
      end  
  endcase

  return, {x:rx, y:ry}
end

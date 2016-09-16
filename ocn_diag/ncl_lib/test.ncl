;McDougall, Wright, Jackett, and Feistel EOS
; test value : rho = 1.033213387 for
; S = 35.0 PSU, theta = 20.0 C, pressure = 2000.0 dbars

load "eos.ncl"

test_rho =  1.033213387d
;print(eos(20.0,35.0, 19027.880804d,0))

print(test_rho)
print(eos(20.0,35.0, 2000,0))
print("difference: test_rho - computed: " + (test_rho - eos(20.0,35.0, 2000,0)))
print("ratio: test_rho / computed: " + (test_rho / eos(20.0,35.0, 2000,0)))

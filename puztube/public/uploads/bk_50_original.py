import math
import fractions

def modinv26(n) :
    if n == 5 :
        return 21
    elif n == 3 :
        return 9
    else :
        raise Exception("No such inverse of " + str(n))

def compute(n3, n4, n5, n6, n7, n8, n9, n12, n14, n16, n18, n21, n24) :
    return [(n3+n4) % 26,
            fractions.gcd(n9, n24) % 26,
            (n5 * n6) % 26,
            (n8 + n24) % 26,
            (n9 ** n18) % 26,
            (n14 - n5) % 26,
            (n12 - n14) % 26,
            (n4 * n6) % 26,
            (n7 + n21) % 26,
            (n16 *fractions.gcd(n16,n12) * modinv26(n12/fractions.gcd(n16,n12))) % 26]

def toChar(n) :
    return chr(65+n)

a = compute(12, 6, 9, 11, 3, 7, 10, 5, 8, 4, 13, 1, 2)
print a

print map(toChar, a)

b = compute(12, 1, 9, 11, 3, 7, 10, 5, 8, 4, 13, 6, 2)
print b

print map(toChar, b)

c = compute(3, 4,5,6,7,8,9,12,14,16,18,21,24)
print c
print map(toChar, c)

#d = compute(1,2,2,2,2

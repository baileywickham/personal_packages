import sys

def sieve(N):
    P = [1 if x % 2 == 1  or x == 2 else 0 for x in range(N+1)]
    m = 3
    n = m**2
    while n <= N:
        if P[m] == 1:
            while n <= N:
                P[n] = 0
                n = n + 2*m
        m = m + 2
        n = m**2
    for i, v in enumerate(P):
        if v == 1:
            P[i] = i
    return P

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("isprime <num>")
        exit()

    num = int(sys.argv[1])
    print(num in sieve(num+1))

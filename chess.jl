using Random
using Statistics

struct King end
struct Knight end
struct Rook end
struct Queen end
struct Bishop end

const PIECES = [Bishop(), King(), Queen(), Rook(), Knight()]
const PIECE_NAMES = ["Bishop", "King", "Queen", "Rook", "Knight"]

legal_moves(::King, r, c, N) = [(r+dr, c+dc) for dr in -1:1 for dc in -1:1 if (0 < r+dr <= N && 0 < c+dc <= N && !(dr == 0 && dc == 0))]
legal_moves(::Knight, r, c, N) = [(r+dr, c+dc) for dr in (-2, -1, 1, 2) for dc in (-2, -1, 1, 2) if (0 < r+dr <= N && 0 < c+dc <= N && abs(dr) != abs(dc))]
legal_moves(::Rook, r, c, N) = [(r+dr, c+dc) for dr in (-N+1):(N-1) for dc in (-N+1):(N-1) if (0 < r+dr <= N && 0 < c+dc <= N && !(dr == 0 && dc == 0) && (dr == 0 || dc == 0))]
legal_moves(::Bishop, r, c, N) = [(r+dr, c+dc) for dr in (-N+1):(N-1) for dc in (-N+1):(N-1) if (0 < r+dr <= N && 0 < c+dc <= N && !(dr == 0 && dc == 0) && abs(dr) == abs(dc))]
legal_moves(::Queen, r, c, N) = [legal_moves(Rook(), r, c, N); legal_moves(Bishop(), r, c, N)]

function random_start(N)
    r1, c1 = rand(1:N), rand(1:N)
    r2, c2 = rand(1:N), rand(1:N)
    while r1 == r2 && c1 == c2
        r2, c2 = rand(1:N), rand(1:N)
    end
    return (r1, c1), (r2, c2)
end

function duel_random(typeA, typeB, N)
    (r1, c1), (r2, c2) = random_start(N)
    active, target = shuffle([(typeA, r1, c1), (typeB, r2, c2)])
    while true
        moves = legal_moves(active[1], active[2], active[3], N)
        nr, nc = rand(moves)
        active = (active[1], nr, nc)
        if active[2] == target[2] && active[3] == target[3]
            return active[1]
        end
        active, target = target, active
    end
end

function duel(typeA, typeB, N)
    (r1, c1), (r2, c2) = random_start(N)
    active, target = shuffle([(typeA, r1, c1), (typeB, r2, c2)])
    while true
        moves = legal_moves(active[1], active[2], active[3], N)
        target_pos = (target[2], target[3])
        if target_pos in moves
            return active[1]
        end
        nr, nc = rand(moves)
        active = (active[1], nr, nc)
        active, target = target, active
    end
end

function run_matchup(typeA, typeB, N, trials)
    wins = 0
    for _ in 1:trials
        if duel(typeA, typeB, N) == typeA
            wins += 1
        end
    end
    return wins / trials * 100
end

function build_matrix(N, trials)
    n = length(PIECES)
    M = zeros(n, n)
    for i in 1:n, j in (i+1):n
        pct = run_matchup(PIECES[i], PIECES[j], N, trials)
        M[i, j] = pct
        M[j, i] = 100 - pct
    end
    return M
end

function print_matrix(M)
    print(rpad("", 8))
    for name in PIECE_NAMES
        print(lpad(name, 8))
    end
    println()
    for i in eachindex(PIECE_NAMES)
        print(rpad(PIECE_NAMES[i], 8))
        for j in 1:length(PIECE_NAMES)
            print(lpad(round(Int, M[i, j]), 8))
        end
        println()
    end
end

function piece_values(M)
    n = size(M, 1)
    w = [sum(M[i, :]) / (n - 1) for i in 1:n]
    b = zeros(n)
    for i in 1:n
        numerator = 0.0
        denominator = 0.0
        for j in 1:n
            if j != i
                numerator += M[i, j] * w[j]
                denominator += w[j]
            end
        end
        b[i] = numerator / denominator
    end
    return b
end

function value_sweep(N_list, trials)
    V = zeros(length(PIECES), length(N_list))
    for (k, N) in enumerate(N_list)
        V[:, k] = piece_values(build_matrix(N, trials))
    end
    return V
end

function print_value_table(V, N_list)
    print(rpad("", 8))
    for N in N_list
        print(lpad("N=$N", 7))
    end
    println()
    for i in eachindex(PIECE_NAMES)
        print(rpad(PIECE_NAMES[i], 8))
        for k in 1:length(N_list)
            print(lpad(round(Int, V[i, k]), 7))
        end
        println()
    end
end

function sweep_with_error(N_list, trials, R)
    n_pieces = length(PIECES)
    n_N = length(N_list)
    runs = zeros(n_pieces, n_N, R)
    for r in 1:R
        runs[:, :, r] = value_sweep(N_list, trials)
    end
    means = dropdims(mean(runs, dims=3), dims=3)
    stds = dropdims(std(runs, dims=3), dims=3)
    return means, stds
end

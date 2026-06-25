using Random
using Statistics

struct King end
struct Knight end
struct Rook end
struct Queen end
struct Bishop end

legal_moves(::King, r, c, N) = [(r+dr, c+dc) for dr in -1:1 for dc in -1:1 if (0 < r+dr <= N && 0 < c+dc <= N && !(dc == 0 && dr == 0))]
legal_moves(::Knight, r, c, N) = [(r+dr, c+dc) for dr in (-2, -1, 1, 2) for dc in (-2, -1, 1, 2) if (0 < r+dr <= N && 0 < c+dc <= N && abs(dr) != abs(dc))]
legal_moves(::Rook, r, c, N) = [(r+dr, c+dc) for dr in (-N+1):(N-1) for dc in (-N+1):(N-1) if (0 < r+dr <= N && 0 < c+dc <= N && !(dc == 0 && dr == 0) && ((dr == 0) || (dc == 0)))]
legal_moves(::Bishop, r, c, N) = [(r+dr, c+dc) for dr in (-N+1):(N-1) for dc in (-N+1):(N-1) if (0 < r+dr <= N && 0 < c+dc <= N && !(dc == 0 && dr == 0) && (abs(dr) == abs(dc)))]
legal_moves(::Queen, r, c, N) = [legal_moves(Rook(), r, c, N); legal_moves(Bishop(), r, c, N)]

function print_moves(r, c, N)
    println("King movement:")
    println(legal_moves(King(), r, c, N))
    println("Knight movement:")
    println(legal_moves(Knight(), r, c, N))
    println("Rook movement:")
    println(legal_moves(Rook(), r, c, N))
    println("Bishop movement:")
    println(legal_moves(Bishop(), r, c, N))
    println("Queen movement:")
    println(legal_moves(Queen(), r, c, N))
end

function duel_random(typeA, typeB, N)
    r_1 = rand(1:N)
    r_2 = rand(1:N)
    c_1 = rand(1:N)
    c_2 = rand(1:N)
    while r_1 == r_2 && c_1 == c_2
        r_2 = rand(1:N)
        c_2 = rand(1:N)
    end
    piece1 = (typeA, r_1, c_1)
    piece2 = (typeB, r_2, c_2)
    start = shuffle([piece1, piece2])
    active = start[1]
    target = start[2]
    captured = false
    move_count_per_duel = 0
    while captured == false
        active_new = rand(legal_moves(active[1], active[2], active[3], N))
        active = (active[1], active_new[1], active_new[2])
        if active[2] == target[2] && active[3] == target[3]
            captured = true
        else
            active, target = target, active
        end
        move_count_per_duel += 1
    end
    return active[1]
end

function duel(typeA, typeB, N)
    r_1 = rand(1:N)
    r_2 = rand(1:N)
    c_1 = rand(1:N)
    c_2 = rand(1:N)
    while r_1 == r_2 && c_1 == c_2
        r_2 = rand(1:N)
        c_2 = rand(1:N)
    end
    piece1 = (typeA, r_1, c_1)
    piece2 = (typeB, r_2, c_2)
    start = shuffle([piece1, piece2])
    active = start[1]
    target = start[2]
    captured = false
    move_count_per_duel = 0
    while captured == false
        target_pos = (target[2], target[3])
        if target_pos in legal_moves(active[1], active[2], active[3], N)
            active = (active[1], target[2], target[3])
            captured = true
        else
            active_new = rand(legal_moves(active[1], active[2], active[3], N))
            active = (active[1], active_new[1], active_new[2])
        end
        if active[2] == target[2] && active[3] == target[3]
            captured = true
        else
            active, target = target, active
        end
        move_count_per_duel += 1
    end
    return active[1]
end

function run_matchup(typeA, typeB, N, trials)
    win_count = Dict(
        typeA => 0,
        typeB => 0
    )
    i = 0
    while i < trials
        win_count[duel(typeA, typeB, N)] += 1
        i += 1
    end
    return win_count[typeA]/trials*100
end

function piece_matrix()
    piece_list = [Bishop(), King(), Queen(), Rook(), Knight()]
    n = length(piece_list)
    return [(piece_list[i], piece_list[j]) for i in 1:n for j in (i+1):n]
end

function build_matrix(N, trials)
    pieces = [Bishop(), King(), Queen(), Rook(), Knight()]
    names = ["Bishop", "King", "Queen", "Rook", "Knight"]
    n = length(pieces)
    M = zeros(n, n)
    for i in 1:n, j in (i+1):n
        pct = run_matchup(pieces[i], pieces[j], N, trials)
        M[i, j] = pct
        M[j, i] = 100 - pct
    end
    return M, names
end

function print_matrix(M, names)
    print("\t")
    for name in names
        print(name, "\t")
    end
    println()
    n = length(names)
    for i in 1:n
        print(names[i], "\t")
        for j in 1:length(names)
            print(M[i, j], "\t")
        end
        println()
    end
end

function multiple_test(a, b, c)
    if a > b
        a, b = b, a
    end
    if a <= 3
        a = 4
    end
    for i in a:b
        M, names = build_matrix(i, c)
        print_matrix(M, names)
    end
end

function calculate_piece_value(M)
    n = size(M, 1)
    w = [sum(M[i, :])/(n-1) for i in 1:n]
    return w

end

function calculate_piece_value_weighted(M, w)
    n = size(M, 1)
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

function multiple_value_sweep(N, trials)
    V = zeros(5, length(N))
    names = ["Bishop", "King", "Queen", "Rook", "Knight"]
    for (k, n) in enumerate(N)
        M, _ = build_matrix(n, trials)
        w = calculate_piece_value_weighted(M, calculate_piece_value(M))
        V[:, k] = w
    end
    return V, names
end

function print_value_table(V, names, N_list)
    print(lpad("", 8))
    for n in N_list
        print(lpad("N=$n", 7))
    end
    println()
    n_names = length(names)
    for i in 1:n_names
        print(rpad(names[i], 8))
        for k in 1:length(N_list)
            print(lpad(round(Int, (V[i, k])), 7))
        end
        println()
    end
end

function sweep_with_error(N_list, trials, R)
    runs = []
    for r in 1:R
        V, _ = multiple_value_sweep(N_list, trials)
        push!(runs, V)
    end

    n_pieces = 5
    n_N = length(N_list)
    means = zeros(n_pieces, n_N)
    stds = zeros(n_pieces, n_N)

    for i in 1:n_pieces
        for k in 1:n_N
            cell_values = [runs[r][i, k] for r in 1:R]
            means[i, k] = mean(cell_values)
            stds[i, k] = std(cell_values)
        end
    end
    names = ["Bishop", "King", "Queen", "Rook", "Knight"]
    return means, stds, names
end

include("chess.jl")
using Plots, Statistics

N_list = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
means, stds, names = sweep_with_error(N_list, 100000, 10)

styles = Dict(
    "Queen" => (color=RGB(0.20, 0.60, 0.40), style=:solid, width=3.0),
    "Rook" => (color=RGB(0.55, 0.35, 0.75), style=:solid, width=3.0),
    "Bishop" => (color=RGB(0.20, 0.55, 0.85), style=:solid, width=2.5),
    "King" => (color=RGB(0.85, 0.30, 0.25), style=:solid, width=2.5),
    "Knight" => (color=RGB(0.90, 0.65, 0.10), style=:dash, width=2.5),
)

plt = plot(
    size=(900, 600), dpi=200,
    background_color=RGB(0.98, 0.98, 0.97),
    background_color_inside=RGB(1, 1, 1),
    foreground_color_grid=RGB(0.88, 0.88, 0.88),
    gridalpha=0.6, framestyle=:box,
    xlabel="Board size  (N × N)",
    ylabel="Piece value   (weighted win %)",
    title="Chess piece value vs board size  (±1σ over 10 runs)",
    titlefontsize=14, guidefontsize=12, tickfontsize=10, legendfontsize=11,
    legend=:outerright,
    left_margin=5Plots.mm, bottom_margin=5Plots.mm,
)

draw_order = ["Queen", "Rook", "Bishop", "King", "Knight"]
for name in draw_order
    i = findfirst(==(name), names)
    s = styles[name]
    plot!(plt, N_list, means[i, :],
        ribbon=stds[i, :],        # ← hata bandı: her noktada ±std gölge
        fillalpha=0.18,           # gölgenin saydamlığı
        label=name,
        color=s.color, linestyle=s.style, linewidth=s.width,
        marker=:circle, markersize=4, markerstrokewidth=0,
    )
end

hline!(plt, [50], color=RGB(0.6, 0.6, 0.6), linestyle=:dot, linewidth=1, label="50% (even)")
display(plt)
savefig(plt, "piece_values_error.png")
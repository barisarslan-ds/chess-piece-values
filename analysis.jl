include("chess.jl")
using Plots, Statistics

N_list = collect(4:1:20)
trials = 100_000
R = 10

means, stds = sweep_with_error(N_list, trials, R)

styles = Dict(
    "Queen" => (color=RGB(0.18, 0.55, 0.36), style=:solid, width=3.2),
    "Rook" => (color=RGB(0.52, 0.33, 0.72), style=:solid, width=3.2),
    "Bishop" => (color=RGB(0.16, 0.52, 0.82), style=:solid, width=2.8),
    "King" => (color=RGB(0.83, 0.28, 0.24), style=:solid, width=2.8),
    "Knight" => (color=RGB(0.90, 0.62, 0.08), style=:dash, width=2.8),
)

plt = plot(
    size=(1100, 720),
    dpi=300,
    background_color=RGB(0.985, 0.985, 0.975),
    background_color_inside=RGB(1, 1, 1),
    foreground_color_grid=RGB(0.86, 0.86, 0.86),
    foreground_color_axis=RGB(0.35, 0.35, 0.35),
    foreground_color_text=RGB(0.25, 0.25, 0.25),
    gridalpha=0.7,
    gridlinewidth=1,
    minorgrid=true,
    minorgridalpha=0.3,
    framestyle=:box,
    xlabel="Board size  (N × N)",
    ylabel="Piece value   (weighted win %)",
    title="Chess piece value depends on board geometry\n",
    titlefontsize=17,
    guidefontsize=13,
    tickfontsize=11,
    legendfontsize=12,
    legend=:outerright,
    legendtitle="Piece",
    legendtitlefontsize=12,
    xticks=4:2:20,
    yticks=20:10:80,
    xlims=(3.5, 20.5),
    ylims=(15, 80),
    left_margin=8Plots.mm,
    bottom_margin=8Plots.mm,
    right_margin=5Plots.mm,
    top_margin=5Plots.mm,
)

hline!(plt, [50],
    color=RGB(0.55, 0.55, 0.55),
    linestyle=:dot,
    linewidth=1.2,
    label="50% (even)",
)

draw_order = ["Queen", "Rook", "Bishop", "King", "Knight"]
for name in draw_order
    i = findfirst(==(name), PIECE_NAMES)
    s = styles[name]
    plot!(plt, N_list, means[i, :],
        ribbon=stds[i, :],
        fillalpha=0.15,
        label=name,
        color=s.color,
        linestyle=s.style,
        linewidth=s.width,
        marker=:circle,
        markersize=4.5,
        markerstrokewidth=0.5,
        markerstrokecolor=RGB(1, 1, 1),
        markercolor=s.color,
    )
end

for name in draw_order
    i = findfirst(==(name), PIECE_NAMES)
    s = styles[name]
    yval = means[i, end]
    annotate!(plt, N_list[end] + 0.15, yval,
        text(string(round(Int, yval)), 9, s.color, :left))
end

display(plt)
savefig(plt, "piece_values.png")
println("done — saved piece_values.png")
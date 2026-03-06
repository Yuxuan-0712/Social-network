
def window_stats(edges, s0, s1, target_col="target_fid", size_col="size"):
    edges = edges[[target_col, size_col]].copy()

    w = edges[(edges[size_col] >= s0) & (edges[size_col] < s1)]
    delta = w.groupby(target_col).size().rename("delta_k_in")

    pre = edges[edges[size_col] < s0]
    kin0 = pre.groupby(target_col).size().rename("k_in_start")

    dfw = pd.concat([kin0, delta], axis=1).fillna(0).reset_index()
    dfw = dfw[dfw["delta_k_in"] > 0]   # 只保留窗口内入度增长的节点
    dfw = dfw.rename(columns={target_col: "target_fid"})
    return dfw

def extract_persistent_top_nodes(edges, s_min=0, s_max=5000, n_windows=10,
                                 q=0.99, min_windows=7,
                                 target_col="target_fid", size_col="size"):
    cuts = np.linspace(s_min, s_max, n_windows + 1).astype(int)
    hit_count = {}

    hit_windows = {}

    for i in range(n_windows):
        s0, s1 = cuts[i], cuts[i+1]
        dfw = window_stats(edges, s0, s1, target_col=target_col, size_col=size_col)
        if dfw.empty:
            continue

        x_thr = dfw["delta_k_in"].quantile(q)
        y_thr = dfw["k_in_start"].quantile(q)

        is_top = (dfw["delta_k_in"] >= x_thr) & (dfw["k_in_start"] >= y_thr)
        top_nodes = dfw.loc[is_top, "target_fid"].astype(int).unique()

        for v in top_nodes:
            hit_count[v] = hit_count.get(v, 0) + 1
            hit_windows.setdefault(v, []).append(i)

    summary = (pd.DataFrame({"target_fid": list(hit_count.keys()),
                             "n_windows": list(hit_count.values())})
                 .sort_values("n_windows", ascending=False)
                 .reset_index(drop=True))

    persistent = summary[summary["n_windows"] >= min_windows].copy()
    persistent["windows"] = persistent["target_fid"].map(hit_windows)

    persistent_nodes = persistent["target_fid"].tolist()
    return persistent_nodes, persistent, summary, cuts
persistent_nodes, persistent_df, all_counts_df, cuts = extract_persistent_top_nodes(
    df,                # 你的 edges 表
    s_min=0, s_max=5000,
    n_windows=10,
    q=0.95,            # 你刚刚用的 top1%
    min_windows=7,
    target_col="target_fid",
    size_col="size"
)

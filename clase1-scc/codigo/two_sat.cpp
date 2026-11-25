// 2-SAT con Kosaraju sobre el grafo de implicación. O(n + m)
// Entrada (CSES 1684): m n, luego m líneas "+ a - b" (cláusula a ∨ ¬b).
#include <bits/stdc++.h>
using namespace std;

// Literales: x_i = 2i, ¬x_i = 2i + 1. Negar: l ^ 1.
struct TwoSat {
    int n;
    vector<vector<int>> g, gt;
    vector<int> orden, comp;
    vector<bool> vis, valor;
    TwoSat(int n) : n(n), g(2 * n), gt(2 * n) {}

    void implica(int a, int b) {  // a → b
        g[a].push_back(b); gt[b].push_back(a);
    }
    // (a ∨ b)  ≡  (¬a → b) ∧ (¬b → a)
    void clausula(int a, int b) {
        implica(a ^ 1, b); implica(b ^ 1, a);
    }

    void dfs1(int u) {
        vis[u] = true;
        for (int v : g[u]) if (!vis[v]) dfs1(v);
        orden.push_back(u);
    }
    void dfs2(int u, int c) {
        comp[u] = c;
        for (int v : gt[u]) if (comp[v] == -1) dfs2(v, c);
    }
    bool resolver() {
        vis.assign(2 * n, false); comp.assign(2 * n, -1);
        for (int u = 0; u < 2 * n; u++) if (!vis[u]) dfs1(u);
        for (int i = 2 * n - 1, k = 0; i >= 0; i--)
            if (comp[orden[i]] == -1) dfs2(orden[i], k++);
        valor.assign(n, false);
        for (int i = 0; i < n; i++) {
            if (comp[2 * i] == comp[2 * i + 1]) return false;
            valor[i] = comp[2 * i] > comp[2 * i + 1];
        }
        return true;
    }
};

int lit(int i, bool pos) { return 2 * i + (pos ? 0 : 1); }

int main() {
    int m, n; cin >> m >> n;
    TwoSat ts(n);
    for (int i = 0; i < m; i++) {
        char s1, s2; int a, b;
        cin >> s1 >> a >> s2 >> b;
        ts.clausula(lit(a - 1, s1 == '+'),
                    lit(b - 1, s2 == '+'));
    }
    if (!ts.resolver()) { cout << "IMPOSSIBLE\n"; return 0; }
    for (int i = 0; i < n; i++) cout << (ts.valor[i] ? '+' : '-') << ' ';
    cout << '\n';
}

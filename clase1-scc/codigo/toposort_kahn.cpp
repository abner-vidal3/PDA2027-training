// Orden topológico con el algoritmo de Kahn. O(n + m)
// Entrada (CSES 1679): n m, luego m aristas a b (a antes que b).
#include <bits/stdc++.h>
using namespace std;

int n, m;
vector<vector<int>> g;

// Devuelve un orden topológico, o vacío si hay un ciclo.
vector<int> kahn() {
    vector<int> indeg(n, 0), orden;
    for (int u = 0; u < n; u++)
        for (int v : g[u]) indeg[v]++;
    queue<int> q;
    for (int u = 0; u < n; u++)
        if (indeg[u] == 0) q.push(u);
    while (!q.empty()) {
        int u = q.front(); q.pop();
        orden.push_back(u);
        for (int v : g[u])
            if (--indeg[v] == 0) q.push(v);
    }
    if ((int)orden.size() < n) return {};  // quedó un ciclo
    return orden;
}

int main() {
    cin >> n >> m;
    g.assign(n, {});
    for (int i = 0; i < m; i++) {
        int a, b; cin >> a >> b;
        g[a - 1].push_back(b - 1);
    }
    vector<int> orden = kahn();
    if (orden.empty()) { cout << "IMPOSSIBLE\n"; return 0; }
    for (int u : orden) cout << u + 1 << ' ';
    cout << '\n';
}

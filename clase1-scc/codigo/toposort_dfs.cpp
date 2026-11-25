// Orden topológico con DFS + detección de ciclos. O(n + m)
// Entrada (CSES 1679): n m, luego m aristas a b (a antes que b).
#include <bits/stdc++.h>
using namespace std;

int n, m;
vector<vector<int>> g;
vector<int> color, orden;  // 0 = blanco, 1 = gris, 2 = negro
bool ciclo = false;

void dfs(int u) {
    color[u] = 1;  // entra: gris
    for (int v : g[u]) {
        if (color[v] == 0) dfs(v);
        else if (color[v] == 1) ciclo = true;  // retroceso
    }
    color[u] = 2;  // sale: negro
    orden.push_back(u);  // orden de salida
}

vector<int> toposort() {
    color.assign(n, 0);
    orden.clear();
    for (int u = 0; u < n; u++)
        if (color[u] == 0) dfs(u);
    reverse(orden.begin(), orden.end());  // salida decreciente
    return orden;
}

int main() {
    cin >> n >> m;
    g.assign(n, {});
    for (int i = 0; i < m; i++) {
        int a, b; cin >> a >> b;
        g[a - 1].push_back(b - 1);
    }
    vector<int> orden = toposort();
    if (ciclo) { cout << "IMPOSSIBLE\n"; return 0; }
    for (int u : orden) cout << u + 1 << ' ';
    cout << '\n';
}

// Componentes fuertemente conexas: algoritmo de Kosaraju. O(n + m)
// Entrada (CSES 1683): n m, luego m aristas dirigidas a b.
#include <bits/stdc++.h>
using namespace std;

int n, m;
vector<vector<int>> g, gt;  // grafo y su transpuesto
vector<int> orden, comp;
vector<bool> vis;

void dfs1(int u) {
    vis[u] = true;
    for (int v : g[u]) if (!vis[v]) dfs1(v);
    orden.push_back(u);  // orden de salida
}

void dfs2(int u, int c) {
    comp[u] = c;
    for (int v : gt[u]) if (comp[v] == -1) dfs2(v, c);
}

// Retorna k = #SCC. comp[u] en [0, k), en orden topológico
// del condensado: si u -> v, entonces comp[u] <= comp[v].
int kosaraju() {
    vis.assign(n, false); comp.assign(n, -1); orden.clear();
    for (int u = 0; u < n; u++) if (!vis[u]) dfs1(u);
    int k = 0;
    for (int i = n - 1; i >= 0; i--)  // salida decreciente
        if (comp[orden[i]] == -1) dfs2(orden[i], k++);
    return k;
}

// Grafo condensado (DAG). Puede tener aristas repetidas.
vector<vector<int>> condensar(int k) {
    vector<vector<int>> dag(k);
    for (int u = 0; u < n; u++) for (int v : g[u])
        if (comp[u] != comp[v]) dag[comp[u]].push_back(comp[v]);
    return dag;
}

int main() {
    cin >> n >> m;
    g.assign(n, {}); gt.assign(n, {});
    for (int i = 0; i < m; i++) {
        int a, b; cin >> a >> b; a--, b--;
        g[a].push_back(b);
        gt[b].push_back(a);
    }
    int k = kosaraju();
    cout << k << '\n';
    for (int u = 0; u < n; u++) cout << comp[u] + 1 << ' ';
    cout << '\n';
}

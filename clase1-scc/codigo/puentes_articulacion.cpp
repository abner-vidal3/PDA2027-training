// Puentes y puntos de articulación (grafo no dirigido). O(n + m)
// Entrada: n m, luego m aristas a b (se permiten multiaristas).
// Salida: #puentes y la lista; luego #puntos de articulación y la lista.
#include <bits/stdc++.h>
using namespace std;

int n, m, timer_ = 0;
vector<vector<pair<int, int>>> g;  // (vecino, id de arista)
vector<int> tin, low;
vector<bool> esCorte;  // ¿punto de articulación?
vector<pair<int, int>> puentes;

// pe = id de la arista por la que llegamos a u (-1 si es raíz)
void dfs(int u, int pe) {
    tin[u] = low[u] = ++timer_;  // tiempos desde 1
    int hijos = 0;
    for (auto [v, id] : g[u]) {
        if (id == pe) continue;  // no volver por la MISMA arista
        if (tin[v] != -1) {  // arista de retroceso
            low[u] = min(low[u], tin[v]);
        } else {  // arista de árbol
            dfs(v, id);
            hijos++;
            low[u] = min(low[u], low[v]);
            if (low[v] > tin[u]) puentes.push_back({u, v});
            if (pe != -1 && low[v] >= tin[u]) esCorte[u] = true;
        }
    }
    if (pe == -1 && hijos >= 2) esCorte[u] = true;  // raíz
}

void resolver() {
    tin.assign(n, -1); low.assign(n, 0);
    esCorte.assign(n, false);
    for (int u = 0; u < n; u++) if (tin[u] == -1) dfs(u, -1);
}

int main() {
    cin >> n >> m;
    g.assign(n, {});
    for (int i = 0; i < m; i++) {
        int a, b; cin >> a >> b; a--, b--;
        g[a].push_back({b, i});
        g[b].push_back({a, i});
    }
    resolver();
    cout << puentes.size() << '\n';
    for (auto [u, v] : puentes) cout << u + 1 << ' ' << v + 1 << '\n';
    vector<int> cortes;
    for (int u = 0; u < n; u++) if (esCorte[u]) cortes.push_back(u + 1);
    cout << cortes.size() << '\n';
    for (int u : cortes) cout << u << ' ';
    cout << '\n';
}

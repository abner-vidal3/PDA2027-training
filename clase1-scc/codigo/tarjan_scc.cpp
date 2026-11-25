// Componentes fuertemente conexas: algoritmo de Tarjan. O(n + m)
// Entrada (CSES 1683): n m, luego m aristas dirigidas a b.
#include <bits/stdc++.h>
using namespace std;

int n, m, timer_ = 0, ncomp = 0;
vector<vector<int>> g;
vector<int> tin, low, comp, pila;
vector<bool> enPila;

void dfs(int u) {
    tin[u] = low[u] = ++timer_;  // tiempos desde 1
    pila.push_back(u); enPila[u] = true;
    for (int v : g[u]) {
        if (tin[v] == -1) {  // arista de árbol
            dfs(v);
            low[u] = min(low[u], low[v]);
        } else if (enPila[v]) {  // a una SCC aún abierta
            low[u] = min(low[u], tin[v]);
        }  // si no: SCC cerrada, ignorar
    }
    if (low[u] == tin[u]) {  // u es raíz de su SCC
        int v;
        do {
            v = pila.back(); pila.pop_back();
            enPila[v] = false;
            comp[v] = ncomp;
        } while (v != u);
        ncomp++;
    }
}

// Retorna #SCC. Ojo: comp[] sale en orden topológico INVERSO:
// si u -> v, entonces comp[u] >= comp[v].
int tarjan() {
    tin.assign(n, -1); low.assign(n, 0); comp.assign(n, -1);
    enPila.assign(n, false);
    for (int u = 0; u < n; u++) if (tin[u] == -1) dfs(u);
    return ncomp;
}

int main() {
    cin >> n >> m;
    g.assign(n, {});
    for (int i = 0; i < m; i++) {
        int a, b; cin >> a >> b;
        g[a - 1].push_back(b - 1);
    }
    int k = tarjan();
    cout << k << '\n';
    for (int u = 0; u < n; u++) cout << comp[u] + 1 << ' ';
    cout << '\n';
}

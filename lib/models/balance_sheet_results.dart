import 'package:hive/hive.dart';

part 'balance_sheet_results.g.dart';

@HiveType(typeId: 4)
class KBalanceSheetResults {
  @HiveField(0)
  final List<List<int>> _mat;

  KBalanceSheetResults(this._mat);
  KBalanceSheetResults.defaults(int n) : _mat = [] {
    for (int i = 0; i < n; ++i) {
      addPerson();
    }
  }

  void set(int person0, int person1, int amount) {
    if (person0 == person1) return;
    if (person0 > person1) {
      _mat[person0][person1] = amount;
    } else {
      _mat[person1][person0] = -amount;
    }
  }

  int get(int person0, int person1) {
    if (person0 == person1) return 0;
    if (person0 > person1) {
      return _mat[person0][person1];
    } else {
      return -_mat[person1][person0];
    }
  }

  void add(int person0, int person1, int amount) {
    if (person0 == person1) return;
    if (person0 > person1) {
      _mat[person0][person1] += amount;
    } else {
      _mat[person1][person0] -= amount;
    }
  }

  void addPerson() {
    _mat.add(List<int>.generate(_mat.length, (_) => 0, growable: true));
  }

  void removePerson(int p) {
    for (int i = p + 1; p < _mat.length; ++i) {
      _mat[i].removeAt(p);
    }
    _mat.removeAt(p);
  }

  bool isPersonRemovable(int p) {
    for (int i = p + 1; p < _mat.length; ++i) {
      if (_mat[i][p] != 0) return false;
    }
    return _mat[p].every((element) => element == 0);
  }

  bool isRemovable() {
    for (int i = 0; i < _mat.length; ++i) {
      bool ans = _mat[i].every((element) => element == 0);
      if (ans == false) return false;
    }
    return true;
  }

  List<List<int>> recap(int p) {
    _simplify();

    List<List<int>> ans = [];
    for (int i = 0; i < _mat[p].length; ++i) {
      if (_mat[p][i] != 0) {
        ans.add([i, _mat[p][i]]);
      }
    }
    for (int i = p + 1; i < _mat.length; ++i) {
      if (_mat[i][p] != 0) {
        ans.add([i, -_mat[i][p]]);
      }
    }

    return ans;
  }

  void _simplify() {
    _simplifyLoops();
    _simplifyTriangles();
  }

  void _simplifyTriangles() {
    for (int i = 0; i < _mat.length; ++i) {
      for (int j = 0; j < _mat[i].length; ++j) {
        final vij = _mat[i][j];
        if (vij == 0) continue;
        for (int k = j+1; k < _mat[i].length; ++k) {
          final vik = _mat[i][k];
          if (vik == 0) continue;
          final vjk = get(j, k);
          if (vjk == 0) continue;

          // List<int> t = [];
          if (vij > 0 && vik > 0 && vjk < 0) {
            // t = [i, k, j];
            final int q = vik > -vjk ? -vjk : vik;
            _mat[i][j] += q;
            _mat[i][k] -= q;
            add(j, k, q);
          } else if (vij > 0 && vik < 0 && vjk < 0) {
            // t = [k, i, j];
            final int q = -vik > vij ? vij : -vik;
            _mat[i][j] -= q;
            _mat[i][k] += q;
            add(j, k, -q);
          } else if (vij < 0 && vik > 0 && vjk > 0) {
            // t = [j, i, k];
            final int q = vik > -vij ? -vij : vik;
            _mat[i][j] += q;
            _mat[i][k] -= q;
            add(j, k, q);
          } else if (vij > 0 && vik > 0 && vjk > 0) {
            // t = [i, j, k];
            final int q = vjk > vij ? vij : vjk;
            _mat[i][j] -= q;
            _mat[i][k] += q;
            add(j, k, -q);
          } else if (vij < 0 && vik < 0 && vjk < 0) {
            // t = [k, j, i];
            final int q = -vjk > -vij ? -vij : -vjk;
            _mat[i][j] += q;
            _mat[i][k] -= q;
            add(j, k, q);
          } else if (vij < 0 && vik < 0 && vjk > 0) {
            // t = [j, k, i];
            final int q = -vik > vjk ? vjk : -vik;
            _mat[i][j] -= q;
            _mat[i][k] += q;
            add(j, k, -q);
          }
          // print("$t $i $j $k $vij $vik $vjk");
        }
      }
    }
  }

  void _simplifyLoops() {
    final loops = _getLoops();
    for (var c in loops) {
      int minv = -1;
      for (int i = 0; i < c.length; ++i) {
        final int p0 = c[i];
        final int p1 = c[(i+1)%c.length];
        final int v = get(p0, p1).abs();
        if (minv == -1 || v < minv) {
          minv = v;
        }
      }

      for (int i = 0; i < c.length; ++i) {
        final int p0 = c[i];
        final int p1 = c[(i+1)%c.length];
        final int v = get(p0, p1).abs();
        add(p0, p1, v > 0 ? minv : -minv);
      }
    }
  }

  List<List<int>> _getLoops() {
    int n = _mat.length;
    List<int> index = List.filled(n, -1);
    List<int> lowlink = List.filled(n, -1);
    List<bool> onStack = List.filled(n, false);
    List<int> stack = [];
    List<List<int>> sccs = [];
    int currentIndex = 0;

    void strongConnect(int v) {
      index[v] = currentIndex;
      lowlink[v] = currentIndex;
      currentIndex++;
      stack.add(v);
      onStack[v] = true;

      for (int j = 0; j < v; j++) {
        if (_mat[v][j] > 0) {
          int w = j;
          if (index[w] == -1) {
            strongConnect(w);
            lowlink[v] = lowlink[v] < lowlink[w] ? lowlink[v] : lowlink[w];
          } else if (onStack[w]) {
            lowlink[v] = lowlink[v] < index[w] ? lowlink[v] : index[w];
          }
        }
      }

      for (int w = v + 1; w < n; w++) {
        if (_mat[w][v] < 0) {
          if (index[w] == -1) {
            strongConnect(w);
            lowlink[v] = lowlink[v] < lowlink[w] ? lowlink[v] : lowlink[w];
          } else if (onStack[w]) {
            lowlink[v] = lowlink[v] < index[w] ? lowlink[v] : index[w];
          }
        }
      }

      if (lowlink[v] == index[v]) {
        List<int> scc = [];
        int w;
        do {
          w = stack.removeLast();
          onStack[w] = false;
          scc.add(w);
        } while (w != v);
        sccs.add(scc);
      }
    }

    for (int i = 0; i < n; i++) {
      if (index[i] == -1) {
        strongConnect(i);
      }
    }

    return sccs.where((scc) => scc.length > 1).toList();
  }
}


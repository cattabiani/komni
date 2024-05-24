import 'package:hive/hive.dart';
import 'package:tuple/tuple.dart';

part 'balance_sheet_results.g.dart';

@HiveType(typeId: 4)
class KBalanceSheetResults {
  @HiveField(0)
  final Map<Tuple3<int, int, int>, int> _s;

  KBalanceSheetResults(this._s);
  KBalanceSheetResults.defaults() : _s = {};

  (int, int, int) keySwap({required int b, required int c, int v = 0}) {
    if (b < c) return (b, c, v);
    return (c, b, -v);
  }

  void applyTransaction(int curr, int person0, int person1, int amount) {
    // print("Apply: $curr, $person0, $person1, $amount");
    if (amount == 0 || person0 == person1 || person0 < 0 || person1 < 0) {
      return;
    }
    (person0, person1, amount) = keySwap(b: person0, c: person1, v: amount);

    final key = Tuple3(curr, person0, person1);
    _s[key] = amount + (_s[key] ?? 0);
    // we do not remove keys with 0 values for performance
  }

  void removePerson(int person) {
    // print("remove person $person");
    final Map<Tuple3<int, int, int>, int> modifiedMap = {};

    _s.forEach((key, value) {
      var item2 = key.item2;
      var item3 = key.item3;
      if (item2 != person && item3 != person) {
        if (item2 > person) item2--;
        if (item3 > person) item3--;

        final modifiedKey = Tuple3(key.item1, item2, item3);
        modifiedMap[modifiedKey] = value;
      }
    });

    _s.clear();
    _s.addAll(modifiedMap);
  }

  void removeCurrency(int index) {
    final Map<Tuple3<int, int, int>, int> modifiedMap = {};

    _s.forEach((key, value) {
      var item1 = key.item1;
      if (item1 != index) {
        if (item1 > index) item1--;

        final modifiedKey = Tuple3(item1, key.item2, key.item3);
        modifiedMap[modifiedKey] = value;
      }
    });

    _s.clear();
    _s.addAll(modifiedMap);
  }

  List<Tuple3<int, int, int>> personRecap(int person) {
    _simplifyLoops();

    final List<Tuple3<int, int, int>> v = [];
    _s.forEach((key, value) {
      if ((key.item2 == person || key.item3 == person) && value != 0) {
        final multi = key.item2 == person ? 1 : -1;
        final other = key.item2 == person ? key.item3 : key.item2;
        v.add(Tuple3(key.item1, multi * value, other));
      }
    });
    v.sort((a, b) {
      if (a.item1 != b.item1) {
        return a.item1.compareTo(b.item1);
      } else if (a.item2 != b.item2) {
        return a.item2.compareTo(b.item2);
      } else {
        return a.item3.compareTo(b.item3);
      }
    });

    return v;
  }

  _simplifyLoops() {
    final loops = _findLoops();

    loops.forEach((graphId, graphLoops) {
      for (var loop in graphLoops) {
        int mev = -1;
        for (int i = 0; i < loop.length; i++) {
          int fromNode = loop[i];
          int toNode = loop[(i + 1) % loop.length];
          (fromNode, toNode, _) = keySwap(b: fromNode, c: toNode);
          final key = Tuple3<int, int, int>(graphId, fromNode, toNode);
          final value = _s[key] ?? 0;
          if ((value.abs() < mev || mev < 0) && value != 0) {
            mev = value.abs();
          }
        }

        if (mev > 0) {
          for (int i = 0; i < loop.length; i++) {
            int fromNode = loop[i];
            int toNode = loop[(i + 1) % loop.length];
            (fromNode, toNode, _) = keySwap(b: fromNode, c: toNode);
            final key = Tuple3<int, int, int>(graphId, fromNode, toNode);
            final value = _s[key] ?? 0;
            _s[key] = value > 0 ? value - mev : value + mev;
          }
        }
      }
    });
  }

// Function to detect loops in all graphs
  Map<int, List<List<int>>> _findLoops() {
    Map<int, Map<int, List<int>>> graphs = {};

    // Parse the results to build adjacency lists
    _s.forEach((key, value) {
      int graphId = key.item1;
      int fromNode = value > 0 ? key.item2 : key.item3;
      int toNode = value > 0 ? key.item3 : key.item2;

      if (value == 0) return; // Ignore if value is 0

      graphs.putIfAbsent(graphId, () => {});
      graphs[graphId]!.putIfAbsent(fromNode, () => []);
      graphs[graphId]![fromNode]!.add(toNode);
    });

    // Detect loops in each graph
    Map<int, List<List<int>>> allLoops = {};
    graphs.forEach((graphId, adjList) {
      List<List<int>> loops = _detectCycles(adjList);
      if (loops.isNotEmpty) {
        allLoops[graphId] = loops;
      }
    });

    return allLoops;
  }

// Function to detect cycles in a graph using DFS
  List<List<int>> _detectCycles(Map<int, List<int>> adjList) {
    List<List<int>> cycles = [];
    Set<int> visited = {};
    Set<int> stack = {};
    List<int> path = [];

    void dfs(int node) {
      if (stack.contains(node)) {
        int index = path.indexOf(node);
        cycles.add(path.sublist(index));
        return;
      }
      if (visited.contains(node)) return;

      visited.add(node);
      stack.add(node);
      path.add(node);

      if (adjList.containsKey(node)) {
        for (int neighbor in adjList[node]!) {
          dfs(neighbor);
        }
      }

      stack.remove(node);
      path.removeLast();
    }

    for (int node in adjList.keys) {
      if (!visited.contains(node)) {
        dfs(node);
      }
    }

    return cycles;
  }
}

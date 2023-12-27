import networkx as nx


graph = nx.Graph()

for line in open("../../main/resources/25.txt", "r").readlines():
    source, destinations = line.split(":")
    for destination in destinations.strip().split(" "):
        graph.add_edge(source, destination)
        graph.add_edge(destination, source)

graph.remove_edges_from(nx.minimum_edge_cut(graph))
a, b = nx.connected_components(graph)

print("Part 1:", len(a) * len(b))

defmodule PreflowPush do
  # Public function to find the maximum flow in a flow network
  def max_flow(graph, source, sink) do
    # Initialize the preflow and excess arrays
    preflow = initialize_preflow(graph, source)
    excess = initialize_excess(graph, source)
    
    # Initialize the heights array using the highest-label-first rule
    heights = initialize_heights(graph, source, sink)
    
    # Push excess flow until no vertices are active
    active_vertices = get_active_vertices(preflow, excess)
    
    while !Enum.empty?(active_vertices) do
      v = get_highest_label_vertex(active_vertices, heights)
      push_or_relabel(preflow, excess, heights, v, graph, sink)
      active_vertices = get_active_vertices(preflow, excess)
    end
    
    # Return the final maximum flow
    excess[sink]
  end

  # Private function to initialize the preflow array
  defp initialize_preflow(graph, source) do
    Enum.reduce(graph, %{}, fn {u, v, capacity}, preflow ->
      Map.put(preflow, {u, v}, 0)
    end)
  end

  # Private function to initialize the excess array
  defp initialize_excess(graph, source) do
    Enum.reduce(graph, %{}, fn {u, v, capacity}, excess ->
      if u == source, do: Map.put(excess, u, capacity), else: excess
    end)
  end


  # Private function to initialize the heights array using the highest-label-first rule
  defp initialize_heights(graph, source, sink) do
    # Initialize heights to 0 for all vertices except the source
    heights = Enum.reduce(graph, %{}, fn {u, v, _}, heights ->
      Map.put(heights, u, 0)
    end)
    
    # Set the height of the source to the number of vertices
    Map.put(heights, source, length(graph))
    
    # Initialize the queue with vertices at height n-1
    queue = Enum.filter(graph, fn {u, _, _} -> u != source end)
    
    # BFS to set heights in the highest-label-first order
    while !Enum.empty?(queue) do
      {current, _, _} = Enum.at(queue, 0)
      queue = Enum.drop(queue, 1)
      
      neighbors = Enum.filter(graph, fn {u, v, _} -> u == current and Map.get(heights, v, 0) == 0 end)
      new_vertices = Enum.map(neighbors, fn {_, v, _} ->
        Map.put(heights, v, Map.get(heights, current) - 1)
      end)
      
      queue = queue ++ new_vertices
    end
    
    heights
  end
end

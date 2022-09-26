classdef matching < handle
    
    properties
        G       % the 

        g       % the graph
        free    % free blossom indices
        outer   % outer[v], outermost blossom id that contains the v
        deep    % deep[v], contains all the original vertex ids of the blossom v
        shallow % shallow[v], contains the immediate vertices, either original or another blossom
        tip     % tip for the blossom
        mate    % the mate of the given vertex
        active  
        forestList
        visited

        type   % type of the given node
        ODD  {mustBeInteger} = 1
        EVEN {mustBeInteger} = 2
        UNLABLED {mustBeInteger} = 3

        forest % gives the father of v in the alternating forest
        root   % gives the root of v in the alternating forest  

        blocked % blossom will be blocked by dual, indicates that it cannot be expanded and act as original point
        dual % dual multipliers for blossoms, if dual[v] > 0, the blossom is blocked and full
        slack % slack associated to each edge, if slack[e] > 0, the edge cannot be used

        numberOfVertices {mustBeInteger} = 0
        numberOfEdges {mustBeInteger} = 0



    end

    methods
        function obj = matching(g, G)
            obj.g = g;
            obj.G = G;
            
            obj.numberOfEdges = obj.numberOfEdges;
            obj.numberOfVertices = obj.numberOfVertices;
            
            obj.outer = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.deep = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.shallow = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.tip = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.active = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.type = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.forest = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.root = zeros(1, obj.numberOfVertices * 2, 'int32');

            obj.blocked = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.dual = zeros(1, obj.numberOfVertices * 2);
            obj.slack = zeros(1, obj.numberOfEdges);
            obj.mate = zeros(1, obj.numberOfVertices * 2, 'int32');

            obj.visited = zeros(1, obj.numberOfVertices * 2, 'int32');
          
        end

        % blossom index dispatchers
        function index = getFreeBlossomIndex(obj)
            len = size(obj.free, 2);
            if len <= 0
                error("ERROR: matching has no free blossom ID");
            end
            index = obj.free(len);
            obj.free(end) = [];
        end

        function obj = addFreeBlossomIndex(obj, index)
            len = size(obj.free, 2);
            obj.free(len+1) = index;
        end

        function obj = clearBlossomIndices(obj)
            obj.free = [];
            for i = obj.numberOfVertices+1 : 2 * obj.numberOfVertices
                obj.free(i - obj.numberOfVertices) = i;
            end
        end
        % ---------------------------

        
        function obj = destroyBlossom(obj, index)
            if (index <= obj.numberOfVertices ...
                    || (obj.blocked(index) && greater(obj.dual(index), 0)))
                return;
            end
            
            shallowOfIndex = obj.shallow{index};
            for i=1:size(shallowOfIndex, 2)
                s = shallowOfIndex(i);
                obj.outer(s) = s;
                deepOfS = obj.deep{s};

                for j = 1:size(deepOfS, 2)
                    vj = deepOfS(j);
                    obj.outer(vj) = s;
                end

                obj.destroyBlossom(s);
            end

            obj.active(index) = 0;
            obj.blocked(index) = false;
            obj.addFreeBlossomIndex(index);
            obj.mate(index) = -1;

        end

        function obj = reset(obj)
            n = obj.numberOfVertices;
            for i = 1:n * 2
                obj.forest(i) = -1;
                obj.root(i) = i;
                
                if (i > n ...
                        && obj.active(i) == 1 ...
                        && obj.outer(i) == i)
                    obj.destroyBlossom(i);
                end
            end

            obj.visited = zeros(1, 2 * n);
            obj.forestList = [];

            for i = 1:n
                if obj.mate(obj.outer(i)) == -1
                    obj.type(obj.outer(i)) = obj.EVEN;
                    if ~obj.visited(i)
                        obj.forestList(size(obj.forestList, 2) + 1) = i;
                    end
                    obj.visited(i) = 1;
                else
                    obj.type(obj.outer(i)) = obj.UNLABLED;
                end
            end
        end

    end
end
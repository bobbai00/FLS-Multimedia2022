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
        
        perfect = 0

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
            
            obj.numberOfEdges = obj.g.numberOfEdges;
            obj.numberOfVertices = obj.g.numberOfVertices;
            
            obj.outer = zeros(1, obj.numberOfVertices * 2, 'int32');
            obj.deep = cell(1, obj.numberOfVertices * 2);
            obj.shallow = cell(1, obj.numberOfVertices * 2);
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
        
        function r = isAdjacent(obj, u, v)
            r = ismember(v, obj.g.adjMat{u}) && (~obj.isEdgeBlocked(u, v));
        end

        function r = isEdgeBlocked(obj, u, v)
            r = greater(obj.slack(obj.g.getEdgeIndex(u, v)), 0);
        end

        function r = isEdgeBlockedByIndex(obj, e)
            r = greater(obj.slack(e), 0);
        end

        function obj = expand(obj, u, expandBlocked)
            if nargin <= 2
                expandBlocked = 0;
            end
            
            n = obj.numberOfVertices;
            m = obj.numberOfEdges;

            if obj.mate(u) < 0
                Error("msg")
            end
            v = obj.outer(obj.mate(u));
            index = m;

            p = -1;
            q = -1;

            deepOfU = obj.deep{u};
            deepOfV = obj.deep{v};
            % Find the regular edge {p,q} of minimum index connecting u and its mate
            % We use the minimum index to grant that the two possible blossoms u and v will use the same edge for a mate
            for i = 1:size(deepOfU, 2)
                di = deepOfU(i);
                for j = 1:size(deepOfV, 2)
                    dj = deepOfV(j);
                    if obj.isAdjacent(di, dj) && obj.g.getEdgeIndex(di, dj) <= index
                        index = obj.g.getEdgeIndex(di, dj);
                        p = di;
                        q = dj;
                    end
                end
            end
            obj.mate(u) = q;
            obj.mate(v) = p;
            
            % if u is regular, return
            if u <= n || (obj.blocked(u) && ~expandBlocked)
                return;
            end

            found = 0;
            % find the position t of the new tip of the blossom
            it = 1;
            while it <= size(obj.shallow{u}, 2) && ~found
                si = obj.shallow{u}(it);
                deepOfSi = obj.deep{si};
                jt = 1;

                while jt <= size(deepOfSi, 2) && ~found
                    if deepOfSi(jt) == p
                        found = true;
                    end
                    jt = jt + 1;                    
                end
                it = it + 1;
                if ~found
                    % TODO: some problems here
                    obj.shallow{u} = [obj.shallow{u}, si];
                    obj.shallow{u}(1) = [];
                    it = 1;
                end
            end

            it = 1;
            if size(obj.shallow{u}, 2) == 0
                error("stuck");
            end
            obj.mate(obj.shallow{u}(it)) = obj.mate(u);
            it = it+1;

            shallowOfU = obj.shallow{u};
            
            % go through the odd circuit and adjusting the new mates
            while it <= size(shallowOfU, 2)
                itnext = it;
                itnext = itnext + 1;
                
                itid = shallowOfU(it);
                itnextid = shallowOfU(itnext);
                obj.mate(itid) = itnextid;
                obj.mate(itnextid) = itid;
                if obj.mate(itid) == -1 || obj.mate(itnextid) == -1
                   error("stuck");
                end
                itnext = itnext + 1;
                it = itnext;
            end

            for i = 1:size(shallowOfU, 2)
                s = shallowOfU(i);
                obj.outer(s) = s;

                deepOfS = obj.deep{s};
                for j = 1:size(deepOfS, 2)
                    jt = deepOfS(j);
                    obj.outer(jt) = s;
                end
            end
            
            obj.active(u) = false;
            obj.addFreeBlossomIndex(u);

            for i = 1:size(shallowOfU, 2)
                it = shallowOfU(i);
                obj.expand(it, expandBlocked);
            end
        end

        function r = blossom(obj, u, v)
            n = obj.numberOfVertices;
            m = obj.numberOfEdges;

            % find the tip of the blossom
            t = obj.getFreeBlossomIndex();
            isInPath = zeros(1, 2 * n);

            u_ = u;
            while u_ ~= -1
                isInPath(obj.outer(u_)) = 1;
                u_ = obj.forest(obj.outer(u_));
            end
            
            v_ = obj.outer(v);
            while ~isInPath(v_)
                v_ = obj.outer(obj.forest(v_));
            end
            obj.tip(t) = v_;
            
            % Find the odd circuit, update shallow, outer blossom
            circuit = [];
            u_ = obj.outer(u);
            circuit = [u_, circuit];

            while u_ ~= obj.tip(t)
                u_ = obj.outer(obj.forest(u_));
                circuit = [u_, circuit];
            end

            obj.shallow{t} = [];
            obj.deep{t} = [];

            for i = 1:size(circuit, 2)
                obj.shallow{t} = [obj.shallow{t}, circuit(i)];
            end

            v_ = obj.outer(v);
            while v_ ~= obj.tip(t)
                obj.shallow{t} = [obj.shallow{t}, v_];
                v_ = obj.outer(obj.forest(v_)); 
            end

            % construct deep
            shallowOfT = obj.shallow{t};
            for i =1:size(shallowOfT, 2)
                u_ = shallowOfT(i);
                obj.outer(u_) = t;
                
                deepOfU = obj.deep{u_};
                for j = 1:size(deepOfU, 2)
                    jid = deepOfU(j);
                    obj.deep{t} = [obj.deep{t}, jid];
                    obj.outer(jid) = t;
                end
            end
            
            obj.forest(t) = obj.forest(obj.tip(t));
            obj.type(t) = obj.EVEN;
            obj.root(t) = obj.root(obj.tip(t));
            obj.active(t) = 1;
            obj.outer(t) = t;
            obj.mate(t) = obj.mate(obj.tip(t));

            r = t;
        end
        
        function obj = augment(obj, u, v)
            p = obj.outer(u);
            q = obj.outer(v);

            outv = q;
            fp = obj.forest(p);
            obj.mate(p) = q;
            obj.mate(q) = p;
            obj.expand(p);
            obj.expand(q);
            
            while fp ~= -1
                q = obj.outer(obj.forest(p));
                p = obj.outer(obj.forest(q));
                fp = obj.forest(p);

                obj.mate(p) = q;
                obj.mate(q) = p;

                obj.expand(p);
                obj.expand(q);
            end

            p = outv;
            fp = obj.forest(p);

            while fp ~= -1
                q = obj.outer(obj.forest(p));
                p = obj.outer(obj.forest(q));

                obj.mate(p) = q;
                obj.mate(q) = p;

                obj.expand(p);
                obj.expand(q);
            end
        end

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
        
        function obj = clear(obj)
            obj.clearBlossomIndices();
            
            n = obj.numberOfVertices;
            m = obj.numberOfEdges;
            for i = 1:2 * n
                obj.outer(i) = i;
                obj.deep{i} = [];
                if i <= n
                    obj.deep{i} = [obj.deep{i}, i];
                end
                obj.shallow{i} = [];
                if i <= n
                    obj.active(i) = 1;
                else
                    obj.active(i) = 0;
                end

                obj.type(i) = 0;
                obj.forest(i) = -1;
                obj.root(i) = i;
            
                obj.blocked(i) = 0;
                obj.dual(i) = 0;
                obj.mate(i) = -1;
                obj.tip(i) = i;
            end
            obj.slack = zeros(1, m);
            
        end
        

        function obj = grow(obj)
            obj.reset();
            n = obj.numberOfVertices;
            m = obj.numberOfEdges;
            while size(obj.forestList, 2) > 0
                w = obj.forestList(1);
                obj.forestList(:, 1) = [];
                
                deepForW = obj.deep{w};
                for i = size(deepForW, 2)
                    u = deepForW(i);
                    
                    cont = 0;

                    neighborsOfU = obj.g.getAdjList(u);

                    for j = 1:size(neighborsOfU, 2)
                        v = neighborsOfU(j);
    
                        if v == u || obj.isEdgeBlocked(u, v)
                            continue;
                        end
                        
                        % u is even and v is odd
                        if obj.type(obj.outer(v)) == obj.ODD
                            continue;
                        end
                        
                        % if v is unlabeled
                        if obj.type(obj.outer(v)) ~= obj.EVEN
                            % grow the alternating forest
                            vm = obj.mate(obj.outer(v));

                            obj.forest(obj.outer(v)) = u;
                            obj.type(obj.outer(v)) = obj.ODD;
                            obj.root(obj.outer(v)) = obj.root(obj.outer(u));
                            obj.forest(obj.outer(vm)) = v;
                            obj.type(obj.outer(vm)) = obj.EVEN;
                            obj.root(obj.outer(vm)) = obj.root(obj.outer(u));

                            if ~obj.visited(obj.outer(vm))
                                obj.forestList = [obj.forestList, vm];
                                obj.visited(obj.outer(vm)) = 1;
                            end
                        
                        % now, u and v are all EVEN, if they are on different trees, we find an augmenting path
                        elseif obj.root(obj.outer(v)) ~= obj.root(obj.outer(u))
                            obj.augment(u, v);
                            obj.reset();

                            cont = 1;
                            break;
                        % if u and v are all EVEN and are on the same tree, we found a blossom
                        elseif obj.outer(u) ~= obj.outer(v)
                            b = obj.blossom(u, v);
                            obj.forestList = [b, obj.forestList];
                            obj.visited(b) = 1;

                            cont = 1;
                            break;
                        end
                    end
                    if cont
                        break;
                    end
                end
            end
            obj.perfect = 1;
            for i = 1:n
                if obj.mate(obj.outer(i)) == -1
                    obj.perfect = 0;
                end
            end
        end

        function r = retrieveMatching(obj)

            n = obj.numberOfVertices;
            m = obj.numberOfEdges;

            matching = [];
            for i = 1:2*n
                if obj.active(i) && obj.mate(i) ~= -1 && obj.outer(i) == i
                    obj.expand(i, 1);
                end
            end

            for i = 1:m
                e = obj.g.getEdge(i);
                u = e(1);
                v = e(2);

                if obj.mate(u) == v
                    matching = [matching, i];
                end
            end

            r = matching;
        end
        function r = solveMaximumMatching(obj)
            obj.clear();
            obj.grow();
            r = obj.retrieveMatching();
        end

        function obj = positiveCosts(obj)
            minEdge = 0.0;
            for i = 1:obj.numberOfEdges
                if greater(minEdge - obj.slack(i), 0)
                    minEdge = obj.slack(i);
                end
            end

            for i = 1:obj.numberOfEdges
                obj.slack(i) = obj.slack(i) - minEdge;
            end
        end
        
        function heuristic(obj)
            n = obj.numberOfVertices;
            m = obj.numberOfEdges;

            degree = zeros(1, obj.numberOfVertices);
            B = binaryHeap();

            for i = 1:m
                if obj.isEdgeBlockedByIndex(i)
                    continue;
                end

                p = obj.g.getEdge(i);
                u = p(1);
                v = p(2);

                degree(u) = degree(u) + 1;
                degree(v) = degree(v) + 1;
            end

            for i = 1:n
                B.insert(degree(i), i);
            end

            while B.numElement > 0
                u = B.deleteMin();
                if obj.mate(obj.outer(u)) == -1
                    min = -1;

                    adjOfU = obj.g.getAdjList(u);

                    % TODO shrink this code
                    for i = 1:size(adjOfU, 2)
                        v = adjOfU(i);

                        if v == u || obj.isEdgeBlocked(u, v) || obj.outer(u) == obj.outer(v) || obj.mate(obj.outer(v)) ~= -1
                            continue;
                        end

                        if min == -1 || degree(v) < degree(min)
                            min = v;
                        end
                    end

                    if min ~= -1
                        obj.mate(obj.outer(u)) = min;
                        obj.mate(obj.outer(min)) = u;
                    end
                end
            end
        end

        function updateDualCosts(obj)
            e1 = 0.0;
            e2 = 0.0;
            e3 = 0.0;

            inite1 = 0; 
            inite2 = 0; 
            inite3 = 0;

            n = obj.numberOfVertices;
            m = obj.numberOfEdges;

            for i = 1:m
                edge = obj.g.getEdge(i);
                u = edge(1);
                v = edge(2);

                if (obj.type(obj.outer(u)) == obj.EVEN && obj.type(obj.outer(v)) == obj.UNLABLED) || (obj.type(obj.outer(v)) == obj.EVEN && obj.type(obj.outer(u)) == obj.UNLABLED)
                    if ~inite1 || greater(e1, obj.slack(i))
                        e1 = obj.slack(i);
                        inite1 = 1;
                    end
                elseif obj.outer(u) ~= obj.outer(v) && obj.type(obj.outer(u)) == obj.EVEN && obj.type(obj.outer(v)) == obj.EVEN
                    if ~inite2 || greater(e2, obj.slack(i))
                        e2 = obj.slack(i);
                        inite2 = true;
                    end
                end
            end

            for i = n+1 : 2*n
                if obj.active(i) && i == obj.outer(i) && obj.type(obj.outer(i)) == obj.ODD && (~inite3 || greater(e3, obj.dual(i)))
                    e3 = obj.dual(i);
                    inite3 = 1;
                end
            end

            e = 0.0;
            if inite1
                e = e1;
            elseif inite2
                e = e2;
            elseif inite3
                e = e3;
            end
            
            if greater(e, e2/2.0) && inite2
                e = e2/2.0;
            end

            if greater(e, e3) && inite3
                e = e3;
            end
            
            for i = 1:2*n
                if i ~= obj.outer(i)
                    continue;
                end

                if obj.active(i) && obj.type(obj.outer(i)) == obj.EVEN
                    obj.dual(i) = obj.dual(i) + e;
                elseif obj.active(i) && obj.type(obj.outer(i)) == obj.ODD
                    obj.dual(i) = obj.dual(i) - e;
                end
            end

            for i = 1:m
                edge = obj.g.getEdge(i);
                u = edge(1);
                v = edge(2);

                if obj.outer(u) ~= obj.outer(v)
                    if obj.type(obj.outer(u)) == obj.EVEN && obj.type(obj.outer(v)) == obj.EVEN
                        obj.slack(i) = obj.slack(i) - 2.0 * e;
                    elseif obj.type(obj.outer(u)) == obj.ODD && obj.type(obj.outer(v)) == obj.ODD
                        obj.slack(i) = obj.slack(i) + 2.0 * e;
                    elseif (obj.type(obj.outer(v)) == obj.UNLABLED && obj.type(obj.outer(u)) == obj.EVEN) || (obj.type(obj.outer(u)) == obj.UNLABLED && obj.type(obj.outer(v)) == obj.EVEN)
                        obj.slack(i) = obj.slack(i) - e;
                    elseif (obj.type(obj.outer(v)) == obj.UNLABLED && obj.type(obj.outer(u)) == obj.ODD) || (obj.type(obj.outer(u)) == obj.UNLABLED && obj.type(obj.outer(v)) == obj.ODD)
                        obj.slack(i) = obj.slack(i) + e;
                    end
                end
            end

            for i = n+1:2*n
                if greater(obj.dual(i), 0)
                    obj.blocked(i) = 1;
                elseif obj.active(i) && obj.blocked(i)
                    if obj.mate(i) == -1
                        obj.destroyBlossom(i);
                    else
                        obj.blocked(i) = 0;
                        obj.expand(i);
                    end
                end
            end
        end

        % solving minimum weight matching
        function r = solveMinimumWeightPerfectMatching(obj)
            n = obj.numberOfVertices;
            
            obj.solveMaximumMatching();
            if ~obj.perfect
                error('Error: the graph is not a perfect matching');
            end
            obj.clear();
            
            obj.slack = obj.g.getCostOfEdges();
            
            obj.positiveCosts();
            obj.perfect = 0;
            while ~obj.perfect
                obj.heuristic();
                obj.grow();
                obj.updateDualCosts();
                obj.reset();
            end

            matching = obj.retrieveMatching();
            o = 0.0;

            for i = 1:size(matching, 2)
                o = o + cost(matching(i));
            end

            dualo = 0.0;
            for i = 1:2*n
                if i < n
                    dualo = dualo + obj.dual(i);
                elseif obj.blocked(i)
                    dualo = dualo + obj.dual(i);
                end
            end

            r = {matching, o};
        end

    end
end
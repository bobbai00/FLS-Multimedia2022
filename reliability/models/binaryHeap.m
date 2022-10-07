classdef binaryHeap < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        key
        pos
        satellite

        elementNum
    end
    
    methods
        function obj = binaryHeap()
            obj.elementNum = 0;
            obj.pos = [];
        end

        function obj = clear(obj)
            obj.key = [];
            obj.pos = [];
            obj.satellite = [];
            obj.elementNum = 0;
        end

        function obj = insert(obj, k, s)
            if s > size(obj.pos, 2)
                for i = size(obj.pos, 2) + 1:s+1
                    obj.pos(i) = -1;
                    obj.key(i) = 0;
                    obj.satellite(i) = 0;
                end
            elseif obj.pos(s) ~= -1
                error("satellite already in the heap");
            end

            i = obj.elementNum + 1;
            obj.elementNum = obj.elementNum + 1;
            fi = floor(i/2);
            while fi > 0 && greater(obj.key(fi), k)
                obj.satellite(i) = obj.satellite(fi);
                obj.pos(obj.satellite(i)) = i;
                
                i = fi;
                fi = floor(fi/2);
            end
            
            obj.satellite(i) = s;
            obj.pos(s) = i;
            obj.key(s) = k;
        end

        function r = numElement(obj)
            r = obj.elementNum;
        end

        function r = deleteMin(obj)
            if obj.elementNum == 0
                error("Error: empty heap");
            end
            
            min = obj.satellite(1);
            slast = obj.satellite(obj.elementNum);
            obj.elementNum = obj.elementNum - 1;

            child = 2;
            i = 1;
            while child <= obj.elementNum
                if child < obj.elementNum && greater(obj.key(obj.satellite(child)), obj.key(obj.satellite(child + 1)))
                    child = child + 1;
                end

                if greater(obj.key(slast), obj.key(obj.satellite(child)))
                    obj.satellite(i) = obj.satellite(child);
                    obj.pos(obj.satellite(child)) = i;
                else
                    break;
                end
                i = child;
                child = child * 2;
            end
            
            obj.satellite(i) = slast;
            obj.pos(slast) = i;

            obj.pos(min) = -1;
            r = min;
        end

        function changeKey(obj, k, s)
            obj.remove(s);
            obj.insert(k, s);
        end

        function remove(obj, s)
            i = obj.pos(s);
            fi = floor(i/2);
            while fi > 0
                obj.satellite(i) = obj.satellite(fi);
                obj.pos(obj.satellite(i)) = i;

                i = fi;
                fi = floor(i/2);
            end
            obj.satellite(1) = s;
            obj.pos(s) = 1;

            obj.deleteMin();
        end
    end
end


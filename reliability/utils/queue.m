classdef queue
    %QUEUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        arr = []
        arrSize {mustBeInteger} = 0
        currentIndex = 1
    end
    
    methods
        function obj = queue()
            
        end

        function obj = pushBack(obj, element)
            actualSize = size(obj.arr, 2);
            obj.arr(actualSize + 1) = element;
            obj.arrSize = obj.arrSize + 1;
           
        end

        function obj = pushBackMultiple(obj, elements)
            for i = 1:size(elements, 2)
                obj.pushBack(elements(i));
            end
        end

        function obj = pop(obj)
            if ~obj.isEmpty()
                obj.currentIndex = obj.currentIndex + 1;
                obj.arrSize = obj.arrSize - 1;
            end
        end

        function r = isEmpty(obj)
            r = 0;
            if obj.arrSize == 0
                r = 1;
            end
        end

        function t = front(obj)
            if obj.isEmpty()
                error("ERROR, Queue is empty");
            end
            t = obj.arr(obj.currentIndex);
        end

        function obj = clear(obj)
            obj.arr = [];
            obj.currentIndex = 1;
            obj.arrSize = 0;
        end
    end
end


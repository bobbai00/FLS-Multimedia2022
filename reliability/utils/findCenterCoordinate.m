function centerCoordinate = findCenterCoordinate(widthLineSegment, heightLineSegment, depthLineSegment)
    w = (widthLineSegment(1) + widthLineSegment(2)) / 2.0;
    h = (heightLineSegment(1) + heightLineSegment(2)) / 2.0;
    d = (depthLineSegment(1) + depthLineSegment(2)) / 2.0;
    centerCoordinate = [w, h, d, 255, 255, 255, 255];
end


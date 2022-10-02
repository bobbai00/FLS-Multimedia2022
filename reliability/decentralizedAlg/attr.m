function weight = attr(v, C, flsScheduler)
[isValid, weight] = isProper(v, C, flsScheduler);

% weight = -weight;
if ~isValid
    weight = 0;
end
end


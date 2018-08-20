function [ options ] = Initialize( options )
if ~isfield(options, 'numOfBackGroundFrames')
    options.numOfBackGroundFrames = 120;
end
if ~isfield(options, 'numOfOverallModelFrames')
    options.numOfOverallModelFrames = 140;
end
if ~isfield(options, 'startFrame')
    options.startFrame = 1;
end
if ~isfield(options, 'numOfGrimsonFramesMax')
    options.numOfGrimsonFramesMax = 150;
end
if ~isfield(options, 'displayMode')
    options.displayMode = 0;
end
if ~isfield(options, 'waitBar')
    options.waitBar = 0;
end
if ~isfield(options, 'profileMode')
    options.profileMode = 0;
end
if ~isfield(options, 'scatterMode')
    options.scatterMode = 0;
end
if ~isfield(options, 'playMovieMode')
    options.playMovieMode = 0;
end
if ~isfield(options, 'numOfRefSets') % number of control pixel sets (=estimators)
    options.numOfRefSets = 3;
end
if ~isfield(options, 'numOfAreas')
    options.numOfAreas = 4;
end
if ~isfield(options, 'alphaBG')
    options.alphaBG = 0.99995;
end
if ~isfield(options, 'fileName')
    options.fileName = [];
end

end


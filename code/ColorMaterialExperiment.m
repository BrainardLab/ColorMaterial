function ColorMaterialExperiment

% Experimental file for the color material experiment.  
% 
% Feb 11 ar  Adapted it from 'the standard envelope'


% Set up the directory and make sure it's on the path.

exp.baseDir = fileparts(which('ColorMaterialExperiment'));
exp.dataDir = getpref('ColorMaterial', 'dataFolder');
% Figure out the data directory path.  Instead of the old way of finding the data directory on the same level, better to simply provide it.
exp.stimulusDir = getpref('ColorMaterial', 'stimulusFolder');


% Dynamically add the code to the path if it isn't already on it.
if isempty(strfind(path, exp.baseDir))
	fprintf('- Adding ColorMaterialExperiment dynamically to the path...');
	addpath(RemoveSVNPaths(genpath(exp.baseDir)), '-end');
	fprintf('Done\n');
end
if isempty(strfind(path, exp.stimulusDir))
    fprintf('- Adding ColorMaterial stimuli dynamically to the path...');
	addpath(RemoveSVNPaths(genpath(exp.stimulusDir)), '-end');
	fprintf('Done\n');
end

% Set the configuration file path.
exp.configFileDir = sprintf( sprintf('%s/config', exp.baseDir));

% Read the condition list.
exp.conditionListFileName = sprintf('%s/conditions.cfg', exp.configFileDir);
exp.conditionList =  ReadStructsFromText(exp.conditionListFileName);
exp.numConditions = length(exp.conditionList);

% Display a list of what conditions are available and have the user select
% one by number.
while true
	fprintf('\n- Available conditions\n\n');
	
	for i = 1:exp.numConditions
		fprintf('%d - %s\n', i, exp.conditionList(i).name);
	end
	fprintf('\n');
	exp.conditionIndex = GetInput('Choose a condition number', 'number', 1);
	
	% If the user selected a condition in the range of available conditions,
	% break out of the loop.  Otherwise, display the condition list again.
	if any(exp.conditionIndex == 1:exp.numConditions)
		% Create the path to where the condition's data will be stored.
		exp.conditionDataDir = sprintf('%s/%s', exp.dataDir, exp.conditionList(exp.conditionIndex).dataDirectory);
		break;
	else
		disp('*** Invalid condition selected, try again.');
	end
end

% In the data directory, we can see the list of subjects available if the
% condition has been run before.  If it hasn't been run, then we will create
% the top level data directory, then ask the user to create a subject.

	availableSubjects = {};
	if exist(exp.conditionDataDir, 'dir')
		% Get a list of available subjects.
		dirList = dir(exp.conditionDataDir);
		
		% Skip the first two results because they are '.' and '..'.
		for i = 3:length(dirList)
			% Filter out non directory files.  We assume all directories are
			% subject directories.
			if dirList(i).isdir
				if ~strcmp(dirList(i).name, '.svn')
					availableSubjects{end+1} = dirList(i).name; %#ok<AGROW>
				end
			end
		end
	else
		mkdir(exp.conditionDataDir);
	end


% Display the list of available subjects and also give an option to create
% one.
while true
	fprintf('- Subject Selection\n\n');
	
	fprintf('0 - Create a new subject\n');
	
	for i = 1:length(availableSubjects)
		fprintf('%d - %s\n', i, availableSubjects{i});
	end
	fprintf('\n');
	
	subjectIndex = GetInput('Choose a subject number', 'number', 1);
	
	if subjectIndex == 0
		% Create a new subject.
		newSubject = GetInput('Enter a new subject name', 'string');
		mkdir(sprintf('%s/%s', exp.conditionDataDir, newSubject));
		availableSubjects{end+1} = newSubject; %#ok<AGROW>
	elseif any(subjectIndex == 1:length(availableSubjects))
		% We got our subject, now setup the proper variables and get out of
		% this loop.
		exp.subject = availableSubjects{subjectIndex};
		exp.subjectDataDir = sprintf('%s/%s', exp.conditionDataDir, ...
			exp.subject);
		break;
	else
		disp('*** Invalid subject selected, try again.');
	end
end
% Set the config file name for this condition.
exp.configFileName = sprintf('%s/%s', exp.configFileDir, exp.conditionList(exp.conditionIndex).configFile);

% Grab the subversion information now.  We'll add it the 'params' variable
% later.  We do it here just in case we get an error with function which
% would cause the program to terminate.  If we did it after the experiment
% finished, we would get an error prior to saving, thus losing collected
% data.

% % FIX THIS 
% svnInfo.VisualWorldColorSVNInfo = GetSVNInfo(exp.baseDir);
% svnInfo.toolboxSVNInfo = GetBrainardLabStandardToolboxesSVNInfo;

% Find the largest iteration number in the data filenames.
iter = 0;
d = dir(exp.subjectDataDir);
for i = 3:length(d)
	s = textscan(d(i).name, '%s%s%s', 'Delimiter', '-');
	if ~isempty(s{3})
		% Get rid of the .mat part.
		n = strtok(s{3}, '.');
		
		val = str2double(n);
		if ~isnan(val) && val > iter
			iter = val;
		end
	end
end
iter = iter + 1;

exp.saveFileName = sprintf('%s/%s-%s-%d.mat', exp.subjectDataDir, ...
	exp.subject, exp.conditionList(exp.conditionIndex).dataDirectory, iter);

% Store the date/time when the experiment starts.
exp.experimentTimeNow = now;
exp.experimentTimeDateString = datestr(exp.experimentTimeNow);

% Now we can execute the driver associated with this condition.
driverCommand = sprintf('params = %s(exp);', exp.conditionList(exp.conditionIndex).driver);
eval(driverCommand);

% Save the experimental data 'params' along with the experimental setup
% data 'exp'.
%save(exp.saveFileName, 'params', 'exp', 'svnInfo');
if strcmp (exp.conditionList(exp.conditionIndex).name, 'Training')
	% don't save anything.
else
	save(exp.saveFileName, 'params', 'exp');
	fprintf('- Data saved to %s\n', exp.saveFileName);
end

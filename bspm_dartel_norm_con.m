function bspm_dartel_norm_con(analysisdirs, flowfields, template, voxsize, fwhm)
% BSPM_DARTEL_NORM_CON
%
%   ARGUMENTS:
%       analysisdirs = analysis dirs containg con*img files
%       flowfields = flowfields (i.e. u_rc1*) (same length/order as images)
%       template = template image (i.e. Template_6.nii)
%       voxsize = voxel size for re-sampling (isotropic) [default = 3]
%       fwhm = kernel for smoothing (isotropic) [default = 6]
%

% ------------------------------- Copyright (C) 2014 -------------------------------
%	Author: Bob Spunt
%	Affilitation: Caltech
%	Email: spunt@caltech.edu
%
%	$Revision Date: Aug_20_2014

if nargin<3, error('USAGE: bspm_dartel_norm_func(analysisdirs, flowfields, template, voxsize, fwhm)'); end
if nargin<4, voxsize = 3; end
if nargin<5, fwhm = 8; end
if length(fwhm)==1, fwhm = repmat(fwhm,1,3); end
if length(voxsize)==1, voxsize = repmat(voxsize,1,3); end
if ischar(flowfields), flowfields = cellstr(flowfields); end
if ischar(template), template = cellstr(template); end
if ischar(analysisdirs), analysisdirs = cellstr(analysisdirs); end
nsubs = length(analysisdirs);
matlabbatch{1}.spm.tools.dartel.mni_norm.template = cellstr(template);
cnames = cell(nsubs,1);
for s = 1:nsubs
    cim = files([analysisdirs{s} filesep 'con*img']);
    tmp = spm_vol(char(cim));
    cnames{s} = {tmp.descrip};
    if isempty(cim), cim = files([analysisdirs{s} filesep 'con*nii']); end
    if isempty(cim), error('No contrast images found in %s', analysisdirs{s}); end
    cim = strcat(cim, ',1');
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(s).flowfield = flowfields(s);
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(s).images = cim;
end                     
matlabbatch{1}.spm.tools.dartel.mni_norm.vox = voxsize;
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [-78 -112 -50; 78 76 85];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = fwhm;
spm_jobman('initcfg');    
global defaults
spm_get_defaults('normalise.write.prefix',sprintf('w%d',voxsize*100));
spm_get_defaults('smooth.prefix',sprintf('s%d',fwhm));
spm_jobman('run',matlabbatch);

% now fix contrast names
for s = 1:nsubs
    cc = cnames{s};
    basename = sprintf('%s/s%dw%d', analysisdirs{s}, fwhm(1), voxsize(1)); 
    wim = files([analysisdirs{s} filesep 'sw*img']);
    for i = 1:length(wim)
        h = spm_vol(wim{i});
        d = spm_read_vols(h);
        h.descrip = cc{i};
        [p n e] = fileparts(wim{i});
        h.fname = regexprep(h.fname, 'sw', sprintf('s%dw%d', fwhm(1), voxsize(1))); 
        spm_write_vol(h, d);
    end
    delete(wim{:});
end
 


end

 
 
 
 

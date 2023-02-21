function mix = readmix(fname,rxxFlag)
% MIX=READMIX(FNAME,RXXFLAG) 
%  Reads the parameters of a mixture of gaussians from file specified
%  by string  FNAME and builds up the cell array MIX with the relevant 
%  parameters. The overall format of the output file
%  is always the same. RXXFLAG is a boolean flag which defines 
%  how the model covariance  is defined in the data file. If RXXFLAG=1, 
%  each gaussian is described by its covariance matrix. With RXXFLAG=0, 
%  each gaussian is described instead by a "generation matrix".
%
%   The generation matrix defines the transformation required for
%   generating samples of a given class from uncorrelated
%   samples of zero mean and unitary variance. Let s be a vector
%   of gaussian uncorrelated samples of zero mean and unitary variance.
%   If A is a generation matrix for a given Gaussian distribution,then
%   data x for this class can be generated by
%
%   x = A s
% 
%   The covariance matrix Rxx is related to A by
%
%    Rxx = A A^T 
%
%  The format of the mixture file is the following:
%
%  [Number of dimensions]
%  [Number of gaussians]
%  [Weight-gaussian-1 Weight-gaussian-2 ... Weight-gaussian-n]
%  [Mean of gaussian  1]
%  [Generation or covariance matrix 1]
%  [Mean of gaussian  2]
%  [Generation or covariance matrix 2]
% ...
%  [mean of gaussian  n]
%  [Generation or covariance matrix n]
%
% The cell array MIX has the following components:
%
%  MIX{1} - Number of Gaussians
%  MIX{2} - Vector of weights
%  MIX{3} ...  MIX{K+2}...MIX{NG+2} Parameter 
%             data for the Gaussians   1...K...NG  (NG denotes the number of Gaussians)
%  The cell corresponding to each Gaussian, G=MIX{K}, includes the following parameters:
%
%    G{1} - Mean
%    G{2} - Generation matrix
%    G{3} - Covariance matrix
%    G{4} - Inverse of covariance matrix
%    G{5} - Determinant of covariance matrix
%
% See also: SAVEMIX
%
% Author: Fernando M. Silva
%         Instituto Superior T'ecnico
%         fcr@inesc.pt
%
  fid = fopen(fname,'r');

  dim = fscanf(fid,'%d',1);
  ng  = fscanf(fid,'%d',1);
  p=fscanf(fid,'%f',ng);

  mix{1} = ng;
  mix{2} = p;

  for i=1:ng,
    m=fscanf(fid,'%f',dim);
    mat=fscanf(fid,'%f',[dim,dim]);

    if(rxxFlag),      
      if(sum(sum(abs(mat-mat'))) ~= 0),
	fprintf(1,'Error found reading gaussian %d from %s\n:',i,fname);
	error('Covariance matrix is not symmetric');
      end
      [v,d] = eig(mat);
      lg = v * sqrt(d);
    else
      lg = mat;
    end



    rxx = lg*lg';
    drxx = det(rxx);
    c = {m,lg,rxx,inv(rxx),drxx};
    mix{i+2} = c;
  end

  th(1)=p(1);
  for k=2:ng,
    th(k) = th(k-1) + p(k);
  end;
  if(abs(th(ng) - 1) > 1e-6),
    fprintf(1,'Error in weights: weights add up to %f (should be 1)',th);
    error('Error found in readmix');
  end
  mix{ng+3} = th;
  fclose(fid);
  return
  

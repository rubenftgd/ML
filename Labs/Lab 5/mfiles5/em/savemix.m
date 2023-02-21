function savemix(m,fname,rxxFlag)
%  SAVEMIX(MIX,FNAME,RXX) 
%  Saves the parameters of a mixture of gaussians specified by MIX
%  on the file named FNAME. The overall format of the output file
%  is always the same. RXX is a boolean flag which defines 
%  how the model covariance  is defined. If RXX=1, the covariance 
%  matrices are written. This is usually the relevant data needed
%  for the definition of the model. With RXX=0, a generation matrix 
%  is written instead of the covariance matrix. 
%
%  Note that, in general, there are an infinite number of generating 
%  matrices leading to the same covariance matrix. Therefore, the 
%  generation matrix may be different from the expected. The one
%  computed here results from the eigenvalue decomposition of the
%  covariance matrix; however, any orthogonal transformation of this
%  matrix leads to the same covariance matrix.
%
%  The format of the output mixture file is the following:
%
%  [Number of dimensions]
%  [Number of gaussians]
%  [Prior-gaussian-1 Prior-gaussian-2 ... Prior-gaussian-n]
%  [Mean of gaussian  1]
%  [Generation or covariance matrix 1]
%  [Mean of gaussian  2]
%  [Generation or covariance matrix 2]
% ...
%  [mean of gaussian  n]
%  [Generation or covariance matrix n]
%
%   The generating matrix defines the transformation required for
%   generating samples of a given class. If s is a vector of 
%   gaussian uncorrelated samples of 0 mean and unitary variance,
%   and A is a generation matrix for a given class, data x this class
%   can be generated by
%
%   x = A s
% 
%   Note that the covariance matrix Rxx is related with A by
%
%    Rxx = E[xx^T] = E[A s s^T A^T] = A E[ s s^T] A^T = A A^T 
%
% The cell array MIX has the following components:
%
%  MIX{1} - Number of gaussians
%  MIX{2} - Vector of Priors
%  MIX{3} ...  MIX{K+2}...MIX{NG+2} Parameter 
%             data for gaussian   1...K...NG 
%  Each gaussian cell G=MIX{k} includes the following parameters:
%
%    G{1} - Mean
%    G{2} - Generation matrix
%    G{3} - Covariance matrix
%    G{4} - Inverse of covariance matrix
%    G{5} - Determinant of covariance matrix
%
% See also: READMIX
%
% Author: Fernando M. Silva
%         Instituto Superior T'ecnico
%         fcr@inesc.pt
%

  fid = fopen(fname,'w');

  dim = length(m{3}{2});
    
  fprintf(fid,'%d\n',dim);
  ng  = m{1};
  p   = m{2};
  fprintf(fid,'%d\n\n',ng);  

  for i=1:ng,
    fprintf(fid,'%20.10f ',p(i));
  end

  fprintf(fid,'\n\n');
  for i=1:ng,
    g = m{i+2};
    for k=1:dim,
      fprintf(fid,'%20.2f ',g{1}(k));
    end
    fprintf(fid,'\n\n');
    
    rxx=g{3};
    if(rxxFlag),
      out = rxx;
    else
      [v,d] = eig(rxx);
      out = v * sqrt(d);
    end


    for k2=1:dim,
      for k1=1:dim,
	fprintf(fid,'%20.2f ',out(k1,k2));
      end
      fprintf(fid,'\n');
    end
    fprintf(fid,'\n\n\n');
 end
 fclose(fid);
 
 fprintf(1,'------ Wrote %s\n',fname);
 return
  










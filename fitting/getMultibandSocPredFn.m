%% Define the function
% params (gain, a, lmbd) in equation gain*sum(resp(A^2) ./ (a + lmbd*resp(B^2))));

function fn = getMultibandSocPredFn(Amat, Bmat)

    nsf = size(Amat, 4);

    % outfirst = NaN(501,501,nor,nsf);
    A_sq_resp = squeeze(sum(sum(bsxfun(@minus,Amat,mean(mean(Amat,2),1)).^2, 2),1)); % nor * nsf * nim
    % TODO: get pixel variance within aperture
    clear Amat;
    
    % outsecond = NaN(301,301,nor,nsf);
    B_sq_resp = squeeze(sum(sum(Bmat.^2, 2),1));
    B_sq_resp_repmat = repmat(sum(B_sq_resp,2),[1, nsf]); % collapse and re-expand
    clear Bmat;
    
    % TODO NOTE; we only use these collapsed ones; x and y are no longer
    % relevant
    
    fn = @(params)(params(1) * squeeze(sum(sum(A_sq_resp ./ (1 + params(2)*B_sq_resp_repmat)))));
%         cost = sum(sqrt((prediction - targetVec).^2));
    
%     function cost = multibandSocCostFn(params)  
%         prediction = params(1) * squeeze(sum(sum(A_sq_resp ./ (params(2) + params(3)*B_sq_resp_repmat))));
%         cost = sum(sqrt((prediction - targetVec).^2));
%     end
end
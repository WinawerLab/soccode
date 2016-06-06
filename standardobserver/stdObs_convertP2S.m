function sigmaS = stdObs_convertP2S(sigmaP, n)
% CONVERT SIGMA P-TO-S
% sigmaS = stdObs_convertP2S(sigmaP, n)
%
% Convert the pRF model's pRF size parameter to the equivalent SOC model's
% pRF size parameter

    sigmaS = (sigmaP - 0.23) ./ (0.16./sqrt(n) - 0.05);
end


function [nonseps, seps, theta, epsilon] = dsm(evaluations, lambda, Global)
    fhat_archive = evaluations.fhat;
    f_archive = evaluations.F;
    fp1 = evaluations.base;
    F1 = ones(Global.problem.dimension, Global.problem.dimension) * fp1;
    F2 = repmat(fhat_archive', Global.problem.dimension, 1);
    F3 = repmat(fhat_archive, 1, Global.problem.dimension);
    F4 = f_archive;
    FS = cat(3, F1, F2, F3, F4);
    Fmax = max(FS, [], 3);
    %Fmin = min(FS, [], 3);
    FS = cat(3, F1 + F4, F2 + F3);
    Fmax_inf = max(FS, [], 3);
    theta = nan(Global.problem.dimension);
    %reliable_calcs = 0;
    muM = eps / 2;
    gamma = @(n)((n.*muM)./(1-n.*muM));
    errlb = gamma(2) * Fmax_inf;
    errub = gamma(Global.problem.dimension^0.5) * Fmax;
    I1 = lambda <= errlb;
    theta(I1) = 0;
    I2 = lambda >= errub;
    theta(I2) = 1;
    %si1 = sum(sum(I1));
    %si3 = sum(sum(I2));
    I0 = (lambda == 0);
    c0 = sum(sum(I0));
    count_seps = sum(sum(~I0 & I1));
    count_nonseps = sum(sum(I2));
    reliable_calcs = count_seps + count_nonseps;
    w1 = ((count_seps+c0) / (c0+reliable_calcs));
    w2 = (count_nonseps / (c0+reliable_calcs));
    epsilon = w1*errlb + w2*errub;
    %grayind = (lambda < errub) & (lambda > errlb);
    %grayindsum = sum(sum(grayind));
    AdjTemp = lambda > epsilon;
    idx = isnan(theta);
    theta(idx) = AdjTemp(idx);
    theta = theta | theta';
    theta(logical(eye(Global.problem.dimension))) = 1;
    components = findConnComp(theta);
    h = @(x)(length(x) == 1);
    sizeone = cellfun (h, components);
    seps = components(sizeone);
    seps = cell2mat(seps);
    components(sizeone) = [];
    nonseps = components;
end

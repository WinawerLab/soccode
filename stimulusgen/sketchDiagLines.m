sz = 100;
spacing = 10;
dotme = [1 2];
dotme = dotme / norm(dotme);
[xx, yy] = meshgrid(1:sz, 1:sz);

lines = zeros(sz, sz);

for ii = 1:sz
    for jj = 1:sz
        loc = [xx(ii,jj), yy(ii,jj)];
        if dot(dotme, loc) / norm(loc) == 1
            lines(loc(1), loc(2)) = 1;
        end
    end
end
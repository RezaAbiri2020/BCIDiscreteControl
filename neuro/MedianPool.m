function map_filt = MedianPool(map,sz)

% sizing
[m,n] = size(map);
ex = ones(1,m/sz)*sz;
ey = ones(1,n/sz)*sz;

% split into cells
ac = mat2cell(a,ex,ey);

% compute for each cell
for i=1:m/sz,
    for j=1:n/sz,
        ac{i,j} = median(ac{i,j}(:));
    end
end
map_filt = cell2mat(ac);

end % MedianPool
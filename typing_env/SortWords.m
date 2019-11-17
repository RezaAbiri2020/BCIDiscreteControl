function [ ix_sort ] = SortWords( corpus )
% function: Short description
%
% Extended description
% TODO: implement other sorting algorigthms

% if b_type == length ...
word_lens = cellfun(@length, corpus);
[~, ix_sort] = sort(word_lens);
% words = corpus(ix_sort);

end  % function

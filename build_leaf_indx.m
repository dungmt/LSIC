function [theNode,synsets] = build_leaf_indx(theNode,synsets, parent_indx)
    names=fieldnames(theNode);
    node_id = getfield(theNode,names{1}) ;
    fprintf('\n build_leaf_indx: Process node %s',theNode.words);
    if isempty(theNode.children)
        theNode.leaf_indx = node_id;
        theNode.parent_indx = parent_indx;
    else
        leaf_indx = [];
        removed_children =[];
        for i=1: theNode.num_children
            child_id = theNode.children(i);
            Node = synsets(child_id);
            if isfield(Node,'parent_indx') && ~isempty(Node.parent_indx)
                removed_children = [removed_children, child_id];
                continue;
            end
            if ~isfield(Node,'leaf_indx') || isempty(Node.leaf_indx)
                [Node2,synsets] = build_leaf_indx(Node, synsets,node_id);                
                synsets(child_id).parent_indx = Node2.parent_indx;     
                synsets(child_id).leaf_indx = Node2.leaf_indx;
            elseif isempty(Node.children)
                synsets(child_id).parent_indx = parent_indx;
            end
            leaf_indx = [leaf_indx, synsets(child_id).leaf_indx];
        end
        if ~isempty(removed_children)
            fprintf('\nCap nhat children cua node %s',theNode.WNID); 
            children = theNode.children;
            for j=1:length(removed_children)
                children(children==removed_children(j))=[];
            end
            theNode.children = children;
            theNode.num_children = length(children);

         end
        theNode.leaf_indx = leaf_indx;
        theNode.parent_indx = parent_indx
    end
end
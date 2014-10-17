function m = maxF (AP,j)
    if numel(AP)==1
        m = 1;
        return;
    end
    if numel(AP)==2
        if (AP{1}(j)>AP{2}(j))
            m=1;
        else
            m=2;
        end
        return;
    end
    t = fusion.maxF(AP(2:end),j)+1;
    if AP{1}(j)>AP{t}(j)
        m=1;
    else
        m = t;
    end
end
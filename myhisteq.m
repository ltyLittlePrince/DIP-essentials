% userpath('C:\Users\LTY\Desktop\dip_hw1\asset')
function [matched_img] = histogram_matching(img, template)
    % 直方图匹配主函数
    [~,equal_luma] = histogram_equalization(img); % 获得img的均衡后亮度
    table2 = histogram_equalization(template); % 获得模板规定的均衡直方图
    % 构造逆查找表
    reverseTable2 = zeros(1,256);
    for i=0:255
        [b,e] = binary_search(table2,i);
        offset = 0;
        while b==0 && e==0 % 先在逆查找表中查找，存在且同等亮度差中较小者
            offset = offset+1;
            if i-offset>=0, [b,e]=binary_search(table2,i-offset); end 
            if b~=0 && e~=0, break, end
            if i+offset<=255, [b,e]=binary_search(table2,i+offset); end
        end
        % 选取相同取值的下标区间[b,e]的中心点作为预测值
        p = div(b+e,2);
        % p = b; % 备选方案
        reverseTable2(i+1) = p-1; % 加1/减1是因为索引从1开始。
    end
    final_luma = reverseTable2(equal_luma+1);
    % 计算一下原始亮度
    [h,w,~] = size(img);
    img = reshape(img,h*w,3);
    luma = sum(double(img)*[0.299;0.587;0.114],2);
    luma = uint8(round(luma));
    % 再逐像素计算新老亮度比
    table_ratio = double(final_luma)./double(luma');
    table_ratio = reshape(table_ratio,h*w,1);
    % 相同像素亮度值等比例缩放，故横轴方向扩展三倍
    table_ratio = repmat(table_ratio, 1, 3);
    % RGB值点乘上每个像素，获得新的RGB值
    result = uint8(round(double(img).*table_ratio));
    matched_img = reshape(result,h,w,3); 
end

% 有序数组内二分查找
function [idx1, idx2] = binary_search(vector, num) 
    [~,len] = size(vector);
    lb = 1; rb = len; temp = 0;
    while lb <= rb
       temp = div(lb+rb,2);
       if vector(temp)<num, lb=temp+1;
       elseif vector(temp)>num, rb=temp-1;
       else, break;
       end
    end
    if vector(temp)==num
        idx1 = temp; idx2 = temp;
        while idx1>=1 && vector(idx1)==num, idx1=idx1-1; end
        while idx2<=256 && vector(idx2)==num, idx2=idx2+1; end
    else
        idx1 = 0; idx2 = 0;
    end
end

% 直方图均衡化子函数
function [table, equal_luma, equal_img] = histogram_equalization(img)
    % 直方图均衡主函数,img是亮度矩阵（R/G/B）
    [h,w,~] = size(img);
    img = reshape(img,h*w,3);
    luma = sum(double(img)*[0.299;0.587;0.114],2);
    luma = uint8(round(luma));
    % 第二个参数值为[0,1,...,256], 每个bin维护左闭右开区间
    bincounts = histcounts(luma, linspace(0,256,257)) / (h*w);
    cdf = cumsum(bincounts);
    table = uint8(round(255*cdf));
    % plot(linspace(0,255,256),table) % 检查亮度转换表
    if nargout>=2
        equal_luma = table(luma+1);
        if nargout==3
            % 逐像素的新老亮度比率
            table_ratio = double(equal_luma)./double(luma');
            table_ratio = reshape(table_ratio,h*w,1);
            % 相同像素亮度值等比例缩放，故横轴方向扩展三倍
            table_ratio = repmat(table_ratio, 1, 3);
            % RGB值点乘上每个像素，获得新的RGB值
            result = uint8(round(double(img).*table_ratio));
            equal_img = reshape(result,h,w,3); 
        end
    end
end

% 辅助函数 - 整除
function [res] = div(A,B)
   res = idivide(A,int32(B),'floor');
end
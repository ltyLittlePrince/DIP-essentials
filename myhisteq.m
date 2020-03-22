% userpath('C:\Users\LTY\Desktop\dip_hw1\asset')
function [matched_img] = histogram_matching(img, template)
    % ֱ��ͼƥ��������
    [~,equal_luma] = histogram_equalization(img); % ���img�ľ��������
    table2 = histogram_equalization(template); % ���ģ��涨�ľ���ֱ��ͼ
    % ��������ұ�
    reverseTable2 = zeros(1,256);
    for i=0:255
        [b,e] = binary_search(table2,i);
        offset = 0;
        while b==0 && e==0 % ��������ұ��в��ң�������ͬ�����Ȳ��н�С��
            offset = offset+1;
            if i-offset>=0, [b,e]=binary_search(table2,i-offset); end 
            if b~=0 && e~=0, break, end
            if i+offset<=255, [b,e]=binary_search(table2,i+offset); end
        end
        % ѡȡ��ͬȡֵ���±�����[b,e]�����ĵ���ΪԤ��ֵ
        p = div(b+e,2);
        % p = b; % ��ѡ����
        reverseTable2(i+1) = p-1; % ��1/��1����Ϊ������1��ʼ��
    end
    final_luma = reverseTable2(equal_luma+1);
    % ����һ��ԭʼ����
    [h,w,~] = size(img);
    img = reshape(img,h*w,3);
    luma = sum(double(img)*[0.299;0.587;0.114],2);
    luma = uint8(round(luma));
    % �������ؼ����������ȱ�
    table_ratio = double(final_luma)./double(luma');
    table_ratio = reshape(table_ratio,h*w,1);
    % ��ͬ��������ֵ�ȱ������ţ��ʺ��᷽����չ����
    table_ratio = repmat(table_ratio, 1, 3);
    % RGBֵ�����ÿ�����أ�����µ�RGBֵ
    result = uint8(round(double(img).*table_ratio));
    matched_img = reshape(result,h,w,3); 
end

% ���������ڶ��ֲ���
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

% ֱ��ͼ���⻯�Ӻ���
function [table, equal_luma, equal_img] = histogram_equalization(img)
    % ֱ��ͼ����������,img�����Ⱦ���R/G/B��
    [h,w,~] = size(img);
    img = reshape(img,h*w,3);
    luma = sum(double(img)*[0.299;0.587;0.114],2);
    luma = uint8(round(luma));
    % �ڶ�������ֵΪ[0,1,...,256], ÿ��binά������ҿ�����
    bincounts = histcounts(luma, linspace(0,256,257)) / (h*w);
    cdf = cumsum(bincounts);
    table = uint8(round(255*cdf));
    % plot(linspace(0,255,256),table) % �������ת����
    if nargout>=2
        equal_luma = table(luma+1);
        if nargout==3
            % �����ص��������ȱ���
            table_ratio = double(equal_luma)./double(luma');
            table_ratio = reshape(table_ratio,h*w,1);
            % ��ͬ��������ֵ�ȱ������ţ��ʺ��᷽����չ����
            table_ratio = repmat(table_ratio, 1, 3);
            % RGBֵ�����ÿ�����أ�����µ�RGBֵ
            result = uint8(round(double(img).*table_ratio));
            equal_img = reshape(result,h,w,3); 
        end
    end
end

% �������� - ����
function [res] = div(A,B)
   res = idivide(A,int32(B),'floor');
end
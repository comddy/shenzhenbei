MAX = 10000;%Ԥ���ۻ��������������������
total = 20;%������,Ҳ������СʱΪ��λ
m = 5;%ÿ���������������Ӷ��ٸ��ִ������
m0 = 40;%��ʼ������
e = 0.3;%����֮���������ֵ
e2 = 0.5;%�û���������ֵ
num = 500;%ÿ��num���û�������
activity = 1;%ȡ1�ܴﵽ�����ͬϵ����һ��

%��ϳ�ÿ������������
a1 =       984.7  ;
       b1 =       11.25 ;
       c1 =      0.7128 ;
       a2 =       120.4 ;
       b2 =       11.71 ;
       c2 =      0.8534 ;
       a3 =       232.3 ;
       b3 =       12.84  ;
       c3 =      0.9464 ;
       a4 =       211.7 ;
       b4 =       9.554 ;
       c4 =       7.581 ;
       a5 =      -176.4  ;
       b5 =       7.249  ;
       c5 =       5.674 ;
       a6 =      -65.14 ;
       b6 =       15.76 ; 
       c6 =       5.265 ;
t = 1:total;%����
newtalk = a1.*exp(-((t-b1)./c1).^2) + a2.*exp(-((t-b2)./c2).^2) +...
              a3.*exp(-((t-b3)./c3).^2) + a4.*exp(-((t-b4)./c4).^2) +... 
              a5.*exp(-((t-b5)./c5).^2) + a6.*exp(-((t-b6)./c6).^2);%ÿ��������������
newtalk = fix(newtalk)+6;
u1 = 1/pi*atan(activity);%�۵����ʱ����ͬϵ��,���Ϊ0.5
u2 = 0.2/pi*atan(activity);%�۵㲻ͬʱ����ͬϵ�������Ϊ0.1
cocoon = 10;%10����û�п�������ֵ������Ӿ���Ϊ������Ϣ�뷿
step = 20;%�û�ÿ�����ߵĲ���

%���û��ĽǶȳ�����������������ָ�꣺��Ȥ�������ӣ���ҳ�Ƽ������ò�η�����ȷ������ָ���Ȩ�أ�����TOPSIS������ڵ�÷֣����ݵ÷�ȷ��ת�Ƹ���
w1 = 0.7;%�û���ȤȨ��
w2 = 0.15;%������Ȩ��
w3 = 0.15;%��ҳ�Ƽ�Ȩ��
last = 3;%��ҳ�Ƽ����ǹ�ȥlast�����������

op = zeros(1,MAX);%���Ӱ����Ĺ۵�
A = zeros(MAX,MAX);%��ʾ���ӵ��������,A(i,j)��ʾiָ��j��������ͱ�ʾ��ȣ�������ͱ�ʾ����
op(1:m0) = unifrnd(-1,1,[1,m0]);%��ʼ��
trap = zeros(num,total);%0��ʾû������뷿��1��ʾ����
%�����ʼ����ֻҪ�۵���������ֵ�ھ�����
for i = 1:m0
    for j = i+1:m0
        if abs(op(i) - op(j)) < e
            A(i,j) = 1;
            A(j,i) = 1;
        end
    end
end

op(m0+1:MAX) = unifrnd(-1,1,[1,MAX-m0]);%���������ӹ۵���ȷֲ���[-1,1]
cnt = m0;%��ǰ���ӵ�����
for day = 1:total
    %�Ƚ��½ڵ���ɽڵ�����
    cnt0 = cnt;
    for i = 1:newtalk(day)%ÿ��������������
        in_degree = sum(A(1:cnt,1:cnt));%����������������Ӹ���
        interval = cumsum(in_degree);%���ۺ�
        all = sum(in_degree);%�����
        for ji = 1:m
            while 1
                rand_degree = fix(all*rand()+1);
                Ans = find(rand_degree <= interval);
                j = Ans(1);
                if abs(op(i+cnt0) - op(j)) < e
                    A(i+cnt0,j) = 1;
                    break;
                end
            end
        end
        cnt = cnt + 1;
    end
    
    %����������������
    
    %�����û���ʼλ��
    adress = zeros(num,step);%��¼num���û���step�����߹��Ľڵ�
    user_op = zeros(num,step);%��¼num���û���step����۵�ı仯
    in_degree = sum(A(1:cnt,1:cnt));%�����������������
    interval = cumsum(in_degree);%���ۺ�
    all = sum(in_degree);%�����
    user_op(:,1) = (unifrnd(-1,1,[num,1]));%�û��ĳ�ʼ�۵�
    %�ȸ�����ʼλ��
    for h = 1:num
        while 1
            rand_degree = fix(all*rand()+1);
            Ans = find(rand_degree <= interval);
            j = Ans(1);
            if abs(user_op(h,1) - op(j)) < e
                adress(h,1) = j;%�û��ĳ�ʼλ��
                break;
            end
        end
    end
    %num���û�ͬʱ����
    IC_cnt = zeros(1,num);%������
    P = zeros(num,cnt);%num���û���cnt���ڵ�
    record = zeros(cnt,3);%cnt���ڵ㣬3������ָ��
    for walk = 2:step
        for h = 1:num  %����ת�Ƹ���
            %�����ʼ����
            %�û���Ȥ
            distance = abs(op(1:cnt) - user_op(h,walk-1));
            oppos1 = find(e2 >= distance);
            turn = in_degree(oppos1).^3;
            record(oppos1,1) = turn';
            oppos2 = find((e2 < distance) + (2*e2 > distance) - 1);
            turn = in_degree(oppos2).^2;
            record(oppos2,1) = turn';
            oppos3 = find(2*e2 <= distance);
            turn = in_degree(oppos3).^1;
            record(oppos3,1) = turn';
            %������
            qwe = adress(h,walk-1);
            pos = find(1 == A(qwe,1:cnt));%Ѱ�����ӵĽڵ�
            record(:,2) = 0;
            record(pos,2) = 1;
            %��ҳ�Ƽ�
            if walk <= last
                record(:,3) = 1/cnt;
            else  %��ȥlast���Ĳο��۵�
                wwe = adress(h,walk - last:walk - 1);
                last_op = mean(op(wwe));
                record(:,3) = 1./abs(op(1:cnt) - last_op);
            end
            record(adress(h,walk-1),:) = 0;
            %���򻯾����׼��
            rrr = record.^2;
            for uuu = 1:3
                record(:,uuu) = record(:,uuu)/sqrt(sum(rrr(:,uuu)));
            end
            %����÷ֲ���һ��
            zuida = max(record);
            zuixiao = min(record);
            Dmin = zeros(1,cnt);%ÿ���ڵ�����ֵ�ľ���
            Dmax = zeros(1,cnt);
            for ccc = 1:cnt
                Dmin(ccc) = sqrt(w1*(zuixiao(1)-record(ccc,1))^2 + w2*(zuixiao(2)-record(ccc,2))^2 + w3*(zuixiao(3)-record(ccc,3))^2);
                Dmax(ccc) = sqrt(w1*(zuida(1)-record(ccc,1))^2 + w2*(zuida(2)-record(ccc,2))^2 + w3*(zuida(3)-record(ccc,3))^2);
            end
            %�õ�δ��һ��������
            P(h,:) = Dmin./(Dmax + Dmin);
            %��һ��
            P(h,:) = P(h,:)/sum(P(h,:));
        end
        %num���û���ʼ����
        for h = 1:num
            inter = cumsum(P(h,:),2);
            ww = rand();
            Ans = find(ww <= inter);
            adress(h,walk) = Ans(1);%��һ����λ��
            if abs(user_op(h,walk-1) - op(adress(h,walk))) < e2
                user_op(h,walk) = user_op(h,walk-1) + u1*(op(adress(h,walk)) - user_op(h,walk-1));
                IC_cnt(h) = IC_cnt(h) + 1;
            else
                user_op(h,walk) = user_op(h,walk-1) + u2*(op(adress(h,walk)) - user_op(h,walk-1));
                IC_cnt(h) = 0;
            end
        end
        %�û�֮����໥Ӱ��
%         ANS = tabulate(adress(:,walk));
%         for jk = 1:size(ANS,1)
%             target = ANS(jk,1);
%             zig =  find(target == adress(:,walk));
%             
%             for jkk = 1:length(zig)
%                 effect = 0;
%                 for jkkk = 1:length(zig)
%                     if abs(user_op(zig(jkk),walk-1) - user_op(zig(jkkk),walk-1)) < e2
%                         effect = effect + u1*(user_op(zig(jkkk),walk-1) - user_op(zig(jkk),walk-1));
% %                     else
% %                         effect = effect + u2*(user_op(zig(jkkk),walk-1) - user_op(zig(jkk),walk-1));
%                     end
%                 end
%                 user_op(zig(jkk),walk) = user_op(zig(jkk),walk) + effect;
%             end
%        end
        
        pos = find(cocoon <= IC_cnt);
        trap(pos,day) = 1;
            
        
    end
end
percentage = sum(trap)/num;
day = 1:total;
plot(day,percentage);



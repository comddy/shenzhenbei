MAX = 10000;%预计累积的帖子数不超过这个数
total = 20;%总天数,也可以以小时为单位
m = 5;%每个新增的帖子连接多少个现存的帖子
m0 = 40;%初始帖子数
e = 0.3;%帖子之间的信任阈值
e2 = 0.5;%用户的信任阈值
num = 500;%每天num个用户做游走
activity = 1;%取1能达到最大趋同系数的一半

%拟合出每天新增的帖子
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
t = 1:total;%天数
newtalk = a1.*exp(-((t-b1)./c1).^2) + a2.*exp(-((t-b2)./c2).^2) +...
              a3.*exp(-((t-b3)./c3).^2) + a4.*exp(-((t-b4)./c4).^2) +... 
              a5.*exp(-((t-b5)./c5).^2) + a6.*exp(-((t-b6)./c6).^2);%每天新增的帖子数
newtalk = fix(newtalk)+6;
u1 = 1/pi*atan(activity);%观点近似时的趋同系数,最大为0.5
u2 = 0.2/pi*atan(activity);%观点不同时的趋同系数，最大为0.1
cocoon = 10;%10步内没有看信任阈值外的帖子就视为陷入信息茧房
step = 20;%用户每天游走的步数

%从用户的角度出发，引入三个评价指标：兴趣，超链接，首页推荐，先用层次分析法确定出各指标的权重，在用TOPSIS计算各节点得分，根据得分确定转移概率
w1 = 0.7;%用户兴趣权重
w2 = 0.15;%超链接权重
w3 = 0.15;%首页推荐权重
last = 3;%首页推荐考虑过去last步浏览的帖子

op = zeros(1,MAX);%帖子包含的观点
A = zeros(MAX,MAX);%表示帖子的连接情况,A(i,j)表示i指向j，对列求和表示入度，对行求和表示出度
op(1:m0) = unifrnd(-1,1,[1,m0]);%初始化
trap = zeros(num,total);%0表示没有陷入茧房，1表示陷入
%假设初始帖子只要观点在信任阈值内就连接
for i = 1:m0
    for j = i+1:m0
        if abs(op(i) - op(j)) < e
            A(i,j) = 1;
            A(j,i) = 1;
        end
    end
end

op(m0+1:MAX) = unifrnd(-1,1,[1,MAX-m0]);%假设新帖子观点均匀分布在[-1,1]
cnt = m0;%当前帖子的数量
for day = 1:total
    %先将新节点与旧节点连接
    cnt0 = cnt;
    for i = 1:newtalk(day)%每日新增的帖子数
        in_degree = sum(A(1:cnt,1:cnt));%根据入度来决定连接概率
        interval = cumsum(in_degree);%求累和
        all = sum(in_degree);%总入度
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
    
    %当天的网络连接完毕
    
    %决定用户初始位置
    adress = zeros(num,step);%记录num个用户在step步里走过的节点
    user_op = zeros(num,step);%记录num个用户在step步里观点的变化
    in_degree = sum(A(1:cnt,1:cnt));%根据入度来决定概率
    interval = cumsum(in_degree);%求累和
    all = sum(in_degree);%总入度
    user_op(:,1) = (unifrnd(-1,1,[num,1]));%用户的初始观点
    %先给定初始位置
    for h = 1:num
        while 1
            rand_degree = fix(all*rand()+1);
            Ans = find(rand_degree <= interval);
            j = Ans(1);
            if abs(user_op(h,1) - op(j)) < e
                adress(h,1) = j;%用户的初始位置
                break;
            end
        end
    end
    %num个用户同时游走
    IC_cnt = zeros(1,num);%计数器
    P = zeros(num,cnt);%num个用户，cnt个节点
    record = zeros(cnt,3);%cnt个节点，3个评价指标
    for walk = 2:step
        for h = 1:num  %先算转移概率
            %填入初始数据
            %用户兴趣
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
            %超链接
            qwe = adress(h,walk-1);
            pos = find(1 == A(qwe,1:cnt));%寻找连接的节点
            record(:,2) = 0;
            record(pos,2) = 1;
            %首页推荐
            if walk <= last
                record(:,3) = 1/cnt;
            else  %过去last步的参考观点
                wwe = adress(h,walk - last:walk - 1);
                last_op = mean(op(wwe));
                record(:,3) = 1./abs(op(1:cnt) - last_op);
            end
            record(adress(h,walk-1),:) = 0;
            %正向化矩阵标准化
            rrr = record.^2;
            for uuu = 1:3
                record(:,uuu) = record(:,uuu)/sqrt(sum(rrr(:,uuu)));
            end
            %计算得分并归一化
            zuida = max(record);
            zuixiao = min(record);
            Dmin = zeros(1,cnt);%每个节点和最大值的距离
            Dmax = zeros(1,cnt);
            for ccc = 1:cnt
                Dmin(ccc) = sqrt(w1*(zuixiao(1)-record(ccc,1))^2 + w2*(zuixiao(2)-record(ccc,2))^2 + w3*(zuixiao(3)-record(ccc,3))^2);
                Dmax(ccc) = sqrt(w1*(zuida(1)-record(ccc,1))^2 + w2*(zuida(2)-record(ccc,2))^2 + w3*(zuida(3)-record(ccc,3))^2);
            end
            %得到未归一化的评分
            P(h,:) = Dmin./(Dmax + Dmin);
            %归一化
            P(h,:) = P(h,:)/sum(P(h,:));
        end
        %num个用户开始游走
        for h = 1:num
            inter = cumsum(P(h,:),2);
            ww = rand();
            Ans = find(ww <= inter);
            adress(h,walk) = Ans(1);%下一步的位置
            if abs(user_op(h,walk-1) - op(adress(h,walk))) < e2
                user_op(h,walk) = user_op(h,walk-1) + u1*(op(adress(h,walk)) - user_op(h,walk-1));
                IC_cnt(h) = IC_cnt(h) + 1;
            else
                user_op(h,walk) = user_op(h,walk-1) + u2*(op(adress(h,walk)) - user_op(h,walk-1));
                IC_cnt(h) = 0;
            end
        end
        %用户之间的相互影响
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



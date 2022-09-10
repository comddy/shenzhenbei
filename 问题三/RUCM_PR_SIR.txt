
%需要设置的参数
N = 2000;   %总节点个数
m = 16;%每次加入的连线数，平均度约等于m,新加入节点应该是让旧节点来连接自己
m0 = 100;    %初始的节点个数
A = zeros(N,N);%邻接矩阵，A(i,j)表示i指向j，对列求和表示入度，对行求和表示出度
op = unifrnd(0,1,[1,N]);%使用周期性边界
e = 0.3;%用户之间的信任阈值
total = 100;%模拟多少天
sita = 0.5;%在线概率
u = 0.15;%趋同系数
q = 0.85;%pagerank跳转因子
h = 2;%外部社会加强因子
w = 0.1;%网络用户对消息的不敏感度，(0,1]
rho = 5;%信息传播增长速率相关系数
epsilo = 2;%免疫增长因子
lamda = 0.7;%信息的固有传播概率,(0,1)
%先建立无标度有向网络
%假设初始节点只要观点在信任阈值内就互相连接
for i = 1:m0
    for j = i+1:m0
        if (op(i) - op(j))>=-1&&(op(i) - op(j))<-0.5
            pj = -1;
        end
        if (op(i) - op(j))>=-0.5&&(op(i) - op(j))<=0.5
            pj = 0;
        end
        if (op(i) - op(j))>0.5&&(op(i) - op(j))<=1
            pj = 1;
        end
        if abs(op(i) - op(j)- pj ) < e
            A(i,j) = 1;
            A(j,i) = 1;
        end
    end
end
for new = m0+1:N
    %先找出所有和新节点观点相近的旧节点
    cnt = 1;
    pos = zeros(1,N);
    for i = 1:new-1
         if (op(new) - op(i))>=-1&&(op(new) - op(i))<-0.5
             p = -1;
         end
         if (op(new) - op(i))>=-0.5&&(op(new) - op(i))<=0.5
             p = 0;
         end
         if (op(new) - op(i))>0.5&&(op(new) - op(i))<=1
             p = 1;
         end
         if abs(op(new) - op(i)- p ) < e
            pos(cnt) = i;
            cnt = cnt + 1;
         end
    end
    %出度越大连接上的概率越大
    out_Degree = sum(A(1:new-1,1:new-1),2);  %每个顶点的出度
    out_Degree = out_Degree + 1;%出度最小为1
    pos = pos(1:cnt-1);
    out_Degree = out_Degree(pos);
    %制造出一个出度的分布区间，模拟概率
    out_DegreeInterval = cumsum(out_Degree);
    %连接 新节点 与 m个old节点
    All_out_Degree = sum(out_Degree); %总出度
    for i = 1:m 
        while 1
            %以概率从old节点中找到合适的顶点连接
            RandDegree  = fix(All_out_Degree*rand()+1); %要与度区间包含RandDegree的顶点相连
            %找到 符合 要求的区间所属顶点
            Ans = find(RandDegree <= out_DegreeInterval);
            Ans = Ans(1);
            old = pos(Ans);
            if A(old,new) == 0
                A(old,new) = 1;
                break;         %成功连接
            end
        end
    end
end
vv = op;
op = zeros(total,N);%用户观点,横标为天数,t = 1代表初始状态
op(1,:) = vv;
state = zeros(total,N);%记录每个节点的状态，横标为天数，S态(未知者)：0，I态（感染者）：1，R态（免疫者）：2
time = zeros(1,N);%节点计时器，记录感染者的衰退时间

%初始化,观点每间隔0.2找出出度最大的节点并感染
out_Degree = sum(A,2);
initial1 = find((0 <= op(1,:)) + (0.2 > op(1,:)) - 1);
[initial,im] = max(out_Degree(initial1));
state(1,initial1(im)) = 1;
out_Degree = sum(A,2);
initial1 = find((0.2 <= op(1,:)) + (0.4 > op(1,:)) - 1);
[initial,im] = max(out_Degree(initial1));
state(1,initial1(im)) = 1;
initial1 = find((0.4 <= op(1,:)) + (0.6 > op(1,:)) - 1);
[initial,im] = max(out_Degree(initial1));
state(1,initial1(im)) = 1;
initial1 = find((0.6 <= op(1,:)) + (0.8 > op(1,:)) - 1);
[initial,im] = max(out_Degree(initial1));
state(1,initial1(im)) = 1;
initial1 = find((0.8 <= op(1,:)) + (1 >= op(1,:)) - 1);
[initial,im] = max(out_Degree(initial1));
state(1,initial1(im)) = 1;
% for inital = 1:5
%     while 1
%         i = fix(N*rand()+1);
%         if state(1,i) == 0
%             state(1,i) = 1;
%             break;
%         end
%     end
% end


for t = 2:total
    %感染的节点先对邻居发生作用，再考虑感染和免疫
    %S态用户的观点不受别人影响也不影响别人，I态受别人影响也影响别人，R态观点受影响但不影响别人
    %只有I态影响别人,找出所有I态
    I = find(1 == state(t-1,:));%当前所有I节点的位置
    effect = zeros(1,N);%当天所有节点受到的影响
    for pos_I = 1:length(I)
        %找出这个节点指向的所有I态和R态节点
        %I态R态节点位置
        pos_IR = find((1 == state(t-1,:)) + (2 == state(t-1,:)));
        cc = pos_IR;
        for kill = 1:length(pos_IR)
            if A(I(pos_I),pos_IR(kill)) == 0
                cc(kill) = -1;
            end
        end
        poss = find(-1 ~= cc);
        pos_IR = cc(poss);
        %此时的pos_IR是这个节点指向的所有I态和R态节点的位置
        for target = 1:length(pos_IR)
            if (op(t-1,pos_IR(target)) - op(t-1,I(pos_I)))>=-1&&(op(t-1,pos_IR(target)) - op(t-1,I(pos_I)))<-0.5
                p = -1;
            end
            if (op(t-1,pos_IR(target)) - op(t-1,I(pos_I)))>=-0.5&&(op(t-1,pos_IR(target)) - op(t-1,I(pos_I)))<=0.5
                p = 0;
            end
            if (op(t-1,pos_IR(target)) - op(t-1,I(pos_I)))>0.5&&(op(t-1,pos_IR(target)) - op(t-1,I(pos_I)))<=1
                p = 1;
            end
            if abs(op(t-1,pos_IR(target)) - op(t-1,I(pos_I)) - p) < e
                effect(pos_IR(target)) = effect(pos_IR(target)) + u*(op(t-1,I(pos_I)) - op(t-1,pos_IR(target)));
            else
                effect(pos_IR(target)) = effect(pos_IR(target)) - u*(op(t-1,I(pos_I)) - op(t-1,pos_IR(target)) + p);
                %开始重线
                A(I(pos_I),pos_IR(target)) = 0;
                %先找出所有观点相近的节点
                cnt = 1;
                pos = zeros(1,N);
                for i = 1:N
                    if (op(t-1,pos_IR(target)) - op(t-1,i))>=-1&&(op(t-1,pos_IR(target)) - op(t-1,i))<-0.5
                        p = -1;
                    end
                    if (op(t-1,pos_IR(target)) - op(t-1,i))>=-0.5&&(op(t-1,pos_IR(target)) - op(t-1,i))<=0.5
                        p = 0;
                    end
                    if (op(t-1,pos_IR(target)) - op(t-1,i))>0.5&&(op(t-1,pos_IR(target)) - op(t-1,i))<=1
                        p = 1;
                    end
                    if abs(op(t-1,pos_IR(target)) - op(t-1,i) - p ) < e
                        pos(cnt) = i;
                        cnt = cnt + 1;
                    end
                end
                %出度越大连接上的概率越大
                out_Degree = sum(A,2);  %每个顶点的出度
                out_Degree = out_Degree + 1;%出度最小为1
                pos = pos(1:cnt-1);
                out_Degree = out_Degree(pos);
                %制造出一个出度的分布区间，模拟概率
                out_DegreeInterval = cumsum(out_Degree);
                %连接 新节点 与 1个old节点
                All_out_Degree = sum(out_Degree); %总出度
                for rrr = 1:10%最多尝试10次重线
                    %以概率从old节点中找到合适的顶点连接
                    RandDegree  = fix(All_out_Degree*rand()+1); %要与度区间包含RandDegree的顶点相连
                    %找到 符合 要求的区间所属顶点
                    Ans = find(RandDegree <= out_DegreeInterval);
                    Ans = Ans(1);
                    old = pos(Ans);
                    if A(old,pos_IR(target)) == 0
                        A(old,pos_IR(target)) = 1;
                        break;         %成功连接
                    end
                end
            end
        end
    end
    op(t,:) = op(t-1,:)+effect;
    %观点交互后可能会超出范围
    range1 = find(1 < op(t,:));
    range2 = find(0 > op(t,:));
    op(t,range1) = abs(op(t,range1) - 1);
    op(t,range2) = abs(op(t,range2) + 1);
    
    %观点交互结束，开始对每个考虑感染和免疫
    %先计算出所有节点的pagerank值
    B = A';
    P = zeros(N,N);
    r = sum(B,2);
    for i = 1:N
        for j = 1:N
            P(i,j) = (1-q)/N + q*B(i,j)/r(i);%状态转移矩阵
        end
    end
    [x,y] = eigs(B',1);
    x = x/sum(x);%各节点pagerank值
    %找出所有S态节点，考虑感染
    infect_S = find(0 == state(t-1,:));
    %S态节点的消息总量
    d = zeros(1,length(infect_S));
    for i = 1:length(d)
        neighbor = find(1 == A(:,infect_S(i)));
        neighbor = neighbor';
        for j = 1:length(neighbor)
            if state(t-1,neighbor(j)) == 1
                d(i) = d(i) + x(neighbor(j));
            end
        end
    end
    %各S态节点感染概率
    n = sita*(1 - (1 - lamda).^d);
    panduan = rand(1,length(n));
    panduan = n - panduan;
    infect = find(0 < panduan);
    gg = infect_S(infect);
    state(t,gg) = 1;
    
    
    %找出所有I态节点，考虑免疫
    immue_I = find(1 == state(t-1,:));
    state(t,immue_I) = 1;
    time(immue_I) = time(immue_I)+ 1;
    %各I态节点免疫概率
    a = w./(1+ exp(rho - epsilo*time(immue_I)));
    panduan = rand(1,length(a));
    panduan = a - panduan;
    immue = find(0 < panduan);
    gg = immue_I(immue);
    state(t,gg) = 2;
    
    %找出所有R态节点，继承
    immue_R = find(2 == state(t-1,:));
    state(t,immue_R) = 2;
end
subplot(1,2,1)
hold on
x = 1:total;
S = zeros(1,total);
for t = 1:total
    ii = find(0 == state(t,:));
    S(t) = length(ii)/N;
end
I = zeros(1,total);
for t = 1:total
    ii = find(1 == state(t,:));
    I(t) = length(ii)/N;
end
R = zeros(1,total);
for t = 1:total
    ii = find(2 == state(t,:));
    R(t) = length(ii)/N;
end
plot(x,S,'b');
plot(x,I,'g');
plot(x,R,'r');
legend('S(Susceptile)','I(Infected)','R(Remove)');
xlabel('step');
ylabel('node density');
ylim([0 1]);
title('RUCM :randomly infect 5 nodes');
hold off
%ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');

subplot(1,2,2)
r = find(2 == state(total,:));
op_R = op(total,r);
xmin=0;
xmax=1;
op_x = linspace(xmin,xmax,20);
op_y = hist(op_R,op_x);
op_y = op_y/length(r);
plot (op_x,op_y,'s-','LineWidth',2);
xlim([0 1]);
xlabel('opinion');
ylabel('PDF');
title('Probability density functions of final opinion withε=0.15,u=0.1');
legend('RUCM');
% ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');
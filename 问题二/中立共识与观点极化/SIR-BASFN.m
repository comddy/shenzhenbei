%需要设置的参数
N = 2000;   %总节点个数
max_degree = 700;%预估最大的degree数
st = 5;%初始随机感染的节点数
rt = 5;%或者初始感染rt个枢纽节点
%建立无标度网络
m = 4;%每次加入的连线数
m0 = 60;    %初始的节点个数
A = zeros(N,N);%邻接矩阵
%先建立小型随机网络
%随机连边  1表示有边
for i=1:m0
    for j= (i+1):m0
        A(i,j)= round(rand());   %非1即0
        A(j,i) =  A(i,j);
    end
end   %初始完成
DegreeInterval = zeros(1,N);
for new = m0+1:N
    %old vertice 度越大连接上的概率越大
    Degree = sum(A(1:new-1,1:new-1));  %每个顶点的度
    %制造出一个度的分布区间，模拟概率
    DegreeInterval(1) = Degree(1);
    for i=2:new-1
        DegreeInterval(i) = Degree(i)+DegreeInterval(i-1);
    end 
    %连接 新节点 与 m个old节点
    AllDegree = sum(sum(A(1:new-1,1:new-1))); %整个图的总度
    for i = 1:m 
        while 1
         %以概率从old节点中找到合适的顶点连接
         RandDegree  = fix(AllDegree*rand()+1); %要与度区间包含RandDegree的顶点相连
         %找到 符合 要求的区间所属顶点
         Ans = find(RandDegree <= DegreeInterval(1:new-1));
         old = Ans(1);
         if A(new,old) == 0
            A(new,old) = 1;
            A(old,new) = 1;
            break;         %成功连接
         end
        end
    end
end
Degree = sum(A);
k_aver = sum(Degree)/N;
P = zeros(1,max_degree);%各种度的概率
% 演化
Num_k = zeros(1,max_degree);%度为k的节点的数量，从第m列开始填入
for i = m:max_degree
    Num_k(i) = size(find(i == Degree),2);
end
P = Num_k/N;
SIR = zeros(3,max_degree);%S在第一行，I在第二行，R在第三行，与矩阵Num_k对应,SIR(1,6)表示度为6的s节点数
%初始化状态
SIR(1,:) = Num_k(1,:);

% % 假设初始随机感染st个节点
% degree = sum(A);
% for inital = 1:st
%     
%     while 1
%         i = fix(N*rand()+1);
%         i = degree(i);
%         if SIR(1,i) ~= 0
%             SIR(2,i) = SIR(2,i) + 1;
%             SIR(1,i) = SIR(1,i) - 1;
%             break;
%         end
%     end
% end

%感染rt个度最大的节点
for i = 1:rt
    degree11 = sum(A);
    [zuidazhi,weizhi] = max(degree11);
    SIR(1,zuidazhi) = SIR(1,zuidazhi) - 1;
    SIR(2,zuidazhi) = SIR(2,zuidazhi) + 1;
    degree11(weizhi) = 0;
end

step = 0;%计时器,从0时刻开始
density_S = zeros(1,50);%节点密度,预计1000步以内
density_I = zeros(1,50);
density_R = zeros(1,50);
density_S(1) = sum(SIR(1,:))/N;
density_I(1) = sum(SIR(2,:))/N;
density_R(1) = sum(SIR(3,:))/N;
%开始演化
while 1
    step = step + 1;
    last_SIR = SIR;%记录上一时刻的状态
    for i = m:max_degree
        %度为i的S节点演化
        n_s = last_SIR(2,:);
        n_s(i) = 0;
        effect_s = 0;
        if Num_k(i) == 0
        else
            for node_s = 1:max_degree
                effect_s = effect_s + n_s(node_s)*(1-1/node_s)*(node_s*P(node_s)/k_aver)*last_SIR(1,i)/Num_k(i);
            end
        end
        SIR(1,i) = last_SIR(1,i) -  effect_s;
        %度为i的R节点演化
        nki = last_SIR(2,:);
        nkr = last_SIR(3,:);
        nki(i) = 0;
        nkr(i) = 0;
        effect_r = 0;
        for node_r = 1:max_degree
            if Num_k(node_r) == 0
                
            else
                effect_r = effect_r + (node_r*P(node_r)/k_aver)*(nki(node_r)+nkr(node_r))/Num_k(node_r);
            end
        end
        SIR(3,i) = last_SIR(3,i) + last_SIR(2,i)*(1/i + (1 - 1/i)*effect_r);%???????
        %度为i的I节点演化
        SIR(2,i) = Num_k(i) - SIR(1,i) - SIR(3,i);
    end
    density_S(step+1) = sum(SIR(1,:))/N;
    density_I(step+1) = sum(SIR(2,:))/N;
    density_R(step+1) = sum(SIR(3,:))/N;
    if sum(SIR(2,:)) < 1%结束条件
        for j = step+2:50
            density_S(j) = density_S(step+1);
            density_I(j) = density_I(step+1);
            density_R(j) = density_R(step+1);
        end
        break;
    end
end
t = 1:50;
hold on
plot(t,density_S,'X-b');
plot(t,density_I,'d-g');
plot(t,density_R,'o-r');
legend('S','I','R');
xlabel('time');
ylabel('node density');
title('randomly infect 5 nodes');
ylim([0 1]);
hold off
%ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');

step = 2*10^4;%总步数
N = 1000;   %总节点个数
N1 = 500;   %community 1的节点数
N2 = 500;   %community 2的节点数
connection_12 = 500; %两个community之间的连线数
x1 = unifrnd(0,1,[1,N1]);%观点初始化
x2 = -unifrnd(0,1,[1,N2]);
x = zeros(step,N);
x(1,:) = [x1 x2];
u = 0.3;%趋同系数
e1 = 0.5;%community 1 内部的信任阈值
e3 = 0.5;%community 2 内部的信任阈值
e2 = 0.2;%community之间的信任阈值
%建立无标度网络
%community 1
m = 23;%每次加入的连线数
m0 = 50;    %初始的节点个数
A1 = zeros(N1,N1);%邻接矩阵
for i=1:m0
    for j= (i+1):m0
        A1(i,j)= 1;   
        A1(j,i) =  A1(i,j);
    end
end   
DegreeInterval = zeros(1,N1);
for new = m0+1:N1
    %old vertice 度越大连接上的概率越大
    Degree = sum(A1(1:new-1,1:new-1));  %每个顶点的度
    %制造出一个度的分布区间，模拟概率
    DegreeInterval(1) = Degree(1);
    for i=2:new-1
        DegreeInterval(i) = Degree(i)+DegreeInterval(i-1);
    end 
    %连接 新节点 与 m个old节点
    AllDegree = sum(sum(A1(1:new-1,1:new-1))); %整个图的总度
    for i = 1:m 
        while 1
         %以概率从old节点中找到合适的顶点连接
         RandDegree  = fix(AllDegree*rand()+1); %要与度区间包含RandDegree的顶点相连
         %找到 符合 要求的区间所属顶点
         Ans = find(RandDegree <= DegreeInterval(1:new-1));
         old = Ans(1);
         if A1(new,old) == 0
            A1(new,old) = 1;
            A1(old,new) = 1;
            break;         %成功连接
         end
        end
    end
end

%community 2
m = 23;%每次加入的连线数
m0 = 50;    %初始的节点个数
A2 = zeros(N2,N2);%邻接矩阵
%先建立小型随机网络
%防bug
for i=1:m0
    for j= (i+1):m0
        A2(i,j)= 1;   
        A2(j,i) =  A2(i,j);
    end
end   
DegreeInterval = zeros(1,N2);
for new = m0+1:N2
    %old vertice 度越大连接上的概率越大
    Degree = sum(A2(1:new-1,1:new-1));  %每个顶点的度
    %制造出一个度的分布区间，模拟概率
    DegreeInterval(1) = Degree(1);
    for i=2:new-1
        DegreeInterval(i) = Degree(i)+DegreeInterval(i-1);
    end 
    %连接 新节点 与 m个old节点
    AllDegree = sum(sum(A2(1:new-1,1:new-1))); %整个图的总度
    for i = 1:m 
        while 1
         %以概率从old节点中找到合适的顶点连接
         RandDegree  = fix(AllDegree*rand()+1); %要与度区间包含RandDegree的顶点相连
         %找到 符合 要求的区间所属顶点
         Ans = find(RandDegree <= DegreeInterval(1:new-1));
         old = Ans(1);
         if A2(new,old) == 0
            A2(new,old) = 1;
            A2(old,new) = 1;
            break;         %成功连接
         end
        end
    end
end

%初始化总邻接矩阵
A1A2 = zeros(N2,N1);
A = [A1 A1A2';A1A2 A2];

%连接两个community
degree_1 = sum(A1);
all_degree1 = sum(degree_1);
interval_1 = cumsum(degree_1);
degree_2 = sum(A2);
all_degree2 = sum(degree_2);
interval_2 = cumsum(degree_2);
for c = 1:connection_12
    while 1
        rand1 = fix(all_degree1*rand()+1);
        Ans = find(rand1 <= interval_1);
        i = Ans(1);
        rand2 = fix(all_degree2*rand()+1);
        Ans = find(rand2 <= interval_2);
        j = N1 + Ans(1);
        if A(i,j) ~= 1
            A(i,j) = 1;
            A(j,i) = 1;
            break
        end
    end
end
%每一轮抽取一个community1里的节点，使之与随机一个neighbor作用，再抽一个community2里的节点，使之与随机一个neighbor作用
for s = 2:step
    x(s,:) = x(s-1,:);
    %community 1
    i1 = fix(N1*rand()+1);
    while 1
        j1 = fix(N*rand()+1);
        if A(i1,j1) == 1
            %先判断j属于哪个community
            if j1 <= N1  %同属community 1
                if abs(x(s-1,i1) - x(s-1,j1)) < e1
                    x(s,i1) = x(s-1,i1) + u*(x(s-1,j1) - x(s-1,i1));
                    x(s,j1) = x(s-1,j1) + u*(x(s-1,i1) - x(s-1,j1));
                end
            else %j属于community 2
                if abs(x(s-1,i1) - x(s-1,j1)) < e2
                    x(s,i1) = x(s-1,i1) + u*(x(s-1,j1) - x(s-1,i1));
                    x(s,j1) = x(s-1,j1) + u*(x(s-1,i1) - x(s-1,j1));
                end
            end
            break;
        end
    end
    %community 2
    i2 = N1 + fix(N2*rand()+1);
    while 1
        j2 = fix(N*rand()+1);
        if A(i2,j2) == 1
            %先判断j属于哪个community
            if j2 > N1  %同属community 2
                if abs(x(s-1,i2) - x(s-1,j2)) < e3
                    x(s,i2) = x(s-1,i2) + u*(x(s-1,j2) - x(s-1,i2));
                    x(s,j2) = x(s-1,j2) + u*(x(s-1,i2) - x(s-1,j2));
                end
            else %j属于community 1
                if abs(x(s-1,i2) - x(s-1,j2)) < e2
                    x(s,i2) = x(s-1,i2) + u*(x(s-1,j2) - x(s-1,i2));
                    x(s,j2) = x(s-1,j2) + u*(x(s-1,i2) - x(s-1,j2));
                end
            end
            break;
        end
    end
    
end
hold on 
t = 1:step;
for i = 1:5:N
    plot(t,x(:,i),'g');
    plot(t,x(:,i+1),'r');
    plot(t,x(:,i+2),'b');
    plot(t,x(:,i+3),'y');
    plot(t,x(:,i+4),'c');
end
hold off
ylim([-1 1]);
title ('');
xlabel('time');
ylabel('opinion');
% title('δ_1=δ_3=0.2,δ_2=0.2,ζ=0.3');%δ信任阈值ζ趋同系数
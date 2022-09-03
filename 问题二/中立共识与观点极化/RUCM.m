
%需要设置的参数
N = 2000;   %总节点个数（话题吸引度）
x = rand(1,N);%初始观点
e = 0.4;%信任阈值，范围[0,0.5](用户心理)0.25
u = 0.15;%观点接近时的相互作用系数，范围（0，0.5），0代表完全不接受，1代表完全接受，0.5代表折中（用户之间的相互影响）
step = 2*10^6;%步数
attempt = 90;%最多尝试重连次数
%建立无标度网络
m = 5;%每次加入的连线数（用户活跃度）
m0 = 20;    %初始的节点个数
A = zeros(N,N);%邻接矩阵
%防bug
for i=1:m0
    for j= (i+1):m0
        A(i,j)= 1;  
        A(j,i) =  A(i,j);
    end
end   
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
        cnt = 0;%计数器，防bug
        while 1
         
         %以概率从old节点中找到合适的顶点连接
         RandDegree  = fix(AllDegree*rand()+1); %要与度区间包含RandDegree的顶点相连
         %找到 符合 要求的区间所属顶点
         Ans = find(RandDegree <= DegreeInterval);
         old = Ans(1);
         
         if A(new,old) == 0
            A(new,old) = 1;
            A(old,new) = 1;
            break;         %成功连接
         end
         
        end
    end
end
%     %求度分布
%     Degree = sum(A);  %完成后的网络的每个节点的度  2 3 2 2 4 3
%     UniDegree = unique(Degree);  %去重后度       2 3 4
%     for i = 1:length(UniDegree)
%         DegreeNum(i) = sum(Degree==UniDegree(i));
%     end



%一次抽取一对节点，使之互相作用，再决定是否重线，如果要重线，只对i节点重线，j节点不管。如此往复
for s = 1:step
    i = fix(N*rand()+1);
    j = fix(N*rand()+1);
    if A(i,j) == 1
        if (x(i) - x(j))>=-1&&(x(i) - x(j))<-0.5
            pj = -1;
        end
        if (x(i) - x(j))>=-0.5&&(x(i) - x(j))<=0.5
            pj = 0;
        end
        if (x(i) - x(j))>0.5&&(x(i) - x(j))<=1
            pj = 1;
        end
        
        if (x(j) - x(i))>=-1&&(x(j) - x(i))<-0.5
            pi= -1;
        end
        if (x(j) - x(i))>=-0.5&&(x(j) - x(i))<=0.5
            pi = 0;
        end
        if (x(j) - x(i))>0.5&&(x(j) - x(i))<=1
            pi = 1;
        end
        %判断如何相互作用
        if abs(x(i) - x(j)- pj ) >= e
            op_i = x(i);
            op_j = x(j);
            x(i) = x(i) - u*(op_j - op_i - pi);
            x(j) = x(j) - u*(op_i - op_j - pj);
            %作用完后xi和xj可能会超出范围
            if x(i)<0 
                x(i) = abs(x(i)+1);
            end
            if x(i)>1 
                x(i) = abs(x(i)-1);
            end
            if x(j)<0 
                x(j) = abs(x(j)+1);
            end
            if x(j)>1 
                x(j) = abs(x(j)-1);
            end
            A(i,j) = 0;
            A(j,i) = 0;
            %重连i
           while 1
                Degree = sum(A);%各节点的度
                DegreeInterval(1) = Degree(1);
                for c=2:N
                    DegreeInterval(c) = Degree(c)+DegreeInterval(c-1);
                end
                AllDegree = sum(Degree);
                RandDegree  = fix(AllDegree*rand()+1);
                Ans = find(RandDegree <= DegreeInterval(1:N));%指出位置
                k = Ans(1);
                if A(i,k) == 0
                    A(i,k) = 1;
                    A(k,i) = 1;
                    break;
                end
           end
           
        else
            op_i = x(i);
            op_j = x(j);
            x(i) = x(i) + u*(op_j - op_i);
            x(j) = x(j) + u*(op_i - op_j);
        end
    end                 
end
%累积分布图
xmin=0;
xmax=1;
op_RUCM = linspace(xmin,xmax,20);%将最大最小区间分成100个等分点(49等分),然后分别计算各个区间的个数
yy_RUCM=hist(x,op_RUCM);%计算各个区间的个数
yy_RUCM=yy_RUCM/length(x);%计算各个区间的个数
bar(op_RUCM,yy_RUCM,'w');%画出概率密度分布图
hold on;
plot (op_RUCM,yy_RUCM,'s-','LineWidth',2);
xlim([0 1]);
xlabel('x','FontSize',20);
ylabel('PDF','FontSize',20);
set(gca,'linewidth',1,'fontsize',16,'fontname','Times');
ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');
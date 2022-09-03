%需要设置的参数
N = 2000;   %总节点个数
x = rand(1,N);%初始观点
e = 0.4;%信任阈值，范围[0,0.5]
u = 0.45;%观点接近时的相互作用系数，范围（0，0.5）,0代表完全不接受，1代表完全接受，0.5代表折中
step = 2*10^6;%步数
%建立无标度网络
m = 5;%每次加入的连线数
m0 = 20;    %初始的节点个数
A = zeros(N,N);%邻接矩阵
%先建立小型随机网络
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
%BCM
for t = 1:step
        i = fix(N*rand() + 1);
        j = fix(N*rand() + 1);
        if A(i,j) == 1
            if (x(i) - x(j))>=-1&&(x(i) - x(j))<-0.5
                p = -1;
            end
            if (x(i) - x(j))>=-0.5&&(x(i) - x(j))<=0.5
                p = 0;
            end
            if (x(i) - x(j))>0.5&&(x(i) - x(j))<=1
                p = 1;
            end
            if abs(x(i)-x(j)-p) < e
                op_i = x(i);
                op_j = x(j);
                x(i) = x(i) + u*(op_j - op_i);
                x(j) = x(j) + u*(op_i - op_j);
            end
        end
end
%累积分布图
xmin=0;%想要在[a b]区间内画频率分布，就把xmin设置为a，xmax设置为b
xmax=1;
op_BCM = linspace(xmin,xmax,50);%将最大最小区间分成50个等分点(49等分),然后分别计算各个区间的个数
yy_BCM=hist(x,op_BCM);%计算各个区间的个数
yy_BCM=yy_BCM/length(x);%计算各个区间的个数
bar(op_BCM,yy_BCM,'w');%画出概率密度分布图
hold on;
plot (op_BCM,yy_BCM,'s-','LineWidth',2);
xlim([0 1]);
xlabel('x','FontSize',20);
ylabel('PDF','FontSize',20);
set(gca,'linewidth',1,'fontsize',16,'fontname','Times');
ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');
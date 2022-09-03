%��Ҫ���õĲ���
N = 2000;   %�ܽڵ����
x = rand(1,N);%��ʼ�۵�
e = 0.4;%������ֵ����Χ[0,0.5]
u = 0.45;%�۵�ӽ�ʱ���໥����ϵ������Χ��0��0.5��,0������ȫ�����ܣ�1������ȫ���ܣ�0.5��������
step = 2*10^6;%����
%�����ޱ������
m = 5;%ÿ�μ����������
m0 = 20;    %��ʼ�Ľڵ����
A = zeros(N,N);%�ڽӾ���
%�Ƚ���С���������
%��bug
for i=1:m0
    for j= (i+1):m0
        A(i,j)= 1;   
        A(j,i) =  A(i,j);
    end
end   
DegreeInterval = zeros(1,N);
for new = m0+1:N
    %old vertice ��Խ�������ϵĸ���Խ��
    Degree = sum(A(1:new-1,1:new-1));  %ÿ������Ķ�
    %�����һ���ȵķֲ����䣬ģ�����
    DegreeInterval(1) = Degree(1);
    for i=2:new-1
        DegreeInterval(i) = Degree(i)+DegreeInterval(i-1);
    end 
    %���� �½ڵ� �� m��old�ڵ�
    AllDegree = sum(sum(A(1:new-1,1:new-1))); %����ͼ���ܶ�
    for i = 1:m 
        while 1
         %�Ը��ʴ�old�ڵ����ҵ����ʵĶ�������
         RandDegree  = fix(AllDegree*rand()+1); %Ҫ����������RandDegree�Ķ�������
         %�ҵ� ���� Ҫ���������������
         Ans = find(RandDegree <= DegreeInterval(1:new-1));
         old = Ans(1);
         if A(new,old) == 0
            A(new,old) = 1;
            A(old,new) = 1;
            break;         %�ɹ�����
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
%�ۻ��ֲ�ͼ
xmin=0;%��Ҫ��[a b]�����ڻ�Ƶ�ʷֲ����Ͱ�xmin����Ϊa��xmax����Ϊb
xmax=1;
op_BCM = linspace(xmin,xmax,50);%�������С����ֳ�50���ȷֵ�(49�ȷ�),Ȼ��ֱ�����������ĸ���
yy_BCM=hist(x,op_BCM);%�����������ĸ���
yy_BCM=yy_BCM/length(x);%�����������ĸ���
bar(op_BCM,yy_BCM,'w');%���������ܶȷֲ�ͼ
hold on;
plot (op_BCM,yy_BCM,'s-','LineWidth',2);
xlim([0 1]);
xlabel('x','FontSize',20);
ylabel('PDF','FontSize',20);
set(gca,'linewidth',1,'fontsize',16,'fontname','Times');
ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');
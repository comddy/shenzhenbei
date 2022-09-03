
%��Ҫ���õĲ���
N = 2000;   %�ܽڵ����
x = rand(1,N);%��ʼ�۵�
e = 0.25;%������ֵ����Χ[0,0.5]
u = 0.15;%�۵���໥����ϵ������Χ��0��0.5��
step = 2*10^6;%����

%�����ޱ������
m = 5;%ÿ�μ����������
m0 = 20;    %��ʼ�Ľڵ����
A = zeros(N,N);%�ڽӾ���
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

%UCM
for t = 1:step
        i = fix(N*rand() + 1);
        j = fix(N*rand() + 1);
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
            if abs(x(i)-x(j)-pj) < e
                op_i = x(i);
                op_j = x(j);
                x(i) = x(i) + u*(op_j - op_i);
                x(j) = x(j) + u*(op_i - op_j);
            else
                op_i = x(i);
                op_j = x(j);
                x(i) = x(i) - u*(op_j - op_i - pi);
                x(j) = x(j) - u*(op_i - op_j - pj);
                %xi��xj�п��ܳ�����Χ
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
            end
        end
end
%�ۻ��ֲ�ͼ
xmin=0;
xmax=1;
op_UCM = linspace(xmin,xmax,20);%�������С����ֳ�50���ȷֵ�(49�ȷ�),Ȼ��ֱ�����������ĸ���
yy_UCM=hist(x,op_UCM);%�����������ĸ���
yy_UCM=yy_UCM/length(x);%�����������ĸ���
bar(op_UCM,yy_UCM,'w');%���������ܶȷֲ�ͼ
hold on;
plot (op_UCM,yy_UCM,'s-','LineWidth',2);
xlim([0 1]);
xlabel('x','FontSize',20);
ylabel('PDF','FontSize',20);
set(gca,'linewidth',1,'fontsize',16,'fontname','Times');
ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');
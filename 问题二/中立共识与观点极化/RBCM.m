
%��Ҫ���õĲ���
N = 2000;   %�ܽڵ����
x = rand(1,N);%��ʼ�۵�
e = 0.25;%������ֵ����Χ[0,0.5]
u = 0.15;%�۵�ӽ�ʱ���໥����ϵ������Χ��0��0.5����0������ȫ�����ܣ�1������ȫ���ܣ�0.5��������
step = 2*10^6;%����
attempt = 90;%��ೢ����������
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
%     %��ȷֲ�
%     Degree = sum(A);  %��ɺ�������ÿ���ڵ�Ķ�  2 3 2 2 4 3
%     UniDegree = unique(Degree);  %ȥ�غ��       2 3 4
%     for i = 1:length(UniDegree)
%         DegreeNum(i) = sum(Degree==UniDegree(i));
%     end



%һ�γ�ȡһ�Խڵ㣬ʹ֮�������ã��پ����Ƿ����ߣ����Ҫ���ߣ�ֻ��i�ڵ����ߣ�j�ڵ㲻�ܡ��������
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
        %�ж�����໥����
        if abs(x(i) - x(j)- pj ) >= e
            A(i,j) = 0;
            A(j,i) = 0;
            %����i
           while 1
                Degree = sum(A);%���ڵ�Ķ�
                DegreeInterval(1) = Degree(1);
                for c=2:N
                    DegreeInterval(c) = Degree(c)+DegreeInterval(c-1);
                end
                AllDegree = sum(Degree);
                RandDegree  = fix(AllDegree*rand()+1);
                Ans = find(RandDegree <= DegreeInterval(1:N));%ָ��λ��
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
%�ۻ��ֲ�ͼ
xmin=0;
xmax=1;
op_RBCM = linspace(xmin,xmax,50);%�������С����ֳ�50���ȷֵ�(49�ȷ�),Ȼ��ֱ�����������ĸ���
yy_RBCM=hist(x,op_RBCM);%�����������ĸ���
yy_RBCM=yy_RBCM/length(x);%�����������ĸ���
bar(op_RBCM,yy_RBCM,'w');%���������ܶȷֲ�ͼ
hold on;
plot (op_RBCM,yy_RBCM,'s-','LineWidth',2);
xlim([0 1]);
xlabel('x','FontSize',20);
ylabel('PDF','FontSize',20);
set(gca,'linewidth',1,'fontsize',16,'fontname','Times');
ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');
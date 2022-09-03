
step = 2*10^4;%�ܲ���
N = 1000;   %�ܽڵ����
N1 = 500;   %community 1�Ľڵ���
N2 = 500;   %community 2�Ľڵ���
connection_12 = 500; %����community֮���������
x1 = unifrnd(0,1,[1,N1]);%�۵��ʼ��
x2 = -unifrnd(0,1,[1,N2]);
x = zeros(step,N);
x(1,:) = [x1 x2];
u = 0.3;%��ͬϵ��
e1 = 0.5;%community 1 �ڲ���������ֵ
e3 = 0.5;%community 2 �ڲ���������ֵ
e2 = 0.2;%community֮���������ֵ
%�����ޱ������
%community 1
m = 23;%ÿ�μ����������
m0 = 50;    %��ʼ�Ľڵ����
A1 = zeros(N1,N1);%�ڽӾ���
for i=1:m0
    for j= (i+1):m0
        A1(i,j)= 1;   
        A1(j,i) =  A1(i,j);
    end
end   
DegreeInterval = zeros(1,N1);
for new = m0+1:N1
    %old vertice ��Խ�������ϵĸ���Խ��
    Degree = sum(A1(1:new-1,1:new-1));  %ÿ������Ķ�
    %�����һ���ȵķֲ����䣬ģ�����
    DegreeInterval(1) = Degree(1);
    for i=2:new-1
        DegreeInterval(i) = Degree(i)+DegreeInterval(i-1);
    end 
    %���� �½ڵ� �� m��old�ڵ�
    AllDegree = sum(sum(A1(1:new-1,1:new-1))); %����ͼ���ܶ�
    for i = 1:m 
        while 1
         %�Ը��ʴ�old�ڵ����ҵ����ʵĶ�������
         RandDegree  = fix(AllDegree*rand()+1); %Ҫ����������RandDegree�Ķ�������
         %�ҵ� ���� Ҫ���������������
         Ans = find(RandDegree <= DegreeInterval(1:new-1));
         old = Ans(1);
         if A1(new,old) == 0
            A1(new,old) = 1;
            A1(old,new) = 1;
            break;         %�ɹ�����
         end
        end
    end
end

%community 2
m = 23;%ÿ�μ����������
m0 = 50;    %��ʼ�Ľڵ����
A2 = zeros(N2,N2);%�ڽӾ���
%�Ƚ���С���������
%��bug
for i=1:m0
    for j= (i+1):m0
        A2(i,j)= 1;   
        A2(j,i) =  A2(i,j);
    end
end   
DegreeInterval = zeros(1,N2);
for new = m0+1:N2
    %old vertice ��Խ�������ϵĸ���Խ��
    Degree = sum(A2(1:new-1,1:new-1));  %ÿ������Ķ�
    %�����һ���ȵķֲ����䣬ģ�����
    DegreeInterval(1) = Degree(1);
    for i=2:new-1
        DegreeInterval(i) = Degree(i)+DegreeInterval(i-1);
    end 
    %���� �½ڵ� �� m��old�ڵ�
    AllDegree = sum(sum(A2(1:new-1,1:new-1))); %����ͼ���ܶ�
    for i = 1:m 
        while 1
         %�Ը��ʴ�old�ڵ����ҵ����ʵĶ�������
         RandDegree  = fix(AllDegree*rand()+1); %Ҫ����������RandDegree�Ķ�������
         %�ҵ� ���� Ҫ���������������
         Ans = find(RandDegree <= DegreeInterval(1:new-1));
         old = Ans(1);
         if A2(new,old) == 0
            A2(new,old) = 1;
            A2(old,new) = 1;
            break;         %�ɹ�����
         end
        end
    end
end

%��ʼ�����ڽӾ���
A1A2 = zeros(N2,N1);
A = [A1 A1A2';A1A2 A2];

%��������community
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
%ÿһ�ֳ�ȡһ��community1��Ľڵ㣬ʹ֮�����һ��neighbor���ã��ٳ�һ��community2��Ľڵ㣬ʹ֮�����һ��neighbor����
for s = 2:step
    x(s,:) = x(s-1,:);
    %community 1
    i1 = fix(N1*rand()+1);
    while 1
        j1 = fix(N*rand()+1);
        if A(i1,j1) == 1
            %���ж�j�����ĸ�community
            if j1 <= N1  %ͬ��community 1
                if abs(x(s-1,i1) - x(s-1,j1)) < e1
                    x(s,i1) = x(s-1,i1) + u*(x(s-1,j1) - x(s-1,i1));
                    x(s,j1) = x(s-1,j1) + u*(x(s-1,i1) - x(s-1,j1));
                end
            else %j����community 2
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
            %���ж�j�����ĸ�community
            if j2 > N1  %ͬ��community 2
                if abs(x(s-1,i2) - x(s-1,j2)) < e3
                    x(s,i2) = x(s-1,i2) + u*(x(s-1,j2) - x(s-1,i2));
                    x(s,j2) = x(s-1,j2) + u*(x(s-1,i2) - x(s-1,j2));
                end
            else %j����community 1
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
% title('��_1=��_3=0.2,��_2=0.2,��=0.3');%��������ֵ����ͬϵ��
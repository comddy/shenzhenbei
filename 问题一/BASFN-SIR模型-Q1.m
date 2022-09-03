%��Ҫ���õĲ���
N = 5000;   %�ܽڵ����
max_degree = 700;%Ԥ������degree��
st = 500;%��ʼ�����Ⱦ�Ľڵ���
%�����ޱ������
m = 4;%ÿ�μ����������
m0 = 60;    %��ʼ�Ľڵ����
A = zeros(N,N);%�ڽӾ���
%�Ƚ���С���������
%�������  1��ʾ�б�
for i=1:m0
    for j= (i+1):m0
        A(i,j)= round(rand());   %��1��0
        A(j,i) =  A(i,j);
    end
end   %��ʼ���
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
Degree = sum(A);
k_aver = sum(Degree)/N;
P = zeros(1,max_degree);%���ֶȵĸ���
% �ݻ�
Num_k = zeros(1,max_degree);%��Ϊk�Ľڵ���������ӵ�m�п�ʼ����
for i = m:max_degree
    Num_k(i) = size(find(i == Degree),2);
end
P = Num_k/N;
SIR = zeros(3,max_degree);%S�ڵ�һ�У�I�ڵڶ��У�R�ڵ����У������Num_k��Ӧ,SIR(1,6)��ʾ��Ϊ6��s�ڵ���
%��ʼ��״̬
SIR(1,:) = Num_k(1,:);
%�����ʼ�����Ⱦ500���ڵ�

for inital = 1:st
    while 1
        i = fix(max_degree*rand()+1);
        if SIR(1,i) ~= 0
            SIR(2,i) = SIR(2,i) + 1;
            SIR(1,i) = SIR(1,i) - 1;
            break;
        end
    end
end
step = 0;%��ʱ��,��0ʱ�̿�ʼ
density_S = zeros(1,50);%�ڵ��ܶ�,Ԥ��1000������
density_I = zeros(1,50);
density_R = zeros(1,50);
density_S(1) = sum(SIR(1,:))/N;
density_I(1) = sum(SIR(2,:))/N;
density_R(1) = sum(SIR(3,:))/N;
%��ʼ�ݻ�
while 1
    step = step + 1;
    last_SIR = SIR;%��¼��һʱ�̵�״̬
    for i = m:max_degree
        %��Ϊi��S�ڵ��ݻ�
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
        %��Ϊi��R�ڵ��ݻ�
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
        %��Ϊi��I�ڵ��ݻ�
        SIR(2,i) = Num_k(i) - SIR(1,i) - SIR(3,i);
    end
    density_S(step+1) = sum(SIR(1,:))/N;
    density_I(step+1) = sum(SIR(2,:))/N;
    density_R(step+1) = sum(SIR(3,:))/N;
    if sum(SIR(2,:)) < 1%��������
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
ylim([0 1]);
hold off
ggplotAxes2D([],'AxesTheme','gray','LegendStyle','ggplot','ColorOrder','Set2');
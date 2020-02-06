%����ֿ⣬���ƻ�ͼ�Ŀ��٣����ӳ����ڣ�������ɳ��׮����,�������ó��׮λ���Ա�����ײ��������ʾ��������
%����A_direction������趨ֵ�����õ����ߣ������ƻ������ڻ��������ײ����
%ȥ������������ƶ���������struct����������״̬�����㻭ͼ�����ٱ���
%��Ѱ·�������̷ŵ��ӳ�����ȥ����̬���ɻ������һ����ʱ����̬�������񣬼������˶�̬���֡�
%============================================================================
%�汾���ܣ�
%ʹ��A*���·���㷨���ȽϵϽ�˹�����㷨����Ч�ʸ��ߣ�
%���ﶯ̬���ɣ������˶�̬�滮��������δ�������������ǰ��
%�Ͻ�����汾�������˲ֿ�����������������������ڣ������������������
%�������Эͬ����������ײ�����ƣ���ʾ�ϼ�������
%�����˳��׮����

function final()
close all
%�û�������������������
num_of_tasks = 30;     %���ɸ������
robot_num = 10;          %����������
%��ͼԤ����
set(figure,'units','normalized','position',[0.1 0.1 0.8 0.8]);
%�������Ԥ���壬��functionռ�ø��ٵ��ڴ�
dynamical_draw_handle = @dynamical_draw;
%===============================
%��ʼ����
[Matrix,Matrix_no_obstacle,n,m] = advance_definition();  %��ͼ���ϰ�������
if(num_of_tasks < robot_num)
    robot_num = num_of_tasks;
end

global tasks;
tasks = zeros(num_of_tasks,5);      %��������ǰ����Ϊ���꣬������Ϊ�����ڣ�������Ϊ״̬��������Ϊ���ĸ�������ԤԼ�������������-1��
%״̬��0-δ���ɻ������ 1-�ѱ�������Ԥ����δȡ��, 2-��Ԥ���Ҹհ��ߣ� 3-�Ѿ��������������
global fflag;        %���ڲ鿴�õ��Ƿ����л���

fflag = zeros(m,n);

global robot;
%=======================��������Ϣ
robot = struct('Spoint',{},'free',{},'first',{},'Epoint',{},'P_sum',{},'carry',{},'end',{},'last_point',{},'prior',{},...
    'battery',{},'temp',{},'low',{},'temp_spoint',{});
for I=1:robot_num
    robot(I).Spoint = [1+I,2];
    
    robot(I).free = 1;
    robot(I).first = 1;
    robot(I).Epoint = zeros(1,2);
    robot(I).P_sum = [];
    robot(I).carry = 3; %3 �ǿ��л����ˣ�1�ǻ��2�Ƿ��ػ���
    robot(I).end = -1;
    robot(I).last_point = robot(I).Spoint;
    robot(I).prior = 0;
    robot(I).battery = 600;
    robot(I).temp = zeros(1,3);
    robot(I).low = 0; %��ʾ�͵�����״̬���Ƚϼ���
    robot(I).temp_spoint = zeros(1,2);
    
    %gen1_handle(Matrix,m,n,num_of_tasks);
end
clear I;
%��̬���ɻ���
t=timer;
t.StartDelay = 0;%��ʱ��ʼ
t.ExecutionMode = 'fixedRate';%����ѭ��ִ��
t.Period = 0.5;%ѭ�����
t.TasksToExecute = num_of_tasks;%ѭ������
t.TimerFcn = {@cargo_gen,Matrix}; %�����������
start(t);%��ʼִ��

T=timer;
T.StartDelay = 0;%��ʱ��ʼ
T.ExecutionMode = 'fixedRate';%����ѭ��ִ��
T.Period = 0.2;%ѭ�����
T.TasksToExecute = 10000;%ѭ������
T.TimerFcn = {@find_free_robot,num_of_tasks,m,n,Matrix,Matrix_no_obstacle,robot_num}; %�����������
start(T);%��ʼִ��

%��ʽ��ʼ
while(1)
    empty_index = -1;    %Ĭ�ϻ����˶���û����
    while(1)
        dynamical_draw_handle(robot_num,num_of_tasks);
        for I=1:robot_num
            [c,~] = size(robot(I).P_sum);
            if(c==0 && robot(I).free == 0 && robot(I).temp(1)~= 0)
                empty_index = I;   %���ܵĻ�����������
                break;
            elseif(c==1)
                robot(I).last_point = robot(I).P_sum;
            end
        end
        if (empty_index > 0)
            break;       %�л����������ˣ��������������ѭ��������һֱ������������·��
        end
    end
    robot(empty_index).free = 1;    %�ղŵĻ����������п�
    
    if(min(tasks(:,4))~=0)
        %robot(empty_index).P_sum=[robot(empty_index).temp(1),robot(empty_index).temp(2)];
        robot(empty_index).end = 1;
        robot(empty_index).temp = [0,0,0];
    end
    
    if(min(tasks(:,4))==3)
        break;
    end
end

end
%===========================�Ӻ�������============================
function find_free_robot(~,~,num_of_tasks,m,n,Matrix,Matrix_no_obstacle,robot_num)
global robot tasks;
distri_route_handle = @distri_route;
task2robot_handle = @task2robot;
for i=1:num_of_tasks
    if(tasks(i,1)==0)
        break;
    elseif(tasks(i,4)==0 && tasks(i,1)~=0)
        for I=1:robot_num
            if(robot(I).free == 1)  %free=1��ʾ�������пգ����������д�ִ�еĻ���
                task2robot_handle(I,i); %��������
            end
            
            if(robot(I).free == 2 && robot(I).temp(1)~=0)
                distri_route_handle(m,n,Matrix,Matrix_no_obstacle,I);
                break;
            end
        end
    end
end
end

function distri_route(m,n,Matrix,Matrix_no_obstacle,I)
findroute_handle = @findroute;
global robot;
[P] = findroute_handle(robot(I).Spoint, robot(I).Epoint,m,n,Matrix_no_obstacle); %�ӵ�ǰλ�õ������
robot(I).Spoint = [robot(I).temp(1),robot(I).temp(2)];        %���˻��ܵ㣬�յ��������
robot(I).Epoint = [6 * robot(I).temp(3),64];
P_0=P;                       %�ղŵ�·������P���õ�P_0��ȥ

[P] = findroute_handle(robot(I).Spoint, robot(I).Epoint, m,n,Matrix);  %�õ�����֮���Ѱ·���ô��ϰ��ľ���
P_0=[6 * robot(I).temp(3),64;
    6 * robot(I).temp(3),64;
    6 * robot(I).temp(3),64;
    P;P_0];     %������·��������������,�ҳ�������Ҫͣ��

robot(I).Spoint = [6 * robot(I).temp(3),64];      %Ҫ�ѻ��ܷŻ�ȥ������ǳ�����
robot(I).Epoint = [robot(I).temp(1),robot(I).temp(2)];    %�յ��ǸղŻ����

[P] = findroute_handle(robot(I).Spoint, robot(I).Epoint, m,n,Matrix);   %Ѱ·������Ǹղŷ�����ܵĵط�
P=[P;P_0];             %������·�������������������ڻ�

%�жϵ���������һ�λ���ٵ����׮����������30��С��ʣ�����������Ϊ��������
[length,~]=size(P);
if((length+m+n+30) >= robot(I).battery)  %��������
    robot(I).low = 1;
    robot(I).Spoint = robot(I).temp_spoint;
    
    if(robot(I).temp(1) < 15)
        robot(I).Epoint = [9,2];
    else
        robot(I).Epoint = [21,2];
    end            %ѡ����׮
    
    [P] = findroute_handle(robot(I).Spoint, robot(I).Epoint,m,n,Matrix_no_obstacle); %�ӵ�ǰλ�õ����׮
    P_0=[robot(I).Epoint(1),robot(I).Epoint(2);
        robot(I).Epoint(1),robot(I).Epoint(2);
        robot(I).Epoint(1),robot(I).Epoint(2);
        P];
    
    robot(I).Spoint = robot(I).Epoint;
    robot(I).Epoint = [robot(I).temp(1),robot(I).temp(2)];   %�յ㻹���Ǹ������
    [P] = findroute_handle(robot(I).Spoint, robot(I).Epoint,m,n,Matrix_no_obstacle); %����磬��Ȼ��no_obstacle
    P_0=[P;P_0];
    
    robot(I).Spoint = [robot(I).temp(1),robot(I).temp(2)];
    robot(I).Epoint = [6*robot(I).temp(3),64];
    [P] = findroute_handle(robot(I).Spoint, robot(I).Epoint, m,n,Matrix);  %�õ�����֮���Ѱ·���ô��ϰ��ľ���
    P_0=[6 * robot(I).temp(3),64;
        6 * robot(I).temp(3),64;
        6 * robot(I).temp(3),64;
        P;P_0];
    
    robot(I).Spoint = [6 * robot(I).temp(3),64];      %Ҫ�ѻ��ܷŻ�ȥ������ǳ�����
    robot(I).Epoint = [robot(I).temp(1),robot(I).temp(2)];    %�յ��ǸղŻ����
    [P] = findroute_handle(robot(I).Spoint, robot(I).Epoint, m,n,Matrix);   %Ѱ·������Ǹղŷ�����ܵĵط�
    P=[P;P_0];             %������·�������������������ڻ�
end
clear length
%ȷ��·��
robot(I).P_sum=[robot(I).P_sum;flipud(P)];  %���þ��󣬲��ܻ�·��
robot(I).free=0;  %free=0��ʾ����·���滮���ˣ�������
end

function [Matrix,Matrix_no_obstacle,n,m] = advance_definition()
A=zeros(29,66);
A=uint8(A);
[m,n] = size(A);

for i=3:m-2
    for j=3:n-5
        if((rem(i-3,3)==1 || rem(i-3,3)==2) && (rem(j-3,10)>=1 && rem(j-3,10)<=8))
            A(i,j) = 1;
        else
            A(i,j) = 0;
        end
    end
end
A(1,:) = 2;
A(m,:) = 2;
A(:,1) = 2;
A(:,n) = 2;  %ǽ�ڵ����趨

global A_direction;
A_direction=[
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
0	4	8	8	8	8	8	8	8	8	8	8	1	8	8	8	8	8	8	8	8	8	1	8	8	8	8	8	8	8	8	8	1	8	8	8	8	8	8	8	8	8	1	8	8	8	8	8	8	8	8	8	1	8	8	8	8	8	8	8	8	1	1	1	1	0	;
0	5	5	5	5	5	5	5	5	5	5	5	6	5	5	5	5	5	5	5	5	5	6	5	5	5	5	5	5	5	5	5	6	5	5	5	5	5	5	5	5	5	6	5	5	5	5	5	5	5	5	5	6	5	5	5	5	5	5	5	5	5	4	0	3	0	;
0	5	5	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	8	0	3	0	;
0	5	5	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	8	0	3	0	;
0	5	5	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	5	2	3	0	;
0	5	5	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	8	0	3	0	;
0	5	5	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	8	0	3	0	;
0	5	5	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	5	2	3	0	;
0	5	5	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	8	0	3	0	;
0	5	5	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	8	0	3	0	;
0	5	5	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	5	0	3	0	;
0	5	5	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	8	0	3	0	;
0	5	5	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	8	0	3	0	;
0	2	9	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	9	9	2	12	0	;
0	6	6	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	11	7	0	4	0	;
0	6	6	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	11	7	0	4	0	;
0	6	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	6	6	2	4	0	;
0	6	6	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	11	7	0	4	0	;
0	6	6	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	11	7	0	4	0	;
0	6	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	6	6	2	4	0	;
0	6	6	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	11	7	0	4	0	;
0	6	6	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	11	7	0	4	0	;
0	6	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	5	6	9	9	9	9	9	9	9	9	6	6	2	4	0	;
0	6	6	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	10	11	9	9	9	9	9	9	9	9	11	7	0	4	0	;
0	6	6	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	10	11	13	13	13	13	13	13	13	13	11	7	0	4	0	;
0	6	6	6	6	6	6	6	6	6	6	5	6	6	6	6	6	6	6	6	6	5	6	6	6	6	6	6	6	6	6	5	6	6	6	6	6	6	6	6	6	5	6	6	6	6	6	6	6	6	6	5	6	6	6	6	6	6	6	6	6	6	3	0	4	0	;
0	3	7	7	7	7	7	7	7	7	7	1	7	7	7	7	7	7	7	7	7	1	7	7	7	7	7	7	7	7	7	1	7	7	7	7	7	7	7	7	7	1	7	7	7	7	7	7	7	7	7	1	7	7	7	7	7	7	7	7	7	1	1	1	1	0	;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	
];
A_direction = uint8(A_direction);


global B;
B = zeros(m,n,3);
B=uint8(B);
for i=1:m                %��ɫ�ǿ����ߵ�·����ɫ���ϰ���
    for j=1:n
        if(A(i,j)==0)
            B(i,j,:) = 255;    %255->white
        elseif(A(i,j)==2)
            B(i,j,:) = [96,96,96];
        else
            B(i,j,:) = 0;
        end
    end
end

Matrix_no_obstacle = inf;
Matrix_no_obstacle = Matrix_no_obstacle(ones(m,n));
Matrix_no_obstacle(1,:) = -inf;
Matrix_no_obstacle(m,:) = -inf;
Matrix_no_obstacle(:,1) = -inf;
Matrix_no_obstacle(:,n) = -inf;

Matrix = zeros(m,n);
%%���ͼ������ϰ�
for i = 1:m
    for j=1:n
        if(A(i,j)==1 || A(i,j)==2)
            Matrix(i,j)=-inf;
        else
            Matrix(i,j)=inf;
        end
    end
end
clear i j A
end

function cargo_gen(~,~,Matrix)
global B tasks fflag;
[num,~] = size(tasks);
while(1)
    reg(1)=unidrnd(23)+3;
    reg(2)=unidrnd(60)+3;
    if(Matrix(reg(1),reg(2))~=-inf || fflag(reg(1),reg(2))==1)  %Ҫ�������ڻ����ϣ����ܲ����ص�������
        continue;
    else
        break;
    end
end

for i =1:num
    if(tasks(i,1) == 0)
        break;
    end
end

fflag(reg(1),reg(2)) = 1;
%�趨������
if(reg(1) >=4 && reg(1) <=8)
    reg(3) = 1;
elseif(reg(1) >=10 && reg(1) <=14)
    reg(3) = 2;
elseif(reg(1) >=16 && reg(1) <=20)
    reg(3) = 3;
else
    reg(3) = 4;
end

if(i <= num)
    h = 1:3;
    tasks(i,h) = reg(h);
end

B(reg(1),reg(2),1) = 255;
B(reg(1),reg(2),2) = 0;
B(reg(1),reg(2),3) = 0;
clear reg h i
end

function [P]=findroute(Spoint,Epoint,m,n,Matrix)
%Ѱ·Ԥ����========================
Matrix(Spoint(1),Spoint(2)) = 0;
Matrix(Epoint(1),Epoint(2)) = inf;
G=Matrix;%����ֵG
F=Matrix;%F
openlist=Matrix;
closelist=Matrix;
parentx=Matrix;
parenty=Matrix;
openlist(Spoint(1),Spoint(2)) =0;
global A_direction;
%========================route finding=========================
while(1)
    num=inf;%����ֵ
    for p=1:m
        for q=1:n
            if(openlist(p,q)==0 && closelist(p,q)~=1)%����ڿ����б�û�ڹر��б���
                %Outpoint=[p,q];%��һ�� ��ʼ��
                if(F(p,q)>=0 && num>F(p,q))% �ڿ����б���ѡ��һ����С��Fֵ�Ľڵ㣻num������С��f�Ƚϣ�����С��
                    num=F(p,q);
                    Nextpoint=[p,q];
                end
            end
        end
    end
    clear p q;
    closelist(Nextpoint(1),Nextpoint(2))=1;%��ʼ�����ر��б�
    kkk=[1,2;
        2,1;
        2,3;
        3,2];
    lanenoright=[1,2;
        2,1;
        2,1;
        3,2];
    lanenodown=[1,2;
        2,1;
        2,3;
        2,1];
    laneup=[1,2;
        1,2;
        1,2;
        1,2];
    lanenoup=[2,1;
        2,1;
        3,2;
        2,3];
    lanenoleft=[1,2;
        2,3;
        2,3;
        3,2];
    laneright=[2,3;
        2,3;
        2,3;
        2,3];
    laneleft=[2,1;
        2,1;
        2,1;
        2,1];
    
    laneleftup=[2,1;
        1,2;
        1,2;
        2,1];
    laneleftdown=[2,1;
        2,1;
        3,2;
        3,2];
    lanedown=[3,2;
        3,2;
        3,2;
        3,2];
    lanerightdown=[2,3;
        2,3;
        3,2;
        3,2];
    lanerightup=[2,3;
        2,3;
        1,2;
        1,2];
    laneupdown=[3,2;
        3,2;
        1,2;
        1,2];
    
    
    for p = 1:4
        A_i = Nextpoint(1);
        A_j = Nextpoint(2);
        
        if (A_direction(A_i,A_j) == 0)
           i=kkk(p,1);
           j=kkk(p,2);
        elseif (A_direction(A_i,A_j) == 1)
           i=laneleft(p,1);
           j=laneleft(p,2);

        elseif (A_direction(A_i,A_j) == 2)
           i=laneright(p,1);
           j=laneright(p,2);

        elseif (A_direction(A_i,A_j) == 3)
           i=laneup(p,1);
           j=laneup(p,2);

        elseif (A_direction(A_i,A_j) == 4)
           i=lanedown(p,1);
           j=lanedown(p,2);

        elseif (A_direction(A_i,A_j) == 5)
           i=lanerightdown(p,1);
           j=lanerightdown(p,2);

        elseif (A_direction(A_i,A_j) == 6)
           i=lanerightup(p,1);
           j=lanerightup(p,2);

        elseif (A_direction(A_i,A_j) == 7)
           i=laneleftup(p,1);
           j=laneleftup(p,2);

        elseif (A_direction(A_i,A_j) == 8)
           i=laneleftdown(p,1);
           j=laneleftdown(p,2);

         elseif (A_direction(A_i,A_j) == 9)
           i=lanenoleft(p,1);
           j=lanenoleft(p,2);

          elseif (A_direction(A_i,A_j) == 10)
           i=lanenoup(p,1);
           j=lanenoup(p,2);

           elseif (A_direction(A_i,A_j) == 11)
           i=lanenodown(p,1);
           j=lanenodown(p,2);

            elseif (A_direction(A_i,A_j) == 12)
           i=laneupdown(p,1);
           j=laneupdown(p,2);
            elseif (A_direction(A_i,A_j) == 13)
           i=lanenoright(p,1);
           j=lanenoright(p,2);
           
        end
        
        %end
        k = G(Nextpoint(1)-2+i,Nextpoint(2)-2+j);%��Χ8�����Gֵ �͵�ǰ���Gֵ
        if(closelist(Nextpoint(1)-2+i,Nextpoint(2)-2+j)==1)
            continue;%ǰ���Gֵ ����
        elseif (k == -inf)% �ϰ��� ���迼�ǣ������뵽 �ر��б������ڸ��迼��
            G(Nextpoint(1)-2+i,Nextpoint(2)-2+j) = G(Nextpoint(1)-2+i,Nextpoint(2)-2+j);
            closelist(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=1;
        elseif (k == inf)% ������������ֵ
            distance = abs(i-2)+abs(j-2);
            G(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=G(Nextpoint(1),Nextpoint(2))+distance;%���㵽 ��һ����G
            openlist(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=0;%�����ĵ�ĳ�ȥ���ɴ�����򣬼��뵽�����б���
            
            H=abs(Nextpoint(1)-2+i-Epoint(1))+abs(Nextpoint(2)-2+j-Epoint(2));
            
            F(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=G(Nextpoint(1)-2+i,Nextpoint(2)-2+j)+H;%���㵽 ��һ����F ����ֵ
            parentx(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=Nextpoint(1);%��¼�õ�ĸ��ڵ��x����
            parenty(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=Nextpoint(2);%��¼�õ�ĸ��ڵ��y����
        else
            distance = abs(i-2)+abs(j-2);
            if(k>(distance+G(Nextpoint(1),Nextpoint(2))))
                k=distance+G(Nextpoint(1),Nextpoint(2));%������º��gֵ��ԭ�ȵ�С����������˵����һ���߶���
                
                H =abs(Nextpoint(1)-2+i-Epoint(1))+abs(Nextpoint(2)-2+j-Epoint(2));
                
                F(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=k+H;%����Fֵ�����Ѹ��ڵ㻻�ɵ�ǰ�Ľڵ�
                parentx(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=Nextpoint(1);
                parenty(Nextpoint(1)-2+i,Nextpoint(2)-2+j)=Nextpoint(2);
            end
        end
        if(((Nextpoint(1)-2+i)==Epoint(1)&&(Nextpoint(2)-2+j)==Epoint(2))||num==inf)%�Ѱ��ս�ķŵ������б��ڡ������·�����
            parentx(Epoint(1),Epoint(2))=Nextpoint(1);
            parenty(Epoint(1),Epoint(2))=Nextpoint(2);
            break;
        end
    end
    if(((Nextpoint(1)-2+i)==Epoint(1)&&(Nextpoint(2)-2+j)==Epoint(2))||num==inf)
        parentx(Epoint(1),Epoint(2))=Nextpoint(1);
        parenty(Epoint(1),Epoint(2))=Nextpoint(2);
        break;
    end
end
%==============================ѭ���һ���·��=================================
P=[];
%P=uint8(P);
while(1)
    if(num==inf)%û·��
        break;
    end
    P=[P;Epoint];%��·����β�ڵ���뵽·��������
    Epoint=[parentx(Epoint(1),Epoint(2)),parenty(Epoint(1),Epoint(2))];
    if(parentx(Epoint(1),Epoint(2))==Spoint(1) & parenty(Epoint(1),Epoint(2))==Spoint(2))%������ݵ���ʼ�ڵ� ���������
        P=[P;Epoint];
        break;
    end
end
P=[P;Spoint];
end

function drawmap()
global B;
imagesc(B);
axis square;
set(gca,'XTick',0.5:size(B,2)+0.5,'YTick',0.5:size(B,1)+0.5,...
    'XTickLabel','','YTicklabel','','dataaspect',[1 1 1],...
    'XGrid','on','YGrid','on','GridColor','k','GridAlpha',1)
end

function dynamical_draw(robot_num,num_of_tasks)
clf;
global robot B tasks;
drawmap_handle = @drawmap;
drawmap_handle();
%========================�����˵�ǰλ��========================
cmap = flipud(colormap('jet'));
cmap(1,:) = ones(3,1);
cmap(end,:) = zeros(3,1);
colormap(flipud(cmap));
hold on;

for H=1:robot_num
    if(~isempty(robot(H).P_sum))
        %=============��ʾ��ʽ��������==============
        if(robot(H).carry==1)
            rectangle('Position',[robot(H).P_sum(1,2)-0.5,robot(H).P_sum(1,1)-0.5,1,1],'facecolor','r');
        elseif(robot(H).carry==2)
            for j=1:num_of_tasks   %�ҳ�������������ĸ�����
                if(tasks(j,5) == H)
                    break;
                end
            end
            
            if(robot(H).temp(1)==robot(H).P_sum(1,1) && robot(H).temp(2)==robot(H).P_sum(1,2))
                tasks(j,4) = 3;  %��������
                tasks(j,5) = -1; %���ĸ�������Ԥ����״̬Ҫ���
            end
            clear j;
            
            rectangle('Position',[robot(H).P_sum(1,2)-0.5,robot(H).P_sum(1,1)-0.5,1,1],'facecolor','b');
        elseif(robot(H).carry==3)
            for i=1:num_of_tasks   %�ҳ�������������ĸ�����
                if(tasks(i,5) == H)
                    break;
                end
            end
            
            if(robot(H).temp(1)==robot(H).P_sum(1,1) && robot(H).temp(2)==robot(H).P_sum(1,2))
                tasks(i,4) = 2;
            end
            clear i;
            
            if(robot(H).battery < 200)
                robot(H).low = 1;
            end
            %��ʾ����
            if(robot(H).low == 0)
                plot(robot(H).P_sum(1,2),robot(H).P_sum(1,1),'go','MarkerSize',5,'LineWidth',6); %�������㣬��ɫ
            elseif(robot(H).low == 1)
                plot(robot(H).P_sum(1,2),robot(H).P_sum(1,1),'yo','MarkerSize',5,'LineWidth',6); %�������㣬��ɫ
            end
        end
        hold on;
        
        if(robot(H).temp(1)==robot(H).P_sum(1,1) && robot(H).temp(2)==robot(H).P_sum(1,2)) %���֮ǰ��û����ܹ�ȥ�����˻�����ɫ
            if robot(H).carry == 3
                robot(H).carry = 1;
            elseif robot(H).carry == 2  %���֮ǰ�����ſջ��ܣ��ǵ����������ǰѿջ��ܷ���
                robot(H).carry = 3;
            end
        elseif(robot(H).P_sum(1,1)== 6 * robot(H).temp(3) && robot(H).P_sum(1,2)== 64)
            robot(H).carry = 2;
        end
        
        if((robot(H).P_sum(1,1) == 9 || robot(H).P_sum(1,1) == 21) && robot(H).P_sum(1,2) == 2 && robot(H).low == 1)
            robot(H).battery = 500;
            robot(H).low = 0;
        end
        
        %���ȼ�
        robot(H).prior = robot(H).free * 100 + (66-robot(H).P_sum(1,2)) + abs(14 - robot(H).P_sum(1,1));
    elseif (isempty(robot(H).P_sum) && (robot(H).first==1 || robot(H).last_point(2)~=2))
        plot(robot(H).last_point(1,2),robot(H).last_point(1,1),'go','MarkerSize',5,'LineWidth',6); %�������㣬��ɫ
    end
end
pause(0.03);

for P=1:num_of_tasks
    if tasks(P,1)==0
        continue;
    elseif tasks(P,1)~=0 && tasks(P,4) <= 1
        B(tasks(P,1),tasks(P,2),:) = [255,0,0];
    elseif tasks(P,1)~=0 && tasks(P,4) == 2
        B(tasks(P,1),tasks(P,2),:) = [255,255,255];
    elseif tasks(P,1)~=0 && tasks(P,4) == 3
        B(tasks(P,1),tasks(P,2),:) = [0,0,255];
    end
end

x=1:4;
B(6*x,64,:)=50;   %��������ɫ
B(21,2,:)=[255,255,0];
B(9,2,:)=[255,255,0];  %���׮
drawmap_handle();
clear x P;

for IND=1:robot_num
    if(~isempty(robot(IND).P_sum))
        %============================
        %��ײ���
        ind = robot(IND).P_sum(1,:);
        
        if(robot(IND).end == -1)
            robot(IND).P_sum(1,:) = [];  %û���꣬����ɾ��P���󣬷����ǽ����ˣ�Ҫͣ���ڵ�ͼ��
            robot(IND).battery = robot(IND).battery - 1;    %������һ
            if(robot(IND).carry == 2 || robot(IND).carry == 3)
                robot(IND).battery = robot(IND).battery - 1;
            end
        end
        
        %������ֵԽС�����ȼ�Խ��
        for L = 1:robot_num
            if(L~=IND)
                [p1,~]=size(robot(IND).P_sum);
                [l1,~]=size(robot(L).P_sum);
                if(p1>1 && l1>1)
                    if(robot(L).P_sum(1,1) == robot(IND).P_sum(1,1) && robot(L).P_sum(1,2) == robot(IND).P_sum(1,2) && robot(IND).prior >= robot(L).prior)
                        robot(IND).P_sum = [ind;robot(IND).P_sum];
                        break;
                    end
                end
            end
        end
        clear p1 l1 L ind
    end
end
end

function task2robot(I,j)
global tasks robot;
if(robot(I).first == 1) %��һ��ִ�����������ģ�����Ͳ�����
    robot(I).first = 0;
else
    robot(I).Spoint = [robot(I).temp(1),robot(I).temp(2)];
end
robot(I).temp_spoint = [robot(I).temp(1),robot(I).temp(2)]; %��ʱ����㣬��һ��������

robot(I).Epoint = [tasks(j,1),tasks(j,2)];  %�յ�Ϊ��һ��δ����������
robot(I).free = 2;                %free=2��ʾ�ѷ���������ִ����
robot(I).temp = [tasks(j,1),tasks(j,2),tasks(j,3)];      %��ǰ�����˵ĵ�ǰ����Ϊ�������ĵ�һ��δ�������
tasks(j,4) = 1;    %�ѱ�������Ԥ��
tasks(j,5) = I;    %���ĸ�������Ԥ��
end
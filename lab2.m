% Лабораторная 2. Нечёткая система Agg_lvl.
clear;
clc;
close all;

% Матрицы из лабораторной 1.
A1 = [1 1/2 1/3 1/4 1/5 1/6 1/7 1/8 1/9;
      2 1 1/2 1/3 1/4 1/5 1/6 1/7 1/8;
      3 2 1 1/2 1/3 1/4 1/5 1/6 1/7;
      4 3 2 1 1/2 1/3 1/4 1/5 1/6;
      5 4 3 2 1 1/2 1/3 1/4 1/5;
      6 5 3 3 2 1 1/2 1/3 1/4;
      7 5 4 4 3 2 1 1/2 1/3;
      8 7 5 5 3 3 2 1 1/2;
      9 8 7 6 5 4 3 2 1];

A2 = [1 2 3 4 5 6 7 8 9;
      1/2 1 2 2 3 4 5 5 7;
      1/3 1/2 1 2 3 3 4 6 6;
      1/4 1/2 1/2 1 2 3 4 4 5;
      1/5 1/3 1/3 1/2 1 2 3 4 5;
      1/6 1/4 1/3 1/4 1/2 1 2 2 3;
      1/7 1/5 1/4 1/4 1/3 1/2 1 2 3;
      1/8 1/5 1/6 1/4 1/4 1/2 1/2 1 2;
      1/9 1/7 1/6 1/6 1/5 1/3 1/3 1/2 1];

A3 = [1 1/3 1/4 1/6 1/7 1/6 1/4 1/3 1;
      3 1 1/2 1/5 1/6 1/5 1/2 1 3;
      4 2 1 1/3 1/4 1/3 1 2 4;
      6 5 3 1 1/3 1 3 5 6;
      7 6 4 3 1 3 4 6 7;
      6 5 3 1 1/3 1 3 5 6;
      4 2 1 1/3 1/4 1/3 1 2 4;
      3 1 1/2 1/5 1/6 1/5 1/2 1 3;
      1 1/3 1/4 1/6 1/7 1/6 1/4 1/3 1];

% Столбцы соответствуют термам: низкий, средний, высокий.
matrices = {A2, A3, A1};
muNodes = zeros(9, 3);
for term = 1:3
    [V, D] = eig(matrices{term});
    [~, idx] = max(real(diag(D)));
    w = real(V(:, idx));
    w = w / sum(w);
    muNodes(:, term) = w / max(w);
end

% Девять узлов первой работы перенесены на шкалу 0–10.
nodes = linspace(0, 10, 9);
gridX = linspace(0, 10, 401).';
muGrid = interp1(nodes, muNodes, gridX, 'linear');

names = {'Sudden_Agg', 'Irritability', 'React_Agg', 'AL'};
figure('Name', 'Agg_lvl', 'NumberTitle', 'off');
for variable = 1:4
    subplot(2, 2, variable);
    plot(gridX, muGrid, 'LineWidth', 1.5);
    grid on;
    title(names{variable}, 'Interpreter', 'none');
    xlabel('Score');
    ylabel('\mu');
    axis([0 10 0 1.05]);
    legend('Low', 'Medium', 'High', 'Location', 'best');
end

% Пример входа: [Sudden_Agg, Irritability, React_Agg].
inputScores = [8 6 7];
assert(isreal(inputScores) && isvector(inputScores) && ...
       numel(inputScores) == 3 && all(inputScores >= 0 & inputScores <= 10), ...
       'Enter three real scores between 0 and 10.');
inputMu = interp1(nodes, muNodes, inputScores(:), 'linear');

% Все 27 правил. Выходной терм — округлённое среднее номеров термов.
[t1, t2, t3] = ndgrid(1:3, 1:3, 1:3);
ruleInputs = [t1(:), t2(:), t3(:)];
ruleOutputs = round(mean(ruleInputs, 2));

% Вывод Мамдани: минимум для И и отсечения, максимум для объединения.
outputMu = zeros(size(gridX));
for rule = 1:size(ruleInputs, 1)
    terms = ruleInputs(rule, :);
    strength = min([inputMu(1, terms(1)), inputMu(2, terms(2)), ...
                    inputMu(3, terms(3))]);
    clipped = min(strength, muGrid(:, ruleOutputs(rule)));
    outputMu = max(outputMu, clipped);
end

% Дефаззификация методом центра тяжести.
AL = trapz(gridX, gridX .* outputMu) / trapz(gridX, outputMu);
fprintf('Sudden_Agg = %.2f, Irritability = %.2f, React_Agg = %.2f\n', inputScores);
fprintf('AL = %.4f\n', AL);

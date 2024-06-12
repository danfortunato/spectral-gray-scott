function plot_gs(pattern, init, isim)

pattern = lower(pattern);

switch pattern
    case 'gliders'
        F = 0.014;
        k = 0.054;
    case 'bubbles'
        F = 0.098;
        k = 0.057;
    case 'maze'
        F = 0.029;
        k = 0.057;
    case 'worms'
        F = 0.058;
        k = 0.065;
    case 'spirals'
        F = 0.018;
        k = 0.051;
    case 'spots'
        F = 0.03;
        k = 0.062;
    otherwise
        error('Unknown pattern.');
end

file = sprintf('snapshots/gs_%s_F=%.3d_k=%.3d_%s_%d.mat', pattern, 1000*F, 1000*k, init, isim);
load(file, 'uv');

shg
for ik = 1:2:size(uv{1},3)
    clf
    surf(real(uv{1}(:,:,ik)))
    shading interp
    view(2)
    axis tight equal
    colorbar
    drawnow
end

end

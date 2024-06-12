function gen_gs(pattern)

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

rng(0)
dom = [-1 1 -1 1];
delta_u = 0.00002;
delta_v = 0.00001;

nsim = 100;
n = 128;
dt = 1;
snap_dt = 10;
tend = 10000;
tspan = 0:snap_dt:tend;

pref = spinpref2();
pref.plot = 'off';
pref.scheme = 'etdrk4';
pref.dealias = 'on';

S = spinop2(dom, tspan);
S.lin    = @(u,v) [ delta_u*lap(u)   ; delta_v*lap(v)  ];
S.nonlin = @(u,v) [ -u.*v.^2+F*(1-u) ; u.*v.^2-(F+k)*v ];

%% Gaussians
init = 'gaussians';
ngauss = [10 100];
amp = [1 3];
width = [150 300];
normalize = @(u) (u-min2(u)) / max2(u-min2(u));

for isim = 1:nsim
    fprintf('Running Gaussians: %d / %d\n', isim, nsim);

    uinit = random_gaussians(ngauss, amp, width, dom);
    uinit = @(x,y) 1-uinit(x,y);
    vinit = random_gaussians(ngauss, amp, width, dom);
    uinit = chebfun2(uinit, dom, 'trig');
    vinit = chebfun2(vinit, dom, 'trig');
    uinit = normalize(uinit);
    vinit = normalize(vinit);
    S.init = chebfun2v(uinit, vinit, dom);

    try
        uv = spin2(S, n, dt, pref);
        file = sprintf('snapshots/gs_%s_F=%.3d_k=%.3d_%s_%d.mat', pattern, 1000*F, 1000*k, init, isim);
        save(file, 'uv');
    catch
        warning('Solution blew up.');
    end

end

%% Fourier
init = 'fourier';
nfourier = 32;

for isim = 1:nsim
    fprintf('Running Fourier: %d / %d\n', isim, nsim);

    [uinit, vinit] = init_fourier(F, k, nfourier, dom);
    S.init = chebfun2v(uinit, vinit, dom);

    try
        uv = spin2(S, n, dt, pref);
        file = sprintf('snapshots/gs_%s_F=%.3d_k=%.3d_%s_%d.mat', pattern, 1000*F, 1000*k, init, isim);
        save(file, 'uv');
    catch
        warning('Solution blew up.');
    end
end

end

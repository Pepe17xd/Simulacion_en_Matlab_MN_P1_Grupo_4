function archivos = graficar_experimentos(ruta_simulacion)
%GRAFICAR_EXPERIMENTOS Exporta figuras A-D solo desde los CSV existentes.
    if nargin<1 || isempty(ruta_simulacion)
        ruta_simulacion=fileparts(fileparts(mfilename('fullpath')));
    end
    ruta_resultados=fullfile(ruta_simulacion,'resultados');
    ruta_figuras=fullfile(ruta_resultados,'figuras_matlab');
    if ~isfolder(ruta_figuras), mkdir(ruta_figuras); end
    set(groot,'defaultFigureColor','white','defaultAxesColor','white', ...
        'defaultAxesXColor','black','defaultAxesYColor','black', ...
        'defaultAxesGridColor',[0.78 0.78 0.78], ...
        'defaultTextColor','black');
    base=fullfile(ruta_resultados,'escenario_base');
    ref=fullfile(ruta_resultados,'refinamiento');
    sen=fullfile(ruta_resultados,'sensibilidad');
    stress=fullfile(ruta_resultados,'estres_numerico');
    hist=readtable(fullfile(base,'convergence_history.csv'),'VariableNamingRule','preserve');
    sol=readtable(fullfile(base,'solver_summary.csv'),'VariableNamingRule','preserve');
    refinement=readtable(fullfile(ref,'refinement.csv'),'VariableNamingRule','preserve');
    timing=readtable(fullfile(ref,'timing_repeats.csv'),'VariableNamingRule','preserve');
    sensitivity=readtable(fullfile(sen,'sensitivity.csv'),'VariableNamingRule','preserve');
    stressData=readtable(fullfile(stress,'stress.csv'),'VariableNamingRule','preserve');

    deg=char(176); a=char(225); iacute=char(237);

    % A1: campo espacial en una columna, con contorno, fuentes y máximo.
    f=figure('Name','Experimento A - campo','Color','w');
    tiledlayout(f,1,1,'TileSpacing','compact','Padding','compact');
    field=readtable(fullfile(base,'baseline_field.csv'),'VariableNamingRule','preserve');
    x=unique(field.x_m); y=unique(field.y_m);
    T=reshape(field.T_C,numel(y),numel(x));
    nexttile; imagesc(x,y,T); axis image xy; cb=colorbar; hold on
    cb.Label.String=['Temperatura (' deg 'C)']; cb.Label.FontSize=8; cb.Label.Color='k';
    cfg=planteamiento_modelo();
    rectangle('Position',[cfg.cpu.x cfg.cpu.y cfg.cpu.width cfg.cpu.height], ...
        'EdgeColor','w','LineWidth',1.2);
    rectangle('Position',[cfg.gpu.x cfg.gpu.y cfg.gpu.width cfg.gpu.height], ...
        'EdgeColor','w','LineWidth',1.2);
    rectangle('Position',[0 0 cfg.Lx cfg.Ly], ...
        'EdgeColor','w','LineStyle','--','LineWidth',1.0);
    text(cfg.cpu.x,cfg.cpu.y,' CPU','Color','w','FontWeight','bold','FontSize',8);
    text(cfg.gpu.x,cfg.gpu.y,' GPU','Color','w','FontWeight','bold','FontSize',8);
    [tm,im]=max(T(:)); [iy,ix]=ind2sub(size(T),im);
    plot(x(ix),y(iy),'wp','MarkerFaceColor','k','MarkerSize',8);
    text(x(ix)-0.008,y(iy)+0.018,sprintf('Tmax %.2f %sC',tm,deg), ...
        'Color','k','BackgroundColor','w','Margin',1, ...
        'HorizontalAlignment','right','FontWeight','bold','FontSize',8);
    xlabel('x (m)'); ylabel('y (m)');
    exportar(f,fullfile(ruta_figuras,'experimento_A_campo.pdf'),3.35,2.45);

    % A2: panel independiente por método; la escala vertical es común.
    f=figure('Name','Experimento A - convergencia','Color','w');
    tiledlayout(f,2,1,'TileSpacing','compact','Padding','compact');
    solverNames={"Gauss-Seidel","Conjugate Gradient"};
    panelNames={'Gauss-Seidel','Gradiente conjugado'};
    legendNames={'GS','CG'};
    for k=1:2
        nexttile; hold on
        sel=string(hist.solver)==solverNames{k};
        niter=sol.iter(strcmp(sol.solver,solverNames{k}));
        semilogy(hist.iter(sel),hist.rel_residual(sel),'LineWidth',1.35, ...
            'DisplayName',sprintf('%s (%d iter.)',legendNames{k},niter));
        yline(sol.tolerance(1),':k','Tolerancia 10^{-8}', ...
            'LabelHorizontalAlignment','left','FontSize',7.5);
        set(gca,'YScale','log','YMinorGrid','off'); ylim([sol.tolerance(1)/100 1]);
        grid on; xlabel('Iteraciones'); ylabel('Residuo relativo');
        title(panelNames{k},'FontSize',8,'FontWeight','normal');
    end
    exportar(f,fullfile(ruta_figuras,'experimento_A_convergencia.pdf'),3.35,3.25);

    % B: paneles apilados a ancho de columna.
    f=figure('Name','Experimento B - refinamiento','Color','w');
    tiledlayout(f,2,1,'TileSpacing','compact','Padding','compact');
    grids=unique(refinement(:,{'nx','ny','unknowns'}),'rows','stable');
    nexttile; hold on
    yy=[];
    for k=1:height(grids)-1
        row=find(refinement.nx==grids.nx(k) & refinement.ny==grids.ny(k),1);
        yy(end+1)=refinement.spatial_max_abs_difference_C(row); %#ok<AGROW>
    end
    plot(1:numel(yy),yy,'o-','LineWidth',1.35);
    set(gca,'XTick',1:3,'XTickLabel',{'(1)','(2)','(3)'}, ...
        'XTickLabelRotation',0,'TickLabelInterpreter','none');
    grid on; xlabel('Par de mallas'); ylabel(['Diferencia nodal m' a 'xima (' deg 'C)']);
    title('Diferencia entre mallas','FontSize',8,'FontWeight','normal');
    nexttile; hold on
    labels=unique(string(timing.solver),'stable');
    for k=1:numel(labels)
        sel=string(timing.solver)==labels(k);
        n=unique(timing.unknowns(sel)); med=zeros(size(n));
        for j=1:numel(n), med(j)=median(timing.time_s(sel & timing.unknowns==n(j))); end
        if labels(k)=="Gauss-Seidel", curveName='GS'; else, curveName='CG'; end
        loglog(n,med,'o-','LineWidth',1.35,'DisplayName',curveName);
    end
    set(gca,'XScale','log','YScale','log','XTick',[345 1457 5985 24257], ...
        'XTickLabel',{'345','1457','5985','24257'},'XTickLabelRotation',0, ...
        'XMinorGrid','off','YMinorGrid','off');
    grid on; xlabel(['Inc' char(243) 'gnitas interiores, N']);
    ylabel('Tiempo mediano (s; eje log)');
    title('Costo de GS y CG','FontSize',8,'FontWeight','normal');
    legend('Location','northwest');
    exportar(f,fullfile(ruta_figuras,'experimento_B_refinamiento.pdf'),3.35,3.35);

% C: series de sensibilidad apiladas; cada panel usa su escala vertical propia.
    f=figure('Name','Experimento C - sensibilidad','Color','w');
    tiledlayout(f,2,1,'TileSpacing','compact','Padding','compact');
    src=unique(string(sensitivity.varied_source),'stable');
    for k=1:numel(src)
        nexttile; hold on; sel=string(sensitivity.varied_source)==src(k);
        if src(k)=="cpu"
            p=sensitivity.cpu_power_W(sel); fixed=cfg.gpu.power;
            ttl=sprintf('CPU variable; GPU fija: %.0f W',fixed);
        else
            p=sensitivity.gpu_power_W(sel); fixed=cfg.cpu.power;
            ttl=sprintf('GPU variable; CPU fija: %.0f W',fixed);
        end
        [p,ord]=sort(p); vals=sensitivity.Tmax_C(sel); vals=vals(ord);
        plot(p,vals,'o-','LineWidth',1.35); grid on
        xlabel(['Potencia ' upper(char(src(k))) ' (W)']);
        ylabel(['Temperatura m' a 'xima (' deg 'C)']);
        title(ttl,'FontSize',8,'FontWeight','normal');
    end
    exportar(f,fullfile(ruta_figuras,'experimento_C_sensibilidad.pdf'),3.35,3.35);

    % D: iteraciones observadas para las tolerancias del control.
    f=figure('Name','Experimento D - verificacion','Color','w');
    tiledlayout(f,1,1,'TileSpacing','compact','Padding','compact');
    nexttile; hold on; tols=unique(stressData.tol);
    labels=unique(string(stressData.solver),'stable');
    for k=1:numel(labels)
        sel=string(stressData.solver)==labels(k) & stressData.case=="baseline_tolerance";
        [tv,ord]=sort(stressData.tol(sel)); it=stressData.iterations(sel); it=it(ord);
        if labels(k)=="Gauss-Seidel", curveName='Gauss-Seidel'; else, curveName='Gradiente conjugado'; end
        semilogy(1:numel(tv),it,'o-','LineWidth',1.3,'DisplayName',curveName);
    end
    sortedTols=sort(tols);
    set(gca,'XScale','linear','YScale','log','XTick',1:numel(sortedTols), ...
        'XTickLabel',compose('10^{%d}',round(log10(sortedTols))), ...
        'XTickLabelRotation',0); grid on
    xlabel(['Tolerancia del residuo relativo (escala logar' char(237) 'tmica)']);
    ylabel('Iteraciones'); legend('Location','northoutside','Orientation','horizontal','NumColumns',2);
    exportar(f,fullfile(ruta_figuras,'experimento_D_verificacion.pdf'),3.35,2.35);

    archivos={fullfile(ruta_figuras,'experimento_A_campo.pdf'), ...
        fullfile(ruta_figuras,'experimento_A_convergencia.pdf'), ...
        fullfile(ruta_figuras,'experimento_B_refinamiento.pdf'), ...
        fullfile(ruta_figuras,'experimento_C_sensibilidad.pdf'), ...
        fullfile(ruta_figuras,'experimento_D_verificacion.pdf')};
end

function exportar(figura,archivo,ancho,alto)
    set(figura,'Units','inches','Position',[0.5 0.5 ancho alto]);
    set(findall(figura,'Type','axes'),'FontSize',8,'LineWidth',0.8, ...
        'TitleFontSizeMultiplier',1.0,'LabelFontSizeMultiplier',1.0);
    set(findall(figura,'Type','axes'),'Color','white','XColor','black', ...
        'YColor','black','GridColor',[0.78 0.78 0.78]);
    set(findall(figura,'Type','text'),'Color','black','FontSize',8);
    set(findall(figura,'Type','legend'),'FontSize',7.5);
    set(figura,'Color','white');
    exportgraphics(figura,archivo,'ContentType','vector');
    close(figura);
end

function HM4_GraphSpectra(file_numb)
    currentFile = mfilename( 'fullpath' );
    [pathstr,~,~] = fileparts( currentFile );
    addpath( fullfile( pathstr, '\data\' ) );
    file = ['\data\example' num2str(file_numb) '.dat'];
    disp(file)
    E = readmatrix(file);
    col1 = E(:,1);
    col2 = E(:,2);
    max_ids = max(max(col1,col2));
    As= sparse(col1, col2, 1, max_ids, max_ids); 
    A = full(As);
    A = min(A,1); %remove value over 1
    %D = diag(sum(A));
    c= sum(A);
    disp(min(c)+">0, so D is inversible");
    inv_c = 1./c;
    D_12 = diag(sqrt(inv_c));
    L = D_12*A*D_12;
    [v,DiagL] = eig(L);
    eigen_values = diag(DiagL);
    %already sort sorted_eigenvalues = sort(eigen_values,1,"descend");
    delta = eigen_values(2:max_ids,1)-eigen_values(1:max_ids-1,1);
    [~, n_clusters] = max(delta);
    n_clusters = max_ids -n_clusters;
    disp("The number of clusters is "+n_clusters+".");
    X = v(1:max_ids,max_ids-n_clusters+1:max_ids);
    row_X = sqrt(sum(X.*X,2));
    Y=X;
    for i=1:n_clusters
        Y(1:max_ids,i)=Y(1:max_ids,i)./row_X(1:max_ids,1);
    end
    clust = kmeans(Y,n_clusters);
    %plot parameters
    G = graph(A,'omitselfloops');
    t=2*pi()*(0.5:1:n_clusters-0.5)/n_clusters;
    n=2*pi()*(1:1:max_ids)/max_ids;
    R = 5;
    r=1;
    [~, order] = sort(clust);
    Index = zeros(size(clust));
    for i=1:max_ids
        Index(i) = find(order==i);
    end
    t_plot = tiledlayout(1,3);
    nexttile
    scatter(col1,col2, 6,"filled");
    title('Original Sparsity Pattern');
    nexttile
    plot(G,'XData',R*arrayfun(@(var) cos(var),t(clust))+r*arrayfun(@(var) cos(var),n),'YData',R*arrayfun(@(var) sin(var),t(clust))+r*arrayfun(@(var) sin(var),n),'Marker','.','NodeLabel',{});
    title('Graph after computing the communities');
    nexttile
    scatter(Index(col1),Index(col2), 6,"filled");
    title('Reordered Sparsity Pattern');
    title(t_plot,['Example ' int2str(file_numb)]);
    figure;
    t_plot_2 = tiledlayout(1,n_clusters);
    for i=1:n_clusters
        nexttile;
        plot(Y(order(:),i));
        title(['x' int2str(i)]);
        ylim([-1.2,1.2]);
    end
    title(t_plot_2,['Example ' int2str(file_numb) ': Component value']);
end



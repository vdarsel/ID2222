function p_1 = HM4_GraphSpectra(file_numb)
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
    D = diag(sum(A));
    c= sum(A);
    disp(min(c)+">0, so D is inversible");
    inv_c = 1./c;
    D_12 = diag(sqrt(inv_c));
    L = D_12*A*D_12;
    [v,DiagL] = eig(L);
    eigen_values = diag(DiagL);
    %already sort sorted_eigenvalues = sort(eigen_values,1,"descend");
    delta = eigen_values(2:max_ids,1)-eigen_values(1:max_ids-1,1);
    [val, n_clusters] = max(delta);
    n_clusters = max_ids -n_clusters;
    disp("The number of clusters is "+n_clusters+".");
    X = v(1:max_ids,max_ids-n_clusters+1:max_ids);
    row_X = sqrt(sum(X.*X,2));
    Y=X;
    for i=1:n_clusters
        Y(1:max_ids,i)=Y(1:max_ids,i)./row_X(1:max_ids,1);
    end
    idx = kmeans(Y,n_clusters);
    G = graph(A,'omitselfloops');
    t=2*pi()*(1:1:n_clusters)/n_clusters;
    n=2*pi()*(1:1:max_ids)/max_ids;
    R = 5;
    r=1;
    cos_t = arrayfun(@(var) cos(var),t);
    [~, order] = sort(idx);
    Index = zeros(size(idx));
    for i=1:max_ids
        Index(i) = find(order==i);
    end
    tiledlayout(1,3)
    nexttile
    p_3 = scatter(col1,col2, 6,"filled");
    nexttile
    p_1 = plot(G,'XData',R*arrayfun(@(var) cos(var),t(idx))+r*arrayfun(@(var) cos(var),n),'YData',R*arrayfun(@(var) sin(var),t(idx))+r*arrayfun(@(var) sin(var),n),'Marker','.');
    nexttile
    p_2 = scatter(Index(col1),Index(col2), 6,"filled");
end
